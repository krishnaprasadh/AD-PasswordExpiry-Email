#BE SURE TO RUN AS ADMIN
#EXECUTE THIS PROGRAM FROM "C:\Scripts" Folder from Active Directory Domain Controller or Change the paths in line number 22,23,17,18,10.

function Email-User($userfirstname, $useremail, $expiredays, $expiredate) {
	
	$SMTPServer = "mailserver.company.com"
	$EmailFrom = "donotreply@company.com"
	$CurDate = Get-Date -Format "dd-MM-yyyy"
	$Yesterdate = (get-date).adddays(-1).tostring("dd-MM-yyyy")
	#$LogFile = 'C:\Scripts\log\passwordreset.log'	#To enable/save logs uncomment this line and line 86,87
	
	echo " API: first name is ($userfirstname)"
	echo "API: user email is ($useremail)"
	echo "API: expiredays is ($expiredays)"
	echo "API: expired date is ($expiredate)"
	
	if (!(Test-Path '.\log')) {New-Item -Path '.\log' -ItemType Directory}
	if (!(Test-Path '.\tmp')) {New-Item -Path '.\tmp' -ItemType Directory}

	
	#Tracking file and subsequent if statement needed to ensure only 1 email per day per user, then deletes yesterday's tracking email to prevent taking up space
	$TrackingFile = 'C:\Scripts\tmp\' + $CurDate + '.tmp'
	$OldTrackingFile = 'C:\Scripts\tmp\' + $Yesterdate + '.tmp'
	if (!(Test-Path $TrackingFile)) {
		#$null > $TrackingFile
		echo "ThisFileHasListOfEntriesExpiringIn3Days" > $TrackingFile
		if ((Test-Path $OldTrackingFile)) 
			{ remove-item $OldTrackingFile }
	}
	
	#Get list of emails sent today, only send email if one hasn't been sent yet
	$alreadysent = get-content $TrackingFile
	#echo " user email is $useremail"
	#echo "already sent " $alreadysent
	
	if (!$alreadysent.contains($useremail))
	{
		$body = "$userfirstname,"
		$body += "<br><br>"
		$body += "Your <CompanyName> account's password will expire on $expiredate UTC. Please change your password as soon as possible."
		$body += "<br><br>"
		$body += "Instructions for how to change your <CompanyName> password are below:"
		$body += "<br><br>"
		$body += "Regards,"
		$body += "<br>"
		$body += "CompanyName Admin"
		
		Try {
			echo "Sending email to $useremail"
			send-mailmessage -To $useremail -Subject "[IMPORTANT] CompanyName Password Expiration in $expiredays days" -bodyashtml -body $body -from $EmailFrom -SmtpServer $SMTPServer
		} catch {
			# Write a log file to indicate email error, and when.
			$DateTime = Get-Date -format "MM/dd/yyyy hh:mm:sstt"
			Add-Content $LogFile -Value "$DateTime - $_"
		}
		
		# Write a log file to indicate who was emailed, and when.
		#$DateTime = Get-Date -format "MM/dd/yyyy hh:mm:sstt"
		#Add-Content $LogFile -Value "$DateTime - $userfirstname - Expires: $expiredate"
		
		#Add user email to tracking list for next run
		echo $useremail >> $TrackingFile
	} else {
		echo "Skipping email to $useremail"
	}
}


#$expiringUsers = Get-ADUser -filter 'enabled -eq $true' -SearchBase 'OU=Example,OU=Example,DC=Example,DC=com' -properties "msDS-UserPasswordExpiryTimeComputed", "UserPrincipalName", "PasswordLastSet","EmailAddress","GivenName" | Select-Object UserPrincipalName,PasswordLastSet,EmailAddress, GivenName, @{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | where-object {$_.PasswordExpiry -ge (Get-date) -and $_.PasswordExpiry -lt (Get-Date).AddDays(3)} #Greater than today and lesser than today+3days.

$expiredUsers = Get-ADUser -identity firstname.lastname -properties "msDS-UserPasswordExpiryTimeComputed", "UserPrincipalName", "PasswordLastSet","EmailAddress","GivenName" | Select-Object UserPrincipalName,PasswordLastSet,EmailAddress, GivenName, @{Name = "PasswordExpiry"; Expression = {[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") }} #Uncomment this line to test email for single user (change firstname.lastname)


foreach ($user in $expiredUsers) {
	
	echo "**************************"
	$aduser = Get-ADUser -Filter "userPrincipalName -eq '$($user.UserPrincipalName)'" 
	echo "$aduser"
	echo "the username is $($user.GivenName)"
	$givenname = $user.GivenName
	$daysuntilexpire = (new-timespan -start (get-date) -end $($user.PasswordExpiry.DateTime)) #To send email that the password will get expired in n days - new-timespan -start (get-date) -end(get-date).AddDays(1)
	echo "$daysuntilexpire"
	
	if ($null -ne $aduser){
		Write-Host "Expiring password: $($user.userPrincipalName)"
		if ($daysuntilexpire.Days -gt 0){
			Email-User -userfirstname $($user.GivenName) -useremail $($user.EmailAddress) -expiredays $daysuntilexpire.Days -expiredate ($($user.PasswordExpiry).touniversaltime()).ToString("dd-MMM-yyyy hh:mm") #print in d-m-y
			echo "user is $user"
			echo "the username is $($user.GivenName)"
			echo "the mail address is ($($user.UserPrincipalName))"
			echo " correct email address is ($($user.EmailAddress))"
			echo "the days until expire is $daysuntilexpire.Days" #Include .Days to print whole number
			echo "the expired date is $user.PasswordExpiry"
			
		} else {
			#Revoke tokens for user to log them out of all services
			#Get-AzureADUser -Filter "UserPrincipalName eq '$($user.UserPrincipalName)'" | Revoke-AzureADUserAllRefreshToken
			
			#Get-AzureADUser -SearchString username@domain.com | Revoke-AzureADUserAllRefreshToken
			#Get-AzureADUser -SearchString "($($user.UserPrincipalName))" | Revoke-AzureADUserAllRefreshToken
			
			#Require Azure password change
			#Set-MsolUserPassword -UserPrincipalName "$user.UserPrincipalName" -ForceChangePassword $true -ForceChangePasswordOnly $true
		} 
	}else {
		Write-Host "No users with Expiring password"
	}
}
