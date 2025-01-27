#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function configure-scriptinfo {

    # $AppConfigFile = "$( $ScriptInfo.BaseConfig ).$( $Platform )" ;
    $AppConfigsFile = Join-Path -Path $ScriptInfo.Directory `
                                -ChildPath "app-configs.$( $Platform )" ;
    $ScriptInfo | Add-Member -MemberType NoteProperty `
                             -Name AppConfigsFile `
                             -Value $AppConfigsFile ;
    # $ScriptInfo.AppConfigsFile ;

    $UserConfigsFile = Join-Path -Path $ScriptInfo.Directory `
                                 -ChildPath "user-configs.$( $Platform )" ;
    $ScriptInfo | Add-Member -MemberType NoteProperty `
                             -Name UserConfigsFile `
                             -Value $UserConfigsFile ;
    # $ScriptInfo.UserConfigsFile ;

    ## Configuring target-Logging folder's path.
    $ScriptInfo | Add-Member -MemberType NoteProperty `
                             -Name Logging `
                             -Value ".logs" ;
    # $ScriptInfo.Logging ;

    ## Configuring target-Configs folder's path.
    $ScriptInfo | Add-Member -MemberType NoteProperty `
                             -Name Configs `
                             -Value ".configs" ;
    # $ScriptInfo.Configs ;

    return ;
} ;

## -----------------------------------------------------------------------------

function configure-environment {

    ## Configuring Operational Errors file.
    $Script:ErrorsFile = Join-Path -Path $ScriptInfo.Directory `
                                   -ChildPath "$( $Environment ).errors.log" ;
    ## Warning: Not working?
    ## if ( $Verbose ) { Write-Host "Script:ErrorsFile -> $( $Script:ErrorsFile )" ; } ;
    ## Purging any existing errors-log file.
    if ( Test-Path $ErrorsFile ) { Remove-Item $ErrorsFile -Force ; } ;

    $Script:LoggingFolder = Join-Path -Path $ScriptInfo.Directory `
                                      -ChildPath $ScriptInfo.Logging ;
    if ( -not ( Test-Path -Path $Script:LoggingFolder ) ) {
        New-Item -ItemType Directory `
                 -Path $Script:LoggingFolder `
        | Out-Null ;
    } ;
    ## if ( $Verbose ) { Write-Host "`nScript:LoggingFolder -> $( $Script:LoggingFolder )" ; } ;

    $Script:ConfigsFolder = Join-Path -Path $ScriptInfo.Directory `
                                      -ChildPath $ScriptInfo.Configs ;
    if ( -not ( Test-Path -Path $Script:ConfigsFolder ) ) {
        New-Item -ItemType Directory `
                 -Path $Script:ConfigsFolder `
        | Out-Null ;
    } ;
    ## if ( $Verbose ) { Write-Host "`nScript:ConfigsFolder -> $( $Script:ConfigsFolder )" ; } ;

    return ;
} ;

## -----------------------------------------------------------------------------

