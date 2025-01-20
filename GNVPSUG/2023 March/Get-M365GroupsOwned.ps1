<#
.Synopsis
   Display modern groups owned by a user.
.DESCRIPTION
   Display modern groups (Office 365 Group, Microsoft Team, Planner, Yammer, etc.) of which the user is an owner.
.EXAMPLE
   Get-M365GroupsOwned -Username SomeAccount

   DisplayName                      Name
    -----------                      ----
    Joe-Demo-Staff-Team              Group_9f695aaf-84fc-419d-ad4b-2873be13e74a
    Research Symposium 2021          Group_67909e5b-3f72-411f-84b4-e82581dd3d0f
    Tree Pop Model                   Group_6ebbf55d-3e8e-46c6-93cc-08d765005f30
    JUGA 2021                        Group_d35186c3-7d11-4cc6-b5b8-4670f2df540f

    Get modern groups owned by the user.

.EXAMPLE
    Get-M365GroupsOwned -Username SomeAccount | Where-Object DisplayName -like '*juga*'

    DisplayName      Name
    -----------      ----
    JUGA 2021        Group_98ec65bd-6585-490f-a13b-5cd5c3e2490b
    JUGA 2021 - DEMO Group_7020f88d-287d-4c15-82a7-008971b9412b
    JUGA 2020        Group_435ff4c5-03fb-4c6b-8641-9bd0b952f971
    JUGA 2020 - DEMO Group_02741799-42f6-46c3-9b35-fdcf35e941b7
    DEPT-JUGA-201... Group_03512c72-4539-4f3d-8158-d631a2cf2f3a

    Display modern groups owned by the user with specific string in the title.
#>
function Get-M365GroupsOwned
{
    [CmdletBinding(SupportsShouldProcess=$true,
                  PositionalBinding=$true)]
    [Alias()]
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $Username
    )

    Begin {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation")) {
            $User = Get-ADUser -Identity $Username -Properties MemberOf
            $M365Groups = $User | Select-Object MemberOf

            foreach ( $Group in $M365Groups.MemberOf ) {
                if ($Group -like 'CN=Group_*') {
                    $Owners = Get-ADGroup -Identity $Group -Properties msExchCoManagedByLink | Select-Object msExchCoManagedByLink -ExpandProperty msExchCoManagedByLink
                    if ( $Owners.Contains($User.DistinguishedName) ) {
                        Get-ADGroup $Group -Properties DisplayName | Select-Object DisplayName,Name
                    }
                }
            }
        }
    }
    End {
    }
}
