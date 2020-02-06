# Windows Sub-Lab

## Install Visual Studio Code for Windows  

1. Launch Microsoft Edge and browse to the [Visual Studio Code for Windows](https://aka.ms/win32-x64-user-stable) page.

    ![download link](media/windows_vscode_01.png)

1. Click Run

    ![select run](media/windows_vscode_02.png)

1. Click Next to start the VSCode Setup Wizard

      ![select next](media/windows_vscode_03.png)

1. Accept the license agreement and click Next

      ![accept license agreement and select next](media/windows_vscode_04.png)

1. Verify/Change the installation folder and click Next

      ![confirm install location and select next](media/windows_vscode_05.png)

1. Verify/Change the Start Menu folder and click Next

      ![select start menu folder and select next](media/windows_vscode_06.png)

1. Select Additional Tasks and then click Next

      ![select additional tasks and select next](media/windows_vscode_07.png)

1. Click Next on the Ready to Install screen

      ![select install](media/windows_vscode_08.png)

1. Allow the installation of VSCode to complete

      ![install progress](media/windows_vscode_09.png)

1. Click Finish to exit the VSCode Setup Wizard

    ![select finish](media/windows_vscode_10.png)

## Install Node.js on Windows

1. Launch Microsoft Edge and browse to the [Node.js](https://nodejs.org) page.

    ![browse to nodejs.org](media/windows_nodejs_01.png)

1. Click the "Recommended for Most Users" version.  The version may differ from what is shown in the screenshot below.

    ![select recommended for most users](media/windows_nodejs_02.png)

1. Click Run

    ![select run](media/windows_nodejs_03.png)
  
1. Click Next to begin the Node.js Setup Wizard

    ![select next on initial setup screen](media/windows_nodejs_04.png)
  
1. Accept the license agreement and click Next

    ![select next on license agreement](media/windows_nodejs_05.png)

1. Click next on the Destination Folder screen

    ![select next on destination folder](media/windows_nodejs_06.png)
  
1. Click Next on the Custom Setup screen

    ![select next on custom setup](media/windows_nodejs_07.png)
  
1. Click Install on the Node.js Setup screen

    ![select install](media/windows_nodejs_08.png)
  
1. Click Yes on the User Account Control screen

    ![select yes to UAC](media/windows_nodejs_09.png)
  
1. Click Finish to exit the Setup Wizard

    ![select finish](media/windows_nodejs_10.png)

## Install VSCode Extensions on Windows

### Install the [Azure Account](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account) Extension  

> [!NOTE]
> On Windows, the Azure Account Extension requires that Node.js v6 or later be installed.
  
1. Launch VSCode type `Ctrl-Shift-X`
1. Type `Azure Account` in the search box
1. Click Install

    ![CTRL-SHIFT-X Azure Account select install](media/windows_extension_azure_account_01.png)  

### Install the [Ansible](https://marketplace.visualstudio.com/items?itemName=vscoss.vscode-ansible) Extension

> [!NOTE]
> This takes considerably longer to install than the Azure Account extension so be patient!

1. Launch VSCode and type `Ctrl-Shift-X`
1. Type `Ansible` in the search box
1. Click Install

    ![CTRL-SHIFT-X Ansible select install](media/windows_extension_ansible_01.png)

## Install the Windows Subsystem for Linux

> [!NOTE]
> These instructions will cover an apt based distro such as Ubuntu

1. Enable the Windows Subsystem for Linux optional feature

    1. Launch PowerShell as Administrator and run the following command

    ```PowerShell
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    ```

    1. Restart your computer when prompted.

1. Download the Ubuntu distro

    1. Launch PowerShell as Administrator and run the following commands

    ```Powershell
    Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.zip -UseBasicParsing
    ```

1. Extract the Ubuntu distro

     ```Powershell
    Expand-Archive ~/Ubuntu.zip ~/Ubuntu
    ```

1. Launch the Ubuntu distro

    ```Powershell
    ~/Ubuntu/ubuntu1804.exe
    ```

    > [!NOTE]
    > The initial launch will take several minutes!

1. Initialize the Ubuntu Distro

    1. You will be prompted for a new UNIX username
    1. You will then be prompted for a new UNIX password
    1. Retype the new UNIX password
    1. You should see a conformation that the password was updated successfully and be presented with a bash prompt

1. Upgrade the list of packages for the Ubuntu Distro

    ```bash
    sudo apt-get update
    ```

1. Install upgraded packages for the Ubuntu Distro

    ```bash
    sudo apt-get upgrade
    ```

1. Install pip

    ```bash
    sudo apt-get -y install python-pip python-dev libffi-dev libssl-dev
    ```

1. Install Ansible

    ```bash
    pip install ansible --user
    ```

1. Add the Ansible install location to PATH

    ```bash
    echo 'PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
    ```

1. Update PATH to include Ansible

    ```bash
    source .bashrc
    ```

1. Verify Ansible is installed correctly

    ```bash
    ansible --version
    ```

1. Configure VSCode to use WSL as an integrated Shell  

    1. Launch VSCode and press `F1`

    1. Type `Terminal:Select Default Shell` and press enter
  
          ![VSCode Default Terminal](media/windows_wsl_vscode_default_terminal_01.png)

    1. Select `WSL Bash C:\Windows\System32\wsl.exe`
  
          ![VSCode Default Terminal](media/windows_wsl_vscode_default_terminal_02.png)

    1. Press `Ctrl-` ` to launch a new WSL terminal within VSCode
  
          ![VSCode Default Terminal](media/windows_wsl_vscode_default_terminal_03.png)

## This completes this section of the lab

1. [Return to the Ansible Labs Outline](../README.md)