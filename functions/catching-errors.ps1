#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

## Centralized error-handling function
function catching-errors {
    param (
        [string]$ErrorMessage,
        [string]$Context = "",
        [string]$Severity = "Error",
        [int]$ExitCode = 1
    )

    $InputObject = "`n$( ( Get-Date ).ToString() ):`n[ $Severity ]: ${ErrorMessage}`n${Context}" ;
    Out-File -FilePath "error.log" `
             -Append `
             -InputObject $InputObject ;
    ## Write-Verbose only when the -Verbose parameter is used.

    if ( $Context -and $Verbose ) { Write-Verbose "Context: ${Context}" ; } ;
    ## Write error to console and stop execution
    Write-Error -Message "${ErrorMessage}" `
                -ErrorAction Stop ;

    ## Aborting with the provided code
    exit $ExitCode ;

    return ;
} ;
