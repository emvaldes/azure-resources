#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

## Define a function to check and install the ImportExcel module.
## Note: This is an A.I. generated code just to give credit to it.
function validating-appmodule {

    $ModuleName = "ImportExcel" ;
    try {
        ## Check if the ImportExcel module is available
        if ( -not ( Get-Module -ListAvailable -Name $ModuleName ) ) {
            Write-Host "`n${ModuleName} modules not found. Installing now ...`n" ;

            try {
                Install-Module -Name $ModuleName `
                               -Scope CurrentUser `
                               -Force `
                               -ErrorAction Stop ;
                ## OS-specific dependencies
                Write-Host "Install the libgdiplus (GDI+-compatible API) package" ;
                Write-Host "https://github.com/mono/libgdiplus`n" ;
                ## Detect OS and provide appropriate installation commands
                if ( $PSVersionTable.Platform -eq "Unix" ) {
                    installing-appmodules ;
                }
                elseif ( $PSVersionTable.Platform -eq "Win32NT" ) {
                    Write-Host "GitHub -> https://github.com/Microsoft/vcpkg`n" `
                               -ForegroundColor Cyan ;
                }
                else { Write-Error "Unsupported platform detected.`n" ; } ;
            }
            catch { throw "Failed to install the ${ModuleName} module: $_" ; }
            finally {} ;

        } else {
            ## Suppress message if module is already installed
            # Write-Host "${ModuleName} module is already installed." ;
        } ;
    }
    catch {
        $ErrorMessage = "libgdiplus is not installed. Some Excel features may not work." ;
        catching-errors -ErrorMessage $_.Message `
                        -ExitCode 1 `
                        -Context $ErrorMessage ;
    } finally {} ;
    ## Optional: PSWriteExcel, ImportExcelPlus

    return ;
} ;
