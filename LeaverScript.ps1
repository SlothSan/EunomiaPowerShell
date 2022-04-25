##Leaver Script v.01
# Author : Mike Oram
# Last Updated : 19/08/21

#Import Modules needed for script

Import-Module AzureAD
Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement

## Connect to Azure / Exchange
Connect-ExchangeOnline
Connect-AzureAD 

#Get username of user who is leaving the buisness
Write-Host "Please enter the username in the standard format eg mike.oram"
$Leaver = Read-Host "Enter the username of the leaver"

#Get EmailAddress to be used later in script
$EmailAddress = (Get-ADUser $Leaver -Properties EmailAddress | Select-Object EmailAddress).emailaddress

#Get Managers SamAccountName to use for Exchange
$Manager = (get-aduser (get-aduser $leaver -Properties manager).manager).samaccountName
$ManagerEmail = (Get-ADUser $Manager -Properties EmailAddress | Select-Object EmailAddress).emailaddress

##Get Details for Leaver OOF
$LeaverName = (get-aduser $Leaver -Properties name).name
$ManagerName = (get-aduser (get-aduser $leaver -Properties manager).manager).name

##Get UPN for O365
$UPN = (get-aduser $Leaver -properties UserPrincipalName).UserPrincipalName


##Create OOF Message 
$OOF = "<html>
        <head>
        <style>
        pre {font-family: Calibri;}
        </style
        </head>
        <body>
Hello, thank you very much for your email.<br> 
<br>
$LeaverName no longer works at Eunomia. Please contact $ManagerName ($ManagerEmail) for any help and support that you need.<br>
<br>
Or mail@eunomia.co.uk / +44 (0)117 917 2250 for reception enquiries.<br>
<br>
Many thanks
</body>
</html>"



##Convert Leavers Mailbox To Shared
Set-Mailbox -Identity $EmailAddress -Type Shared

## Add Leavers Line Manager to Shared Mailbox
Add-MailboxPermission -Identity $EmailAddress -User $ManagerEmail -AccessRights FullAccess

## Set Out Of Office
Set-MailboxAutoReplyConfiguration -Identity $EmailAddress -AutoReplyState Enabled -InternalMessage "$OOF" -ExternalMessage "$OOF"

##Remove Licences in 365
$userUPN=$UPN
$userList = Get-AzureADUser -ObjectID $userUPN
$Skus = $userList | Select-Object -ExpandProperty AssignedLicenses | Select-Object SkuID
if($userList.Count -ne 0) {
    if($Skus -is [array])
    {
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        for ($i=0; $i -lt $Skus.Count; $i++) {
            $Licenses.RemoveLicenses +=  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus[$i].SkuId -EQ).SkuID   
        }
        Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    } else {
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $Licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus.SkuId -EQ).SkuID
        Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    }
}

##Add 365 Basic Licence
$planName="O365_BUSINESS_ESSENTIALS"
$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$LicensesToAssign.AddLicenses = $License
Set-AzureADUserLicense -ObjectId $EmailAddress -AssignedLicenses $LicensesToAssign
Write-Host "$leaver is now licenced for 365 Buisness Standard"

##Disable User Account in 365
Set-AzureADUser -ObjectID $UPN -AccountEnabled $false

#Disable in Active Directory & Remove from all groups
#Remove Leaver from all groups.
Get-AdPrincipalGroupMembership -Identity $Leaver | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $Leaver


#Disables the Account in Active Directory.
Disable-ADAccount -Identity $Leaver


##End all PS Sessions
Get-PSSession | Remove-PSSession

##All steps complete
Write-Host "All steps have been completed for the leaver, please continue to shutdown there accounts in NS / OA"
Set-ExecutionPolicy Restricted