# Extracting Unique Keys Function

## Overview
The **`extracting-uniquekeys`** function processes JSON or hashtable resource objects to identify and extract unique keys. These keys are either user-defined in configuration files or dynamically derived from the dataset. This function ensures that all critical keys are available for further data processing and reporting.

---

## Key Features

- **User-Defined Key Extraction**: Reads keys specified in JSON/YAML configuration files.
- **Dynamic Key Derivation**: Automatically identifies unique keys from the dataset if no user-defined keys are provided.
- **Flexible Configuration**: Supports user-defined and default PowerShell-specific key filtering.
- **Error Handling**: Captures and logs errors during key extraction and configuration validation.

---

## Prerequisites

Before using this function, ensure the following:

1. **Resource Data**:
   - `$Script:HashedObjects` must be populated with the dataset to process.
2. **Configuration File**:
   - `$Script:AppConfigs` must include an `export` section containing user-defined keys.
3. **Required Functions**:
   - `catching-errors` for handling errors and logging.

---

## Parameters

The function does not accept explicit input parameters but relies on the following global variables:

- **`$Script:HashedObjects`**:
  - Input dataset containing JSON or hashtable resource objects.
- **`$Script:AppConfigs`**:
  - Configuration file that defines user-defined keys in its `export` section.

---

## Workflow

### 1. **Initialize Dataset and Keys**
   - Ensures `$Script:HashedObjects` is wrapped in an array if it is a single object.
   - Initializes `$Script:UniqueKeys` as an ordered hashtable.

### 2. **Validate Configuration**
   - Checks if `$Script:AppConfigs` is loaded.
   - Extracts user-defined keys from the `export` section.

### 3. **Process User-Defined Keys**
   - Iterates through the user-defined keys.
   - Ensures each key contains valid `id` and `title` properties.
   - Adds default attributes (`index` and `remove`) to each key.

### 4. **Derive Default Keys**
   - If no user-defined keys exist, extracts unique keys from `$Script:HashedObjects`.
   - Ignores PowerShell-specific keys (e.g., `PSComputerName`, `RunspaceId`).

### 5. **Error Handling**
   - Captures and logs errors during key extraction.
   - Uses `catching-errors` to manage failures gracefully and provide context for troubleshooting.

---

## Example Usages

### Example 1: Extract User-Defined Keys
```powershell
# Example configuration
$Script:AppConfigs = @{
    export = @(
        @{ id = "name"; title = "Resource Name" },
        @{ id = "location"; title = "Resource Location" }
    )
}

# Example dataset
$Script:HashedObjects = @(
    @{ name = "Resource1"; location = "eastus" },
    @{ name = "Resource2"; location = "westus" }
)

# Call the function
extracting-uniquekeys

# Output:
# $Script:UniqueKeys contains:
# [ordered]@{
#    @{ id = "name"; title = "Resource Name"; index = 0; remove = $false };
#    @{ id = "location"; title = "Resource Location"; index = 1; remove = $false };
# }
```

### Example 2: Derive Default Keys
```powershell
# Example dataset
$Script:HashedObjects = @(
    @{ id = "1"; name = "Resource1"; location = "eastus" },
    @{ id = "2"; name = "Resource2"; location = "westus" }
)

# No user-defined keys in AppConfigs
$Script:AppConfigs = $null

# Call the function
extracting-uniquekeys

# Output:
# $Script:UniqueKeys contains:
# [ordered]@{
#    @{ id = "id"; title = "id"; index = 0; remove = $false };
#    @{ id = "name"; title = "name"; index = 1; remove = $false };
#    @{ id = "location"; title = "location"; index = 2; remove = $false };
# }
```

---

## Dependencies and Linked Components

### Functions
- **[catching-errors](./catching-errors)**: Manages errors during key extraction and configuration validation.

### Global Variables
- **`$Script:HashedObjects`**: Input dataset for key extraction.
- **`$Script:AppConfigs`**: Configuration containing user-defined keys.
- **`$Script:UniqueKeys`**: Stores the extracted keys as an ordered hashtable.

---

## Error Handling

- **Configuration Errors**: Throws an error if `$Script:AppConfigs` is not loaded.
- **Key Extraction Errors**: Captures issues during key validation or dynamic derivation.
- **Graceful Failures**: Logs errors and exits gracefully using `catching-errors`.

---

## Notes

- Ensure that `$Script:HashedObjects` is populated with valid JSON or hashtable objects before calling the function.
- User-defined keys in `$Script:AppConfigs` should include valid `id` and `title` properties.
- This function modifies the `$Script:UniqueKeys` variable directly.

---

## Additional Resources

- [PowerShell Hashtable Documentation](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/hashtable)
- [PowerShell Error Handling](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/error-handling)
