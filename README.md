# Azure Resources - Manage Reporting

## Overview

This PowerShell script is designed for efficient batch processing of Azure resources using the Azure CLI (`az`).<br />
It automates resource data retrieval, processes data in parallel using background jobs, and compiles the results into a JSON file. The script is modular, flexible, and supports advanced customization options for deployment scenarios.

### Project Genesis

The script was created to address a very specific automation issue.<br />

*   Provide an [automated mechanism](azure-resources.ps1) (script) to manage loging/session credentials with verbosity and proper error-handling.
*   Allow end-users to define how the fetched/retrieved data would be structured. What was important or of value to them and adjust data-structures as needed. **Note**: This is managed via an application (script) [JSON configuration](azure-resources.json) file.
*   Offering different file-formats to export the processed data as tabularized output.

The different captured data (JSON Objects) needed to be automatically refrehsed if it has expired (limited timeframe) but otherwised, stored and re-used. The script downloads all the Subscription Resources and then generate scope-specific files to expedite the filtering process.

At first, a simple request was made to find a way to fetch (enumerate) all Azure Infrastructure Resources in a Subscription and provide some tabularizzed data output (e.g.: CSV/TSV or MS Excel).<br />
**Note**: A specific Scripting language requirement was not defined so I decided to Script in PowerShell. I will allocate some time to port this into Python and help others with their existential insecurities if Python is not used. ;)

### Objectives

1. Provide an [automated mechanism](azure-resources.ps1) for managing login/session credentials with robust error handling and verbose logging.
2. Enable end-users to customize data structures dynamically via configuration files ([app-configs.json](azure-resources.json)).
3. Support multiple export formats (e.g., CSV, TSV, Excel) for tabularized output.
4. Refresh cached data automatically if expired, while maintaining high performance.

---

### Core Functionality
- **Batch Processing:**
  - Splits large datasets into smaller batches for efficient processing.
  - Supports configurable batch sizes and limits.

- **Parallel Execution:**
  - Utilizes PowerShell background jobs for concurrent processing of resources.

- **Azure CLI Integration:**
  - Fetches resource data directly using `az resource show`.

- **JSON Output:**
  - Outputs processed data to a JSON file, with options for formatting and error handling.

- **Error Handling:**
  - Gracefully handles errors at both resource and batch levels.
  - Provides detailed error messages for troubleshooting.

- **Customizable Configuration:**
  - Adjustable batch size and depth of JSON object conversion.

### Advanced Capabilities
- **Depth Control:** Handles deeply nested JSON structures with customizable deserialization depth.
- **Output Management:** Automatically creates and manages JSON files for processed data.
- **Custom Error Handling:** Integrates with the `catching-errors` function for centralized error logging.
- **Cross-Platform Compatibility:** Fully compatible with PowerShell Core and Windows PowerShell across multiple operating systems.

---

### Design Principles

- **Modularity:**
  - Separate concerns between batch-level operations (`Batching-Resources`) and resource-level processing (`Batching-Deployment`).

- **Scalability:**
  - Parallel job execution ensures scalability for processing large datasets.

- **Error Resilience:**
  - Errors in individual resource processing do not interrupt the overall execution.

- **Resource Efficiency:**
  - Limits memory usage by leveraging jobs and processing resources in batches.

---

### Requirements

1. **Azure CLI**
   - Install and authenticate the Azure CLI on your system.
2. **PowerShell**
   - Compatible with PowerShell Core or Windows PowerShell.
3. **PowerShell Modules**
   - Ensure modules like `ImportExcel` are installed for advanced exporting features.
4. **Configuration Files**
  - Verify the presence of JSON configurations (e.g.: [app-configs.json](app-configs.json) and optionally [user-configs.json](user-configs.json)) for advanced customization.<br /> Alterntively, you can use YAML configurations files (provided in the project).
3. **Resource Data**
   - Input data should be an array of Azure Resources with valid `id` properties.

