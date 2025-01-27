# Manage Azure Session Function

## Overview
The **`manage-azuresession`** function ensures that a valid Azure session is established and maintained for the Azure Resources Management project. It validates the current session token and reauthenticates if necessary, guaranteeing uninterrupted access to Azure resources.

---

## Key Features

- **Session Validation**: Checks the validity of the current Azure session using `az account get-access-token`.
- **Automatic Reauthentication**: Prompts reauthentication when the session is invalid or expired.
- **Debug Mode Support**: Displays detailed session and account information when debugging is enabled.
- **Error Handling**: Provides informative error messages and ensures graceful failure for invalid credentials.

---

## Prerequisites

Before using this function, ensure the following:

1. **Azure CLI**:
   - Installed and configured.
   - Must be accessible via the `az` command.
2. **User Credentials**:
   - The account must have sufficient permissions to access Azure resources.
3. **Network Access**:
   - Internet connectivity to communicate with Azure authentication endpoints.

---

## Parameters

The function does not accept explicit input parameters but relies on:

- **Global Variables**:
  - `$Script:AccessToken`: Stores the Azure session access token for reuse.
  - `$Debug`: Enables debug-level output.

---

## Workflow

### 1. **Session Validation**
   - Invokes the `Validate-AzureSession` sub-function to check the validity of the current Azure session using the command:
     ```powershell
     az account get-access-token --output json
     ```
   - Returns `$true` if the session is valid and `$false` otherwise.

### 2. **Reauthentication**
   - If the session is invalid, prompts reauthentication by executing:
     ```powershell
     az login --scope https://management.core.windows.net//.default
     ```
   - Validates the new session to confirm successful reauthentication.

### 3. **Debug Information**
   - When `$Debug` is enabled, displays:
     - The Azure access token.
     - Current account details using:
       ```powershell
       az account show
       ```

### 4. **Error Handling**
   - Logs warnings when the session is invalid or expired.
   - Throws an exception if reauthentication fails, providing a clear error message for troubleshooting.

---

## Example Usages

### Example 1: Validate Existing Session
```powershell
# Run the function to validate the current Azure session
manage-azuresession

# Output (if valid):
# Azure session is valid.
```

### Example 2: Reauthenticate When Session Expires
```powershell
# Simulate an expired session
$Script:AccessToken = $null

# Call the function to reauthenticate
manage-azuresession

# Output:
# Reauthenticating to Azure...
# Re-authentication was successful.
```

### Example 3: Debugging Mode
```powershell
# Enable debug mode
$Debug = $true

# Call the function
manage-azuresession

# Output:
# Azure Access Token:
# {access token details}
# Azure Account Info:
# {account details}
```

---

## Dependencies and Linked Components

### Sub-Functions
- **`Validate-AzureSession`**: Validates the Azure session token using the `az` CLI.

### Global Variables
- **`$Script:AccessToken`**: Stores the session token for validation and reuse.
- **`$Debug`**: Enables verbose logging and debugging information.

---

## Error Handling

- **Warnings**: Logs warnings when the session is invalid.
- **Exceptions**: Throws errors with clear messages when reauthentication fails.
- **Debug Output**: Provides detailed session and account information for troubleshooting in debug mode.

---

## Notes

- Ensure that the Azure CLI is installed and accessible before running this function.
- Reauthentication requires valid credentials and sufficient permissions for the target Azure account.
- Test the function in both debug and non-debug modes to verify behavior.

---

## Additional Resources

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [Azure Authentication Overview](https://learn.microsoft.com/en-us/azure/active-directory/develop/authentication-scenarios)
