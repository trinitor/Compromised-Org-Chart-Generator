Write-Host "### Install RSAT Tools"
Import-Module ServerManager
Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter

Write-Host "### Disable Password Complexity"
secedit /export /cfg C:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
rm -force C:\secpol.cfg -confirm:$false

Write-Host "### Change local Administrator password to vagrant"
$computerName = $env:COMPUTERNAME
$adminPassword = "vagrant"
$adminUser = [ADSI] "WinNT://$computerName/Administrator,User"
$adminUser.SetPassword($adminPassword)

Write-Host "### Install ADDS"
Install-WindowsFeature AD-domain-services

Write-Host "### Create Forest"
$PlainPassword = "vagrant" 
$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force

Import-Module ADDSDeployment
Install-ADDSForest `
  -SafeModeAdministratorPassword $SecurePassword `
  -CreateDnsDelegation:$false `
  -DatabasePath "C:\Windows\NTDS" `
  -DomainMode "7" `
  -DomainName "contoso.local" `
  -DomainNetbiosName "CONTOSO" `
  -ForestMode "7" `
  -InstallDns:$true `
  -LogPath "C:\Windows\NTDS" `
  -NoRebootOnCompletion:$true `
  -SysvolPath "C:\Windows\SYSVOL" `
  -Force:$true
