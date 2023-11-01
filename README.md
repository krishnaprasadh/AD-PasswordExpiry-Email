# ActiveDirectory-PasswordExpiry-Email

<ins>**Description**:</ins><br>
Powershell script to send email remainder to all users in Active Directory whose passwords are going to expire in the next upcoming 7 days.

<ins>**Script Path**:</ins><br>
Run ADPasswordExpiryEmail.ps1 script from the "C:\Scripts" folder as admin from the powershell in the AD. You can also change the path.

<ins>**Inital Test - To check if the powershell script is working as expected:**</ins><br>

Change the below variables in ADPasswordExpiryEmail.ps1 and run as admin using powershell from "C:\Scripts" Folder on AD:<br>

$SMTPServer = "mailserver.company.com" (LineNo6)<br>
$EmailFrom = "donotreply@company.com" (LineNo7)<br>
$expiredUsers = Get-ADUser -identity firstname.lastname (LineNo106 user firstname.lastname in AD)<br>

You should receive an email to your inbox.

<ins>**To send out email for the actual users whose password is going to expire in the next upcoming 7 days, change the SearchBase OU=Example,OU=Example,DC=Example,DC=com**</ins> which will contain the users account:

**LineNo100**:<br>
$expiringUsers = Get-ADUser -filter 'enabled -eq $true' **-SearchBase 'OU=Example,OU=Example,DC=Example,DC=com'**

**LineNo101**:<br>
$expiringContractors = Get-ADUser -filter 'enabled -eq $true' **-SearchBase 'OU=Example,OU=Example,DC=Example,DC=com'**

<ins>**Getting the SearchBase value in your AD which has users in OU**</ins>:

Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-Table Name, DistinguishedName -A

The above Get-ADOrganizationalUnit cmdlet gets an organizational unit (OU) object or performs a search to get multiple OUs.<br>

**Microsoft link**: https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adorganizationalunit?view=windowsserver2022-ps

<ins>**Change the path running the powershell ps1.script and logs from "C:\Scripts" Folder to different path**</ins>:

**LineNo22**:<br>
$TrackingFile = 'C:\Scripts\tmp\' + $CurDate + '.tmp'

**LineNo23**:<br>
$OldTrackingFile = 'C:\Scripts\tmp\' + $Yesterdate + '.tmp'

**LineNo17** Change Test-Path:<br>
if (!(**Test-Path** '.\log')) {New-Item -Path '.\log' -ItemType Directory}

**LineNo18** Change Test-Path:<br>
if (!(**Test-Path** '.\tmp')) {New-Item -Path '.\tmp' -ItemType Directory}

**LineNo10**:<br>
#$LogFile = 'C:\Scripts\log\passwordreset.log'

<ins>**To send email remainder to all users in Active Directory whose passwords are going to expire in the next upcoming 3 days**</ins>:

**LineNo100 and LineNo101**: at the end of line change 7 to 3<br>
(Get-Date).AddDays(**7**)

<ins>**Troubleshoot email**</ins>:

In the Powershell window, it will say **sending email to user** if the user has not recevied the email for the day. If you try to send it again on the same day by executing the script it will say **skipping email** since the user has already received the email for the day.<br>

For example, After you execute the script and it sends a remainder email to your account for testing purposes and its successful for the first time but if you are not receiving email for the second time or later executing it again on the same day. Delete the file in "log" folder and "tmp" folder from "C:\Scripts" folder or remove your name entry from the file. It won't send an email again because it has already sent it for that day once and it has been written in the logs.

<ins>**NOTE**</ins>: This program will send an email remainder to all the AD users whose password will expire in the next upcoming 7 days. It will send one email per day as a remainder for those users whose passwords are expiring in the next upcoming 7 days. You can also use this script with the windows task scheduler in AD to run everyday. It will check users whose password will expire in the next upcoming 7 days and sends an email to them.
