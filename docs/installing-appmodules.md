# Installing App Modules Function

## Overview
The **`installing-appmodules`** function is responsible for ensuring that all required system and PowerShell modules are installed for the Azure Resources Management project. It handles platform-specific dependencies, such as installing the `libgdiplus` library for Unix-based systems, and ensures that PowerShell modules like `PSWriteExcel` and `ImportExcelPlus` are available.

---

## Key Features

- **Cross-Platform Support**: Detects the operating system and installs dependencies accordingly.
- **PowerShell Module Installation**: Ensures required PowerShell modules are installed.
- **Dependency Management**: Automates installation of `libgdiplus` for Unix systems using Homebrew or APT.
- **Error Handling**: Provides robust error messages for installation issues.

---

## Prerequisites

Before using this function, ensure the following:

1. **System Permissions**:
   - Administrative or superuser privileges for installing system dependencies.
2. **Homebrew**:
   - Required on macOS to install `libgdiplus`.
3. **Internet Access**:
   - Necessary to download PowerShell modules from the PowerShell Gallery.
4. **PowerShell Version**:
   - Compatible with both Windows and Unix-based systems.

---

## Parameters

### Input Parameters

- **`$System`** *(string)*:
  - The name of the operating system (e.g., `Darwin`, `Linux`).

---

## Workflow

### 1. **Platform Detection and System Dependency Installation**
   - **macOS (`Darwin`)**:
     - Checks if Homebrew is installed.
     - Installs the `mono-libgdiplus` package using Homebrew.
   - **Linux**:
     - Installs the `libgdiplus` package using APT (`sudo apt-get install --yes libgdiplus`).
   - **Other Platforms**:
     - Logs a warning message for unsupported platforms.

### 2. **PowerShell Module Installation**
   - Iterates through the required modules (`PSWriteExcel`, `ImportExcelPlus`).
   - Checks if each module is already installed using `Get-Module -ListAvailable`.
   - If missing, installs the module using `Install-Module` with the `-Scope CurrentUser` flag.

### 3. **Error Handling**
   - Captures errors during system or module installation.
   - Logs detailed error messages for troubleshooting.

---

## Example Usages

### Example 1: Install Dependencies on macOS
```powershell
# Call the function for macOS
installing-appmodules -System "Darwin"

# Output:
# > brew install mono-libgdiplus
# PSWriteExcel modules were installed successfully.
```

### Example 2: Install Dependencies on Linux
```powershell
# Call the function for Linux
installing-appmodules -System "Linux"

# Output:
# > sudo apt-get install --yes libgdiplus
# PSWriteExcel modules were installed successfully.
```

### Example 3: Unsupported Platform
```powershell
# Call the function with an unsupported platform
installing-appmodules -System "Windows"

# Output:
# Unknown platform detected. Check dependencies.
```

---

## Dependencies and Linked Components

### Functions
- **[catching-errors](./catching-errors)**: Handles exceptions during module installation.

### Modules
- **`PSWriteExcel`**: Required for Excel-related operations.
- **`ImportExcelPlus`**: Enhances Excel import/export capabilities.

---

## Error Handling

- **System Dependency Errors**: Logs errors when Homebrew or APT commands fail.
- **PowerShell Module Errors**: Captures and logs issues during PowerShell module installations.
- **Unsupported Platforms**: Provides clear warnings for unsupported operating systems.

---

## Notes

- Ensure that Homebrew is installed on macOS before running the function.
- For Linux, the function assumes `apt-get` is available for package installation.
- Additional modules can be added to the `$Modules` array for installation as needed.

---

## Additional Resources

- [PowerShell Install-Module Documentation](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/install-module)
- [Homebrew Documentation](https://brew.sh/)
- [APT Package Manager Documentation](https://linux.die.net/man/8/apt-get)
