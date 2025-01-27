#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

# Determines to either load from file or download resources
function reloading-resources {
    param (
        [string]$Filename
    )

    try {
        ## Checking Cache-file's age and refresh if needed (e.g., 24 hours):
        $cacheAgeLimit = ( Get-Date ).AddMinutes( -$UserConfigs["params"]["CacheExpiry"] ) ;
        # Write-Host "Checking cache for '$( $UserConfigs["params"]["Environment"] )' ..." ;
        ## Check if the cache file exists
        if ( Test-Path $Filename ) {
            $TargetEnvironment = $UserConfigs["params"]["Environment"] ;
            if ( ( Get-Item $Filename ).LastWriteTime -lt $cacheAgeLimit ) {
                Write-Host "Cache-file for $( $TargetEnvironment ) is outdated." `
                           -NoNewline `
                           -ForegroundColor Yellow ;
                Write-Host " Reloading ${DatasetScope} ..." `
                           -ForegroundColor Yellow ;
                return $false ;
            } ;
            Write-Host "Cache for '$( $TargetEnvironment )' is valid." `
                       -NoNewline `
                       -ForegroundColor Green ;
            Write-Host " Loading ${DatasetScope} ..." `
                       -ForegroundColor Green ;
            ## Load and validate the content of the file

            try {
                $rawJSON = Get-Content -Path $Filename -Raw ;
                $ImportedObjects = $rawJSON | ConvertFrom-Json -Depth $UserConfigs["params"]["MaxDepth"] `
                                                               -AsHashTable ;

                if ( $ImportedObjects -eq $null ) {
                    Write-Host "Failed to import JSON objects for '$( $TargetEnvironment )'!" `
                               -ForegroundColor Red ;
                } elseif ( $ImportedObjects.Count -eq 0 ) {
                    Write-Host "No JSON objects were found for '$( $TargetEnvironment )'" `
                               -ForegroundColor Yellow ;
                } elseif ( $ImportedObjects.Count -gt 0 ) {
                    ## Retrieve the folder name dynamically from UserConfigs["reports"]["folder"]
                    ## Note: Escaping special characters in folder name
                    $ReportsFolder = [regex]::Escape( $UserConfigs["reports"]["folder"] ) ;
                    ## Retain the folder name and everything after it
                    $TargetFile = $Filename -replace "^.+?${ReportsFolder}[\\/]", "${ReportsFolder}/" ;
                    Write-Host "Loaded $( $ImportedObjects.Count ) resources for '$( $TargetEnvironment )' from Cache-file '${TargetFile}'`n" ;
                    # $paddingWidth = $ImportedObjects.Count.ToString().Length ;
                    # $counter = 1 ;
                    # $ImportedObjects | ForEach-Object {
                    #     $paddedCounter = $counter.ToString().PadLeft( $paddingWidth, '0' ) ;
                    #     Write-Host "${paddedCounter} -> $( $_.id )" ;
                    #     $counter++ ;
                    # } ;
                    return $ImportedObjects ;
                } else {
                    Write-Host "Cache-file is empty or invalid. Downloading ${DatasetScope} ..." `
                               -ForegroundColor Red ;
                    return $false ;
                } ;
            }
            catch {
                $ErrorMessage = "Failed to convert JSON raw-data." ;
                catching-errors -ErrorMessage $_ `
                                -ExitCode 1 `
                                -Context $ErrorMessage ;
            } finally {} ;

        } else { return $true ; } ;
    }
    catch {
        $ErrorMessage = "Failed to process ${DatasetScope} list." ;
        catching-errors -ErrorMessage $_.Exception.Message `
                        -ExitCode 2 `
                        -Context $ErrorMessage ;
    } finally {} ;

    return $false ;
} ;
