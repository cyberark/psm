<powershell>
# Configure machine for ansible remoting
$logfile="C:\ProgramData\Amazon\EC2-Windows\Launch\Log\kitchen-ec2.log"

# Allow script execution
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

# PS Remoting and & winrm.cmd basic config
Enable-PSRemoting -Force -SkipNetworkProfileCheck
winrm set winrm/config '@{MaxTimeoutms="1800000"}' >> $logfile
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}' >> $logfile
winrm set winrm/config/winrs '@{MaxShellsPerUser="50"}' >> $logfile

# Server settings - support username/password login
winrm set winrm/config/service/auth '@{Basic="true"}' >> $logfile
winrm set winrm/config/service '@{AllowUnencrypted="true"}' >> $logfile
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}' >> $logfile

#Firewall Config
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" profile=public protocol=tcp localport=5985 remoteip=localsubnet new remoteip=any  >> $logfile

# Disable Complex Passwords
"Disabling Complex Passwords" >> $logfile
$seccfg = [IO.Path]::GetTempFileName()
secedit /export /cfg $seccfg
(Get-Content $seccfg) | Foreach-Object {$_ -replace "PasswordComplexity\s*=\s*1", "PasswordComplexity=0"} | Set-Content $seccfg
secedit /configure /db $env:windir\security\new.sdb /cfg $seccfg /areas SECURITYPOLICY
del $seccfg

# Change Password
"Change Password" >> $logfile
$ComputerName = $env:COMPUTERNAME
$user = [adsi]"WinNT://$ComputerName/Administrator,user"
$user.setpassword("Kitchen")
Set-ItemProperty -Name LocalAccountTokenFilterPolicy -Path HKLM:\software\Microsoft\Windows\CurrentVersion\Policies\system -Value 1
</powershell>