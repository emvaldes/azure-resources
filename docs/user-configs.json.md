# User Configurations File (user-configs.json)

## Overview
The **`user-configs.json`** file is a critical part of the Azure Resources Management project. It allows end-users to customize runtime parameters, reporting options, and export configurations dynamically. This file works alongside application configurations to provide flexibility and adaptability for various environments and use cases.

---

## Key Features

- **Customizable Export Options**: Supports flexible export formats (e.g., `csv`, `tsv`, `xlsx`).
- **Batch Processing Settings**: Enables control over batch size, limits, and cache expiry.
- **Environment-Based Reporting**: Allows reports to be generated for specific environments.
- **Export Key Mappings**: Defines the fields to be included in exported data with customizable titles.
- **User-Specific Targets**: Supports the definition of specific environments and their attributes.

---

## Structure and Fields

### 1. **params** *(object)*
Defines general runtime settings for batch processing and exports:
- **`ExportFormat`** *(string)*: Default format for exporting data (e.g., `excel`).
- **`BatchSize`** *(int)*: Number of items processed per batch.
- **`BatchLimit`** *(int)*: Maximum number of batch iterations (`0` for unlimited).
- **`CacheExpiry`** *(int)*: Time in minutes before the cache expires.
- **`MaxDepth`** *(int)*: Maximum depth for parsing JSON objects.

### 2. **reports** *(object)*
Specifies settings related to reports:
- **`folder`** *(string)*: Directory where reports will be saved.
- **`environments`** *(array)*: List of target environments for generating reports (e.g., `demo`, `test`, `prod`).
- **`formats`** *(array)*: Supported export formats (e.g., `csv`, `tsv`, `xlsx`).

### 3. **targets** *(array)*
Defines specific environments and their attributes:
- **`item`** *(string)*: Environment name (e.g., `prod`).
- **`title`** *(string)*: Display title for the environment (e.g., `Production`).

### 4. **export** *(array)*
Defines the fields to include in exported data:
- **`id`** *(string)*: Unique identifier or path for the field (e.g., `identity.principalId`).
- **`title`** *(string)*: Human-readable title for the field (e.g., `Identity - Principal ID`).

---

## Example Configuration

### Example File
```json
{
    "params": {
        "ExportFormat": "excel",
        "BatchSize": 10,
        "BatchLimit": 0,
        "CacheExpiry": 1440,
        "MaxDepth": 20
    },
    "reports": {
        "folder": "Azure-Reports",
        "environments": [
            "demo",
            "test",
            "staging",
            "prod"
        ],
        "formats": [
            "csv",
            "tsv",
            "xlsx"
        ]
    },
    "targets": [
        {
            "item": "prod",
            "title": "Production"
        }
    ],
    "export": [
        {
            "id": "identity.principalId",
            "title": "Identity - Principal ID"
        },
        {
            "id": "identity.type",
            "title": "Identity - Type"
        },
        {
            "id": "properties.publicNetworkAccess",
            "title": "Properties - Public Network Access"
        }
    ]
}
```

---

## Usage and Integration

### Configuration File Path
Ensure the `user-configs.json` file is located in the directory specified by the script configuration settings.

### Integration with Scripts
This file is loaded and merged with application configurations during the execution of:
- **`configure-settings`**: Ensures user-defined settings override application defaults.
- **`exporting-resources`**: Uses the `export` section to determine the fields to include in the output.
- **`batching-resources`**: Adjusts batch size and limits based on the `params` section.

---

## Notes

- Ensure the file is well-formatted JSON to prevent parsing errors.
- Use descriptive titles in the `export` section for clarity in reports.
- Update the `reports.environments` section to include all required environments for reporting.

---

## Additional Resources

- [JSON Syntax and Structure](https://www.json.org/json-en.html)
- [PowerShell JSON Overview](https://learn.microsoft.com/en-us/powershell/scripting/json-overview)
