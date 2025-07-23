
if (wsl --status -ne null) {
    Write-Host "WSL déjà présent"
    ## Force la version 2 de WSL
    wsl --set-default-version 2
    wsl --status
} else {
    Write-Host "WSL non présent"
    Write-Host "Lancement de l'installation de WSL"
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    shutdown /r /t 20 /c "Redémarrage de Windows dans 20s suite à l'activation de WLS" /f
}