**Requirements**: If you are a [MacOS](docs/install-powershell.md#install-powershell-on-macos) or a [Linux](docs/install-powershell.md#install-the-az-powershell-module) user, please follow these install instructions. If you are [Windows user](docs/install-powershell.md#install-the-az-powershell-module), you might already have PowerShell installed but try to get the latest version.

---

#### NAME
  azure-resources/azure-resources.ps1

#### SYNOPSIS
  The script manages the download and filtering of Azure Subscription Resources.
  Fetching configurations and exporting them based on a specific output criteria.
  Note: The script uses Batch-Processing for data and Caching to expedite operations.

#### DESCRIPTION
  This script automates the processing of retrieving and parsing Azure resources
  in batches, using Azure CLI, processing the JSON-data concurrently with background jobs,
  and saves the output to a JSON file.
  It is highly configurable and supports error handling, verbose logging, and JSON-driven configurations.

#### **Application Parameters**
The script supports multiple modes of operation with flexible parameters.

| Parameter | Alias | Description |
|-----------|-------|-------------|
| `-Environment` | `-e` | Target environment (e.g., prod, dev, test). |
| `-Platform` | `-p` | Application Configuration files (JSON/YAML). |
| `-ExportFormat` | `-x` | Supports export formats like: csv, tsv, json, excel. |
| `-BatchSize` | `-s` | Configure total items for Batch's data-sets (resources). |
| `-BatchLimit` | `-l` | Configure total amount of Batch iterations to process. |
| `-CacheExpiry` | `-c` | Defines when (Minutes) it's time to refresh JSON resources. |
| `-MaxDepth` | `-m` | Defines JSON max levels of nested objects to be parsed. |
| `-Override` | `-o` | Overriding operational workflows constrains. |
| `-Verbose` | `-v` | Activates the use of vervbosity-level in the script's output. |
| `-Debug` | `-d` | Activates the use of debug-level in the script's output. |
| `-Help` | `-h` | Provides built-in native script operational support . |

```powershell
param (
    [ValidateNotNullOrEmpty()][Alias("e")]
    [string]$Environment,
    [ValidateSet( 'json', 'yaml' )][Alias("p")]
    [string]$Platform = 'json',
    [ValidateSet( 'csv', 'tsv', 'excel', 'xlsx' )][Alias("x")]
    [string]$ExportFormat = 'csv',
    [ValidateRange( 1, 10 )][Alias("s")]
    [int]$BatchSize = 10,
    [Alias("l")]
    [int]$BatchLimit = 0,
    [ValidateRange( 1, 1440 )][Alias("c")]
    [int]$CacheExpiry = 1440,
    [Alias("m")]
    [int]$MaxDepth = 20,
    [Alias("o")]
    [switch]$Override,
    [Alias("v")]
    [switch]$Verbose,
    [Alias("d")]
    [switch]$Debug
)
```

#### **User Configurations**

**Objective**: The "params" property provides a user-centric configuration for the application.<br />
**Note**: It's superceeding the application's default behavior but run-time parameters will override them.

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
            {
                "id": "demo",
                "title": "Demonstration"
            },
            {
                "id": "test",
                "title": "Testing / Q&A"
            },
            {
                "id": "staging",
                "title": "Staging / UAT"
            },
            {
                "id": "prod",
                "title": "Production"
            }
        ]
    },
    ...
}
```

```yaml
params:
  ExportFormat: "excel"
  BatchSize: 10
  BatchLimit: 0
  CacheExpiry: 1440
  MaxDepth: 20

reports:
  folder: "Azure-Reports"
  environments:
    - id: "demo"
      title: "Demonstration"
    - id: "test"
      title: "Testing / Q&A"
    - id: "staging"
      title: "Staging / UAT"
    - id: "prod"
      title: "Production"
...
```

#### **Example 1:**

```powershell
.\azure-resources.ps1 -Environment 'prod'
                      -Platform 'json'
                      -ExportFormat 'csv'
                      -BatchSize 10
                      -BatchLimit 10
                      -CacheExpiry 60
                      -MaxDepth 10
                      -Verbose
                      -Debug ;
```

#### **Example 2:**

**Objective**: Reporting on Azure Resources for the Production (prod) environment and exporting JSON object's keys (columns) as MS Excel file-format.
```powershell
.\azure-resources.ps1 -Environment 'prod' `
                      -ExportFormat 'excel' `
                      -Verbose ;
```

#### **Example 2:**

**Objective**: Specify batch size and limit to sampling data-sets.
```powershell
.\azure-resources.ps1 -Environment 'prod' `
                      -BatchSize 3 `
                      -BatchLimit 2 `
                      -ExportFormat 'excel' `
                      -Verbose ;
