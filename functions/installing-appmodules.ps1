#!/usr/bin/env pwsh

## -----------------------------------------------------------------------------

function installing-azurecli {

    try {
        ## Detect and Install `az` CLI
        if ( -not ( Get-Command az -ErrorAction SilentlyContinue ) ) {
            Write-Host "Azure CLI ('az') not detected. Attempting to install..." `
                       -ForegroundColor Yellow ;
            if ( $PSVersionTable.System -eq "Darwin" ) {
                if ( &which brew 2>$null ) {
                    Write-Host "> brew install azure-cli ;`n" `
                               -ForegroundColor Green ;

                    try { brew install azure-cli ; }
                    catch {
                        $ErrorMessage = "Failed to install Azure CLI on macOS: $_" ;
                        catching-errors -ErrorMessage $_.Exception.Message `
                                        -ExitCode 1 `
                                        -Context $ErrorMessage ;
                    } finally {} ;

                } else {
                    Write-Host "Homebrew not found. Please install Homebrew first." `
                               -ForegroundColor Red ;
                } ;
            }
            elseif ( $PSVersionTable.System -eq "Linux" ) {
                Write-Host "> Installing Azure CLI on Linux using apt-get ;`n" `
                           -ForegroundColor Green ;
                try {
                    sudo apt-get update ;
                    sudo apt-get install --yes azure-cli ;
                }
                catch {
                    $ErrorMessage = "Failed to install Azure CLI on Linux: $_" ;
                    catching-errors -ErrorMessage $_.Exception.Message `
                                    -ExitCode 2 `
                                    -Context $ErrorMessage ;
                } finally {} ;

            }
            elseif ( $PSVersionTable.System -eq "Windows_NT" ) {
                Write-Host "Azure CLI is not installed." -NoNewLine `
                           -ForegroundColor Cyan ;
                Write-Host " Please download and install it from: https://aka.ms/installazurecliwindows" `
                           -ForegroundColor Cyan ;
            } else {
                Write-Host "Unknown platform detected. Unable to install Azure CLI." `
                           -ForegroundColor Red ;
            } ;
        } else {
            # Write-Host "Azure CLI ('az') is already installed." `
            #            -ForegroundColor Green ;
        } ;
    }
    catch {
        $ErrorMessage = "Installing Cross-Platform Azure CLI (az): $_" ;
        catching-errors -ErrorMessage $_.Exception.Message `
                        -ExitCode 3 `
                        -Context $ErrorMessage ;
    } finally {} ;

    return ;
} ;

## -----------------------------------------------------------------------------

function installing-appmodules {

    try {
        if ( $PSVersionTable.System -eq "Darwin" ) {
            if ( &which brew 2>$null ) {
                $PackageName = "mono-libgdiplus" ;
                Write-Host "> brew install ${PackageName} ;`n" `
                           -ForegroundColor Green ;
                $PackageInstalled = (
                    &brew list ${PackageName} 2>$null || brew install ${PackageName} 2>$null
                ) ;
                if ( $PackageInstalled ) {
                    Write-Host "${ModuleName} modules were installed successfully.`n" ;
                } ;
            } ;
        }
        elseif ( $PSVersionTable.system -eq "Linux" ) {
            Write-Host "> sudo apt-get install --yes libgdiplus ;`n" `
                       -ForegroundColor Green ;
        }
        else {
            Write-Host "Unknown platform detected. Check dependencies.`n" `
                       -ForegroundColor Red ;
        } ;
    }
    catch {
        $ErrorMessage = "Installing Homebrew package '${PackageName}': $_" ;
        catching-errors -ErrorMessage $_.Exception.Message `
                        -ExitCode 4 `
                        -Context $ErrorMessage ;
    } finally {} ;

    ## Install PowerShell modules
    foreach ( $Module in @( "PSWriteExcel", "ImportExcelPlus" ) ) {
        if ( -not ( Get-Module -ListAvailable -Name $Module ) ) {

            try {
                Install-Module -Name $Module `
                               -Scope CurrentUser `
                               -ErrorAction Silent `
                               -Force ;
            }
            catch {
                $ErrorMessage = "Failed to install the module '${Module}': $_" ;
                catching-errors -ErrorMessage $_.Exception.Message `
                                -ExitCode 5 `
                                -Context $ErrorMessage ;
            } finally {} ;

        } else { Write-Host "Module '${Module}' is already installed." ; } ;
    } ;

    return ;
} ;
