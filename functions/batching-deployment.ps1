#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function batching-deployment {
    param (
        [Parameter(Mandatory)]
        [array]$BatchObjecs,
        [Parameter(Mandatory)]
        [int]$TotalRecords
    )

    ## Suppress verbose output for jobs
    # $VerbosePreference = "SilentlyContinue" ;

    # Initialize a queue to manage jobs
    $jobQueue = @() ;
    # Process each resource in the batch by creating jobs

    $results = $BatchObjecs | ForEach-Object {
        $resource = $_ ;
        if ( $resource -is [pscustomobject] -and $resource.PSObject.Properties.Match( 'id' ) ) {

            $recordIndex = $Script:FilteredObjects.IndexOf( $resource ) + 1 ;
            $totalRecords = $Script:FilteredObjects.Count ;
            $paddedIndex = $recordIndex.ToString().PadLeft( $totalRecords.ToString().Length, '0' ) ;
            $resourceId = $resource.id ;
            $ResourceName = ( $resourceId -split '/' )[6..( $resourceId.Length - 1 )] -join '/' ;
            $ResourceIndex = "${paddedIndex}/${totalRecords}" ;

            # Create a background job for processing each resource
            $job = Start-Job -ScriptBlock {
                param( $resourceId, $ResourceIndex, $ResourceName, $depth ) ;

                try {
                    Write-Host "${ResourceIndex}: ${ResourceName}" `
                               -ForegroundColor Cyan ;
                    # Fetch the resource data using az CLI
                    $resourceJson = az resource show --ids $resourceId --output json ;
                    # if ( $Verbose ) { $resourceJson ; } ;

                    try {
                        if ( $resourceJson ) {
                            $resourceData = $resourceJson | ConvertFrom-Json -Depth $depth `
                                                                             -AsHashTable ;
                            return $resourceData ;
                        } else {
                            throw "Failed to fetch data for resource ID: $resourceId" ;
                        } ;
                    } catch {
                        $ErrorMessage = "Failed to process resource with ID: ${resourceId}" ;
                        catching-errors -ErrorMessage $_.Exception.Message `
                                        -ExitCode 1 `
                                        -Context $ErrorMessage ;
                    } finally {} ;

                } catch {
                    Write-Error $_.Exception.Message ;
                    return $null ;
                } finally {} ;

            } -ArgumentList $resourceId, $ResourceIndex, $ResourceName, $UserConfigs["params"]["MaxDepth"] ;
            $jobQueue += $job ;
        } else {
            Write-Error "Invalid JSON Object: $( $resource | Format-List )" ;
        } ;
    } ;

    # Collect and process job results
    $jobResults = @() ;
    $jobQueue | ForEach-Object {
        $job = $_ ;
        # Wait for the job to complete
        Wait-Job -Job $job ;
        # Retrieve the job output
        $result = Receive-Job -Job $job ;
        if ( $result ) {
            $jobResults += $result ;
        } ;
        # Clean up the job
        Remove-Job -Job $job ;
    } | Out-Null ;

    # Append job results to the JSON file
    if ( Test-Path $JsonObjects ) {
        $existingContent = Get-Content -Path $JsonObjects `
                                       -Raw ;
        $isFirstObject = $existingContent.Trim() -eq "[" ;

        $jobResults | ForEach-Object -Process {
            # Add a comma only if it's not the first object
            if ( -not $isFirstObject ) {
                Add-Content -Path $JsonObjects `
                            -Value ", " ;
            } ;
            $_ | ConvertTo-Json -Depth $UserConfigs["params"]["MaxDepth"] `
               | Add-Content -Path $JsonObjects ;
            $isFirstObject = $false ;
        } ;

    } else {
        Write-Error "JSON file $JsonObjects does not exist." ;
    } ;

    return ;
} ;
