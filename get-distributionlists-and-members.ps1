#connect to exchange online
connect-exchangeonline
# CSV file export path
$Csvfile = "C:\temp\ExportDGs.csv"

# Get all distribution groups
#$Groups = Get-DistributionGroup -ResultSize Unlimited
$Groups = Get-DistributionGroup -ResultSize Unlimited | Where-Object {$_.IsDirsynced -eq "True"} 

# Loop through distribution groups
$Groups | ForEach-Object {

    $GroupDN = $_.DistinguishedName
    $DisplayName = $_.DisplayName
    $PrimarySmtpAddress = $_.PrimarySmtpAddress
    $SecondarySmtpAddress = $_.EmailAddresses | Where-Object {$_ -clike "smtp*"} | ForEach-Object {$_ -replace "smtp:",""}
    $GroupType = $_.GroupType
    $RecipientType = $_.RecipientType
    $Members = Get-DistributionGroupMember $GroupDN -ResultSize Unlimited
    $ManagedBy = $_.ManagedBy
    $Alias = $_.Alias
    $HiddenFromAddressLists = $_.HiddenFromAddressListsEnabled
    $MemberJoinRestriction = $_.MemberJoinRestriction 
    $MemberDepartRestriction = $_.MemberDepartRestriction
    $RequireSenderAuthenticationEnabled = $_.RequireSenderAuthenticationEnabled
    $AcceptMessagesOnlyFrom = $_.AcceptMessagesOnlyFrom
    $GrantSendOnBehalfTo = $_.GrantSendOnBehalfTo
    $Notes = (Get-Group $GroupDN)

    # Create objects
    [PSCustomObject]@{
        DisplayName                        = $DisplayName
        PrimarySmtpAddress                 = $PrimarySmtpAddress
        SecondaryStmpAddress               = ($SecondarySmtpAddress -join ',')
        Alias                              = $Alias
        GroupType                          = $GroupType
        RecipientType                      = $RecipientType
        Members                            = ($Members.Name -join ',')
        MembersPrimarySmtpAddress          = ($Members.PrimarySmtpAddress -join ',')
        ManagedBy                          = $ManagedBy.Name
        HiddenFromAddressLists             = $HiddenFromAddressLists
        MemberJoinRestriction              = $MemberJoinRestriction 
        MemberDepartRestriction            = $MemberDepartRestriction
        RequireSenderAuthenticationEnabled = $RequireSenderAuthenticationEnabled
        AcceptMessagesOnlyFrom             = ($AcceptMessagesOnlyFrom.Name -join ',')
        GrantSendOnBehalfTo                = $GrantSendOnBehalfTo.Name
        Notes                              = $Notes.Notes
    }

# Export report to CSV file
} | Sort-Object DisplayName | Export-CSV -Path $Csvfile -NoTypeInformation -Encoding UTF8 #-Delimiter ";"
