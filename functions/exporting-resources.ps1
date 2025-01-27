#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function exporting-resources () {

    ## Retrieve the folder name dynamically from UserConfigs["reports"]["folder"]
    ## Note: Escaping special characters in folder name
    $ReportsFolder = [regex]::Escape( $UserConfigs["reports"]["folder"] ) ;
    ## Retain the folder name and everything after it
    $TargetFile = $ExportFile -replace "^.+?${ReportsFolder}[\\/]", "${ReportsFolder}/" ;
    ## Export JSON-data to target file-format:
    Write-Host "Exporting resources as $( $UserConfigs["params"]["ExportFormat"] ) format into '${TargetFile}'`n" ;

    # Sanitize all fields in $Script:HashedObjects
    foreach ( $HashedObject in $Script:HashedObjects ) {
        $keys = @( $HashedObject.Keys ) ;  ## Copy the keys for safe iteration
        foreach ( $key in $Keys ) {
            $value = $HashedObject[$key] ;
            ## Sanitize: Remove double quotes at the start and end of the string
            if ( $value -is [string] -and $value.StartsWith( '"' ) -and $value.EndsWith( '"' ) ) {
                $HashedObject[$key] = $value.Trim( '"' ) ;
            } ;
            ## Replace System.Management.Automation.OrderedHashtable values
            if ( $value -is [hashtable] ) {
                if ( $value.Count -eq 0 ) {
                    $HashedObject[$key] = '{}' ;
                } else {
                    $HashedObject[$key] = '{ ... }' ;
                } ;
            } ;
        } ;
    } ;

    $Row = [ordered]@{} ;
    $ExportedData = foreach ( $HashedObject in $Script:HashedObjects ) {
        ## Build the row, excluding fields marked for removal
        foreach ( $Key in $Script:UniqueKeys ) {
            if ( -not $Key.remove ) {
                $Row[$Key.title] = $HashedObject[$Key.id] ;
            } ;
        } ;
        [PSCustomObject]$Row ;
    } ;

    # Extract the title for the current environment from user configurations
    $EnvironmentTitle = ( $UserConfigs["reports"]["environments"] | Where-Object {
        $_.id -eq $UserConfigs["params"]["Environment"]
    } ).title ;
    if ( -not $EnvironmentTitle ) {
        throw "Environment title not found for '$( $UserConfigs["params"]["Environment"])'." ;
    } ;

    switch ( $UserConfigs["params"]["ExportFormat"].ToLower() ) {
        'csv' {
            try {
                $ExportedData | Export-Csv -Path $ExportFile `
                                           -NoTypeInformation `
                                           -Force ;
            } catch { $Exception = $_.Exception ; } finally {} ;
            break ;
        } ;
        'tsv' {
            try {
                $ExportedData | ConvertTo-Csv -Delimiter "`t" `
                                              -NoTypeInformation `
                              | Set-Content -Path $ExportFile `
                                            -Force ;
            } catch { $Exception = $_.Exception ; } finally {} ;
            break ;
        } ;
        'xlsx' {
            validating-appmodule ;
            try {
                $ExportedData | Export-Excel -Path $ExportFile `
                                             -WorksheetName "Environment - $( $EnvironmentTitle )" `
                                             -AutoFilter ;
            } catch { $Exception = $_.Exception ; } finally {} ;
            break ;
        } ;
        Default {
            $Exception = "Unsupported format '$( $UserConfigs["params"]["ExportFormat"] )'" ;
        } ;
    } ;

    if ( $Exception ) {
        $ErrorMessage = "Unable to export resources as '$( $UserConfigs["params"]["FormatType"] )'!" ;
        catching-errors -ErrorMessage $Exception.Message `
                        -ExitCode 3 `
                        -Context $ErrorMessage ;
    } else {
        if ( $Verbose ) {
            ## Retrieve the folder name dynamically from UserConfigs["reports"]["folder"]
            ## Note: Escaping special characters in folder name
            $ReportsFolder = [regex]::Escape( $UserConfigs["reports"]["folder"] ) ;
            ## Retain the folder name and everything after it
            $TargetFile = $ExportFile -replace "^.+?${ReportsFolder}[\\/]", "${ReportsFolder}/" ;
            Write-Host "Note: $( $UserConfigs["params"]["ExportFormat"] ) data exported successfully into '${TargetFile}'`n" ;
        } ;
    } ;

    return ;
} ;
