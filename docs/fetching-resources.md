# Fetching Resources Function

## Overview
The **`fetching-resources`** function is responsible for retrieving Azure resource data from a subscription using the Azure CLI. It processes the resource data into JSON objects and manages caching to optimize performance. Additionally, it supports parallel segmentation to filter resources by environment, ensuring scalability and efficiency in large environments.

---

## Key Features

- **Azure Resource Retrieval**: Uses the `az resource list` command to fetch resources.
- **Caching**: Saves fetched resources to a JSON cache file for reuse.
- **Parallel Processing**: Filters resources for multiple environments concurrently using PowerShell jobs.
- **Dynamic Scope**: Adapts to user-defined configurations for environment-specific segmentation.
- **Error Handling**: Captures and logs errors during data retrieval and processing.

---

## Prerequisites

Before using this function, ensure the following:

1. **Azure CLI**:
   - Installed and authenticated with sufficient permissions to list resources.
2. **Configuration Settings**:
   - `$UserConfigs` global variable must include:
     - `params.MaxDepth`: Maximum depth for JSON parsing.
     - `reports.environments`: Array of target environments for segmentation.
3. **PowerShell Jobs**:
   - Supported on your system for parallel resource segmentation.

---

## Parameters

### Input Parameters

- **`$Filename`** *(string)*:
  - Path to the JSON file used for caching fetched resource data.

---

## Workflow

### 1. **Initialize Dataset Scope**
   - Sets the dataset scope to "Subscription Resources" and initializes the cache file path.

### 2. **Reload Cached Resources**
   - Calls the `reloading-resources` function to load cached data if available.

### 3. **Retrieve Azure Resources**
   - Executes the `az resource list` command to fetch resource data as JSON.
   - Converts the data into PowerShell hashtable objects using `ConvertFrom-Json`.
   - Logs the count of retrieved resources.

### 4. **Cache Retrieved Data**
   - Saves the retrieved resource data to the specified JSON cache file.

### 5. **Parallel Resource Segmentation**
   - Iterates through environments defined in `$UserConfigs["reports"]["environments"]`.
   - Filters resources for each environment and saves them to separate JSON files.
   - Uses PowerShell jobs to process multiple environments concurrently.

### 6. **Error Handling**
   - Captures and logs errors during data retrieval and parallel processing.
   - Uses the `catching-errors` function to manage graceful exits on failures.

---

## Example Usages

### Example 1: Fetch and Cache Resources
```powershell
# Example configuration
$UserConfigs = @{
    params = @{ MaxDepth = 5 };
    reports = @{ environments = @("prod", "dev", "test") }
}

# Call the function
fetching-resources -Filename "./cache/all.resources.json"

# Output:
# Retrieved 50 Subscription Resources.
# Filtered resources are saved for environments: prod, dev, test.
```

### Example 2: Handle Empty Dataset
```powershell
# Simulate no resources in the subscription
$Script:FetchedObjects = @()

# Call the function
fetching-resources -Filename "./cache/all.resources.json"

# Output:
# Error: No Subscription Resources JSON Objects were retrieved.
# Exiting with code: 5
```

---

## Dependencies and Linked Components

### Functions
- **[reloading-resources](./reloading-resources)**: Reloads cached resource data.
- **[catching-errors](./catching-errors)**: Handles exceptions during resource retrieval and segmentation.

### Global Variables
- **`$Script:AzureResources`**: Stores the cache file path.
- **`$Script:FetchedObjects`**: Stores the retrieved resource data.
- **`$UserConfigs`**: Stores configuration settings, including environments and parsing depth.

---

## Error Handling

- **Empty Datasets**: Logs an error and exits with code `5` if no resources are retrieved.
- **Segmentation Errors**: Captures issues during parallel filtering and logs errors for individual environments.
- **Azure CLI Failures**: Logs and exits if the `az resource list` command fails.

---

## Notes

- Ensure the Azure CLI is authenticated before running this function.
- Test the function with different environments and configurations to validate behavior.
- Consider increasing `MaxDepth` in `$UserConfigs` for deeply nested JSON objects.

---

## Additional Resources

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [PowerShell Jobs](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/jobs)
