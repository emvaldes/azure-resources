#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function faltten-nestedkeys {
    param (
        [hashtable]$HashedObject,
        [array]$PseudoKeys
    )

    foreach ( $KeyDefinition in $PseudoKeys ) {
        $PseudoKey = $KeyDefinition["id"] ;
        $Title = $KeyDefinition["title"] ;
        # Navigate the nested object using the pseudo key
        $PathSegments = $PseudoKey -split '\.' ;
        $Value = $HashedObject ;

        foreach ( $Segment in $PathSegments ) {
            if ( $Segment -match '\[(\d+)\]$' ) {
                ## Handle array indices in the path
                $BaseSegment = $Segment -replace '\[(\d+)\]$' ;
                $Index = [int]$matches[1] ;
                if ( $Value -is [hashtable] -and $Value.ContainsKey( $BaseSegment ) ) {
                    $Value = $Value[$BaseSegment] ;
                    if ( $Value -is [array] -and $Index -lt $Value.Count ) {
                        $Value = $Value[$Index] ;
                    } else {
                        $Value = $null ;
                        break ;
                    } ;
                } else {
                    $Value = $null ;
                    break ;
                } ;
            } elseif ( $Value -is [hashtable] -and $Value.ContainsKey( $Segment ) ) {
                $Value = $Value[$Segment] ;
            } else {
                $Value = $null ;
                break ;
            } ;
        } ;

        # Add the pseudo key directly to the hashed object with the extracted value
        if ($null -ne $Value) { $HashedObject[$PseudoKey] = $Value ; } ;
    } ;

    return ;
} ;
