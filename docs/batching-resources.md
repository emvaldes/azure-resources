# Batching Resources Function

## Overview
The **`batching-resources`** function processes a dataset by dividing it into manageable batches for efficient handling. It integrates seamlessly with the `reloading-resources` and `batching-deployment` functions to handle large datasets while adhering to user-defined limits and configurations. This function is critical for optimizing performance and resource allocation during data processing.

---

## Key Features

- **Dynamic Batch Creation**: Divides datasets into batches of configurable size.
- **Resource Deployment Integration**: Passes batches to the `batching-deployment` function for processing.
- **User-Defined Limits**: Supports configurable batch sizes and iteration limits.
- **Error Handling**: Logs errors and ensures graceful handling of unexpected issues during batch processing.
- **JSON File Management**: Validates and finalizes the JSON file for storing processed data.

---

## Prerequisites

Before using this function, ensure the following:

1. **Configuration Settings**:
   - `$UserConfigs` must include:
     - `params.BatchSize`: Specifies the number of items per batch.
     - `params.BatchLimit`: Limits the number of batches processed.
     - `params.MaxDepth`: Defines the depth for JSON processing.
2. **Required Functions**:
   - `reloading-resources`: Prepares and validates the dataset for batching.
   - `batching-deployment`: Processes individual batches.
   - `catching-errors`: Manages errors during batch processing.

---

## Parameters

The function does not accept explicit input parameters but relies on the following global variables:

- **`$Script:FilteredObjects`**: The dataset to be batched.
- **`$UserConfigs`**: Configuration settings for batch size, limits, and JSON processing.
- **`$Script:JsonObjects`**: Path to the JSON file for storing processed data.

---

## Workflow

### 1. **Initialize Dataset Scope**
   - Sets `$Script:DatasetScope` to "Batching Resources."
   - Calls `reloading-resources` to validate and prepare the dataset.

### 2. **Validate and Initialize JSON File**
   - Checks if the JSON file path exists.
   - Creates an empty JSON file with an opening bracket (`[`) if it does not exist.

### 3. **Create Batches**
   - Iterates through `$Script:FilteredObjects` in steps defined by `params.BatchSize`.
   - Creates batches and stores them in a list for processing.

### 4. **Process Batches**
   - Passes each batch to `batching-deployment` for processing.
   - Respects the `params.BatchLimit` setting to control the number of batches processed.

### 5. **Finalize JSON File**
   - Validates and finalizes the JSON file by:
     - Closing the JSON array with a closing bracket (`]`).
     - Formatting the JSON for readability.

### 6. **Error Handling**
   - Captures errors during batch processing and logs detailed messages using `catching-errors`.

### 7. **Log Execution Time**
   - Calculates and logs the total execution time for batch processing.

---

## Example Usages

### Example 1: Process Dataset with Default Settings
```powershell
# Example configuration
$UserConfigs = @{
    params = @{ BatchSize = 10; BatchLimit = 0; MaxDepth = 5 }
}
$Script:FilteredObjects = @(
    @{ id = "1"; name = "Resource1" },
    @{ id = "2"; name = "Resource2" }
)

# Call the function
batching-resources

# Output:
# Initializing Batching Resources...
# Processing batch 1 of 1...
# Total execution time: 0 minutes and 5 seconds
```

### Example 2: Handle Batch Limit
```powershell
# Example configuration
$UserConfigs = @{
    params = @{ BatchSize = 5; BatchLimit = 2; MaxDepth = 3 }
}

# Call the function
batching-resources

# Output:
# Processing batch 1 of 2...
# Batch limit reached. Stopping further processing.
```

### Example 3: Error Handling
```powershell
# Simulate missing JSON file path
$Script:JsonObjects = "missing.json"

# Call the function
batching-resources

# Output:
# Error: JSON file missing.json does not exist or was not created correctly.
# Failed to process Batching Resources list.
```

---

## Dependencies and Linked Components

### Functions
- **[reloading-resources](./reloading-resources)**: Prepares the dataset for batching.
- **[batching-deployment](./batching-deployment)**: Processes individual batches.
- **[catching-errors](./catching-errors)**: Logs errors during batch processing.

### Global Variables
- **`$Script:FilteredObjects`**: Dataset for batching.
- **`$UserConfigs`**: Configuration settings for batch processing.
- **`$Script:JsonObjects`**: Path to the JSON file for storing processed data.

---

## Error Handling

- **Missing JSON File**: Logs an error and exits if the JSON file is not found.
- **Batching Errors**: Captures and logs errors during batch creation or processing.
- **Limit Exceeded**: Stops processing gracefully when the batch limit is reached.

---

## Notes

- Ensure `$Script:FilteredObjects` contains a valid dataset before calling the function.
- Adjust `params.BatchSize` and `params.BatchLimit` in `$UserConfigs` to suit your workload.
- Test the function with representative datasets to validate batch processing behavior.

---

## Additional Resources

- [PowerShell Error Handling](https://learn.microsoft.com/en-us/powershell/scripting/deep-dives/error-handling)
- [PowerShell JSON Processing](https://learn.microsoft.com/en-us/powershell/scripting/json-overview)
