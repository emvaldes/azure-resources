#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function batching-resources {

    $Script:DatasetScope = "Batching Resources" ;
    $response = reloading-resources -Filename $Script:JsonObjects `
                                    -TargetScope $Script:DatasetScope ;
    # $response | ForEach-Object { Write-Host $_.id } ;

    ## Parsing reloading-resources response:
    if ( $response -is [bool] ) {

        if ( $response -eq $true ) {
            Write-Host "Initializing ${DatasetScope} ...`n" `
                       -ForegroundColor Yellow ;
            ## Validate and initialize the JSON file
            if ( -not ( Test-Path $JsonObjects ) ) {
                Set-Content -Path $JsonObjects -Value "[ " ;
            } ;
        } ;

        try {

            ## Process batches
            $batched = New-Object System.Collections.Generic.List[System.Object]
            for ( $i = 0; $i -lt $FilteredObjects.Count; $i += $UserConfigs["params"]["BatchSize"] ) {
                $batched.Add(
                    $FilteredObjects[$i..[Math]::Min(
                        $i + $UserConfigs["params"]["BatchSize"] - 1, $FilteredObjects.Count - 1
                    ) ]
                ) ;
            } ;

            $Counter = 1 ;
            foreach ( $batch in $batched ) {
                ## Write-Host "Processing batch $Counter of $( $batched.Count )"
                batching-deployment -BatchObjecs $batch `
                                    -TotalRecords $FilteredObjects.Count ;
                if ( $UserConfigs["params"]["BatchLimit"] -gt 0 -and $Counter -ge $UserConfigs["params"]["BatchLimit"] ) {
                    break ;
                } ;
                $Counter++ ;
            } ;

            ## Finalize the JSON file with closing bracket
            if ( Test-Path $JsonObjects ) {
                $existingContent = ( Get-Content -Path $JsonObjects -Raw ).Trim() ;
                if ( $existingContent -eq "[" ) {
                    Write-Host "No data added to the JSON file. Skipping finalization." ;
                    Remove-Item -Path $JsonObjects -Force ;
                } else {
                    if ( $existingContent.EndsWith( "," ) ) {
                        $existingContent = $existingContent.TrimEnd( "," ) ;
                    } ;
                    Set-Content -Path $JsonObjects -Value "${existingContent} ]" ;
                } ;
            } else {
                Write-Error "JSON file ${JsonObjects} does not exist or was not created correctly." ;
            } ;

            ## Optional: Format the JSON file for readability
            try {
                $formattedJson = Get-Content -Path $JsonObjects `
                                             -Raw `
                               | ConvertFrom-Json -Depth $UserConfigs["params"]["MaxDepth"] `
                                                  -AsHashTable `
                               | ConvertTo-Json -Depth $UserConfigs["params"]["MaxDepth"] ;
                Set-Content -Path $JsonObjects `
                            -Value $formattedJson ;
            }
            catch {
                # Write-Error "Failed to format JSON file: ${_}" ;
                $ErrorMessage = "Failed to process ${DatasetScope} list." ;
                catching-errors -ErrorMessage $_.Exception.Message `
                                -ExitCode 1 `
                                -Context $ErrorMessage ;
            } finally {} ;

        }
        catch {
            $ErrorMessage = "Failed to process ${DatasetScope} list." ;
            catching-errors -ErrorMessage $_.Exception.Message `
                            -ExitCode 2 `
                            -Context $ErrorMessage ;
        } finally {} ;

    } ;

    ## Record the end time
    $endTime = Get-Date ;

    ## Calculate the duration
    $duration = New-TimeSpan -Start $startTime -End $endTime ;
    $formattedDuration = "{0} minutes and {1} seconds" -f $duration.Minutes, $duration.Seconds ;

    ## Output the elapsed time
    Write-Host "`nTotal execution time: ${formattedDuration}`n" ;

    return ;
} ;
