## Summary
# Create AD User
# Create Office 365 User
# Create Word Documnent with details


## To-do
# Integrate Gsuite module

# Identify New User

$FirstName = Read-Host 'First Name'
$LastName = Read-Host 'Last Name'
$FullName = $FirstName + " " + $LastName
$UserName = $FirstName + "_" + $LastName
$EmailDomain = "@emaildomainhere.com"
$Email = $FirstName + "." + $LastName + $EmailDomain
$rbusername = $FirstName + "." + $LastName


# Member of

[int]$xMenuChoiceA = 0
while ( $xMenuChoiceA -lt 1 -or $xMenuChoiceA -gt 2 ){
Write-host "1. Admin Staff"
Write-host "2. Staff"


[Int]$xMenuChoiceA = read-host "Please enter option 1 or 2..." }
Switch( $xMenuChoiceA ){
  1{$Department = "Admin Staff" } 1{$group = "AdminStaff" } 1{$homefiles = "adminstaff$" } 1{$emailGroup = "Staff Ategol" }
  2{$Department = "Staff" } 2{$group = "GG_Staff" } 2{$homefiles ="staff$" } 2{$emailGroup ="Staff Addysgu" } }


# Create Passwords - mix of uppercase, lowercase, numbers, 10 characters long

$ADpassword = ([char[]]([char]65..[char]90) + ([char[]]([char]97..[char]122)) + 0..9 | sort {Get-Random})[0..9] -join ''
$O365password = ([char[]]([char]65..[char]90) + ([char[]]([char]97..[char]122)) + 0..9 | sort {Get-Random})[0..9] -join ''
$gPassword = ([char[]]([char]65..[char]90) + ([char[]]([char]97..[char]122)) + 0..9 | sort {Get-Random})[0..9] -join ''


# Create user in AD

$secADpassword = ConvertTo-SecureString –String $ADpassword –AsPlainText –Force
New-ADUser -SamAccountName $UserName -AccountPassword $secADpassword -CannotChangePassword 0 -ChangePasswordAtLogon 1 -Department $Department -EmailAddress $Email -Enabled 1 -Name ($FirstName, $LastName -Join " ") -GivenName $FirstName -Surname $LastName -DisplayName ($FirstName, $LastName -Join " ") -UserPrincipalName $UserName@glanclwyd.local -HomeDrive "H:" -HomeDirectory "\\server\$homefiles\homefolders\$UserName\Documents"


# Add user to appropriate group membership

Add-ADGroupMember -Identity $group -Members $UserName


# Move user to appropriate OU

Get-ADUser $UserName | Move-ADObject -TargetPath "OU=$Department,rest of ou path here"


# Create Homefolder

$HomeShare = NEW-ITEM –path "\\server\$homefiles\folder\$UserName\Documents" -type directory -force



# Homefolder Permission

$Domain = 'domain name'
$IdentityReference=$Domain+"\"+$UserName
$FileSystemAccessRights=[System.Security.AccessControl.FileSystemRights]”FullControl”
$InheritanceFlags=[System.Security.AccessControl.InheritanceFlags]”ContainerInherit, ObjectInherit”
$PropagationFlags=[System.Security.AccessControl.PropagationFlags]”None”
$AccessControl=[System.Security.AccessControl.AccessControlType]”Allow”
$AccessRule = NEW-OBJECT System.Security.AccessControl.FileSystemAccessRule -argumentlist ($IdentityReference,$FileSystemAccessRights,$InheritanceFlags,$PropagationFlags,$AccessControl)
$HomeFolderACL=GET-ACL $HomeShare
$HomeFolderACL.AddAccessRule($AccessRule)
SET-ACL –path $HomeShare -AclObject $HomeFolderACL


# Create Email Account
Connect-MsolService
New-MsolUser -DisplayName $FullName -FirstName $FirstName -LastName $LastName -UserPrincipalName $Email -UsageLocation "GB" -LicenseAssignment "license name here" -Password $O365password


# Testing Pause to let account appear before adding groups
Write-Host = "Waiting 1 Minute"
Start-Sleep -s 60


# Connecto to Exchange Online and add to distribution groups
###### Possibly move this or add a pause ######

$UserCredential = Get-Credential
$ProxyOptions = New-PSSessionOption -ProxyAccessType IEConfig
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $session -DisableNameChecking
Add-DistributionGroupMember -Identity "Email Group name" -Member $email
Add-DistributionGroupMember -Identity $emailGroup -Member $email
Remove-PSSession $Session


# Fill Word Document Details

$objWord = New-Object -comobject Word.Application  
    function findAndReplace ($todoObjs)
    {
        $objDoc = $objWord.Documents.Open("C:\users\pathtoDocumentTemplate.docx")
        $objWord.Visible = $false
        $objSelection = $objWord.Selection
        foreach ($todoObj in $todoObjs)
        {
          $a = $objSelection.Find.Execute($($todoObj.FIND), $false, $true, $False, $False, $False, $true, 1, $False, $($todoObj.REPLACE))
        }
        $outputPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
        $outputPath = $FirstName + $LastName + ".docx"
        $objDoc.SaveAs($outputPath)
        $objDoc.close()

    }


# Words to find and replace

$todo = @"
FIND,REPLACE
Fullname,$FullName
Cusername,$Username
Cpassword,$ADpassword
Eusername,$email
Epassword,$O365password
Susername,$Username
gUsername,$Email
gPassword,$gPassword
rbUsername,$rbusername
"@

$todoObjs = ConvertFrom-Csv $todo
findAndReplace $todoObjs