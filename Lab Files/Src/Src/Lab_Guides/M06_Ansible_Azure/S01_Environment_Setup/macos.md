# macOS Sub-Lab

## Installing VSCode on macOS

> [!NOTE]
> These steps will cover the installation via Homebrew. If you do not have Homebrew installed, you can find the installation  instructions [here](https://brew.sh)

1. Launch a terminal window by pressing `⌘-T`

    ![macos terminal](media/macos_vscode_01.png)

1. Update brew

    ```bash
    brew update
    ```

    ![update brew](media/macos_vscode_02.png)

1. Tap the Caskroom/Cask repository on GitHub using HTTPS

    ```bash
    brew tap caskroom/cask
    ```

    ![tap repository](media/macos_vscode_03.png)

1. Search all known Casks for VSCode

    ```bash
    brew search visual-studio-code
    ```

    ![search for vscode](media/macos_vscode_04.png)

1. Display information about the VSCode cask

    ```bash
    brew cask info visual-studio-code
    ```

    ![vscode cask info](media/macos_vscode_05.png)

1. Install VSCode

    ```bash
    brew cask install visual-studio-code
    ```

    ![install vscode](media/macos_vscode_06.png)

1. Verify VSCode was installed successfully

    ```bash
    code
    ```

    ![launch vscode](media/macos_vscode_07.png)

## Installing Node.js on macOS

> [!NOTE]
> These steps will cover installation via Homebrew. If you do not have Homebrew installed, you can find the installation instructions [here](https://brew.sh)

1. Launch a terminal window by pressing `⌘-T`

    ![macos terminal](media/macos_nodejs_01.png)

1. Update brew

    ```bash
    brew update
    ```

    ![update brew](media/macos_nodejs_02.png)

1. Install Node.js

    ```bash
    brew install node
    ```

    ![update brew](media/macos_nodejs_03.png)

1. Verify NodeJs was successfully installed

      ```bash
    node -v
    ```

    ![verify nodejs](media/macos_nodejs_04.png)

## Installing the VSCode Extensions on macOS

### Install the [Azure Account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account) Extension for VSCode

1. Launch a terminal window by pressing `⌘-T`

    ![macOS terminal](media/macos_extension_azure_account_01.png)

1. Install the Azure Account Extension

   ```bash
    code --install-extension ms-vscode.azure-account
    ```

    ![macOS terminal](media/macos_extension_azure_account_02.png)

1. Verify that the Azure Account Extension was installed

    ```bash
    code
    ```

    1. Select Extensions from the VSCode toolbar and verify that the Azure Account extension is enabled.

        ![select extensions](media/macos_extension_azure_account_03.png)

    1. Press `F1`, type `Azure: Sign In`, press `Return`

        ![launch Azure Account extension ](media/macos_extension_azure_account_04.png)

    1. Select the account associated with your Azure Subscription

        ![azure sign in](media/macos_extension_azure_account_05.png)

    1. Close the browser window that displays the successful sign on message

        ![close browser with sign in conformation](media/macos_extension_azure_account_06.png)

    1. Check the lower left corner of VSCode for Azure: followed by the account you signed in as.

        ![verify Azure sign in in VSCode](media/macos_extension_azure_account_07.png)

        > [!TIP]
        > Clicking the account name will bring up a list of subscriptions associated with that account

    1. Close VSCode

### Install the [Ansible](https://marketplace.visualstudio.com/items?itemName=vscoss.vscode-ansible) Extension for VSCode

1. Launch a terminal window by pressing `⌘-T`

    ![macos terminal](media/macos_extension_ansible_01.png)

1. Install the Ansible Extension.

    ```bash
    code --install-extension vscoss.vscode-ansible
    ```

    ![ubuntu install Ansible extension](media/macos_extension_ansible_02.png)

1. Verify that the Ansible Extension was installed successfully.

    ```bash
    code
    ```

    1. Select Extensions from the VSCode toolbar and verify that the Ansible extension is enabled.

        ![select extensions](media/macos_extension_ansible_03.png)

## This completes this section of the lab

1. [Return to the Ansible Labs Outline](../README.md)