# New Starter Script V.01 #
# Author: Mike Oram #
# Last Updated: 16/11/21 #

Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement
Import-Module AzureAD


# Connect to ExchangeOnline
Connect-ExchangeOnline 

#Define UPN#
$UPN = "@eunomia.co.uk"


Write-Host "New Starter Script"
Write-Host "Enter information when prompted !"

Start-Sleep -Seconds 5


Clear-Host
$firstname = Read-Host -Prompt "Input the new users first name"
Clear-Host
$lastname = Read-Host -Prompt "Input the new users last name"
$username = ("$firstname"+"."+$lastname).ToLower() # creates username and forces lower case #
Clear-Host


$jobtitle = Read-Host -Prompt "Input the new users Job Title" 
Clear-Host

##Get a users office location and set a variable for it. 

write-host "Choice of Offices:"
write-host "Bristol"
write-host "Manchester"
write-host "London"
write-host "Brussels"
write-host "Athens"
write-host "New York"
write-host "New Zealand"

$office = Read-Host -Prompt "Input the new users office"

Clear-Host
##Get Users Line Manager and set a variable using it
Write-Host "Input the users line manager in the format mike.oram"
$linemanager = Read-Host -Prompt "Enter the users line manager in the format above"

# Office Address #
# If loop to get office address based on $office variable #

If ($office -eq "Bristol") {
 $streetaddress = "37 Queen Square"
 $city = "Bristol"
 $postcode = "BS1 4QS"
 $company = "Eunomia"
}

if ($office -eq "London" ) {
 $streetaddress = "29 Clerkenwell Road"
 $city = "London"
 $postcode = "EC1M 5TA"
 $company = "Eunomia"
}

if ($office -eq "Manchester" ) {
$streetaddress = "111 Piccadilly"
$city = "Manchester"
$postcode = "M1 2HY"
$company = "Eunomia"
}

if ($office -eq "Brussels") {
$streetaddress = "Rue des Poissonniers 13"
$city = "Brussels"
$postcode = 1000
$company = "Eunomia"
}

if ($office -eq "Athens" ) {
$streetaddress = "44 Avenue Vasileos Konstantinou"
$city = "Athens"
$postcode = "11635"
$company = "Eunomia IKE"
$UPN = "@eunomia-ike.eu"
}

if ($office -eq "New York" ) {
$streetaddress = "The Yard, 33 Nassau Avenue"
$city = "New York"
$postcode = "11222"
$UPN = "@eunomia-inc.com"
$company = "Eunomia Inc"
}


## email loop for Email addresses 
if ($office -eq "New York") {
    $email = "$username@eunomia-inc.com"
}
elseif ($office -eq "Athens") {

    $email = "$username@eunomia-ike.eu"
}
else {
    $email = "$username@eunomia.co.uk"   
}


#generate a random password
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}
 
$password = Get-RandomCharacters -length 10 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 1 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 1 -characters '1234567890'
$password += Get-RandomCharacters -length 1 -characters '!"§$%&/()=?}][{@#*+'
 
$password = Scramble-String $password
 
$OU = "OU=SBSUsers,OU=Users,OU=MyBusiness,DC=eunomialtd,DC=local"

#Check to see if the user already exists in AD

if (Get-ADUser -F {SamAccountName -eq $username }) {
    #If user exists write warning. 
    Write-Warning "A user account with username $username already exists in Active Directory."
}

else {
 #User not found creating User
 #User will be created in Staff OU
 New-ADUser  -Name "$firstname $lastname" -SamAccountName "$username" -GivenName "$firstname" -Description $jobtitle -ScriptPath "logon.bat" -Office $office -Surname "$lastname" -Enabled $true -DisplayName "$firstname $lastname" -Path "$OU" -City "$city" -PostalCode "$postcode" -Company "$company" -StreetAddress "$streetaddress" -EmailAddress "$email" -Title "$jobtitle"-AccountPassword (ConvertTo-secureString $password -AsPlainText -Force)  -UserPrincipalName "$username$upn" 

Write-Host "The user account $username has been created"
Write-Host "Username = $username"
Write-Host "Password = $password" 


}

#Add to Security Groups / DL as needed
Add-ADGroupMember -Identity Eunomia -Members $username
Add-ADGroupMember -Identity "All Staff" -members $username
Add-ADGroupMember -Identity "All Users" -members $username

if ($office -eq "Bristol") {
    add-ADGroupMember  -Identity "Eunomia Bristol" -Members $username
    Add-ADGroupMember -Identity "EunomiaUK" -Members $username

}

if ($office -eq "London") {
    add-ADGroupMember  -Identity "Eunomia London" -Members $username
    Add-ADGroupMember -Identity "EunomiaUK" -Members $username

}

