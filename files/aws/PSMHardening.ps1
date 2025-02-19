. "$PSScriptRoot\Common.ps1"

$LogFile = "C:\CyberArk\Deployment\Logs\PSMConfiguration.log"

try {
    # Log the start of the hardening script
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Setting path location for hardening"
    Set-Location "C:\Cyberark\PSM\InstallationAutomation"

    # Execute the hardening script using 64-bit PowerShell explicitly with NoProfile and ExecutionPolicy Bypass
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Executing hardening script in 64-bit PowerShell"
    & "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command ".\Execute-Stage.ps1 'Hardening\HardeningConfig.xml' -displayJson -delayedrestart | Out-File -FilePath 'psm_hardening_log.log'"

    # Log hardening script output
    WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Hardening script completed. Reading output log."
    $Result = Get-Content "psm_hardening_log.log" -Raw | ConvertFrom-Json

    # Log the result and exit based on success/failure
    if ($Result.isSucceeded -eq 0) {
        WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "PSM Hardening completed successfully"
        exit 0
    } else {
        WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "PSM Hardening failed"
        exit 1
    }
}
catch {
    # Enhanced exception logging
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "An error occurred: $_.Exception.Message"
    if ($_.Exception.InnerException) {
        WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Inner Exception: $($_.Exception.InnerException.Message)"
    }
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Stack Trace: $($_.Exception.StackTrace)"
    WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "Error Details: $($_ | Out-String)"
    exit 1
}
