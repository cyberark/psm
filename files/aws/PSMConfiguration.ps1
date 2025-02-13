[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)][string]$VaultIpAddress,
  [Parameter(Mandatory=$true)][string]$VaultAdminUser,
  [Parameter(Mandatory=$true)][string]$VaultPort
)

. "$PSScriptRoot\Common.ps1"

$LogFile = "C:\CyberArk\Deployment\Logs\PSMConfiguration.log"

try{
  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Get content of PSMRegisterComponentConfig.xml"
  $ScriptPath = $PSScriptRoot
  $FilePath = "C:\CyberArk\PSM\InstallationAutomation\Registration\RegistrationConfig.xml"
  $xml = [xml](Get-Content $filePath)

  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Get vault IP"
  $step1 = $xml.SelectSingleNode("//Parameter[@Name = 'vaultip']")
  $step1.Value = $VaultIpAddress
  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Get vault port"
  $step2 = $xml.SelectSingleNode("//Parameter[@Name = 'vaultport']")
  $step2.Value = $VaultPort
  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Get vault user"
  $step3 = $xml.SelectSingleNode("//Parameter[@Name = 'vaultusername']")
  $step3.Value = $VaultAdminUser
  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Accept eula"
  $step4 = $xml.SelectSingleNode("//Parameter[@Name = 'accepteula']")
  $step4.Value = "Yes"            

  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Save xml"
  $xml.Save($filePath)
  WriteLog -LogFile $LogFile -LogLevel "INFO" -Log "Step completed successfully"
}
catch{
  WriteLog -LogFile $LogFile -LogLevel "ERROR" -Log $_.Exception.Message
  exit 1
}