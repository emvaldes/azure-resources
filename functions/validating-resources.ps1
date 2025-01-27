#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function validating-resources () {

    $Script:RemoveItems = [ordered]@{} ;
    ## Process objects and maintain order

    try {
        foreach ( $HashedObject in $Script:HashedObjects ) {
          foreach ( $UniqueKey in $Script:UniqueKeys ) {
              $key = $UniqueKey["id"] ;
              if ( $HashedObject.Contains( $key ) ) {
                  $value = $HashedObject[$key] ;
                  # Write-Host "Key: ${key}" ;
                  # Write-Host "Value: ${value}" ;
                  $payload = applying-changes -key $key -value $value ;
                  if ( $payload ) {
                      $objects = $payload["objects"] ;
                      $remove = $payload["remove"] ;
                      foreach ( $object in $objects.Keys ) {
                          foreach ( $item in $objects[$object] ) {
                              $HashedObject[$item.id] = $item.value ;
                              # Write-Host "Added property '$( $item.id )' = '$( $item.value )'" ;
                          } ;
                      } ;
                      ## Marking $key for removal
                      if ( $remove ) { $UniqueKey["remove"] = $remove ; } ;
                  } ;
              } ;
          } ;
          ## Flattening Pseudo-keys
          faltten-nestedkeys -HashedObject $HashedObject `
                             -PseudoKeys $Script:UniqueKeys ;
        } ;
        # ## Output the exported-data
        # $Counter = 1 ;
        # ForEach ( $item in $Script:HashedObjects ) {
        #     Write-Host "`nExported ${Counter}/$( $Script:HashedObjects.Count ):" -ForegroundColor Cyan ;
        #     $item | Format-List ; Write-Host "------------------" ;
        #     $counter++ ;
        #     if ( $counter -gt 1 ) { break ; } ;
        # } ;
    }
    catch {
        $ErrorMessage = "Unable to Extract Resources!" ;
        catching-errors -ErrorMessage $_.Exception.Message `
                        -ExitCode 1 `
                        -Context $ErrorMessage ;
    } finally {} ;

    # if ( $Verbose ) {
    #     # $Script:UniqueKeys | ConvertTo-Json -Depth $UserConfigs["params"]["MaxDepth"] ;
    #     $Script:HashedObjects[0] | ConvertTo-Json -Depth $UserConfigs["params"]["MaxDepth"] ;
    #     Write-Host ;
    # } ;

    return ;
} ;
