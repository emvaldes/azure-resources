# Exporting Resources Function

## Overview
The **`exporting-resources`** function is designed to export processed resource data into various file formats, including CSV, TSV, and Excel. This function ensures data is sanitized, formatted, and filtered appropriately before export, providing flexibility for diverse reporting needs.

---

## Key Features

- **Multi-Format Export**: Supports exporting data in CSV, TSV, and Excel formats.
- **Data Sanitization**: Cleans up string values and handles nested hashtable structures.
- **Customizable Output**: Dynamically adapts to user-defined configurations for field inclusion and formatting.
- **Error Handling**: Provides robust error logging and graceful recovery for export failures.

---

## Prerequisites

Before using this function, ensure the following:

1. **Export Configuration**:
   - `$UserConfigs` global variable must include:
     - `params.ExportFormat`: Specifies the target export format (`csv`, `tsv`, or `xlsx`).
     - `params.Environment`: Indicates the environment (e.g., `prod`, `dev`).
2. **PowerShell Modules**:
   - `ImportExcel`: Required for exporting data to Excel format.
3. **Processed Data**:
   - `$Script:HashedObjects`: Contains the dataset to be exported.
   - `$Script:UniqueKeys`: Defines the fields to include in the export.

---

## Parameters

The function does not accept explicit input parameters but relies on the following global variables:

- **`$Script:HashedObjects`**:
  - Processed resource data to be exported.
- **`$Script:UniqueKeys`**:
  - Defines the fields to include in the export.
- **`$UserConfigs`**:
  - Configuration settings for export format and environment.

---

## Workflow

### 1. **Sanitize Data**
   - Iterates through `$Script:HashedObjects` to clean up string values and handle nested hashtables.
   - Removes unnecessary quotes and replaces empty hashtables with placeholders (`{}` or `{ ... }`).

### 2. **Prepare Export Rows**
   - Builds each export row by including only fields defined in `$Script:UniqueKeys`.
   - Excludes fields marked with `remove = $true`.

### 3. **Export Data**
   - Exports the processed data based on the specified format in `params.ExportFormat`:
     - **CSV**: Uses `Export-Csv` with `-NoTypeInformation`.
     - **TSV**: Converts to CSV with a tab delimiter and saves using `Set-Content`.
     - **Excel**: Utilizes the `Export-Excel` cmdlet for structured Excel files.

### 4. **Error Handling**
   - Captures exceptions during the export process and logs errors using `catching-errors`.
   - Provides context-specific messages for unsupported formats or failed operations.

---

## Example Usages

### Example 1: Export Data as CSV
```powershell
# Example configuration
$UserConfigs = @{
    params = @{ ExportFormat = "csv"; Environment = "prod" }
}
$Script:HashedObjects = @(
    @{ id = "1"; name = "Resource1"; location = "eastus" },
    @{ id = "2"; name = "Resource2"; location = "westus" }
)
$Script:UniqueKeys = @(
    @{ id = "name"; title = "Resource Name" },
    @{ id = "location"; title = "Resource Location" }
)

# Call the function
exporting-resources

# Output:
# CSV data exported successfully into 'export.csv'.
```

### Example 2: Export Data as Excel
```powershell
# Example configuration
$UserConfigs = @{
    params = @{ ExportFormat = "xlsx"; Environment = "dev" }
}

# Call the function
exporting-resources

# Output:
# Excel data exported successfully into 'export.xlsx'.
```

### Example 3: Handle Unsupported Format
```powershell
# Example configuration with invalid format
$UserConfigs = @{
    params = @{ ExportFormat = "json"; Environment = "test" }
}

# Call the function
exporting-resources

# Output:
# Error: Unsupported format 'json'.
# Exiting with code: 3
```

---

## Dependencies and Linked Components

### Functions
- **[catching-errors](./catching-errors)**: Handles errors during export.
- **[validating-appmodule](./validating-appmodule)**: Ensures required PowerShell modules are available for Excel export.

### Global Variables
- **`$Script:HashedObjects`**: Dataset to export.
- **`$Script:UniqueKeys`**: Defines export fields.
- **`$UserConfigs`**: Configuration for export settings.

---

## Error Handling

- **Unsupported Formats**: Logs an error and exits if an invalid format is specified.
- **Export Failures**: Captures and logs issues during file writing or cmdlet execution.
- **Graceful Recovery**: Provides detailed error messages and context for troubleshooting.

---

## Notes

- Ensure that `$Script:HashedObjects` is populated with valid data before invoking the function.
- Test the function with different export formats to validate output consistency.
- For Excel export, ensure the `ImportExcel` module is installed and accessible.

---

## Additional Resources

- [PowerShell Export-Csv Documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-csv)
- [ImportExcel PowerShell Module](https://github.com/dfinke/ImportExcel)
