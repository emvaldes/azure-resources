#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function filtering-resources () {
    param (
        [string]$Filename
    )

    $Script:DatasetScope = "Environment '$( $UserConfigs["params"]["Environment"] )' Resources" ;
    $Filename = Join-Path -Path $ScriptInfo.Configs `
                          -ChildPath "$( $UserConfigs["params"]["Environment"] ).resources.json" ;
    $Script:FilteredObjects = reloading-resources -Filename $Filename ;
    # $FilteredObjects | ForEach-Object { Write-Host $_.id } ;

    ## Parsing reloading-resources response:
    if ( $FilteredObjects -is [bool] ) {
        if ( $FilteredObjects -eq $true ) {
            Write-Host "Filtering ${DatasetScope} ..." `
                       -ForegroundColor Yellow ;
        } ;

        try {
            $Script:FilteredObjects = $FetchedObjects | Where-Object {
                $_.id -like "*$( $UserConfigs["params"]["Environment"] )*" ;
            } ;
            if ( $FilteredObjects.Count -eq 0 ) {
                Write-Host "Error: No ${DatasetScope} JSON Objects were retrieved." `
                           -ForegroundColor Red ;
                exit 1 ;
            } else {
                Write-Host "Filtered $( $FilteredObjects.Count ) resource(s) for ${DatasetScope}`n" ;
                ## Store filtered-objects to Cache-file
                $FilteredObjects | ConvertTo-Json -Depth $UserConfigs["params"]["MaxDepth"] `
                                 | Out-File -FilePath $Filename `
                                            -Encoding UTF8 ;
            } ;
        } catch {
            $ErrorMessage = "Unable to fetch environment $( $UserConfigs["params"]["Environment"] ) resources!" ;
            catching-errors -ErrorMessage $_.Exception.Message `
                            -ExitCode 1 `
                            -Context $ErrorMessage ;
        } finally {} ;

    } ;
    # Write-Host "Filtered:`n$( $FilteredObjects )" ;

    return ;
} ;
