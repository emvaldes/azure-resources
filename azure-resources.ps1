#!/usr/bin/env pwsh

## Notes: This script does not handle Azure Login sessions.
##        A Super-User access is required to fetch all target resources.

<#
.SYNOPSIS
    The script manages the download and filtering of Azure Subscription Resources.
    Fetching configurations and exporting them based on a specific output criteria.
    Note: The script uses Batch-Processing for data and Caching to expedite operations.

.DESCRIPTION
    This script automates the processing of retrieving and parsing Azure resources
    in batches, using Azure CLI, processing the JSON-data concurrently with background jobs,
    and saves the output to a JSON file.
    It is highly configurable and supports error handling, verbose logging, and JSON-driven configurations.

.PARAMETER Environment
    Target environment (e.g., prod, dev, test, etc.). Alias = e
.PARAMETER Platform
    Application Configuration files (JSON/YAML). Alias = p
.PARAMETER ExportFormat
    Supports export formats like: csv, tsv, json, excel. Alias = x
.PARAMETER BatchSize
    Configure total items for Batch's data-sets (resources). Alias = s
.PARAMETER BatchLimit
    Configure total amount of Batch iterations to process. Alias = l
.PARAMETER CacheExpiry
    Defines when (Minutes) it's time to refresh JSON resources. Alias = c
.PARAMETER MaxDepth
    Defines JSON max levels of nested objects to be parsed. Alias = m
.PARAMETER Override
    Bypassing logical constrains to override operations workflows constrains. Alias = o
.PARAMETER Verbose
    Activates the use of vervbosity-level in the script's output. Alias = v
.PARAMETER Debug
    Activates the use of debug-level in the script's output. Alias = d
.PARAMETER Help
    Provides built-in native script operational support. Alias = h

.EXAMPLE
    Reporting on Azure Resources for the Production (prod) environment.
         Exporting JSON object's keys (columns) as MS Excel file-format.
         .\azure-resources.ps1 -Environment 'prod' -ExportFormat excel -Verbose ;

.EXAMPLE
    Specify batch size and limit to sampling data-sets.
         .\azure-resources.ps1 -Environment 'prod' -BatchSize 3 -BatchLimit 2 -ExportFormat excel -Verbose ;

.NOTES
    - Ensure that the Azure CLI (`az`) is installed and authenticated.
    - Required: Installing the ImportExcel module. The libgdiplus (GDI+-compatible API) package.
    - The script generates JSON reporting sources. Drives workflow based on JSON/YAML config files.

.LINK
    https://github.com/emvaldes/azure-resources
#>

## Input parameter(s):
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
    [switch]$Debug,
    [Alias("h")]
    [switch]$Help
)

## Display help message if -Help or -? is used
if ( $Help ) {
    Get-Help $PSCommandPath -Detailed ;
    exit ;
} ;

## Ensuring the durability for run-time input parameters
$Script:PSBoundParameters = $PSBoundParameters ;
if ( $Debug ) {
    Write-Host "`nInput Parameters: " -ForegroundColor Cyan ;
    $Script:PSBoundParameters | ConvertTo-Json ;
} ;

$PSVersionTable["System"] = ( $PSVersionTable.OS -split "\s" )[0] ;

## Retrieve script execution details as an object
$ScriptInfo = [PSCustomObject]@{
    FullPath    = $MyInvocation.MyCommand.Path
    Directory   = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
    FileName    = [System.IO.Path]::GetFileName( $MyInvocation.MyCommand.Path )
    BaseName    = [System.IO.Path]::GetFileNameWithoutExtension( $MyInvocation.MyCommand.Path )
    BaseConfig  = Join-Path -Path ( Split-Path -Path $MyInvocation.MyCommand.Path -Parent ) `
                            -ChildPath ( [System.IO.Path]::GetFileNameWithoutExtension( $MyInvocation.MyCommand.Path ) )
} ;

Write-Host ;

## Loading all functions in the functions directory
Get-ChildItem -Path "functions" -Filter "*.ps1" | ForEach-Object {
    if ( $Debug ) {
        ## Retain the folder name and everything after it
        $SourceFile = $_.FullName -replace "^.+?functions[\\/]", "functions/" ;
        Write-Host "Loading: $( $SourceFile )" ;
    } ;
    ## Sourcing project's function
    . $_.FullName ;
} ;

## -----------------------------------------------------------------------------

installing-azurecli ;
manage-azuresession ;

## Record the start time
$startTime = Get-Date ;

## Main script logic
validating-parameters ;
configure-settings ;

## Processing Fetch/Filter resources:
fetching-resources ;
filtering-resources ;

# if ( Test-Path $JsonObjects ) {
#     Remove-Item -Path $JsonObjects -Force ;
# } ;

## Batch-Processing resources:
batching-resources ;

## Processing Report/Import resources:
importing-resources ;

## Processing JSON Structure/Attributes:
extracting-uniquekeys ;

validating-resources ;

## Exporting target environments:
exporting-resources ;

# if ( $Debug ) {
#     Write-Host "Scope (Script) object: " ;
#     Get-Variable -Scope Script | Format-Table -AutoSize ;
# } ;

## -----------------------------------------------------------------------------
