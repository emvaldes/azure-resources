#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

## Load Apple Configuration from JSON/YAML with Default Settings
function loading-configfiles {
    param (
        [string]$ConfigFile
    )

    if ( $( $Platform ) ) {

        try {
            if ( $( $Platform ) -eq "yaml" ) {
                if ( -not ( Get-Module -ListAvailable -Name "powershell-yaml" ) ) {
                    Install-Module -Name "powershell-yaml" `
                                   -Scope CurrentUser `
                                   -Force ;
                } ;
                Import-Module -Name "powershell-yaml" `
                              -ErrorAction Stop ;
                ## Verify and Display Module Information
                $ModuleInfo = Get-Module -Name "powershell-yaml" `
                                         -ListAvailable `
                            | Select-Object Name, Version, Path ;
            } ;
        }
        catch {
            $ErrorMessage = "Failed to enable $( $Platform ) configuration module." ;
            catching-errors -ErrorMessage $_.Exception.Message `
                            -ExitCode 1 `
                            -Context $ErrorMessage ;
        } finally {} ;

    } ;

    ## Abort if configuration file is missing
    if ( -not ( Test-Path $ConfigFile ) ) {
        Write-Error "Configuration file not found at path: $( $ConfigFile ). Aborting." ;
        exit 2 ;
    } ;

    ## Attempt to load Input-Configs Platform-based configuration
    try {
        $JsonConfigs = @{} ;
        if ( $( $Platform ) -eq "json" ) {
            $JsonConfigs = Get-Content -Path $ConfigFile `
                         | ConvertFrom-Json -Depth $MaxDepth `
                                            -AsHashTable ;
        } elseif ( $( $Platform ) -eq "yaml" ) {
            $JsonConfigs = Get-Content -Path $ConfigFile | ConvertFrom-Yaml ;
            ## Convert YAML output to Hashtable if needed
            if ( -not ( $JsonConfigs -is [hashtable] ) ) {
                $JsonConfigs = @{} + $JsonConfigs.PSObject.Properties.Name `
                             | ForEach-Object {
                                   $_ = @{} ;
                                   $_[$_.Name] = $_.Value ;
                                   $_
                               } ;
            } ;
        } else { Throw "Unsupported configuration file format: $( $Platform )" ; } ;
        return $JsonConfigs ;
    }
    catch {
        $ErrorMessage = "Failed to load JSON configuration ${ConfigFilePath}." ;
        catching-errors -ErrorMessage $_.Exception.Message `
                        -ExitCode 3 `
                        -Context $ErrorMessage ;
    } finally {} ;

    return ;
} ;
