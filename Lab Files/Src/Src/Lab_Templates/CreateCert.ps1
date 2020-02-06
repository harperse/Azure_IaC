$cert = New-SelfSignedCertificate -CertStoreLocation "cert:\CurrentUser\My" `
  -Subject "CN=ASD-ServicePrincipal" `
  -KeySpec KeyExchange
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

$PfxCertPath = 'C:\Users\jeberhow\OneDrive - Microsoft\Git\Solutions.Azure.WorkshopPLUS.InfraAsCode\Src\Lab_Templates\ASD-ServicePrincipal.pfx'
$CertificatePassword = 'Cosmic123$'

$flags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable `
    -bor [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet `
    -bor [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet
# Load the certificate into memory
$PfxCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($PfxCertPath, $CertificatePassword, $flags)
# Export the certificate and convert into base 64 string
$Base64Value = [System.Convert]::ToBase64String($PfxCert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12))
openssl pkcs12 -in $PfxCertPath -out c:\certs\cert1.pem -nodes -password pass:Cosmic123$