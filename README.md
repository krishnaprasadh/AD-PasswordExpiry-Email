# AD-PasswordExpiry-Email
Powershell script to send email remainder to all users in Active Directory whose passwords are going to expire in the next upcoming 7 days.

Run from the "C:\Scripts" folder as admin in the AD. You can also change the path.

**Change SMTP server**:

**LineNo6** 
$SMTPServer = "mailserver.company.com"
**LineNo7** 
$EmailFrom = "donotreply@company.com"

**To check and send a test email for a single user change the firstname.lastname** in LineNo106:

$expiredUsers = Get-ADUser -identity firstname.lastname -properties "msDS-UserPasswordExpiryTimeComputed", "UserPrincipalName", "PasswordLastSet","EmailAddress","GivenName" | Select-Object UserPrincipalName,PasswordLastSet,EmailAddress, GivenName, @{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") }}

**To send out email for the actual users whose password is going to expire in the next 7 days change the SearchBase OU=Example,OU=Example,DC=Example,DC=com** in LineNo100 and LineNo101:

$expiringUsers = Get-ADUser -filter 'enabled -eq $true' -SearchBase 'OU=Example,OU=Example,DC=Example,DC=com' -properties "msDS-UserPasswordExpiryTimeComputed", "UserPrincipalName", "PasswordLastSet","EmailAddress","GivenName" | Select-Object UserPrincipalName,PasswordLastSet,EmailAddress, GivenName, @{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | where-object {$_.PasswordExpiry -ge (Get-date) -and $_.PasswordExpiry -lt (Get-Date).AddDays(7)}

$expiringContractors = Get-ADUser -filter 'enabled -eq $true' -SearchBase 'OU=Example,OU=Example,DC=Example,DC=com' -properties "msDS-UserPasswordExpiryTimeComputed", "UserPrincipalName", "PasswordLastSet","EmailAddress","GivenName" | Select-Object UserPrincipalName,PasswordLastSet,EmailAddress, GivenName,@{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") }} | where-object {$_.PasswordExpiry -ge (Get-date) -and $_.PasswordExpiry -lt (Get-Date).AddDays(7)}

**Getting the SearchBase value in your AD which has users**:

Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-Table Name, DistinguishedName -A

The above Get-ADOrganizationalUnit cmdlet gets an organizational unit (OU) object or performs a search to get multiple OUs.
**Microsoft link** : https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adorganizationalunit?view=windowsserver2022-ps

**Change Path instead of running and using from "C:\Scripts" Folder**:

**LineNo22**:
$TrackingFile = 'C:\Scripts\tmp\' + $CurDate + '.tmp'

**LineNo23**:
$OldTrackingFile = 'C:\Scripts\tmp\' + $Yesterdate + '.tmp'

**LineNo17** Change Test-Path:
if (!(Test-Path '.\log')) {New-Item -Path '.\log' -ItemType Directory}

**LineNo18** Change Test-Path:
if (!(Test-Path '.\tmp')) {New-Item -Path '.\tmp' -ItemType Directory}

**LineNo10**:
#$LogFile = 'C:\Scripts\log\passwordreset.log'

**Change remainder days for checking password expiry instead of using 7 days**:

**LineNo100 and Line101**:
(Get-Date).AddDays(7)
