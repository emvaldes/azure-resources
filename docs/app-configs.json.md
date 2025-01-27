# Application Configurations File (app-configs.json)

## Overview
The **`app-configs.json`** file serves as the primary configuration source for the Azure Resources Management project. It provides detailed instructions for resource transformation, data filtering, and export customization. This configuration file is essential for ensuring consistent and flexible handling of Azure resource data across environments.

---

## Key Features

- **Resource Transformation**: Defines transformation rules for key fields (e.g., splitting, extracting values).
- **Field Management**: Specifies which fields to include, modify, or exclude.
- **Export Configuration**: Lists fields to export and their display titles.
- **Nested Data Handling**: Supports hierarchical data structures using `items` arrays.

---

## Structure and Fields

### 1. **provider** *(string)*
Specifies the target cloud provider.
- Example: `"azure"`

### 2. **items** *(array)*
Defines individual fields for transformation and processing:

#### Field Properties
- **`id`** *(string)*: Unique identifier for the field (e.g., `etag`, `sku.name`).
- **`change`** *(array, optional)*: Transformation rules for the field. Each rule includes:
  - **`action`** *(string)*: Action to perform (`split` or `extract`).
  - **`divisor`** *(string)*: Delimiter used for splitting or extracting values.
  - **`index`** *(int, optional)*: Index of the segment to extract.
  - **`fields`** *(array, optional)*: Additional field definitions for split actions.
- **`remove`** *(bool)*: Indicates whether to exclude the field.
- **`items`** *(array, optional)*: Nested fields or sub-properties within the field.

#### Example
```json
{
    "id": "id",
    "change": [
        {
            "action": "split",
            "divisor": "/",
            "fields": [
                { "id": "subscription", "index": 2 },
                { "id": "resource", "index": 6 }
            ]
        }
    ],
    "remove": true
}
```

### 3. **export** *(array)*
Defines fields for export along with their display titles:
- **`id`** *(string)*: Field identifier (e.g., `etag`, `location`).
- **`title`** *(string)*: Human-readable title for the export field.

#### Example
```json
{
    "id": "etag",
    "title": "E-Tag"
}
```

---

## Example Configuration

### Complete File
```json
{
    "provider": "azure",
    "items": [
        {
            "id": "id",
            "change": [
                {
                    "action": "split",
                    "divisor": "/",
                    "fields": [
                        { "id": "subscription", "index": 2 },
                        { "id": "resource", "index": 6 }
                    ]
                }
            ],
            "remove": true
        },
        {
            "id": "identity",
            "items": [
                "principalId",
                "tenantId",
                "type"
            ]
        }
    ],
    "export": [
        { "id": "etag", "title": "E-Tag" },
        { "id": "location", "title": "Location" }
    ]
}
```

---

## Usage and Integration

### Configuration File Path
Ensure the `app-configs.json` file is accessible at the specified path in the script configuration.

### Integration with Scripts
This file is used during:
- **`configure-settings`**: Loads and validates application-level configurations.
- **`applying-changes`**: Applies transformation rules defined in the `items` section.
- **`exporting-resources`**: Determines fields to include and their titles in export files.

---

## Notes

- Always ensure that the `change` rules in the `items` section are properly defined to avoid runtime errors.
- Use the `remove` property to exclude unnecessary fields from further processing.
- Update the `export` section to include all fields required in reports or data exports.

---

## Additional Resources

- [JSON Syntax and Structure](https://www.json.org/json-en.html)
- [PowerShell JSON Overview](https://learn.microsoft.com/en-us/powershell/scripting/json-overview)
