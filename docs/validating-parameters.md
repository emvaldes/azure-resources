# Validating Parameters Function

## Overview
The **`validating-parameters`** function is a key utility in the Azure Resources Management project. Its purpose is to ensure that critical input parameters, such as the environment name, are provided and validated before the execution of the workflow. This function enhances the reliability of scripts by preemptively catching missing or invalid parameters.

---

## Key Features

- **Interactive Parameter Validation**: Prompts the user for missing parameters interactively.
- **Input Validation**: Ensures that the provided input meets basic requirements (e.g., not empty or null).
- **Error Management**: Logs warnings and provides retry mechanisms for invalid inputs.
- **User-Friendly Prompts**: Utilizes intuitive messaging to guide users during parameter entry.

---

## Prerequisites

Before using this function, ensure the following:

1. **PowerShell Environment**: A valid PowerShell environment with access to the project scripts.
2. **User Context**: The function must be executed in an interactive session to allow user input via prompts.

---

## Parameters

The function does not explicitly accept parameters as arguments but instead works with the following:

- **`$Environment`** (Global Variable):
  - The environment name parameter required for subsequent workflows.
  - Examples: `prod`, `dev`, `test`.

---

## Workflow

### 1. **Check for Missing Environment Parameter**
   - If the `$Environment` variable is not set or is empty, the function triggers an interactive prompt to request input.

### 2. **Validate Input**
   - Verifies that the provided input is not null or empty.
   - Rejects invalid inputs and logs a warning, allowing the user to retry.

### 3. **Error Management**
   - Logs warnings instead of terminating the script immediately for invalid inputs.
   - Includes a retry loop to ensure valid input is obtained.

### 4. **Return Valid Environment**
   - Once a valid environment name is provided, the function exits, returning control to the main script.

---

## Example Usages

### Example 1: Interactive Input
```powershell
# Simulate missing environment variable
$Environment = $null

# Call the function
validating-parameters

# User is prompted:
# Please, enter the environment name: [user types "prod"]

# Output:
# Environment is set to "prod"
```

### Example 2: Invalid Input Handling
```powershell
# Simulate missing or invalid environment variable
$Environment = ""

# Call the function
validating-parameters

# User is prompted:
# Please, enter the environment name: [user types " "]
# Warning: Invalid input. Please enter a valid environment name.

# User re-enters "dev" and the script proceeds
```

---

## Error Handling

- **Warning Messages**: Provides warnings instead of immediate termination for invalid inputs.
- **Retry Mechanism**: Allows users to retry entering valid input until successful.
- **Graceful Exit**: Ensures the function exits cleanly once valid input is obtained.

---

## Notes

- This function is designed to operate interactively and may not work as intended in non-interactive sessions.
- Ensure that `$Environment` is explicitly set in non-interactive contexts to avoid runtime issues.
- Customize the input prompt and validation logic if required for specific workflows.

---

## Linked Components

### Functions
- **[fetching-resources](./fetching-resources)**: Requires a valid `$Environment` to retrieve resources.
- **[configure-settings](./configure-settings)**: Utilizes `$Environment` to load environment-specific configurations.

---

## Additional Resources

- [PowerShell Read-Host Documentation](https://learn.microsoft.com/en-us/powershell/scripting/core-powershell/console/read-host)
