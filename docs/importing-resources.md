# Importing Resources Function

## Overview
The **`importing-resources`** function is a key part of the Azure Resources Management project, responsible for importing JSON resource objects from a file and converting them into a PowerShell hashtable. This function ensures that resource data is properly parsed and ready for processing by other components.

---

## Key Features

- **JSON File Parsing**: Reads and converts JSON files into hashtable objects for easy manipulation.
- **Depth Management**: Supports configurable parsing depth to handle deeply nested JSON objects.
- **Error Handling**: Provides robust mechanisms to handle JSON parsing issues, such as invalid or missing files.

---

## Prerequisites

Before using this function, ensure the following:

1. **JSON File**: The file specified in `$JsonObjects` must exist and contain valid JSON data.
2. **Configuration Settings**: The `$UserConfigs` global variable must include:
   - `params.MaxDepth`: Specifies the maximum depth for parsing JSON objects.
3. **Error Handling Function**: The `catching-errors` function must be available in the environment.

---

## Parameters

The function does not accept explicit input parameters but relies on the following:

- **Global Variables**:
  - `$JsonObjects`: Path to the JSON file containing resource data.
  - `$UserConfigs`: Configuration settings, including `MaxDepth` for JSON parsing.

---

## Workflow

### 1. **Parse JSON File**
   - Reads the file specified in `$JsonObjects` using `Get-Content`.
   - Converts the JSON data into a PowerShell hashtable using `ConvertFrom-Json` with the depth set by `$UserConfigs["params"]["MaxDepth"]`.
   - Stores the parsed objects in the `$Script:HashedObjects` variable.

### 2. **Validation**
   - Logs the count of JSON objects successfully parsed.
   - Ensures that the file contains valid JSON data.

### 3. **Error Handling**
   - Captures exceptions during file reading or JSON conversion.
   - Calls the `catching-errors` function to log the error, exit the script, and provide context about the failure.

---

## Example Usages

### Example 1: Import Valid JSON File
```powershell
# Example configuration
$JsonObjects = "./data/resources.json"
$UserConfigs = @{ params = @{ MaxDepth = 5 } }

# Call the function
importing-resources

# Output:
# 50 JSON Objects are present in file './data/resources.json'.
```

### Example 2: Handle Invalid JSON File
```powershell
# Example of a malformed or missing JSON file
$JsonObjects = "./data/invalid.json"

# Call the function
importing-resources

# Output:
# Error: Unable to parse JSON Objects from './data/invalid.json'!
# Exiting with code: 9
```

---

## Dependencies and Linked Components

### Functions
- **[catching-errors](./catching-errors)**: Logs detailed error messages and manages graceful exit on failures.

### Global Variables
- **`$JsonObjects`**: Path to the JSON file.
- **`$UserConfigs`**: Configuration settings, including `MaxDepth`.
- **`$Script:HashedObjects`**: Stores the parsed JSON objects.

---

## Error Handling

- **File Read Errors**: Captures issues related to missing or inaccessible JSON files.
- **JSON Parsing Errors**: Logs errors if the file contains invalid JSON data or if parsing fails due to depth limitations.
- **Contextual Logging**: Provides detailed messages about the cause and location of the error.

---

## Notes

- Ensure the `$JsonObjects` variable points to a valid JSON file before invoking the function.
- Test the function with different JSON files to validate parsing depth and error handling.
- Adjust the `MaxDepth` setting in `$UserConfigs` based on the complexity of your JSON structure.

---

## Additional Resources

- [PowerShell Get-Content Documentation](https://learn.microsoft.com/en-us/powershell/scripting/commands/get-content)
- [PowerShell JSON Conversion](https://learn.microsoft.com/en-us/powershell/scripting/json-overview)
