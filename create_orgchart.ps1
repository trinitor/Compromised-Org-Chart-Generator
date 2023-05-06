param (
    [string]$OutputFile = ".\cypher.txt",
    [string]$CompromisedUsersFile = ".\Users_Compromised.csv"
)

Write-Host "### Get All Enabled User Accounts"
$AllUsers = Get-ADUser -LDAPFilter '(!userAccountControl:1.2.840.113556.1.4.803:=2)' -Properties SamAccountName,Department | Select SamAccountName,Department

Write-Host "### Get Manager Information For All Enabled User Accounts"
$Managers = Get-ADUser -LDAPFilter '(!userAccountControl:1.2.840.113556.1.4.803:=2)' -Properties SamAccountName,Manager | select SamAccountName,@{N='Manager';E={(Get-ADUser $_.Manager).sAMAccountName}} 

Write-Host "### Read Compromised User Accounts From File (Format: SamAccountName)"
if (Test-Path $CompromisedUsersFile) {
  $CompromisedUsers = Import-Csv -Path $CompromisedUsersFile -Header "SamAccountName"
} else {
  $CompromisedUsers = "" 
}

Write-Host "### Compare All User Accounts Objects with Compromised User Account Objects"
$ComparedCompromised = Compare-Object -ReferenceObject $AllUsers -DifferenceObject $CompromisedUsers -Property SamAccountName -PassThru -IncludeEqual

Write-Host "### Generate Status Property For Each User Account"
$Users = @()
ForEach($Result in $ComparedCompromised)
{
    If($Result.SideIndicator -eq "==") #SamAccountName exists in all enabled users and in the compromised user list = risk
    {
        $Result | Add-Member -NotePropertyName "Status" -NotePropertyValue "Risk"
        $Users += $Result
    }  
    If($Result.SideIndicator -eq "=>") #SamAccountName exists in compromised user list, but not in all users = account disabled = no risk = hide
    {
        $Result | Add-Member -NotePropertyName "Status" -NotePropertyValue "Disabled"
        $Users += $Result
    }              
    If($Result.SideIndicator -eq "<=") #SamAccountName exists in all enabled users and is not compromised = safe
    {
        $Result | Add-Member -NotePropertyName "Status" -NotePropertyValue "Safe"
        $Users += $Result
    }   
}

Write-Host "### Generate Cypher Statments"
Write-Host "# Delete Output File"
if (Test-Path $Outputfile) {
  Remove-Item $Outputfile
}
Write-Host "# Create User Account Nodes"
ForEach($User in $Users) 
{
    If ($User.SamAccountName)  {
        $SamAccountName=$User.SamAccountName.replace('.','_')
        $Department=$User.Department
        $Status=$User.Status
        $CypherStatement = "CREATE (${SamAccountName}:${Status} {name:'${SamAccountName}', department:'${Department}'})"
        $CypherStatement | Out-File -FilePath $Outputfile -Append
    }
}
Write-Host "# Create Manager Relationships"
ForEach($ManagerRelation in $Managers) 
{
    If ($ManagerRelation.Manager) 
    {
        $SamAccountName=$ManagerRelation.SamAccountName.replace('.','_')
        $Manager=$ManagerRelation.Manager.replace('.','_')
        $CypherStatement = "CREATE (${Manager})-[:MANAGER_OF ]->(${SamAccountName})"
        $CypherStatement | Out-File -FilePath $Outputfile -Append
    }
}

if (Test-Path $Outputfile) {
  Write-Host "$Outputfile created"
}