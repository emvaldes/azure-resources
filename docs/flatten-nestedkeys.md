# Flatten Nested Keys Function

## Overview
The **`flatten-nestedkeys`** function simplifies deeply nested JSON or hashtable structures by extracting specific values using pseudo keys (dot notation). It navigates through complex hierarchical data, adds extracted values to the top-level hashtable, and enables easier access and manipulation of nested properties.

---

## Key Features

- **Nested Key Resolution**: Extracts values from deeply nested structures using dot notation.
- **Array Indexing**: Handles array indices within paths, enabling access to specific elements inside arrays.
- **Dynamic Key Addition**: Adds the resolved pseudo keys and their corresponding values directly to the top-level hashtable.
- **Flexible Input**: Accepts custom pseudo key definitions to target specific paths.
- **Error Handling**: Handles missing keys, null values, and invalid paths gracefully.

---

## Prerequisites

Before using this function, ensure the following:

1. **Input Data**:
   - `$HashedObject` must be a valid hashtable representing the data structure to flatten.
   - `$PseudoKeys` must be an array of pseudo key definitions, each containing:
     - `id`: Dot notation path to the desired value.
     - `title` (optional): Title or label for the pseudo key.
2. **Data Structure**:
   - The input data should be hierarchical, such as JSON objects converted into hashtables.

---

## Parameters

### Input Parameters

- **`$HashedObject`** *(hashtable)*:
  - The hierarchical data structure to process.
- **`$PseudoKeys`** *(array)*:
  - Array of pseudo key definitions specifying the paths to extract.

---

## Workflow

### 1. **Iterate Through Pseudo Keys**
   - Loops through each key definition in `$PseudoKeys`.
   - Extracts the `id` (pseudo key path) and `title` from each definition.

### 2. **Navigate Nested Paths**
   - Splits the pseudo key path into segments using the dot (`.`) delimiter.
   - Iteratively traverses the `$HashedObject` structure to resolve each segment.
   - Handles array indices using square brackets (e.g., `items[0].name`).

### 3. **Validate and Extract Values**
   - Ensures that each segment exists and is accessible.
   - Assigns `null` if the path is invalid or the value cannot be resolved.

### 4. **Add Resolved Keys**
   - Adds the extracted value to the `$HashedObject` with the pseudo key as the new top-level key.
   - Skips null values to avoid cluttering the top-level hashtable.

---

## Example Usages

### Example 1: Flatten Nested Structure
```powershell
# Input data
$HashedObject = @{
    items = @(
        @{ name = "Item1"; details = @{ description = "First item" } },
        @{ name = "Item2"; details = @{ description = "Second item" } }
    )
}

# Pseudo keys
$PseudoKeys = @(
    @{ id = "items[0].details.description"; title = "FirstItemDescription" },
    @{ id = "items[1].details.description"; title = "SecondItemDescription" }
)

# Call the function
flatten-nestedkeys -HashedObject $HashedObject -PseudoKeys $PseudoKeys

# Output:
# $HashedObject now contains:
# @{
#    items = @( ... );
#    "items[0].details.description" = "First item";
#    "items[1].details.description" = "Second item";
# }
```

### Example 2: Handle Missing Keys
```powershell
# Input data
$HashedObject = @{
    items = @( @{ name = "Item1" } )
}

# Pseudo keys
$PseudoKeys = @(
    @{ id = "items[0].details.description" }
)

# Call the function
flatten-nestedkeys -HashedObject $HashedObject -PseudoKeys $PseudoKeys

# Output:
# $HashedObject now contains:
# @{
#    items = @( ... );
#    "items[0].details.description" = $null;
# }
```

---

## Dependencies and Linked Components

### Parameters
- **`$HashedObject`**: Input hierarchical data structure to flatten.
- **`$PseudoKeys`**: Definitions of the keys to extract.

### Output
- Modifies `$HashedObject` in place by adding extracted values as new keys.

---

## Error Handling

- **Missing Keys**: Skips and logs null values for paths that cannot be resolved.
- **Invalid Paths**: Handles errors gracefully without terminating execution.
- **Array Bounds**: Ensures array indices are within bounds; assigns `null` if out of bounds.

---

## Notes

- Ensure that pseudo keys are correctly defined with valid paths for your data structure.
- Test with representative data to confirm the accuracy of path resolutions.
- This function modifies the input `$HashedObject` directly; use a copy if the original structure must remain unchanged.

---

## Additional Resources

- [PowerShell Hashtable Documentation](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/hashtable)
- [PowerShell Arrays](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/arrays)
