Import-Module ActiveDirectory

$DONE = 0
while ($DONE -ne 1) {
  Write-Host "### Create Objects"
  try {
    $password = "Vagrant1!" | ConvertTo-SecureString -AsPlainText -Force

    $Users = Import-Csv C:\vagrant\demo\import_userlist.csv -Delimiter ";"

    foreach ($User in $Users) {
      $Fistname = $User.Fistname
      $Lastname = $User.Lastname
      $Title = $User.Title
      $Department = $User.Department
      $Manager = $User.Manager
      if ([string]::IsNullOrEmpty($Manager)){
        $Manager = "Administrator"
      }

      New-ADUser `
        -Name "$Fistname $Lastname" `
        -SamAccountName "$Fistname.$Lastname" `
        -UserPrincipalName "$Fistname.$Lastname@contoso.local" `
        -GivenName $Fistname `
        -Surname $Lastname `
        -Department $Department `
        -Title $Title `
        -Manager $Manager `
        -AccountPassword (ConvertTo-secureString $password -AsPlainText -Force) `
        -ChangePasswordAtLogon $false `
        -Enabled $true
      Write-Host "The user account $Fistname.$Lastname is created." -ForegroundColor Cyan
    }

    $DONE = 1
  }
  catch {
    Write-Host "# Active Directory is not ready. Retrying"
    Start-Sleep 5
  }
}