function configure-settings {

    ## Configuring ScriptInfo objects
    configure-scriptinfo ;

    ## Loading file-based (JSON/YAML) Application Configuration.
    $Script:AppConfigs = loading-configfiles -ConfigFile $ScriptInfo.AppConfigsFile ;
    # if ( $Debug ) { Write-Host "`nApp-Configs: $( $AppConfigs | ConvertTo-Json -Depth $MaxDepth )" ; } ;

    ## Configuring Environment objects
    configure-environment ;

    if ( Test-Path $ScriptInfo.UserConfigsFile ) {

        # try {
            ## Loading file-based (JSON/YAML) Application Configuration.
            $Script:UserConfigs = loading-configfiles -ConfigFile $ScriptInfo.UserConfigsFile ;

            ## Updating the $Script:UserConfigs["params"] with $Script:PSBoundParameters keys.
            ## THe objective is to override "params" with run-time parameters.
            foreach ( $key in $Script:PSBoundParameters.Keys ) {
                $Script:UserConfigs["params"][$key] = $Script:PSBoundParameters[$key] ;
            } ;

            # Define the keys to process
            $AppKeys = @( "Environment", "Platform" ) ;
            # Iterate through the keys
            foreach ( $AppKey in $AppKeys ) {
                if ( $Script:PSBoundParameters.ContainsKey( $AppKey ) ) {
                    # Use the runtime parameter value if it exists
                    $Script:UserConfigs["params"][$AppKey] = $Script:PSBoundParameters[$AppKey] ;
                } else {
                    ## Fallback to the default value in the script
                    $Script:UserConfigs["params"][$AppKey] = Get-Variable -Name $AppKey `
                                                                          -Scope Script `
                                                           | Select-Object -ExpandProperty Value ;
                } ;
            } ;
            # if ( $Debug ) { Write-Host "`nUser-Configs: $( $UserConfigs | ConvertTo-Json -Depth $MaxDepth )" ; } ;

            ## Quick validation to ensure all required keys exist in the configuration:
            if ( -not $Script:UserConfigs["reports"]["folder"] -or -not $Script:UserConfigs["reports"]["environments"] ) {
                Throw "Missing required configuration keys: 'reports.folder' or 'reports.environments'." ;
            } else {
                ## Validate the structure of environments
                foreach ( $env in $Script:UserConfigs["reports"]["environments"] ) {
                    if ( -not $env["id"] -or -not $env["title"] ) {
                        Throw "Invalid configuration. Each environment must have both 'id' and 'title' items." ;
                    } ;
                } ;
            } ;

            $Script:ReportsFolder = Join-Path -Path $ScriptInfo.Directory `
                                              -ChildPath $Script:UserConfigs["reports"]["folder"] ;
            if ( -not ( Test-Path -Path $Script:ReportsFolder ) ) {
                New-Item -ItemType Directory `
                         -Path $Script:ReportsFolder `
                | Out-Null ;
            } ;
            # if ( $Verbose ) { Write-Host "`nScript:ReportsFolder -> $( $Script:ReportsFolder )" ; } ;

            ## Merge/Append User-Configurations into App-Configurations
            foreach ( $Key in $Script:UserConfigs.Keys ) {
                if ( $Key -eq "export" ) {
                    # Special handling for the "export" section
                    foreach ($UserItem in $Script:UserConfigs["export"]) {
                        $AppItem = $Script:AppConfigs["export"] | Where-Object {
                            $_.id -eq $UserItem.id
                        } ;
                        if ( $null -ne $AppItem ) {
                            # Replace the existing item
                            $Script:AppConfigs["export"] = $Script:AppConfigs["export"] | Where-Object {
                                $_.id -ne $UserItem.id
                            } ;
                        } ;
                        # Add the new or updated item
                        $Script:AppConfigs["export"] += $UserItem ;
                    } ;
                } else {
                    # General handling: Override or add the key
                    $Script:AppConfigs[$Key] = $Script:UserConfigs[$Key] ;
                } ;
            } ;
            # if ( $Debug ) { Write-Host "App-Configs: $( $AppConfigs | ConvertTo-Json -Depth $MaxDepth )" ; } ;
        # }
        # catch {
        #     $ErrorMessage = "Failed to merge User-Configurations!" ;
        #     catching-errors -ErrorMessage $_.Exception.Message `
        #                     -ExitCode 1 `
        #                     -Context $ErrorMessage ;
        # } finally {} ;

    } else {
        Write-Host "User-Configurations file not found: $( $ScriptInfo.UserConfigsFile )." ;
    } ;

    ## Enforcing the use of lowercased Export-Format:
    $UserConfigs["params"]["ExportFormat"] = $UserConfigs["params"]["ExportFormat"].ToLower() ;

    ## Microsoft Excel specific output requirements.
    if ( $UserConfigs["params"]["ExportFormat"] -eq 'excel' ) {
        $UserConfigs["params"]["ExportFormat"] = 'xlsx' ;
    } ;
    if ( $UserConfigs["params"]["FormatType"] -eq 'xlsx' ) {
        $UserConfigs["params"]["FormatType"] = 'MS Excel' ;
    } ;

    # if ( $Debug ) {
    #     # Write-Host "`nUser-Configs: $( $UserConfigs | ConvertTo-Json -Depth $MaxDepth )" ;
    #     Write-Host "`nApp-Configs: $( $AppConfigs | ConvertTo-Json -Depth $MaxDepth )" ;
    # } ;

    ## Reconfiguring Script-wide properties:
    $Script:JsonObjects = Join-Path -Path $Script:ReportsFolder `
                                    -ChildPath "$( $UserConfigs["params"]["Environment"] ).details.json" ;

    $Script:OutputFile = [System.IO.Path]::GetFileNameWithoutExtension( $JsonObjects ) ;

    $Script:ExportFile  = Join-Path -Path $Script:ReportsFolder `
                                    -ChildPath "${OutputFile}.$( $UserConfigs["params"]["ExportFormat"] )" ;

    return ;
} ;
