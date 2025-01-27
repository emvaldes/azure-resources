#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function extracting-uniquekeys () {

    ## Ensure $Script:HashedObjects is an array (wrap it in an array if it's a single object)
    if ( -not ( $Script:HashedObjects -is [System.Collections.IEnumerable] ) ) {
        $Script:HashedObjects = @( $Script:HashedObjects ) ;
    } ;

    ## Initialize as an ordered hashtable
    $Script:UniqueKeys = [ordered]@{} ;

    ## Validate required configuration is loaded
    if ( -not $Script:AppConfigs ) {
        throw "The (JSON/YAML)-based configuration file is not loaded." ;
    } else {

        # Initialize $Script:UniqueKeys as an array of hashtables
        ## User-defined keys from the JSON configuration
        $Script:UniqueKeys = $Script:AppConfigs.export ;
        ## Extract user-defined keys from the JSON configuration
        $index = 0 ;

        $Script:UniqueKeys | ForEach-Object {
            if ( $_ -is [hashtable] -and $_.ContainsKey( "id" ) -and $_.( "title" ) ) {
                $Script:UniqueKeys[$index]["index"] = $index ;
                $Script:UniqueKeys[$index]["remove"] = $false ;
                # return ;
            } else {
                $WriteWarning = "Unexpected export item: $( $_ | Out-String )" ;
                Write-Warning $WriteWarning ;
                $null ;
            } ;
            $index++ ;
        } | Where-Object { $_ -ne $null ; }

        if ( -not $Script:UniqueKeys -or $Script:UniqueKeys.Count -eq 0 ) {
            Write-Host "No user-defined keys were found." ;
            ## Extract unique keys from all objects

            try {
                ## List of PowerShell-specific keys to ignore
                $IgnoredKeys = @( "PSComputerName", "PSShowComputerName", "RunspaceId" ) ;
                $defaultKeys = $Script:HashedObjects `
                             | ForEach-Object { $_.Keys } `
                             | Where-Object { $IgnoredKeys -notcontains $_ } `
                             | Sort-Object `
                             | Select-Object -Unique ;
                $index = 0 ;
                $defaultKeys | ForEach-Object {
                    $_ | ForEach-Object {
                        $Script:UniqueKeys += @{
                            id = $_ ;
                            title = $_ ;
                            "index" = $index;
                            "remove" = $false;
                        } ;
                        $index++ ;
                    } ;
                } ;
                # Write-Host "Extracted default '$( $UserConfigs["params"]["Environment"] )' environment Unique-Keys: " `
                #            -ForegroundColor Cyan ;
            } catch {
                $ErrorMessage = "Unable to Extract JSON unique keys!" ;
                catching-errors -ErrorMessage $_.Exception.Message `
                                -ExitCode 4 `
                                -Context $ErrorMessage ;
            } finally {} ;

        } else {
            # Write-Host "Extracted User-Defined Reporting keys: " `
            #            -ForegroundColor Cyan ;
        };

    } ;
    # $Script:UniqueKeys ;

    return ;
} ;
