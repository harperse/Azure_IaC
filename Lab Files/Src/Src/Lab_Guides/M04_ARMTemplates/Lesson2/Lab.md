# Module 4 - Lesson 2

## Prerequisites:
   - Install Visual Studio Code
     - [Windows](https://code.visualstudio.com/docs/setup/windows)
     - [macOS](https://code.visualstudio.com/docs/setup/mac)
     - [Linux](https://code.visualstudio.com/docs/setup/linux)
   - Install PowerShell
     - [Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell)
     - [macOS](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos)
     - [Linux](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux)
   - [Install the Azure PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps)

## Install Extensions
1. Launch Visual Studio Code
1. Open the Extensions view
   1. Windows/Linux: `Ctrl+Shift+X`
   1. macOS: `Shift+⌘+X`
1. Install [Azure Resource Manager Tools](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools)

     ![Azure Resource Manager Tools](media/Extensions.ARMTools.png)

1. Install [Azure Resource Manager Snippets](https://marketplace.visualstudio.com/items?itemName=samcogan.arm-snippets)

     ![Azure Resource Manager Snippets](media/Extensions.ARMSnippets.png)

## Create a new ARM template file
1. Create a new file named M04Lesson2.template.json
1. Open the file in Visual Studio Code
1. Type `arm!` and press `Enter` to insert the ARM template skeleton code snippet

     ![ARM template skeleton](media/ARMTemplate.Skeleton.png)

     ![ARM template skeleton completed](media/ARMTemplate.SkeletonCompleted.png)

1. **NOTE:** If IntelliSense does not popup or if hitting enter does not insert the block of code, you can trigger IntelliSense by pressing `Ctrl+Space` on Windows/Linux or `⌃+Space` on macOS

## Add parameters to the ARM template
1. Move your cursor in between the `{}` brackets on the line containing `"parameters": {},` and press `Enter` to create a new line
1. Type `arm-parameter` and press `Enter` to insert a new parameter snippet

     ![ARM parameter](media/ARMTemplate.Parameter.png)

     ![ARM parameter completed](media/ARMTemplate.ParameterCompleted.png)

1. Change `"parameterName"` to `"environment"`
1. Set the `"description"` value to `"Environment (Dev/QA/Prod)"`

     ![ARM environment parameter](media/ARMTemplate.EnvironmentParameter.png)

1. Add four additional parameters with a description of your choice. (**NOTE:** you will need to add a `,` after the closing `}` for each parameter block except the final parameter)
   1. `"projectName"`
   1. `"vNetAddressRange"`
   1. `"subnet1AddressRange"`
   1. `"subnet2AddressRange"`

     ![ARM parameters completed](media/ARMTemplate.AllParametersCompleted.png)

## Add variables to the ARM template
1. Move your cursor in between the `{}` brackets on the line containing `"variables": {},` and press `Enter` to create a new line
1. Type `arm-variable` and press `Enter` to insert a new variable snippet

     ![ARM variable](media/ARMTemplate.Variable.png)

     ![ARM variable completed](media/ARMTemplate.VariableCompleted.png)

1. Change `"variableName"` to `"vNetName"`
1. Change `"variableValue"` to `"[concat(parameters('projectName'), '-', parameters('environment'), '-VNet')]"`
   1. **NOTE:** Use IntelliSense to write this more efficiently
   1. Completely remove `"variableValue"` and start with a new `"`. Notice how Visual Studio Code automatically converts this to `""`
   1. Add a `[` and IntelliSense should present you with a list of functions. If it does not, you can trigger IntelliSense by pressing `Ctrl+Space` on Windows/Linux or `⌃+Space` on macOS
   1. Pick the `concat` function
   1. Now add the `parameters` function and notice how IntelliSense populates a list of available parameters
   1. Continue using IntelliSense to complete the variable value
1. Add another variable named `"subnetNamePrefix"` with a value of `"[concat(parameters('projectName'), parameters('environment'), '-Subnet-')]"`

     ![ARM variables completed](media/ARMTemplate.AllVariablesCompleted.png)

## Add a Virtual Network resource to the ARM template
1. Move your cursor in between the `[]` brackets on the line containing `"resources": [],` and press `Enter` to create a new line
1. Type `arm-vn` and press `Enter` to insert a new variable snippet
1. Change the values of `"name"` and `"displayName"` from `"VirtualNetwork1"` to `"[variables('vNetName')]"`
1. Change the value of `"addressPrefixes"` under the `"addressSpace"` property from `"10.0.0.0/16"` to `"[parameters1'vNetAddressRange')]"`
1. Change the value of `"name"` for the first subnet object from `"Subnet-1"` to `"[concat(variables('subnetNamePrefix'), '11"`
1. Change the value of `"addressPrefix"` for the first subnet object from `"10.0.0.0/24"` to `"[parameters1'subnet1AddressRange')]"`
1. Update the second subnet object accordingly

     ![ARM resource completed](media/ARMTemplate.ResourceCompleted.png)

## Create a new ARM parameters file
1. Create a new file named M04Lesson2.parameters.json
1. Open the file in Visual Studio Code
1. Type `armp!` and press `Enter` to insert the ARM parameters skeleton code snippet

     ![ARM parameters skeleton completed](media/ARMParameters.SkeletonCompleted.png)

## Add parameters to the ARM parameters file
1. Move your cursor in between the `{}` brackets on the line containing `"parameters": {},` and press `Enter` to create a new line
1. Type `arm-paramvalue` and press `Enter` to insert a new parameter value snippet
1. Change `"parameterName"` to `"environment"`
1. Set `"value"` to `"Dev"`

     ![ARM environment parameter value](media/ARMParameters.EnvironmentParameter.png)

1. Add the remaining parameters with the following values
   1. `"projectName"` = `"M04Lesson2"`
   1. `"vNetAddressRange"` = `"10.0.0.0/16"`
   1. `"subnet1AddressRange"` = `"10.0.0.0/24"`
   1. `"subnet2AddressRange"` = `"10.0.1.0/24"`

     ![ARM parameters file completed](media/ARMParameters.AllParametersCompleted.png)

## Deploy the ARM template file with the parameters file
1. Open PowerShell
1. Change directories to the folder containing the ARM template and parameters files
1. Run the following PowerShell commands to deploy the template

```PowerShell
Import-Module Az
Add-AzAccount
New-AzResourceGroupDeployment -Name 'M04Lesson2' -ResourceGroupName 'YOUR_RG_HERE' -TemplateFile '.\M04Lesson2.template.json' -TemplateParameterFile '.\M04Lesson2.parameters.json' -Mode Incremental
```

## Inspect the deployed Virtual Network
1. Open the Azure Portal
1. Navigate to the resource group
1. Open the `M04Lesson2-Dev-VNet` virtual network
1. Notice the virtual network name and tag changed from `"[concat(parameters('projectName'), '-', parameters('environment'), '-VNet')]"` to `M04Lesson2-Dev-VNet`
1. Review the other virtual network properties and see how the template functions changed after deployment