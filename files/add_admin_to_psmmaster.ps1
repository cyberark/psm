
[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)] 
		[string]$username,
        [Parameter(Mandatory=$true)] 
		[string]$password,
        [Parameter(Mandatory=$true)] 
		[string]$pvwaIp,
        [Parameter(Mandatory=$false)] 
		[string]$authenticationType = 'Cyberark'

	)

$logonUrl = 'https://{0}/PasswordVault/API/auth/{1}/Logon' -f $pvwaIp, $authenticationType


### ignore certificates
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$restLogonBody = @{
    "username" = $username
    "password" = $password
} | ConvertTo-Json


$sessionToken = ''

## Logon to PVWA
try
{
    $sessionToken = Invoke-RestMethod -Method Post -Uri $logonUrl -Body $restLogonBody -ContentType "application/json" 
}
catch
{
    Write-host ("Exception on connecting to PVWA: {0}" -f $PSItem)
    return -1
}

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $sessionToken)
Write-Host ("Logon preformed successfully")

## Get vault group

$getFilter = [uri]::EscapeDataString("groupType eq Vault")
$usersUrl = 'https://{0}/PasswordVault/api/UserGroups?filter={1}&search=PSMMaster' -f $pvwaIp, $getFilter

$response = ''
try 
{
    $response = Invoke-RestMethod -Method Get -Uri $usersUrl -ContentType 'application/json' -Headers $headers
}
catch 
{
    Write-Host ("Exceptionoccured during GetVaultGroup: {0}" -f $PSItem)
    return -1
}
if($response.count -le 0)
{
    Write-Host("No group PSMMaster exist on pvwa {0}" -f $pvwaIp)
    return -1
}

$restBody = @{
    "memberId" = $username
} | ConvertTo-Json

## Add user to the Group
try {
$userStatus = Invoke-RestMethod -Method Post -ContentType 'application/json' -Headers $headers -Body $restBody `
                                -Uri ('https://{0}/PasswordVault/api/UserGroups/{1}/Members/' -f $pvwaIp, $response.value[0].id)
}
catch [System.Net.WebException]
{
    write-host("user already exists on group, continue...")
}
catch 
{
    write-host("Unknown error occured pvwa REST Adding user group")
    return -1
}

## Logout from PVWA
$logoffUrl = 'https://{0}/PasswordVault/API/auth/Logoff' -f $pvwaIp
$response = Invoke-RestMethod -Method Post -Uri $logoffUrl -ContentType "application/json" -Headers $headers
Write-Host ("successfully Logged out")
write-host('###### Finished successfully adding user to group #######')