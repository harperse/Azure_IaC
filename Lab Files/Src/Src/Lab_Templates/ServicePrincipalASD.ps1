Connect-AzAccount
Get-AzSubscription |Out-GridView -PassThru |  Select-AzSubscription 

$cert = New-SelfSignedCertificate -CertStoreLocation "cert:\CurrentUser\My" `
  -Subject "CN=exampleappScriptCert" `
  -KeySpec KeyExchange
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
$secret = ConvertTo-SecureString -string $keyValue -AsPlainText -Force 
$Principal = New-AzADServicePrincipal -DisplayName "ASD_AutomationPrincipal" `
    -CertValue $keyValue `
    -EndDate $cert.NotAfter `
    -StartDate $cert.NotBefore

Set-AzContext -SubscriptionId 'cd5624ee-c42c-4f43-9c6d-4aea23072cf3'
New-AzKeyVault -Name 'ASD-AutomationKeys-Dev' `
               -ResourceGroupName 'Cloud-Slice-Resources' `
               -Location 'East US' `
               -EnabledForTemplateDeployment

Set-AzKeyVaultSecret -VaultName 'ASD-AutomationKeys-Dev' `
                     -Name 'CertThumb' `
                     -SecretValue $secret

Set-AzKeyVaultSecret -VaultName 'ASD-AutomationKeys-Dev' `
                     -Name 'AppId' `
                     -SecretValue (ConvertTo-SecureString -String $Principal.ApplicationId -AsPlainText -Force)

Set-AzKeyVaultSecret -VaultName 'ASD-AutomationKeys-Dev' `
                     -Name 'TenantId' `
                     -SecretValue (ConvertTo-SecureString -String ((Get-AzContext).Tenant.Id) -AsPlainText -Force)

Set-AzKeyVaultSecret -VaultName 'ASD-AutomationKeys-Dev' `
                     -Name 'SubId' `
                     -SecretValue (ConvertTo-SecureString -String 'cd5624ee-c42c-4f43-9c6d-4aea23072cf3' -AsPlainText -Force)
