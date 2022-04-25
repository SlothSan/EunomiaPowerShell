# Use this script to Restore Files Deleted in a Specific Project Folder by a User 
# Manually change the Project Name, email and date on the lines below (Note the date is American Format)
# The script will search the Recycle bin for all files deleted by the user Greater than the date specified and then loop through them in batches of 200 for Restores. 
# Author Mike Ora

Install-Module SharePointPnPPowerShellOnline

$siteUrl = "https://eunomiacouk.sharepoint.com/sites/EunomiaDrive/"
Connect-PnPOnline -Url $siteUrl
# Change the Project name leaving the *'s as they are needed to wildcard the directory, amend the Email and the date deleted. 
$RestoreSet = Get-PnPRecycleBinItem -RowLimit 150000 | Where-Object {$_.DirName -Like '*/DG Env - 3345 Packaging waste directive - OPP002580/*' -and $_.DeletedByEmail -eq "sarah.edwards@eunomia-inc.com" -and $_.DeletedDate -gt "10/18/2021"}
$RestoreSet.Count
$RestoreFiltered = $RestoreSet
$RestoreFiltered.Count
$RestoreFileSorted = $RestoreFiltered #| ? {$_.ItemType -eq "File"} | sort DirName, LeafName
$RestoreFileSorted.Count



# Batch restore up to 200 at a time
$restoreList = $RestoreFileSorted | Select-Object Id, ItemType, LeafName, DirName
$apiCall = $siteUrl + "/_api/site/RecycleBin/RestoreByIds"
$restoreListCount = $restoreList.count
$start = 0
$leftToProcess = $restoreListCount - $start
while($leftToProcess -gt 0){
    If($leftToProcess -lt 1){$numToProcess = $leftToProcess} Else {$numToProcess = 1}
    Write-Host -ForegroundColor Yellow "Building statement to restore the following $numToProcess files"
    $body = "{""ids"":["
    for($i=0; $i -lt $numToProcess; $i++){
        $cur = $start + $i
        $curItem = $restoreList[$cur]
        $Id = $curItem.Id
        Write-Host -ForegroundColor Green "Adding ", $curItem.ItemType, ": ", $curItem.DirName, "//", $curItem.LeafName
        $body += """" + $Id + """"
        If($i -ne $numToProcess - 1){ $body += "," }
    }
    $body += "]}"
    Write-Host -ForegroundColor Yellow $body
    Write-Host -ForegroundColor Yellow "Performing API Call to Restore items from RecycleBin..."
    try {
        Invoke-PnPSPRestMethod -Method Post -Url $apiCall -Content $body | Out-Null
    }
    catch {
        Write-Error "Unable to Restore"     
    }
    $start += 1
    $leftToProcess = $restoreListCount - $start
}