```

#### **Request Support**

```powershell
.\azure-resources.ps1 -Help ;
```

```powershell
azure-resources.ps1 [[-Environment] <String>] [[-Platform] <String>]
[[-ExportFormat] <String>] [[-BatchSize] <Int32>] [[-BatchLimit] <Int32>]
[[-CacheExpiry] <Int32>] [[-MaxDepth] <Int32>] [-Override] [-Verbose] [-Debug]
[-Help] [<CommonParameters>]
```

#### RELATED LINKS
  https://github.com/emvaldes/azure-resources

#### REMARKS
  To see the examples, type: "Get-Help ./azure-resources.ps1 -Examples"
  For more information, type: "Get-Help ./azure-resources.ps1 -Detailed"
  For technical information, type: "Get-Help ./azure-resources.ps1 -Full"
  For online help, type: "Get-Help ./azure-resources.ps1 -Online"

#### NOTES

  - Ensure that the Azure CLI (`az`) is installed and authenticated.
  - Required: Installing the ImportExcel module. The libgdiplus (GDI+-compatible API) package.
  - The script generates JSON reporting sources. Drives workflow based on JSON/YAML config files.

---

#### Project's evolution

These commands would get the job done manually:

**Note**: Please, I would suggest that you review this [PowerShell platform](docs/powershell-framework.md) and decide which one works better for you. My recommend path is to embrace the cross-platform method I used [here](docs/powershell-framework.md#azure-cli-cross-platform).

1.  Fetch all Azure Resources (list: JSON output) and identify a specific ID:
```powershell
  # Get all resources
  > $resources = az resources list --query "[].{id:id}" `
                                   --output json | ConvertFrom-Json ;
```

2.  Define the target pattern and output file.
```powershell
  > $target = "*prod*" ;
  > $filename = "<file-name>.json" ;
```

3. Filter resources that match the target pattern.
```powershell
  > $environment = $resources | Where-Object { $_.id -like $target } ;
```

4. Create an array to hold the detailed resource data.
```powershell
  > $jsonArray = @() ;
```

5. Retrieve detailed information for each matching resource and add it to the array.
```powershell
  > $environment | ForEach-Object {
  $resourceDetails = az resource show --id $_.id --output json | ConvertFrom-Json ;
  $jsonArray += $resourceDetails ;
  } ;
```

6. Convert the array to JSON and save it to the file
```powershell
  > $jsonArray | ConvertTo-Json -Depth 10 | Out-File -FilePath $filename ;
```

