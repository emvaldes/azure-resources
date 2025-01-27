#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function applying-changes {
    param (
        [string]$key,
        [string]$value
    )

    # Return early if the value is null or empty
    if ( -not $value ) {
        # $WriteWarning = "This key '${key}' value is null or empty. Skipping ..." ;
        # Write-Warning $WriteWarning ;
        return @{ "objects" = [ordered]@{} ; "remove" = $false } ;
    } ;

    $itemConfig = $Script:AppConfigs.items | Where-Object {
        $_.id -eq $key
    } ;

    if ( $itemConfig ) {
        $changeRules = $itemConfig.change ;
        $remove = $itemConfig.remove ;
        if ( $changeRules ) {

            foreach ( $changeRule in $changeRules ) {
                $ItemsObject = [ordered]@{} ;
                switch ( $changeRule.action ) {

                    "split" {

                        $sections = $value -split [regex]::Escape( $changeRule.divisor ) ;
                        # Ensure the value is valid for splitting
                        $sections = $value -split [regex]::Escape( $changeRule.divisor ) ;
                        if ( -not $sections -or $sections.Count -eq 0 ) {
                            $WriteWarning = "Splitting ${value} returned an empty array. Skipping..." ;
                            Write-Warning $WriteWarning ;
                            continue ;
                        } ;
                        $fields = $changeRule `
                                | Select-Object -ExpandProperty fields ;
                        foreach ( $field in $fields ) {

                            if ( $field.index -ge 0 -and $field.index -lt $sections.Count ) {
                                $section = if ( $field.range ) {
                                    $sections[$field.index..$field.range] -join $changeRule.divisor ;
                                } else {
                                    $sections[$field.index..( $sections.Count - 1 )] -join $changeRule.divisor ;
                                } ;
                                if ( -not $ItemsObject[$field.id] ) {
                                    $ItemsObject[$field.id] = @() ;
                                } ;
                                $ItemsObject[$field.id] += @{ "id" = $field.id ; "value" = $section ; } ;
                                # Write-Host "Processed Field: $( $field.id ), Section: ${section}" ;
                            } else {
                                throw "Index $( $field.index )/$( $sections.Count ) is out of bounds for '${value}'" ;
                            } ;

                        } ;
                        return @{ "objects" = $ItemsObject; "remove" = $remove } ;

                    } ;

                    "extract" {

                        $sections = $value -split [regex]::Escape( $changeRule.divisor ) ;
                        # Ensure the value is valid for extracting
                        if ( -not $sections -or $sections.Count -eq 0 ) {
                            $WriteWarning = "Extracting '$value' returned an empty array. Skipping..." ;
                            Write-Warning $WriteWarning ;
                            continue;
                        }
                        if ( $sections.Count -le $changeRule.index ) {
                            $WriteWarning = "Index $( $changeRule.index )/$( $sections.Count ) is out of bounds for '${value}'" ;
                            Write-Warning $WriteWarning ;
                            continue;
                        # } else {
                        #     Write-Host "Value: '${value}' Index: $( $changeRule.index )/$( $sections.Count )" ;
                        } ;
                        # Extract logic respects the range
                        $section = if ( $changeRule.range ) {
                            # Extract from the index to the end
                            $sections[$changeRule.index..$changeRule.range] -join $changeRule.divisor ;
                        } else {
                            # Extract only the specific section
                            # $sections[$changeRule.index] ;
                            $sections[$changeRule.index..( $sections.Length - 1 )] -join $changeRule.divisor ;
                        } ;
                        $ItemsObject[$key] = @{ "id" = $key ; "value" = $section } ;
                        return @{ "objects" = $ItemsObject; "remove" = $remove } ;

                    } ;

                } ;
            } ;
        } ;
    } ;

    # return ;
    return @{ "objects" = [ordered]@{} ; "remove" = $false } ;
} ;
