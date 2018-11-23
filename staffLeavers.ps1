Import-Module ActiveDirectory
## To-do
# Move Homefolders to differnet location

# Identify Leaver
$FirstName = Read-Host 'First Name'
$LastName = Read-Host 'Last Name'
$FullName = $FirstName + " " + $LastName
$UserName = $FirstName + "_" + $LastName
$EmailDomain = "@ysgolglanclwyd.co.uk"
$Email = $FirstName + "." + $LastName + $EmailDomain
$date = Get-Date -UFormat "%d-%m-%Y"

# Generate Random Password
$Password = ([char[]]([char]65..[char]90) + ([char[]]([char]97..[char]122)) + 0..9 | sort {Get-Random})[0..7] -join ''

# Move to leavers AD Group
Get-ADuser $Username | Move-ADObject -TargetPath 'OU=Leavers,OU=Users,OU=YGC,DC=GlanClwyd,DC=local'

# Remove AD group membership
$ADGroups = Get-ADPrincipalGroupMembership -Identity $UserName | where {$_.Name -ne "Domain Users"}
Remove-ADPrincipalGroupMembership -ErrorAction SilentlyContinue -Identity $Username -MemberOf $ADGroups -Confirm:$false

# Reset Password
$SecPassword = ConvertTo-SecureString –String $Password –AsPlainText –Force
Set-ADAccountPassword -Reset -NewPassword $SecPassword –Identity $UserName
Write-Host "Password has been reset"

# Set Description
Set-ADUser $username -Description "Account Disabled - $date"

# Disable Active Directory Account
Disable-ADAccount -Identity $UserName
Write-Host "Active Directory account - Disabled"

# Disable O365 Account
Connect-MsolService
Remove-MsolUser -UserPrincipalName $Email -Force
Write-Host "Office 365 account for $FirstName $LastName has been disabled"

# Summary
Write-Host "AD Account for $FirstName $LastName has bee disabled"
Write-Host "Password has been reset"
Write-Host "AD Account moved to Leavers OU"
Write-Host "Group Membership has been removed"
Write-Host "Office 365 Account has been disabled and will be deleted in 30 days"
