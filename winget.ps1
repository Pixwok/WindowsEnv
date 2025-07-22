## Script d'installation de Winget pour la gestion des package sous Windows
if (-not (Get-Module -Name Microsoft.WinGet.Client)) {
    Write-Host "Winget is not installed. Launching Winget installation..."
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
    Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
    Repair-WinGetPackageManager -AllUsers
    Write-Host "Installation completed"
} else {
    Write-Host "Winget is already installed"
}