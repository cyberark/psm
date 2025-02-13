[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)][string]$VaultAdminUser,
  [Parameter(Mandatory=$true)][string]$SSMAdminPassParameterID
)

. "$PSScriptRoot\Common.ps1"

$LogFile = "C:\CyberArk\Deployment\Logs\PSMRegistration.log"

try{
  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Getting Admin password from ssm"
  $AdminPassword = (Get-SSMParameterValue -Name "$SSMAdminPassParameterID" -WithDecryption $true).Parameters.Value
  $ScriptPath = $PSScriptRoot
  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Setting path location for registration"
  Set-Location "C:\Cyberark\PSM\InstallationAutomation"
  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Convert Admin password to secure string for registration PS"
  $secStrObj = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
  # $Action = .\Execute-Stage.ps1 "Registration\RegistrationConfig.xml" -displayJson -pwd $AdminPassword
  $Action = .\Execute-Stage.ps1 "Registration\RegistrationConfig.xml" -displayJson -spwdObj $secStrObj
  $Action | Out-File -FilePath "psm_registration_log.log"
  $Result = Get-Content "psm_registration_log.log" -Raw | ConvertFrom-Json
  if ($Result.isSucceeded -eq 0) {
      WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "PSM Registration completed successfully"
      exit 0
  } else {
      WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log "PSM Registration failed"
      exit 1
  }
}
catch{
  WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log $_.Exception.Message
  exit 1
}