# Loading Config Files Function

## Overview
The **`loading-configfiles`** function is designed to load and process application configurations stored in JSON or YAML files. It ensures that the configurations are correctly parsed and validated, enabling the Azure Resources Management project to dynamically adapt to environment-specific settings.

---

## Key Features

- **Multi-Format Support**: Handles both JSON and YAML configuration files.
- **Dynamic Loading**: Adapts to the specified configuration platform (`json` or `yaml`) at runtime.
- **Error Management**: Provides detailed error handling for file access and parsing issues.
- **Dependency Management**: Ensures the required PowerShell modules (e.g., `powershell-yaml`) are installed and available.

---

## Prerequisites

Before using this function, ensure the following:

1. **Configuration File**: The configuration file (`json` or `yaml`) exists and is accessible.
2. **PowerShell Modules**:
   - `powershell-yaml`: Required for processing YAML files. The function installs it automatically if missing.
3. **Global Variables**:
   - `$Platform`: Specifies the format of the configuration file (`json` or `yaml`).
   - `$MaxDepth`: Defines the maximum depth for parsing JSON objects (default: 20).

---

## Parameters

### Input Parameters

- **`$ConfigFile`** *(string)*:
  - Path to the configuration file to be loaded.

---

## Workflow

### 1. **Validate Configuration File Format**
   - Checks the `$Platform` variable to determine the file format (`json` or `yaml`).
   - If `$Platform` is `yaml`, ensures the `powershell-yaml` module is installed and imported.

### 2. **File Existence Check**
   - Validates that the file exists at the specified `$ConfigFile` path.
   - Aborts execution if the file is missing, logging an appropriate error message.

### 3. **Configuration Parsing**
   - Parses the configuration file based on its format:
     - **JSON**: Reads and converts the file using `ConvertFrom-Json`.
     - **YAML**: Reads and converts the file using `ConvertFrom-Yaml`.
   - Ensures the resulting data structure is a valid hashtable.

### 4. **Error Handling**
   - Captures and logs errors during module imports or file parsing.
   - Uses the `catching-errors` function to provide detailed error messages and exit codes.

---

## Example Usages

### Example 1: Load JSON Configuration
```powershell
# Set global variables
$Platform = "json"
$MaxDepth = 10

# Call the function with a JSON configuration file
$Configs = loading-configfiles -ConfigFile "./configs/app-config.json"

# Output:
# Loaded configurations as a hashtable
# @{ key1 = "value1"; key2 = "value2" }
```

### Example 2: Load YAML Configuration
```powershell
# Set global variables
$Platform = "yaml"
$MaxDepth = 5

# Call the function with a YAML configuration file
$Configs = loading-configfiles -ConfigFile "./configs/app-config.yaml"

# Output:
# Loaded configurations as a hashtable
# @{ key1 = "value1"; key2 = "value2" }
```

### Example 3: Handle Missing File
```powershell
# Call the function with a non-existent file
$Configs = loading-configfiles -ConfigFile "./configs/missing-file.yaml"

# Output:
# Configuration file not found at path: ./configs/missing-file.yaml. Aborting.
```

---

## Dependencies and Linked Components

### Functions
- **[catching-errors](./catching-errors)**: Handles exceptions during module imports and file parsing.

### Global Variables
- **`$Platform`**: Defines the configuration file format (`json` or `yaml`).
- **`$MaxDepth`**: Specifies the depth for JSON parsing (applies to `ConvertFrom-Json`).

---

## Error Handling

- **Module Import Errors**: Logs errors and aborts if the `powershell-yaml` module cannot be installed or imported.
- **File Access Errors**: Aborts execution if the configuration file is missing or inaccessible.
- **Parsing Errors**: Captures issues during JSON or YAML parsing and logs detailed error messages.

---

## Notes

- Ensure the `$Platform` variable is set correctly before calling the function.
- For YAML support, the `powershell-yaml` module must be installed. The function installs it automatically if missing.
- Test the function with representative configuration files to ensure compatibility.

---

## Additional Resources

- [PowerShell Get-Content Documentation](https://learn.microsoft.com/en-us/powershell/scripting/commands/get-content)
- [PowerShell JSON Conversion](https://learn.microsoft.com/en-us/powershell/scripting/json-overview)
- [powershell-yaml Module](https://github.com/cloudbase/powershell-yaml)
