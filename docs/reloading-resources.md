# Reloading Resources Function

## Overview
The **`reloading-resources`** function is a key component of the Azure Resources Management project, responsible for managing resource caching. It determines whether to load resources from a cache file or fetch them anew based on the file's age and configuration settings. This function ensures efficient use of cached data while maintaining data freshness.

---

## Key Features

- **Cache Validation**: Checks the age of a cache file against a user-defined expiration threshold.
- **Automatic Reloading**: Initiates resource reloading when the cache is outdated or invalid.
- **Content Validation**: Ensures the cache file contains valid and non-empty JSON data.
- **Error Handling**: Implements robust mechanisms to handle file reading and JSON conversion errors.

---

## Prerequisites

Before using this function, ensure the following:

1. **Cache File Location**: The file path specified in the `$Filename` parameter must be accessible.
2. **Configuration Settings**: The `$UserConfigs` global variable must include:
   - `params.CacheExpiry`: Cache expiration threshold in minutes.
   - `params.Environment`: Target environment for the resources.
   - `params.MaxDepth`: Maximum depth for JSON parsing.
3. **Required Functions**: Ensure the `catching-errors` function is available for error management.

---

## Parameters

### Input Parameters

- **`$Filename`** *(string)*:
  - Path to the cache file containing the resource data.

---

## Workflow

### 1. **Cache Validation**
   - Determines the cache age limit using the `CacheExpiry` setting from `$UserConfigs`.
   - Verifies if the specified cache file exists.
   - Compares the file's last write time against the age limit to check validity.

### 2. **Load or Reload Resources**
   - If the cache file is valid:
     - Reads the file content using `Get-Content`.
     - Converts the content from JSON using `ConvertFrom-Json`.
     - Validates the imported objects.
   - If the cache is invalid or missing:
     - Triggers reloading by returning `$false` to the calling workflow.

### 3. **Content Validation**
   - Ensures the JSON data is not null, empty, or improperly formatted.
   - Logs the number of resources loaded from the cache.

### 4. **Error Handling**
   - Captures and logs errors related to file reading and JSON conversion.
   - Returns contextual error messages using the `catching-errors` function.

---

## Example Usages

### Example 1: Validate and Load Cache
```powershell
# Example UserConfigs setup
$UserConfigs = @{
    params = @{
        CacheExpiry = 1440;
        Environment = "prod";
        MaxDepth = 5;
    }
}

# Call the function with a cache file path
$resources = reloading-resources -Filename "./cache/resources.json"

# Output:
# Cache for 'prod' is valid. Loading resources...
# Loaded 25 resources for 'prod' from Cache-file './cache/resources.json'
```

### Example 2: Handle Outdated Cache
```powershell
# Simulate outdated cache
$resources = reloading-resources -Filename "./cache/old_resources.json"

# Output:
# Cache-file for prod is outdated. Reloading resources...
```

### Example 3: Missing or Invalid Cache
```powershell
# Simulate missing cache
$resources = reloading-resources -Filename "./cache/missing_resources.json"

# Output:
# Cache-file is empty or invalid. Downloading resources...
```

---

## Dependencies and Linked Components

### Functions
- **[catching-errors](./catching-errors)**: Handles exceptions and logs contextual error messages.

### Variables
- **`$UserConfigs`**: Stores user-defined configurations, including `CacheExpiry`, `Environment`, and `MaxDepth`.

---

## Error Handling

- **File Read Errors**: Captures issues related to missing or inaccessible cache files.
- **JSON Conversion Errors**: Manages errors when converting raw data into JSON objects.
- **Contextual Logging**: Uses `catching-errors` to log errors with relevant context and exit codes (`13` and `14`).

---

## Notes

- Ensure the `$UserConfigs` variable is properly initialized before invoking this function.
- Test the function in a staging environment to confirm cache behavior and validity.
- Consider implementing additional logging for debugging and traceability.

---

## Additional Resources

- [PowerShell Get-Content Documentation](https://learn.microsoft.com/en-us/powershell/scripting/commands/get-content)
- [PowerShell JSON Conversion](https://learn.microsoft.com/en-us/powershell/scripting/json-overview)
