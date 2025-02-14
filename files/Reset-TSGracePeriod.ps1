## This Script is intended to be used for Querying remaining time and resetting Terminal Server (RDS) Grace Licensing Period to Default 120 Days.
## Developed by Prakash Kumar (prakash82x@gmail.com) May 28th 2016
## www.adminthing.blogspot.com
## Disclaimer: Please test this script in your test environment before executing on any production server.
## Author will not be responsible for any misuse/damage caused by using it.

try
{
	Clear-Host
	$ErrorActionPreference = "SilentlyContinue"
	
	## Display current Status of remaining days from Grace period.
	try
	{
	$GracePeriod = (Invoke-WmiMethod -PATH (gwmi -namespace root\cimv2\terminalservices -class win32_terminalservicesetting).__PATH -name GetGracePeriodDays).daysleft
	}
	catch
	{
		# RDS does not exist on instance, continue without error
		exit 0
	}
	Write-Host -fore Green ======================================================
	Write-Host -fore Green 'Terminal Server (RDS) grace period Days remaining are' : $GracePeriod
	Write-Host -fore Green ======================================================  
	Write-Host
	
# White space is not allowed before string terminator, do not indent
$definition = @"
using System;
using System.Runtime.InteropServices; 
namespace Win32Api
{
	public class NtDll
	{
		[DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")]
		public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled);
	}
}
"@ 
	
	Add-Type -TypeDefinition $definition -PassThru
	
	$bEnabled = $false
	
	## Enable SeTakeOwnershipPrivilege
	$res = [Win32Api.NtDll]::RtlAdjustPrivilege(9, $true, $false, [ref]$bEnabled)
	
	## Take Ownership on the Key
	$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
	$acl = $key.GetAccessControl()
	$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
	$key.SetAccessControl($acl)
	
	## Assign Full Controll permissions to Administrators on the key.
	$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("Administrators","FullControl","Allow")
	$acl.SetAccessRule($rule)
	$key.SetAccessControl($acl)
	
	## Finally Delete the key which resets the Grace Period counter to 120 Days.
	Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod'
	
	Write-host
	Write-host -ForegroundColor Red 'Resetting, Please Wait....'
	Start-Sleep -Seconds 10 
	Write-host -ForegroundColor Red =================================================================
	Write-host -ForegroundColor Red   Grace period was reset. Shutdown the machine and create image
	Write-host -ForegroundColor Red   ATTENTION: Grace period will start on next machine boot
	Write-host -ForegroundColor Red =================================================================
	
	
	## Cleanup of Variables
	Remove-Variable * -ErrorAction SilentlyContinue
}
catch
{
	Write-Host	-ForegroundColor Red "An Error has occured on Reset RDS Grace Period"
	exit 1
}

exit 0