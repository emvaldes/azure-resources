# Filtering Resources Function

## Overview
The **`filtering-resources`** function filters Azure resource objects based on the current environment, ensuring that only relevant resources are included for processing. It integrates seamlessly with the caching and reloading mechanisms to optimize performance while maintaining data accuracy.

---

## Key Features

- **Environment-Based Filtering**: Filters resource objects specific to the active environment.
- **Cache Management**: Saves filtered results to a JSON cache file for subsequent use.
- **Error Handling**: Logs errors and ensures graceful handling of scenarios where no resources are found.
- **Dynamic Scope**: Automatically adjusts the filtering scope based on user configurations.

---

## Prerequisites

Before using this function, ensure the following:

1. **Configuration Settings**:
   - The `$UserConfigs` global variable must include:
     - `params.Environment`: Target environment name (e.g., `prod`, `dev`, `test`).
     - `params.MaxDepth`: Maximum depth for JSON parsing.
2. **Cache File Location**:
   - Ensure the `reloading-resources` function has been executed to provide an up-to-date dataset.
3. **Required Functions**:
   - `catching-errors`: For robust error handling.
   - `reloading-resources`: To retrieve and cache resource data.

---

## Parameters

### Input Parameters

- **`$Filename`** *(string)*:
  - The path to the cache file containing environment-specific resource data.

---

## Workflow

### 1. **Set Dataset Scope**
   - Defines the dataset scope based on the active environment (`params.Environment`).

### 2. **Reload Resources**
   - Calls the `reloading-resources` function to retrieve the cached resource data.

### 3. **Filter Resources**
   - Filters the dataset using `Where-Object` to match resources specific to the environment.
   - If no resources are found, logs an error and exits with code `7`.

### 4. **Save Filtered Results**
   - Converts the filtered objects to JSON format.
   - Saves the filtered data to the specified cache file.

### 5. **Error Handling**
   - Captures and logs errors encountered during resource filtering.
   - Uses the `catching-errors` function for detailed logging and exit codes.

---

## Example Usages

### Example 1: Filter Resources for Production Environment
```powershell
# Example configuration
$UserConfigs = @{
    params = @{
        Environment = "prod";
        MaxDepth = 5;
    }
}

# Call the function
filtering-resources -Filename "./cache/prod.resources.json"

# Output:
# Filtering Environment 'prod' Resources...
# Filtered 20 resource(s) for Environment 'prod'.
```

### Example 2: Handle No Resources Found
```powershell
# Example configuration
$UserConfigs = @{
    params = @{
        Environment = "dev";
        MaxDepth = 5;
    }
}

# Simulate empty dataset
$FetchedObjects = @()

# Call the function
filtering-resources -Filename "./cache/dev.resources.json"

# Output:
# Error: No Environment 'dev' Resources JSON Objects were retrieved.
# Exiting with code: 7
```

---

## Dependencies and Linked Components

### Functions
- **[reloading-resources](./reloading-resources)**: Provides the dataset for filtering.
- **[catching-errors](./catching-errors)**: Handles exceptions during resource filtering.

### Global Variables
- **`$UserConfigs`**: Stores configuration settings, including `Environment` and `MaxDepth`.
- **`$FetchedObjects`**: Contains the full dataset fetched for filtering.
- **`$Script:FilteredObjects`**: Stores the filtered dataset for further processing.

---

## Error Handling

- **No Resources Found**: Logs an error and exits with code `7` if no resources match the filtering criteria.
- **Reloading Errors**: Captures errors from the `reloading-resources` function.
- **File Write Errors**: Ensures filtered data is saved successfully to the cache file.

---

## Notes

- Ensure the `$UserConfigs` variable is correctly initialized before calling this function.
- Test the function in different environments (`prod`, `dev`, `test`) to validate filtering logic.
- The function modifies the `$Script:FilteredObjects` variable directly; ensure it is used consistently across scripts.

---

## Additional Resources

- [PowerShell Where-Object Documentation](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/where-object)
