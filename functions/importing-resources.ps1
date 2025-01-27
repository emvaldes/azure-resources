#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function importing-resources () {

    ## Parsing existing JSON objects (count):
    try {
        $Script:HashedObjects = Get-Content -Path $JsonObjects `
                              | ConvertFrom-Json -Depth $UserConfigs["params"]["MaxDepth"] `
                                                 -AsHashTable ;
        ## Retrieve the folder name dynamically from UserConfigs["reports"]["folder"]
        ## Note: Escaping special characters in folder name
        $ReportsFolder = [regex]::Escape( $UserConfigs["reports"]["folder"] ) ;
        ## Retain the folder name and everything after it
        $TargetFile = $JsonObjects -replace "^.+?${ReportsFolder}[\\/]", "${ReportsFolder}/" ;
        Write-Host "$( $Script:HashedObjects.Count ) JSON Objects are present in file '${TargetFile}'.`n" ;
    } catch {
        $ErrorMessage = "Unable to parse JSON Objects from '${JsonObjects}'!" ;
        catching-errors -ErrorMessage $_.Exception.Message `
                        -ExitCode 1 `
                        -Context $ErrorMessage ;
    } finally {} ;

    return ;
} ;
