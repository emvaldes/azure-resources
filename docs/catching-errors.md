# Catching Errors Function

## Overview
The **`catching-errors`** function is a centralized error-handling mechanism for the Azure Resources Management project. It logs error details, provides context for troubleshooting, and ensures consistent behavior across scripts by managing execution flow gracefully. This function is critical for maintaining robustness and transparency in the event of failures.

---

## Key Features

- **Error Logging**: Captures error messages and additional context, appending them to an `error.log` file.
- **Severity Levels**: Supports configurable severity levels for warnings, errors, and critical failures.
- **Execution Control**: Aborts script execution gracefully with a specified exit code.
- **Verbose Logging**: Provides additional context when the `-Verbose` flag is enabled.

---

## Prerequisites

Before using this function, ensure the following:

1. **Log File Accessibility**:
   - The `error.log` file is writable in the current working directory.
2. **Verbose Mode**:
   - Optional: Enable verbose mode to include context-specific details in logs and console output.

---

## Parameters

### Input Parameters

- **`$ErrorMessage`** *(string)*:
  - The error message to log and display.
- **`$Context`** *(string, optional)*:
  - Additional information or context about the error.
- **`$Severity`** *(string, optional)*:
  - The severity level of the error (default: `Error`). Options include `Warning`, `Error`, or `Critical`.
- **`$ExitCode`** *(int, optional)*:
  - The exit code to terminate the script with (default: `1`).

---

## Workflow

### 1. **Prepare Error Message**
   - Formats the error message with a timestamp and includes severity and context details.

### 2. **Log to File**
   - Appends the formatted error message to the `error.log` file.

### 3. **Verbose Logging**
   - Outputs additional context information to the console if the `-Verbose` flag is enabled.

### 4. **Write to Console**
   - Displays the error message on the console using `Write-Error`.

### 5. **Terminate Execution**
   - Aborts the script gracefully using the specified exit code.

---

## Example Usages

### Example 1: Log and Abort Execution
```powershell
# Call the function with an error message and exit code
catching-errors -ErrorMessage "File not found" -ExitCode 2

# Output:
# [Error]: File not found
# Error logged to 'error.log'. Script terminated with exit code 2.
```

### Example 2: Log a Warning with Context
```powershell
# Call the function with a warning severity and additional context
catching-errors -ErrorMessage "Low disk space" -Context "Server: AzureVM1" -Severity "Warning"

# Output:
# [Warning]: Low disk space
# Context: Server: AzureVM1
# Warning logged to 'error.log'.
```

### Example 3: Verbose Mode
```powershell
# Enable verbose mode and call the function
$VerbosePreference = "Continue"
catching-errors -ErrorMessage "Authentication failed" -Context "Invalid credentials for Azure login" -Verbose

# Output:
# [Error]: Authentication failed
# Context: Invalid credentials for Azure login
# Error logged to 'error.log'. Script terminated with exit code 1.
```

---

## Dependencies and Linked Components

### Functions
- **[configure-settings](./configure-settings)**: Utilizes this function to handle errors during configuration setup.
- **[fetching-resources](./fetching-resources)**: Logs errors if resource fetching fails.

### Log File
- **`error.log`**:
  - Default location for storing error messages.

---

## Error Handling

- **Log File Issues**: If the `error.log` file cannot be written, ensure the directory is writable and has sufficient permissions.
- **Verbose Mode**: Displays detailed information on the console when enabled.
- **Exit Codes**: Ensure that the provided exit codes are meaningful for the script's workflow.

---

## Notes

- Use consistent exit codes throughout your scripts for better error tracking and debugging.
- The function is designed to abort execution immediately after logging an error.
- Ensure the `error.log` file is reviewed periodically and archived as needed.

---

## Additional Resources

- [PowerShell Write-Error Documentation](https://learn.microsoft.com/en-us/powershell/scripting/deep-dives/error-handling)
- [PowerShell Verbose Output](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_verbose)
