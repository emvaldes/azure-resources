### Installing PowerShell

#### **1. Install PowerShell on MacOS**
1. Install Azure-CLI via homebre:
  ```bash
  devops: ~ $ brew install azure-cli ;
  ==> Downloading https://ghcr.io/v2/homebrew/core/azure-cli/manifests/2.67.0_1
  ==> Fetching azure-cli
  ==> Downloading https://ghcr.io/v2/homebrew/core/azure-cli/blobs/sha256:d3e3bd91ea0f07d99006d5132ca8c7d4d2e393ec45bb1090e3a0821b5b7d9ee3
  ==> Pouring azure-cli--2.67.0_1.sonoma.bottle.tar.gz
  ==> Caveats
  Bash completion has been installed to:
     /usr/local/etc/bash_completion.d
  ==> Summary
  🍺  /usr/local/Cellar/azure-cli/2.67.0_1: 24,350 files, 578.2MB
  ==> Running `brew cleanup azure-cli`...
  Disable this behaviour by setting HOMEBREW_NO_INSTALL_CLEANUP.
  Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).
  ```

#### **2. Install PowerShell on Linux**
The Az PowerShell module requires PowerShell to be installed on your system. Here's how to install PowerShell based on your Linux distribution:

#### **Ubuntu/Debian**
1. Update package lists:
  ```bash
  sudo apt update
  ```
2. Install prerequisites:
  ```bash
  sudo apt install -y wget apt-transport-https software-properties-common
  ```
3. Import the Microsoft GPG key:
  ```bash
  wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
  ```
4. Add the Microsoft PowerShell repository:
  ```bash
  sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-focal-prod focal main"
  ```
5. Install PowerShell:
  ```bash
  sudo apt update
  sudo apt install -y powershell
  ```
6. Start PowerShell:
  ```bash
  pwsh
  ```

#### **CentOS/RHEL/Fedora**
1. Import the Microsoft GPG key:
  ```bash
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  ```
2. Add the Microsoft PowerShell repository:
  ```bash
  sudo tee /etc/yum.repos.d/microsoft.repo <<EOF
[microsoft]
name=Microsoft PowerShell
baseurl=https://packages.microsoft.com/yumrepos/microsoft-rhel8-prod
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
  ```
3. Install PowerShell:
  ```bash
  sudo dnf install -y powershell
  ```
4. Start PowerShell:
  ```bash
  pwsh
  ```

---

#### **3. Install the Az PowerShell Module**
Once PowerShell is installed, use the following steps to install the Az PowerShell module:

1. Open PowerShell:
  ```bash
  pwsh
  ```

2. Install the Az module:
  ```powershell
  Install-Module -Name Az -AllowClobber -Scope CurrentUser
  ```
  - **`-AllowClobber`**: Allows overwriting of cmdlets if there are conflicts.
  - **`-Scope CurrentUser`**: Installs the module for the current user without requiring elevated permissions.

3. Import the Az module:
  ```powershell
  Import-Module Az
  ```

4. Verify installation:
  ```powershell
  Get-Module -Name Az -ListAvailable
  ```
  You should see details about the installed Az module.

---

#### **4. Authenticate with Azure**
To start managing Azure resources, authenticate using:

```powershell
Connect-AzAccount
```
Follow the instructions to log in to your Azure account.

---

#### **5. (Optional) Update the Az Module**
To ensure you have the latest version of the Az module:

```powershell
Update-Module -Name Az
```

---

#### **6. Troubleshooting**
- **Missing Permissions:** If you encounter permission issues, run PowerShell with `sudo` and install the module globally:
  ```powershell
  Install-Module -Name Az -AllowClobber -Scope AllUsers
  ```
- **Firewall Issues:** Ensure your system can access Azure endpoints over HTTPS (port 443).
