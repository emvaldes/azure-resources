#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

## If the session is invalid, run: > az login --use-device-code to reauthenticate:
function manage-azuresession {

    ## Use az account get-access-token to verify if the token is still valid:
    function Validate-AzureSession {

        try {
            if ( $Debug ) { Write-Host "`nValidating Azure Session ..." ; } ;
            $Script:AccessToken = az account get-access-token --output json ;
            if ( $Script:AccessToken -match "accessToken" ) {
                # Write-Host "Azure session is valid." ;
                return $true ;
            } else { return $false ; } ;
        }
        catch {
            $WriteWarning = "Azure session is invalid or expired." ;
            Write-Warning $WriteWarning ;
            return $false ;
        } finally {} ;

        return ;
    } ;

    Validate-AzureSession | Out-Null ;

    if ( -not ( $Script:AccessToken ) ) {
        Write-Host "`nRe-Authenticating to Azure...`n" ;
        az login --scope https://management.core.windows.net//.default ;
        if ( -not ( Validate-AzureSession ) ) {
            Throw "Failed to reauthenticate. Please check your credentials." ;
        } ;
        Write-Host "Re-authentication was successful.`n" ;
    } else {
        if ( $Debug ) {
            Write-Host "`nAzure Access Token: " ;
            $Script:AccessToken ;
            Write-Host "`nAzure Account Info: " ;
            az account show ; Write-Host ;
            Write-Host ;
            # az account list ;
        } ;
    } ;

    return ;
} ;
