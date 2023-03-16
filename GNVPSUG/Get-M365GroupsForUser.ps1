<#
.Synopsis
   Microsoft 365 Group membership for a user or summary report
.DESCRIPTION
   Output a list of a user's modern group memberships (Teams, Yammer, Planner, Groups) or summary report
.EXAMPLE
   Get-365GroupsForUser -UserName pvenkman | sort DisplayName | select DisplayName,Description
.EXAMPLE
   Get-365GroupsForUser -UserName pvenkman -Report | Where-Object Owners -like "*rsantz*"
.EXAMPLE
   Get-365GroupsForUser -UserName pvenkman | select DisplayName,Created,Description | Export-Csv -Path .\Grps.csv -NoTypeInformation
.EXAMPLE
   Get-365GroupsForUser -UserName pvenkman -Report | Format-Table
.EXAMPLE
   Get-365GroupsForUser -UserName pvenkman -Report | Export-Csv -Path .\GrpsReport.csv -NoTypeInformation
#>
function Get-M365GroupsForUser
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $UserName,
        [switch]$Report
    )

    Begin
    {
        class InfoObject {
            [string]$DisplayName
            [string]$ShortName
            [string]$GroupId
            [datetime]$Created
            [int]$NumMembers
            [string]$Owners
            [string]$Description

            InfoObject($DisplayName, $ShortName, $GroupId, $Created, $NumMembers, $Owners, $Description) {
                $this.DisplayName = $DisplayName
                $this.ShortName = $ShortName
                $this.GroupId = $GroupId
                $this.Created = $Created
                $this.NumMembers = $NumMembers
                $this.Owners = $Owners
                $this.Description = $Description
            }
        }
    }
    Process
    {
    $Groups = ((Get-ADUser -Properties MemberOf -Identity $UserName).MemberOf).Where{$_ -match 'CN=Group_'}
    foreach ($Group in $Groups) {
        if ($Report.IsPresent) {
            $RptGrp = Get-ADGroup $Group -Properties DisplayName,mailNickname,Name,Created,msExchGroupMemberCount,msExchCoManagedByLink,Description
            $OwnersFQ = Get-ADGroup $Group -Properties msExchCoManagedByLink | Select-Object -ExpandProperty msExchCoManagedByLink
            $OwnersNames = foreach ($OwnerListed in $OwnersFQ) { $OwnerListed.Replace('CN=','').Split(',')[0] }
            $col1 = $RptGrp.DisplayName
            $col2 = $RptGrp.MailNickName
            $col3 = $RptGrp.Name.Replace('Group_','')
            $col4 = $RptGrp.Created
            $col5 = $RptGrp.msExchGroupMemberCount
            $col6 = $OwnersNames -join ';'
            $col7 = $RptGrp.Description

            [InfoObject]::new($col1, $col2, $col3, $col4, $col5, $col6, $col7)
        } else {
            Get-ADGroup $Group -Properties *
        }
    }
    }
    End
    {
    }
}
