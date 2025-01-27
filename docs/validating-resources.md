# Validating Resources Function

## Overview
The **`validating-resources`** function is a critical component of the Azure Resources Management project. It is responsible for processing Azure resource objects by validating and applying changes based on unique keys and configurations. This function ensures that the resource data is accurate, consistent, and ready for subsequent operations, such as exporting or reporting.

---

## Key Features

- **Validation of Resource Data**: Ensures each resource object is processed against a set of unique keys.
- **Dynamic Updates**: Modifies resource objects based on payloads returned by the `applying-changes` function.
- **Flattening Nested Keys**: Handles nested JSON structures for easier processing.
- **Error Handling**: Robust error handling with custom error messages and exit codes.
- **Maintained Order**: Processes objects in the same order as they are received to preserve consistency.

---

## Prerequisites

Before using this function, ensure the following:

1. **Azure Resources Prepared**: The resources to be validated must be loaded into `$Script:HashedObjects`.
2. **Unique Keys Defined**: A list of unique keys must be defined in `$Script:UniqueKeys` for validation.
3. **Linked Functions Available**:
   - Ensure the `applying-changes`, `flatten-nestedkeys`, and `catching-errors` functions are available in your environment.

---

## Parameters

This function does not take direct input parameters but relies on the following script-level variables:

- **`$Script:HashedObjects`**: Input resource objects to be validated.
- **`$Script:UniqueKeys`**: Configuration containing the unique keys and their processing rules.

---

## Workflow

### 1. **Iterating Through Resources**
   - Loops through each resource object stored in `$Script:HashedObjects`.
   - For each object, iterates through the unique keys defined in `$Script:UniqueKeys`.

### 2. **Validation and Updates**
   - Checks if the resource object contains the specified key.
   - If the key exists, calls the `applying-changes` function with the key and its associated value.
   - Updates the resource object with the returned payload (e.g., adding new properties).
   - Marks keys for removal if indicated by the payload.

### 3. **Flattening Nested Structures**
   - Calls the `flatten-nestedkeys` function to process pseudo-keys and simplify nested structures within the resource object.

### 4. **Error Handling**
   - Catches any errors encountered during the validation process.
   - Logs errors and exits with a specific code if resource extraction fails.

---

## Example Usages

### Example 1: Standard Validation
```powershell
# Populate script-level variables
$Script:HashedObjects = @(
    @{ id = "resource1"; name = "Example Resource"; location = "eastus" },
    @{ id = "resource2"; name = "Another Resource"; location = "westus" }
)
$Script:UniqueKeys = @(
    @{ id = "location"; remove = $false },
    @{ id = "name"; remove = $false }
)

# Call the validating-resources function
validating-resources
```

### Example 2: Handling Errors
```powershell
# Simulate invalid input to trigger error handling
$Script:HashedObjects = @(
    @{ id = "resource1"; name = "Example Resource" }
)
$Script:UniqueKeys = @(
    @{ id = "location"; remove = $false }
)

# Call the function
validating-resources
# Error: Unable to Extract Resources!
```

---

## Dependencies and Linked Components

### Functions
- **[applying-changes](./applying-changes)**: Applies updates to resource objects.
- **[flatten-nestedkeys](./flatten-nestedkeys)**: Flattens nested JSON structures.
- **[catching-errors](./catching-errors)**: Handles errors during execution.

### Variables
- **`$Script:HashedObjects`**: Stores the resource objects to be validated.
- **`$Script:UniqueKeys`**: Contains the unique keys to validate and process within each resource object.

---

## Error Handling

- Uses the `catching-errors` function for managing exceptions.
- Logs detailed error messages and exits with error code `17` in case of failures.
- Ensures no incomplete or incorrect processing of resources occurs during execution.

---

## Notes

- Ensure that `$Script:HashedObjects` and `$Script:UniqueKeys` are populated correctly before invoking this function.
- The function maintains the order of processing to ensure data consistency.
- Automatically simplifies nested keys for better processing and accessibility.

---

## Additional Resources

- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
- [JSON in PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/json-overview)
