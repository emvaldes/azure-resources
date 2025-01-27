#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

## Helper function to Download and Store JSON resources
function fetching-resources () {
    param (
        [string]$Filename = "all.resources.json"
    )

    $Script:DatasetScope = "Subscription Resources" ;
    $Script:AzureResources = Join-Path -Path $ScriptInfo.Configs `
                                       -ChildPath $Filename ;
    $Script:FetchedObjects = reloading-resources -Filename $Script:AzureResources `
                                                 -TargetScope $Script:DatasetScope ;
    # $FetchedObjects | ForEach-Object { Write-Host $_.id } ;

    ## Parsing reloading-resources response:
    if ( $FetchedObjects -is [bool] ) {
        if ( $FetchedObjects -eq $true ) {
            Write-Host "Initializing ${DatasetScope} ..." `
                       -ForegroundColor Yellow ;
        } ;

        try {
            ## Capturing full JSON objects instead of narrowing the scope ( --query "[].{id:id}" )
            $Script:FetchedObjects = az resource list --output json `
                                   | ConvertFrom-Json -Depth $UserConfigs["params"]["MaxDepth"] `
                                                      -AsHashTable ;
            if ( $FetchedObjects.Count -eq 0 ) {
                Write-Host "Error: No ${DatasetScope} JSON Objects were retrieved." `
                           -ForegroundColor Red ;
                exit 5 ;
            } else {
                Write-Host "Retrieved $( $FetchedObjects.Count ) ${DatasetScope}`n" ;
                ## Store retrieved resources to Cache-file
                $FetchedObjects | ConvertTo-Json -Depth $UserConfigs["params"]["MaxDepth"] `
                                | Out-File -FilePath $Script:AzureResources `
                                           -Encoding UTF8 ;
            } ;
        } catch {
            catching-errors -ErrorMessage $_.Exception.Message `
                            -ExitCode 1 `
                            -Context "Failed to retrieve ${DatasetScope} list." ;
        } finally {} ;

        ## Parallel-segmentation of all Input-Configs Environments
        $Jobs = @() ;
        $Targets = $Script:UserConfigs["reports"]["environments"] ;
        foreach ( $Target in $Targets ) {

            if ( -not $Target["id"] ) {
                Write-Error "Invalid target environment: Missing 'id'. Skipping..." ;
                continue ;
            } ;
            $Job = Start-Job -ScriptBlock {
                $TargetID = $Target["id"] ;
                $TargetTitle = $Target["title"];
                param ( $TargetID, $TargetTitle, $Script:AzureResources, $Script:ConfigsFolder )
                try {
                    ## Read and filter resources
                    $Resources = Get-Content -Path $Script:AzureResources `
                               | ConvertFrom-Json -Depth $UserConfigs["params"]["MaxDepth"] `
                                                  -AsHashTable ;
                    $FilteredTarget = $Resources | Where-Object {
                        $_.id -like "*$( $Target["id"] )*"
                    } ;
                    $OutputFile = Join-Path -Path $Script:ConfigsFolder `
                                            -ChildPath "$( $Target["id"] ).resources.json" ;
                    ## Save filtered resources
                    $FilteredTarget | ConvertTo-Json -Depth $UserConfigs["params"]["MaxDepth"] `
                                    | Set-Content -Path $OutputFile `
                                                  -Force ;
                } catch {
                    Write-Error "Error processing environment ${Target}: $_" ;
                } finally {} ;
            } -ArgumentList $TargetID, $TargetID, $Script:AzureResources, $Script:ConfigsFolder ;
            $Jobs += $Job ;

        } ;
        # Limit parallelism and wait for all jobs to complete
        $MaxConcurrentJobs = [math]::Min( $Targets.Count, [System.Environment]::ProcessorCount ) ;
        while ( $Jobs.Count -gt 0 ) {
            Start-Sleep -Seconds 1 ;
            $Jobs = $Jobs | Where-Object {
                $_.State -eq 'Running'
            } ;
            if ( $Jobs.Count -ge $MaxConcurrentJobs ) { Start-Sleep -Seconds 1 ; } ;
        } ;

    } ;
    # Write-Host "Fetched:`n$( $FetchedObjects )" ;

    return ;
} ;
