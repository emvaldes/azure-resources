# Applying Changes Function

## Overview
The **`applying-changes`** function processes key-value pairs by applying transformation rules and configurations. It ensures that data is dynamically updated and formatted based on pre-defined change actions (e.g., splitting or extracting values). This function is integral to adapting input data to meet specific configuration requirements.

---

## Key Features

- **Dynamic Value Transformation**: Supports actions like splitting and extracting values based on configurable rules.
- **User-Defined Configuration**: Adapts behavior using rules defined in the `$Script:AppConfigs` variable.
- **Error Handling**: Logs warnings for invalid or missing data, ensuring seamless execution.
- **Data Validation**: Checks for null or empty values and skips processing as needed.
- **Ordered Output**: Maintains data structure integrity using ordered hashtables.

---

## Prerequisites

Before using this function, ensure the following:

1. **Configuration File**:
   - `$Script:AppConfigs` must include an `items` section with key-specific rules.
2. **Input Data**:
   - Key-value pairs passed as `$key` and `$value` parameters must align with the configuration.

---

## Parameters

### Input Parameters

- **`$key`** *(string, mandatory)*:
  - The key to process.
- **`$value`** *(string, mandatory)*:
  - The value associated with the key to be transformed.

---

## Workflow

### 1. **Null or Empty Value Check**
   - Returns early if `$value` is null or empty.

### 2. **Configuration Lookup**
   - Finds the key in `$Script:AppConfigs.items`.
   - Retrieves associated `change` rules and `remove` flags.

### 3. **Apply Change Rules**
   - Iterates through `change` rules and processes each action:
     - **Split**:
       - Splits the value into sections using a specified divisor.
       - Extracts segments based on indices and range definitions.
     - **Extract**:
       - Extracts a specific section or range of the value using a divisor.

### 4. **Data Validation and Output**
   - Ensures indices are within bounds for split and extract actions.
   - Logs warnings for out-of-bounds or invalid operations.
   - Returns a structured output containing transformed data and a `remove` flag.

---

## Example Usages

### Example 1: Split Value Based on Configuration
```powershell
# Example configuration
$Script:AppConfigs = @{
    items = @(
        @{ id = "name"; change = @(@{ action = "split"; divisor = "/"; fields = @(@{ id = "part1"; index = 0 }, @{ id = "part2"; index = 1 }) }) }
    )
}

# Call the function
$applyingChangesResult = applying-changes -key "name" -value "resource/group"

# Output:
# @{ "objects" = [ordered]@{ "part1" = @{ "id" = "part1"; "value" = "resource" }; "part2" = @{ "id" = "part2"; "value" = "group" } }; "remove" = $false }
```

### Example 2: Extract Value from a Delimited String
```powershell
# Example configuration
$Script:AppConfigs = @{
    items = @(
        @{ id = "id"; change = @(@{ action = "extract"; divisor = "-"; index = 2 }) }
    )
}

# Call the function
$applyingChangesResult = applying-changes -key "id" -value "123-456-789"

# Output:
# @{ "objects" = [ordered]@{ "id" = @{ "id" = "id"; "value" = "789" } }; "remove" = $false }
```

### Example 3: Handle Empty Value
```powershell
# Call the function with an empty value
$applyingChangesResult = applying-changes -key "name" -value ""

# Output:
# @{ "objects" = [ordered]@{}; "remove" = $false }
```

---

## Dependencies and Linked Components

### Configuration Files
- **`$Script:AppConfigs`**:
  - Defines the rules for processing keys and values.

---

## Error Handling

- **Null or Empty Values**: Logs warnings and skips processing for invalid inputs.
- **Out-of-Bounds Indices**: Ensures indices for split or extract actions are within bounds and logs warnings otherwise.
- **Invalid Rules**: Skips processing if rules are incorrectly configured or missing.

---

## Notes

- Ensure the `items` section in `$Script:AppConfigs` is properly defined for all keys to be processed.
- Test the function with various input cases to validate configuration rules.
- Extend the function to support additional actions if required.

---

## Additional Resources

- [PowerShell Hashtable Documentation](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/hashtable)
- [PowerShell Error Handling](https://learn.microsoft.com/en-us/powershell/scripting/deep-dives/error-handling)