**Note**: Alternatively, you could use the [JQ](https://jqlang.github.io/jq/) (lightweight and flexible command-line JSON processor) to parse these resources. Nevertheless, understand that a unified and more simple mechanism was needed to address all these needs and this solution was built to accomplish that.

``` console
$ jq '[.[] | select(.identity != null and .identity.principalId != null)
           | .identity.principalId]' ./.configs/azure.resources.json ;
[
  "9edc6208-d5b1-4c58-a35b-ec241d032b28",
  ...
]
```

---

#### Program's Execution

``` console
$ pwsh ./azure-resources.ps1 -Verbose ;

Validating Azure Session ...

Azure Access Token:
{
  "accessToken": "eyJ0eXAiOi...XQVTdOZ5ww",
  "expiresOn": "2025-01-01 00:00:00.000000",
  "expires_on": 1735689600,
  "subscription": "9a389aa4-c9fe-4a59-80f8-bf454f4dae06",
  "tenant": "33888350-2082-40bb-88fa-a5e94d733f01",
  "tokenType": "Bearer"
}

Azure Account Info:
{
  "environmentName": "AzureCloud",
  "homeTenantId": "33888350-2082-40bb-88fa-a5e94d733f01",
  "id": "9edc6208-d5b1-4c58-a35b-ec241d032b28",
  "isDefault": true,
  "managedByTenants": [
  {
    "tenantId": "b06ad78d-4117-42d3-8c2b-bd73337bf208"
  }
  ],
  "name": "CONTOSO-COM-01",
  "state": "Enabled",
  "tenantDefaultDomain": "contoso.onmicrosoft.com",
  "tenantDisplayName": "CONTOSO",
  "tenantId": "33888350-2082-40bb-88fa-a5e94d733f01",
  "user": {
  "name": "user@domain.tld",
  "type": "user"
  }
}

Please, enter the environment name: prod

Checking cache for 'prod' ...
Initializing Subscription Resources ...

Retrieved 786 Subscription Resources

Checking cache for 'prod' ...
Filtering Environment 'prod' Resources ...
Filtered 202 resource(s) for Environment 'prod' Resources

Checking cache for 'prod' ...
Initializing Batching Resources ...

001/202: Microsoft.DBForPostgreSQL/servers/domain-pgsql-replica
002/202: Microsoft.Web/sites/domain-service
003/202: microsoft.insights/scheduledqueryrules/domain-504-alert
. . .
200/202: Microsoft.Web/certificates/domain-keyvault-service
201/202: Microsoft.Network/publicIPAddresses/domain-vnet-ip
202/202: Microsoft.Network/bastionHosts/domain-vnet-bastion

Total execution time: 1 minutes and 00 seconds

202 JSON Objects are present in file 'Azure-Reports/prod.details.json'.

Exporting resources as csv format into 'Azure-Reports/prod.details.csv'
Note: csv data exported successfully into 'Azure-Reports/prod.details.csv'
```

#### Following Executions

``` console
> ./azure-resources.ps1 ;
Please, enter the environment name: prod

Checking cache for 'prod' ...
Cache for 'prod' is valid. Loading Subscription Resources ...
Loaded 786 resources for 'prod' from Cache-file '.configs/all.resources.json'

Checking cache for 'prod' ...
Cache for 'prod' is valid. Loading Environment 'prod' Resources ...
Loaded 202 resources for 'prod' from Cache-file '.configs/prod.resources.json'

Checking cache for 'prod' ...
Cache for 'prod' is valid. Loading Batching Resources ...
Loaded 202 resources for 'prod' from Cache-file 'Azure-Reports/prod.details.json'

Total execution time: 0 minutes and 2 seconds

202 JSON Objects are present in file 'Azure-Reports/prod.details.json'.

Exporting resources as csv format into 'Azure-Reports/prod.details.csv'
```

---

### Related Documentation

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [PowerShell Scripting Documentation](https://learn.microsoft.com/en-us/powershell/scripting/)
- [JSON Configuration Best Practices](https://www.json.org/json-en.html)

---

### Troubleshooting

#### **Common Issues & Fixes**
| Issue | Solution |
|-------|-------|
| `Missing Azure CLI` | Ensure that the `az` CLI is installed and authenticated. |
| `Invalid Resource IDs` | Check that the input data contains valid Azure resource `id` properties. |
| `JSON File Errors` | Verify write permissions for the output directory. |

#### **Session Expired**

```console
ERROR: AADSTS50173: The provided grant has expired due to it being revoked, a fresh auth
token is needed. The user might have changed or reset their password.
The grant was issued on '2025-01-01T00:00:00.0000000Z' and the TokensValidFrom date
(before which tokens are not valid) for this user is '2025-01-01T00:00:00.0000000Z'.
Trace ID: 00000000-0000-0000-0000-000000000000
Correlation ID: 00000000-0000-0000-0000-000000000000 Timestamp: 2025-01-01 00:00:00Z
Interactive authentication is needed. Please run:
az login --scope https://management.core.windows.net//.default
```

#### **Re-Authenticating to Azure**

```console
Reauthenticating to Azure...

A web browser has been opened at
https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize.
Please continue the login in the web browser. If no web browser is available or if the
web browser fails to open, use device code flow with `az login --use-device-code`.
```

#### **Retrieving Tenants & Subscriptions**

``` console
Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name    Subscription ID                       Tenant
-----  -------------------  ------------------------------------  --------
[1] *  CONTOSO-COM-01       9a389aa4-c9fe-4a59-80f8-bf454f4dae06  CONTOSO

The default is marked with an *; the default tenant is 'CONTOSO' and subscription
is 'CONTOSO-COM-01' (9a389aa4-c9fe-4a59-80f8-bf454f4dae06).

Select a subscription and tenant (Type a number or Enter for no changes): 1

Tenant: CONTOSO
Subscription: CONTOSO-COM-01 (9a389aa4-c9fe-4a59-80f8-bf454f4dae06)

[Announcements]
With the new Azure CLI login experience, you can select the subscription you want
to use more easily. Learn more about it and its configuration
at https://go.microsoft.com/fwlink/?linkid=2271236

If you encounter any problem, please open an issue at https://aka.ms/azclibug

[Warning] The login output has been updated. Please be aware that it no longer
displays the full list of available subscriptions by default.

Re-authentication was successful.
```

#### Logs and Error Handling
- Enable verbose mode for detailed logs: `$VerbosePreference = "Continue"`
- Error logs are stored in `error.log` for debugging.

---

### Contributions

#### How to Contribute

1. Fork the repository and create a feature branch.
2. Implement your feature or fix, ensuring tests pass.
3. Submit a pull request with a detailed description.

---

### License

This project is licensed under the [GNU General Public License](LICENSE).

### Author
[**Eduardo Valdes**](https://github.com/emvaldes)
Contact: [GitHub Issues](https://github.com/emvaldes/azure-resources/issues)
