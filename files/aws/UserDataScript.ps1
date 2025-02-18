[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]  [string]$Region,
    [Parameter(Mandatory = $true)]  [string]$LogGroup,
    [Parameter(Mandatory = $true)]  [string]$UserDataLogStream,
    [Parameter(Mandatory = $true)]  [string]$PSMConfigurationLogStream,
    [Parameter(Mandatory = $true)]  [string]$PSMRegistrationLogStream,
    [Parameter(Mandatory = $true)]  [string]$VaultAdminUser,
    [Parameter(Mandatory = $false)] [string]$SSMAdminPassParameterID,
    [Parameter(Mandatory = $false)] [string]$VaultPrivateIP,
    [Parameter(Mandatory = $true)]  [string]$ComponentHostname,
    [Parameter(Mandatory = $false)] [string]$StackName
)

# Configure logging
. "$PSScriptRoot\Common.ps1"
$LogFile = "C:\CyberArk\Deployment\Logs\UserData.log"

# Ensure userdata is running first time
if (Test-Path -Path $LogFile) {
    Write-Output "Userdata already ran, exiting."
    exit 0
}

# Ensure AmazonSSMAgent is enabled and running
try {
    Set-Service AmazonSSMAgent -StartupType Automatic
    Start-Service AmazonSSMAgent
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "AmazonSSMAgent state verified successfully"
} catch {
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Failed to start AmazonSSMAgent: $_"
    exit 1
}

# Execute configCW commands
try {
    & $PSScriptRoot\CloudWatch.ps1 -LogGroup $LogGroup `
        -UserDataLogStream $UserDataLogStream `
        -PSMConfigurationLogStream $PSMConfigurationLogStream `
        -PSMRegistrationLogStream $PSMRegistrationLogStream `
        -Region $Region
    ChildScriptErrorHandler -ScriptName "CloudWatch"
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "CloudWatch configuration completed successfully"
} catch {
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Failed to configure CloudWatch: $_"
    exit 1
}

# Execute PSMConfiguration commands
try {
    & $PSScriptRoot\PSMConfiguration.ps1 -VaultIpAddress $VaultPrivateIP `
                                        -VaultAdminUser $VaultAdminUser `
                                        -VaultPort 1858
    ChildScriptErrorHandler -ScriptName "PSMConfiguration"
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "PSMConfiguration configuration completed successfully"
} catch {
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Failed to execute PSMConfiguration configuration: $_"
    exit 1
}

# Execute PSMRegistration commands
try {
    & $PSScriptRoot\PSMRegistration.ps1 -VaultAdminUser $VaultAdminUser -SSMAdminPassParameterID $SSMAdminPassParameterID
    ChildScriptErrorHandler -ScriptName "PSMRegistration"
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "PSMRegistration configuration completed successfully"
} catch {
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Failed to execute PSMRegistration configuration: $_"
    exit 1
}

# Execute PSMHardening commands
try {
    & $PSScriptRoot\PSMHardening.ps1
    ChildScriptErrorHandler -ScriptName "PSMHardening"
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "PSMHardening configuration completed successfully"
} catch {
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Failed to execute PSMHardening configuration: $_"
    exit 1
}

# Execute LocalServiceAutoStart commands
try {
    & sc.exe config "CyberArk Privileged Session Manager" start=auto
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "LocalServiceAutoStart configuration completed successfully"
} catch {
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Failed to execute LocalServiceAutoStart configuration: $_"
    exit 1
}

# Execute configHostname commands
try {
    Rename-Computer -NewName $ComponentHostname -Force
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Hostname configuration completed successfully"
} catch {
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Failed to configure hostname: $_"
    exit 1
}

# Configure a completion signal scheduled task
$ResourceName = "PSMMachine"
$scriptBlock = @"
    # Configure logging
    . "$PSScriptRoot\Common.ps1"
    # Signal completion to CloudFormation
    if ("$StackName" -ne "") {
        `$cfn_signal_output = cfn-signal.exe --stack $StackName --success true --resource $ResourceName --region $Region 2>&1
        if (`$LastExitCode -ne 0) {
            WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Failed to signal CloudFormation: `$cfn_signal_output"
            Unregister-ScheduledTask -TaskName "SignalSuccess" -Confirm:`$false
            exit 1
        }
        WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Signaled CloudFormation completion successfully"
    }
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "$ResourceName deployment process completed successfully"
    Unregister-ScheduledTask -TaskName "SignalSuccess" -Confirm:`$false
"@
# Convert script block to a Base64 encoded string to pass it to the scheduled task
$encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptBlock))
# Creating the scheduled task
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-EncodedCommand $encodedCommand"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask `
    -Action $action `
    -Trigger $trigger `
    -User "NT AUTHORITY\SYSTEM" `
    -RunLevel "Highest" `
    -TaskName "SignalSuccess" `
    -Description "Signal completion after reboot"

# Reboot to apply hostname change
try {
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Host will now be restarted to apply hostname change"
    Restart-Computer -Force
} catch {
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Failed to restart computer: $_"
    exit 1
}
