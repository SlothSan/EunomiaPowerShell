# Use this script to Restore Files on Mass for a specific user using the variables below. 
# Manually change the email and date on the lines below (Note the date is American Format)
# The script will search the Recycle bin for all files deleted by the user Greater than the date specified and then loop through them in batches of 200 for Restores. 
# Author Mike Oram 



Install-Module SharePointPnPPowerShellOnline


$siteUrl = "https://eunomiacouk.sharepoint.com/sites/EunomiaDrive/"
Connect-PnPOnline -Url $siteUrl
#EDIT THE EMAIL ADDRESS OF THE USER WHO HAS DONE GOOFED AND THE DATE OF SAID GOOD ON THE LINE BELOW
$RestoreSet = Get-PnPRecycleBinItem -RowLimit 150000 | Where-Object {$_.DeletedByEmail -eq "sarah.edwards@eunomia-inc.com" -and $_.DeletedDate -gt "10/18/2021"}
$RestoreSet.Count
$RestoreFiltered = $RestoreSet
$RestoreFileSorted = $RestoreFiltered | Where-Object {$_.ItemType -eq "File"} | Sort-Object DirName, LeafName
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

