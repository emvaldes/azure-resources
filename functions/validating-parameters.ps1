#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function validating-parameters {

    ## Check if the Input-Configs Environment parameter is missing and prompt for it
    if ( -not $Environment ) {
        Write-Host ;
        do {

            try {
                $Environment = Read-Host "Please, enter the environment name" ;
                ## Ensure the Input-Configs Environment parameter is set
                if ( $Environment -and $Environment.Trim() -ne "" ) {
                    Write-Host ; break ;
                }
                else {
                    ## Instead of throwing an error, log a warning and retry
                    Throw "`nEnvironment parameter is required. Aborting!.`n" ;
                } ;
            }
            catch {
                ## Supressing metadata validation errors:
                Write-Host "`e[1A`e[1A" -NoNewline ;
                $WriteWarning = "Please enter a valid environment name." ;
                Write-Warning $WriteWarning ;
            } finally {} ;

        } while ( -not $Environment -or $Environment.Trim() -eq "" ) ;
    } ;
    if ( -not $Script:PSBoundParameters["Environment"] ) {
        $Script:PSBoundParameters["Environment"] = $Environment ;
    } ;

    return ;
} ;