if ($office -eq "Manchester") {
    Add-ADGroupMember -Identity "Eunomia Manchester" -Members $username
    Add-ADGroupMember -Identity "EunomiaUK" -Members $username
}

if ($office -eq "New York") {
    Add-ADGroupMember -Identity "Eunomia Inc Drive" -Members $username
}

if ($office -eq "Athens") {
    Add-ADGroupMember -Identity "Eunomia IKE Drive" -Members $username
}

#Get First letter of first name for Email DL

$firstletter = $firstname.Substring(0,1).ToLower()
#Match first letter and assign DL
If ($firstletter -match "[a-c]" ) {
    Add-ADGroupMember -Identity "Eunomia A-C" -Members $username
}

If ($firstletter -match "[d-h]" ) {
    Add-ADGroupMember -Identity "Eunomia D-H" -Members $username
}

If ($firstletter -match "[i-l]" ) {
    Add-ADGroupMember -Identity "Eunomia I-L" -Members $username
}

If ($firstletter -match "[m-p]" ) {
    Add-ADGroupMember -Identity "Eunomia M-P" -Members $username

}

If ($firstletter -match "[q-z]" ) {
    Add-ADGroupMember -Identity "Eunomia Q-Z" -Members $username

}


## add line manager
Set-ADUser -Identity $username -Manager $linemanager
##Need to add if loop for Job Title DL's
If ($jobtitle -match "Trainee Consultant") {
    Add-ADGroupMember -Identity "Trainee Consultants" -Members $username
}

If ($jobtitle -match "Consultant") {
    Add-ADGroupMember -Identity "Consultants" -Members $username
}

If ($jobtitle -match "Junior Consultant") {
    Add-ADGroupMember -Identity "Junior Consultants" -Members $username
}

Import-Module ADSync

Start-ADSyncSyncCycle -PolicyType Initial

##Wait for AD Sync to sync account to 365 (Waiting 20 Mins)
Write-Output "Waiting for AD Sync to complete before continuing with Licencing the user in O365"
Start-Sleep -Seconds 600

Clear-Host

##Import AzureAD Module & ExchangeOnline & Connect to it
Import-Module AzureAD
Import-Module ExchangeOnlineManagement
Write-Output "Connect using your standard account and password."
Start-Sleep -Seconds 5
Connect-AzureAD
Write-Output "Connect using your standard account and password."
Connect-ExchangeOnline
##Set Variables for UPN for User
##If US user set Location to US. 
if ($office -eq "New York") {
$userloc = "US"
set-AzureADuser -ObjectId $email -UsageLocation $userloc
}
Elseif ($office -eq "Athens") {
$userloc = "GR"
Set-AzureADUser -ObjectId $email -UsageLocation $userloc
}
## Adds the direct routing voice licence if the user is UK based. 
Else {
$userloc ="GB"
Set-AzureADUser -ObjectId $email -UsageLocation $userloc
}

##Assign Plan Name Variables (TO ADD MORE LICENCES TO SCRIPT) Copy the code block, amend the Plan name using the SKU Id. 

$planName="SPB"
$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$LicensesToAssign.AddLicenses = $License
Set-AzureADUserLicense -ObjectId $email -AssignedLicenses $LicensesToAssign
Write-Host "$username is now licenced for 365 Buisness Premium"


if ($userloc -eq "GB") {
    $planName="BUSINESS_VOICE_DIRECTROUTING"
    $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
    $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    $LicensesToAssign.AddLicenses = $License
    Set-AzureADUserLicense -ObjectId $email -AssignedLicenses $LicensesToAssign
    Write-Host "$username is now licenced for Buisness Voice (DirectRouting)"
    }

Write-Host "Waiting for Mailbox to be created before proceeding"
Start-Sleep 600


If ($jobtitle -match "Trainee Consultant") {
    Add-DistributionGroupMember -Identity "OpsComms" -Member $email
}

If ($jobtitle -match "Consultant") {
    Add-DistributionGroupMember -Identity "OpsComms" -Member $email
}

if ($jobtitle -match "Senior Consultant") {
    Add-DistributionGroupMember -Identity "Senior Consultants" -Member $email
}

if ($jobtitle -match "Principal Consultant") {
    Add-DistributionGroupMember -Identity "Principal Consultants" -Member $email
}

If ($jobtitle -match "Junior Consultant") {
    Add-DistributionGroupMember -Identity "OpsComms" -Member $email
}

if ($office -match "New York") {
    Add-DistributionGroupMember -Identity "EunomiaNA" -Member $email
}

##Assign default calendar permissions. 
$Calendar = $email | Foreach-Object{ "${email}:\Calendar" }
Set-MailboxFolderPermission $Calendar -user Default -AccessRights Reviewer

##End all PS Sessions
Get-PSSession | Remove-PSSession

Set-ExecutionPolicy Restricted