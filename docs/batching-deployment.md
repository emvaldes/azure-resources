# Batching Deployment Function

## Overview
The **`batching-deployment`** function processes individual batches of Azure resources by creating background jobs for each resource. It retrieves detailed resource data using the Azure CLI, handles errors gracefully, and appends results to a JSON file for further processing.

---

## Key Features

- **Parallel Processing**: Utilizes PowerShell jobs to process multiple resources concurrently.
- **Dynamic Resource Retrieval**: Fetches resource data from Azure using the `az resource show` command.
- **Error Handling**: Captures and logs errors during resource processing using a centralized error management system.
- **JSON Data Management**: Appends processed data to a JSON file, ensuring proper formatting and completeness.

---

## Prerequisites

Before using this function, ensure the following:

1. **Azure CLI**:
   - Installed and authenticated with sufficient permissions to access resources.
2. **Configuration Settings**:
   - `$UserConfigs` must include:
     - `params.MaxDepth`: Specifies the depth for JSON processing.
3. **Dataset Preparation**:
   - `$BatchObjects` contains a valid array of resource objects.
   - `$Script:JsonObjects` specifies the path to the JSON file for storing processed results.

---

## Parameters

### Input Parameters

- **`$BatchObjects`** *(array, mandatory)*:
  - The batch of resources to process.
- **`$TotalRecords`** *(int, mandatory)*:
  - Total number of records in the dataset for indexing and progress tracking.

---

## Workflow

### 1. **Initialize Job Queue**
   - Creates a queue to manage background jobs for processing resources.

### 2. **Create Jobs for Each Resource**
   - For each resource in `$BatchObjects`:
     - Retrieves metadata such as `id`, `name`, and index.
     - Starts a PowerShell job to:
       - Fetch the resource data using `az resource show`.
       - Convert the JSON response into a PowerShell hashtable.
       - Handle errors if resource retrieval fails.

### 3. **Process Job Results**
   - Waits for each job to complete.
   - Collects results and cleans up completed jobs.
   - Appends processed data to the JSON file.

### 4. **JSON File Management**
   - Validates the JSON file path.
   - Ensures proper formatting when appending new data.

### 5. **Error Handling**
   - Logs and handles errors during job execution and JSON file updates.

---

## Example Usages

### Example 1: Process a Batch of Resources
```powershell
# Example batch objects
$BatchObjects = @(
    @{ id = "/subscriptions/123/resourceGroups/rg1/providers/Microsoft.Web/sites/site1" },
    @{ id = "/subscriptions/123/resourceGroups/rg2/providers/Microsoft.Web/sites/site2" }
)
$TotalRecords = 50

# Call the function
batching-deployment -BatchObjects $BatchObjects -TotalRecords $TotalRecords

# Output:
# 01/50: site1
# 02/50: site2
```

### Example 2: Handle Missing JSON File
```powershell
# Simulate missing JSON file
$Script:JsonObjects = "missing.json"

# Call the function
batching-deployment -BatchObjects $BatchObjects -TotalRecords $TotalRecords

# Output:
# Error: JSON file missing.json does not exist.
```

### Example 3: Handle Resource Retrieval Errors
```powershell
# Example batch object with an invalid resource ID
$BatchObjects = @(
    @{ id = "invalid/resource/id" }
)

# Call the function
batching-deployment -BatchObjects $BatchObjects -TotalRecords 1

# Output:
# Error: Failed to process resource with ID: invalid/resource/id
```

---

## Dependencies and Linked Components

### Functions
- **[catching-errors](./catching-errors)**: Logs and handles errors during job execution.

### Global Variables
- **`$Script:JsonObjects`**: Specifies the JSON file path for storing processed data.
- **`$UserConfigs`**: Configuration settings, including `params.MaxDepth`.

---

## Error Handling

- **Invalid Resource IDs**: Logs an error if a resource ID is invalid or inaccessible.
- **Azure CLI Failures**: Captures errors from the `az resource show` command.
- **JSON File Issues**: Logs errors if the JSON file path is missing or inaccessible.
- **Graceful Cleanup**: Ensures all jobs are cleaned up, even in case of errors.

---

## Notes

- Ensure the Azure CLI is authenticated and configured before running the function.
- Test the function with representative datasets to validate batch processing behavior.
- Adjust `params.MaxDepth` in `$UserConfigs` to handle nested JSON structures effectively.

---

## Additional Resources

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [PowerShell Jobs](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/jobs)
