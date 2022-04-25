## Use the below code to make changes it will connect to Teams and run anything below this line. 
Import-Module MicrosoftTeams
Connect-MicrosoftTeams
##put amendments below this line, if you re-use a number it will assign it to the new user and remove it from the old. 
#Use -LineURI going forward ! 

Grant-CsOnlineVoiceRoutingPolicy -Identity "Mike.Oram@eunomia.co.uk" -PolicyName "No Restrictions”
Set-CsUser -Identity "Mike.Oram@eunomia.co.uk" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -LineURI tel:+441174400947


## This will get you all numbers currently assigned and spit them into a CSV on your C: drive. 
get-csonlineuser | select DisplayName,UserPrincipalName,LineURI | Sort-Object -Property DisplayName | export-csv -path C:\TeamsNumbers.csv -notypeinformation