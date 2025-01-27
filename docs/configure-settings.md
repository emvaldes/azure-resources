# Configure Settings Function

## Overview
The **`configure-settings`** function orchestrates the setup and management of all necessary configuration files, directories, and runtime parameters for the Azure Resources Management project. It ensures application and user-specific settings are merged seamlessly, creating an operational environment tailored to the active script instance.

---

## Key Features

- **Dynamic Configuration Management**: Loads and merges application and user-specific configurations from JSON or YAML files.
- **Directory Setup**: Automatically creates necessary directories, such as logs, configs, and reports.
- **Environment Validation**: Ensures all required parameters (e.g., environment, platform) are properly initialized.
- **Configuration Overriding**: Dynamically updates configuration values based on runtime parameters.
- **Error Handling**: Captures and logs errors during the setup process.

---

## Prerequisites

Before using this function, ensure the following:

1. **Configuration Files**:
   - Application configurations (`app-configs.json` or `app-configs.yaml`) are available in the project directory.
   - User configurations (`user-configs.json` or `user-configs.yaml`) are optional but enhance functionality.
2. **Required Functions**:
   - `loading-configfiles`: For loading JSON or YAML configuration files.
   - `catching-errors`: For error handling during the configuration process.

---

## Parameters

The function does not accept explicit input parameters but relies on the following global variables:

- **`$ScriptInfo`**:
  - Contains metadata about the script directory and configuration file paths.
- **`$UserConfigs`**:
  - Stores user-specific runtime configurations.
- **`$AppConfigs`**:
  - Stores merged application and user configurations.
- **`$PSBoundParameters`**:
  - Contains runtime parameters passed to the script.

---

## Workflow

### 1. **Configure Script Metadata**
   - Calls `configure-scriptinfo` to initialize file paths for:
     - Application configurations.
     - User configurations.
     - Logging and config directories.

### 2. **Load Application Configurations**
   - Loads the `app-configs.json` or `app-configs.yaml` file using `loading-configfiles`.
   - Validates the structure and initializes `$Script:AppConfigs`.

### 3. **Setup Environment**
   - Calls `configure-environment` to:
     - Create logging and config directories.
     - Initialize paths for error and report files.

### 4. **Merge User Configurations**
   - If a user configuration file exists, loads it and merges it into `$AppConfigs`.
   - Ensures user-defined keys, such as `reports.folder` and `reports.environments`, are present.
   - Dynamically updates configuration keys with runtime parameters from `$PSBoundParameters`.

### 5. **Final Adjustments**
   - Standardizes export format settings (e.g., converting `excel` to `xlsx`).
   - Configures paths for JSON objects and export files based on the active environment.

---

## Example Usages

### Example 1: Configure Settings for Production
```powershell
# Example runtime parameters
$PSBoundParameters = @{ Environment = "prod"; Platform = "json" }

# Call the function
configure-settings

# Output:
# - Application and user configurations merged successfully.
# - Reports folder and logging directories created.
```

### Example 2: Handle Missing User Configurations
```powershell
# Example without user-configs.json
$PSBoundParameters = @{ Environment = "dev"; Platform = "yaml" }

# Call the function
configure-settings

# Output:
# User-Configurations file not found: /path/to/user-configs.yaml.
# Application configurations loaded successfully.
```

### Example 3: Error Handling During Merge
```powershell
# Simulate invalid user configurations
$UserConfigs = @{ "invalid" = "data" }

# Call the function
configure-settings

# Output:
# Error: Failed to merge User-Configurations!
# Exiting with code: 1
```

---

## Dependencies and Linked Components

### Functions
- **[configure-scriptinfo](./configure-scriptinfo)**: Sets up script metadata and file paths.
- **[configure-environment](./configure-environment)**: Initializes directories and environment-specific paths.
- **[loading-configfiles](./loading-configfiles)**: Loads JSON or YAML configuration files.
- **[catching-errors](./catching-errors)**: Handles errors during configuration setup.

### Global Variables
- **`$ScriptInfo`**: Metadata for script and configuration paths.
- **`$AppConfigs`**: Application-specific configurations.
- **`$UserConfigs`**: User-specific runtime configurations.

---

## Error Handling

- **Missing Configurations**: Logs warnings if user configurations are not found.
- **Invalid Data Structures**: Captures errors during configuration file parsing or merging.
- **Runtime Overrides**: Ensures runtime parameters override default configurations safely.

---

## Notes

- Ensure that both application and user configuration files are properly formatted and available.
- Use `$PSBoundParameters` to dynamically override default settings during runtime.
- Test the function with various configurations to ensure compatibility and error resilience.

---

## Additional Resources

- [PowerShell JSON Parsing](https://learn.microsoft.com/en-us/powershell/scripting/json-overview)
- [PowerShell Directory Management](https://learn.microsoft.com/en-us/powershell/scripting/deep-dives/file-management)
