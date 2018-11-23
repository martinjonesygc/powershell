## Instructions
# Enter email domain - line 24
# Enter OU Path - line 34 

## Description
# Reset leaver password in AD to randomly generated password
# Disable Account
# Move account to seperate OU
# Remove AD Group Membership
# Set description
# Disable Office 365 account

## To-do
# Move Homefolders to differnet location

Import-Module ActiveDirectory


# Identify Leaver
$FirstName = Read-Host 'First Name'
$LastName = Read-Host 'Last Name'
$FullName = $FirstName + " " + $LastName
$UserName = $FirstName + "_" + $LastName
$EmailDomain = "@enteremaildomain"
$Email = $FirstName + "." + $LastName + $EmailDomain
$date = Get-Date -UFormat "%d-%m-%Y"


# Generate Random Password
$Password = ([char[]]([char]65..[char]90) + ([char[]]([char]97..[char]122)) + 0..9 | sort {Get-Random})[0..7] -join ''


# Move to leavers AD Group
Get-ADuser $Username | Move-ADObject -TargetPath 'Enter OU Path here'


# Remove AD group membership
$ADGroups = Get-ADPrincipalGroupMembership -Identity $UserName | where {$_.Name -ne "Domain Users"}
Remove-ADPrincipalGroupMembership -ErrorAction SilentlyContinue -Identity $Username -MemberOf $ADGroups -Confirm:$false


# Reset Password
$SecPassword = ConvertTo-SecureString –String $Password –AsPlainText –Force
Set-ADAccountPassword -Reset -NewPassword $SecPassword –Identity $UserName


# Set Description
Set-ADUser $username -Description "Account Disabled - $date"


# Disable Active Directory Account
Disable-ADAccount -Identity $UserName


# Disable O365 Account
Connect-MsolService
Remove-MsolUser -UserPrincipalName $Email -Force
