#connect to the new office 365 tenant
Connect-ExchangeOnline

#specify what to append to alias
#import groups
$groups = import-csv -path "C:\temp\ExportDGs.csv" 

#loop through groups for creation
foreach($group in $groups){

    #determine group type and create a new group
    if($group.grouptype -match "Security"){
        $group.grouptype = "Security"
    }
    else{
        $group.grouptype = "Distribution"
    }

    #convert sender authentication to be $true or $false 
    #create new DL
    if($group.requireSenderAuthenticationEnabled -eq "True"){
        $dl = new-distributiongroup -name $group.DisplayName -alias $group.alias -requireSenderAuthenticationEnabled $true -type $group.grouptype -PrimarySmtpAddress $group.PrimarySmtpAddress

    }
    else{
        $dl = new-distributiongroup -name $group.DisplayName -alias $group.alias -requireSenderAuthenticationEnabled $false -type $group.grouptype -PrimarySmtpAddress $group.PrimarySmtpAddress
    }

    #split members into array
    $members = $group.MembersPrimarySmtpAddress.split(",")

    #add members to new DL
    foreach($member in $members){
        get-mailbox -Identity $member
        add-distributiongroupmember -identity $dl.exchangeguid -member $member
    }

    $managers = @()
    #$managers += (get-connectioninformation).UserPrincipalName[0]
    $ManagedBy = $groups.ManagedBy -split ',' 
    #add managers to new dl
    foreach($manager in $ManagedBy){
        $managers += (get-mailbox -Identity $manager).primarysmtpaddress 
        }
    set-distributiongroup -identity $dl.exchangeguid -managedby $managers
}

