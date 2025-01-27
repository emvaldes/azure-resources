# Azure Resources Management Script

## Overview
The **Azure Resources Management Script** is a PowerShell script designed to automate the retrieval, filtering, and exporting of Azure subscription resources. It utilizes batch processing and caching techniques to handle large datasets efficiently and supports flexible configurations via JSON and YAML files.

This script is a key component of the Azure Resources Management project and interacts with various functions and configurations to achieve its goals.

---

## Key Features

- **Batch Processing**: Processes large datasets in manageable chunks to optimize performance.
- **Flexible Configurations**: Supports JSON and YAML configuration formats for dynamic workflows.
- **Export Options**: Outputs resource data in various formats, including CSV, TSV, JSON, and Excel.
- **Error Handling**: Implements robust error-handling mechanisms for reliable execution.
- **Logging**: Supports verbosity and debug-level logging for detailed execution insights.
- **Cache Management**: Includes options for cache expiry to improve data freshness.

---

## Prerequisites

Before using this script, ensure the following:

1. **Azure CLI**: Install and authenticate the Azure CLI (`az`).
2. **PowerShell Modules**:
   - `ImportExcel` for Excel export functionality.
3. **Platform Compatibility**:
   - Windows or Linux with the `libgdiplus` package installed for GDI+-compatible API support.

---

## Parameters

### Mandatory Parameters

- **`-Environment`** *(Alias: `-e`)*
  - Specifies the target environment (e.g., `prod`, `dev`, `test`).

### Optional Parameters

- **`-Platform`** *(Alias: `-p`)*
  - Specifies the configuration format (`json` or `yaml`). Default is `json`.
- **`-ExportFormat`** *(Alias: `-x`)*
  - Specifies the output format for exported data (`csv`, `tsv`, `json`, `excel`). Default is `csv`.
- **`-BatchSize`** *(Alias: `-s`)*
  - Sets the number of items per batch. Default is 10. Valid range: 1–10.
- **`-BatchLimit`** *(Alias: `-l`)*
  - Limits the number of batch iterations. Default is unlimited (`0`).
- **`-CacheExpiry`** *(Alias: `-c`)*
  - Specifies cache expiration time in minutes. Default is 1440 (24 hours). Valid range: 1–1440.
- **`-MaxDepth`** *(Alias: `-m`)*
  - Specifies the maximum depth for parsing JSON objects. Default is 20.
- **`-Override`** *(Alias: `-o`)*
  - Overrides logical constraints to bypass workflow restrictions.
- **`-Verbose`** *(Alias: `-v`)*
  - Enables verbose logging.
- **`-Debug`** *(Alias: `-d`)*
  - Enables debug-level logging.

---

## Workflow

### 1. **Session Management**
   - Initiates and validates an Azure session using the `manage-azuresession` function.

### 2. **Configuration Setup**
   - Loads settings using `configure-settings`.

### 3. **Resource Retrieval and Filtering**
   - Fetches resources with `fetching-resources`.
   - Filters resources with `filtering-resources` based on configurations.

### 4. **Batch Processing**
   - Processes resources in batches using `batching-resources`.

### 5. **Data Extraction**
   - Extracts unique keys and attributes using `extracting-uniquekeys`.

### 6. **Validation**
   - Validates parameters (`validating-parameters`) and resources (`validating-resources`).

### 7. **Export**
   - Exports results to the specified format using `exporting-resources`.

---

## Example Usages

### Example 1: Basic Reporting
```powershell
# Generate a report for the production environment and export to Excel
.\azure-resources.ps1 -Environment 'prod' -ExportFormat excel -Verbose
```

### Example 2: Batch Data Processing
```powershell
# Fetch and process resources in batches of 3 with a limit of 2 iterations
.\azure-resources.ps1 -Environment 'prod' -BatchSize 3 -BatchLimit 2 -ExportFormat excel -Verbose
```

### Example 3: Override Workflow Constraints
```powershell
# Override constraints and fetch resources with detailed debug logging
.\azure-resources.ps1 -Environment 'dev' -Override -Debug
```

---

## Dependencies and Linked Components

### Functions
- **[manage-azuresession](./manage-azuresession)**: Manages Azure CLI sessions.
- **[configure-settings](./configure-settings)**: Loads and validates configuration settings.
- **[fetching-resources](./fetching-resources)**: Retrieves Azure resources.
- **[filtering-resources](./filtering-resources)**: Filters resources based on configurations.
- **[batching-resources](./batching-resources)**: Handles batch processing of data.
- **[extracting-uniquekeys](./extracting-uniquekeys)**: Extracts unique keys from nested data.
- **[validating-parameters](./validating-parameters)**: Validates input parameters.
- **[validating-resources](./validating-resources)**: Ensures the correctness of fetched resources.
- **[exporting-resources](./exporting-resources)**: Exports data to specified formats.

### Configuration Files
- **[app-configs.json](./app-configs-json)**: Main application configuration.
- **[app-configs.yaml](./app-configs-yaml)**: YAML equivalent of the application configuration.
- **[user-configs.json](./user-configs-json)**: User-specific settings in JSON format.
- **[user-configs.yaml](./user-configs-yaml)**: User-specific settings in YAML format.

---

## Error Handling

- Logs errors during script execution.
- Ensures graceful termination with appropriate exit codes.
- Detailed logs are available in verbose or debug modes.

---

## Notes
- Ensure proper permissions and a Super-User role in Azure to access resources.
- Test the script in a non-production environment before deployment.

---

## Additional Resources
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
