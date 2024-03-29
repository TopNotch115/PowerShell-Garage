#Create a new mailbox and AD user, specifying mailboxDB, OU path, and groups. #Auth:Nicholas Spaugh

#Servers
$DomainController = "Enter Domain Controller Server FQDN"
 $ExchangeDataBase = "Enter Exchange DAG name"
#Only input First,Last,Rank,Edipi,billet, and groups
#Don't change anything else unless user needs to be in different mailbox database or OU
$First = 'John'
$last = 'Doe'
$rank = 'Pvt'
$Edipi = "1234567891"
$billet = '20.2 CE KWT - Test'
$OrganizationalUnit = "Enter OU Location Eg = OU=Users,OU=CE,OU=SPMAGTF-KPOP,OU=MEIN User Catalog,DC=mc,DC=com"


#If Above information is correct, run the script. 
$Alias = $First,$last -join '.'
$Name = $last,$rank,$First -join ' '
#The password being shown here in clear text doesn't matter since the script will enable the 'require smartcard loggin' option which will scramble the password inputted here
$password = Read-Host "1qaz2wsx!QAZ@WSX" -AsSecureString 

#creates mailbox and 
New-Mailbox -DomainController $DomainController -UserPrincipalName $Edipi@mil -Alias $Alias -Database $ExchangeDataBase -Name $name -OrganizationalUnit $OrganizationalUnit -Password $password -FirstName $first -LastName $last -DisplayName $name -ResetPasswordOnNextLogon $false -SamAccountName $Alias 

#The script will be paused for 20 seconds to allow the exchange controller to write to a domain controller and for it to reflect 
Start-Sleep -s 10

#Getting the newly created AD user and setting the billet, and requiring smartcard logon 
Get-ADUser $Alias |Set-ADUser -Description $billet -SmartcardLogonRequired $true 
#adding the created AD user to specified groups
Add-ADGroupMember -Identity 'ShareDriveAccess' -Members $Alias 
#Takes rank input and adds user to appropiate group
if(($rank -eq "Pvt") -or ($rank -eq"PFC") -or ($rank -eq"LCpl") -or ($rank -eq"Cpl") -or ($rank -eq"Sgt") -or ($rank -eq "HA") -or ($rank -eq"HN") -or ($rank -eq"HM3") -or ($rank -eq"HM2")){
    Add-ADGroupMember -Identity 'GP Management' -Members $Alias

}elseif(($rank -eq "SSgt") -or ($rank -eq "GySgt") -or ($rank -eq "MSgt") -or ($rank -eq "MGySgt") -or ($rank -eq "1stSgt") -or ($rank -eq "SgtMaj") -or ($rank -eq "HMC") -or ($rank -eq "SCPO") -or ($rank -eq "HMCS") -or ($rank -eq "HMCM")){
    Add-ADGroupMember -Identity 'Management Officers' -Members $Alias

}elseif(($rank -eq "2ndLt") -or ($rank -eq "1stLt") -or ($rank -eq "Capt") -or ($rank -eq "Maj") -or ($Rank -eq "LtCol") -or ($rank -eq "Col") -or ($rank -eq "WO") -or ($rank -eq "CWO2") -or ($rank -eq "CWO3") -or ($rank -eq "CWO4") -or ($rank -eq "CWO5") -or ($rank -eq "LT") -or ($rank -eq "LCDR") -or ($rank -eq "LTJG") -or ($rank -eq "CDR")){
    Add-ADGroupMember -Identity 'Management VIP' -Members $Alias

}else{
    Write-Host "Rank Format Incorrect" 
}
