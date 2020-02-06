Param(
    [Parameter (Mandatory= $true)]
    [string] $VmName,

    [Parameter (Mandatory= $true)]
    [string] $ResourceGroupName,

    [Parameter (Mandatory= $true)]
    [string] $AutomationAccountName

    )

Disable-AzContextAutosave -Scope Process
$Connection = Get-AutomationConnection -Name 'AzureRunAsConnection'
Connect-AzAccount -ServicePrincipal `
                  -Tenant $Connection.TenantID `
                  -ApplicationId $Connection.ApplicationId `
                  -CertificateThumbprint $Connection.CertificateThumbprint

Select-AzSubscription -SubscriptionId $Connection.SubscriptionId

$VnetName = Get-AzAutomationVariable -Name 'NetworkName' `
                                     -ResourceGroupName (Get-AzResourceGroup).ResourceGroupName `
                                     -AutomationAccountName $AutomationAccountName  
$LocationName = (Get-AzResourceGroup).Location
$VMSize = "Standard_DS3"
$NICName = "MyNIC"
$SubnetName = "MySubnet"
$SubnetAddressPrefix = "10.0.0.0/24"
$VnetAddressPrefix = "10.0.0.0/16"

$SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName `
                                                 -AddressPrefix $SubnetAddressPrefix
$Vnet = New-AzVirtualNetwork -Name $VnetName `
                             -ResourceGroupName $ResourceGroupName `
                             -Location $LocationName `
                             -AddressPrefix $VnetAddressPrefix `
                             -Subnet $SingleSubnet
$NIC = New-AzNetworkInterface -Name $NICName `
                              -ResourceGroupName $ResourceGroupName `
                              -Location $LocationName `
                              -SubnetId $Vnet.Subnets[0].Id

$Credential = Get-AutomationPSCredential -Name 'LocalAdmin'

$VirtualMachine = New-AzVMConfig -VMName $VMName `
                                 -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine `
                                          -Windows `
                                          -ComputerName $VmName `
                                          -Credential $Credential `
                                          -ProvisionVMAgent `
                                          -EnableAutoUpdate
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine `
                                           -Id $NIC.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine `
                                      -PublisherName 'MicrosoftWindowsServer' `
                                      -Offer 'WindowsServer' `
                                      -Skus '2012-R2-Datacenter' `
                                      -Version latest
                

New-AzVM -ResourceGroupName $ResourceGroupName `
         -Location $LocationName `
         -VM $VirtualMachine `
         -Verbose