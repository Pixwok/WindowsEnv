Set-ExecutionPolicy Unrestricted
#Requires -RunAsAdministrator

function ClearWindowsApp {
    Write-Output "Lancement du nettoyage des applications par défaut de Windows"

    Get-AppxPackage *Microsoft.PowerAutomateDesktop* | Remove-AppxPackage
    Get-AppxPackage *Clipchamp.Clipchamp* | Remove-AppxPackage
    Get-AppxPackage *WindowsMaps* | Remove-AppxPackage
    Get-AppxPackage *BingWeather* | Remove-AppxPackage
    Get-AppxPackage *skype* | Remove-AppxPackage
    Get-AppxPackage *zunemusic* | Remove-AppxPackage
    Get-AppxPackage *ZuneVideo* | Remove-AppxPackage
    Get-AppxPackage *BingNews* | Remove-AppxPackage
    Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage
    Get-AppxPackage *MicrosoftStickyNotes* | Remove-AppxPackage
    Get-AppxPackage *MicrosoftCorporationII.QuickAssist* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.BingSearch* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.YourPhone* | Remove-AppxPackage #Mobile
    Get-AppxPackage *Microsoft.People* | Remove-AppxPackage #Contact
    Get-AppxPackage *Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.Todos* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.WindowsFeedbackHub* | Remove-AppxPackage #Hub Commentaire
    Get-AppxPackage *Microsoft.StartExperiencesApp* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.Windows.DevHome* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.OutlookForWindows* | Remove-AppxPackage
    Get-AppxPackage *MSTeams* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.Windows.NarratorQuickStart* | Remove-AppxPackage
    Get-AppxPackage *MicrosoftTeams* | Remove-AppxPackage

    # Désinstallation de OneDrive
    Get-AppxPackage "*OneDrive*" | Remove-AppxPackage
    if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
		& "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
	}
	if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
		& "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
	}
    #Purge OneDrive folder
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"

    # Désinstaller Copilot
    Get-AppxPackage *copilot* | Remove-AppxPackage
}

function ConfigPrivacy {
    #Disable ID Pub
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name "Enabled" -Value "0" -PropertyType DWORD -Force
    #Désactiver reconnaise vocal en ligne
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' -Name "HasAccepted" -Value "0" -PropertyType DWORD -Force
    #Experiance personnalisé avec data diag
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value "0" -PropertyType DWORD -Force
    #Personnalisation de la saisie
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\InputPersonalization' -Name "RestrictImplicitInkCollection" -Value "0" -PropertyType DWORD -Force
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\InputPersonalization' -Name "RestrictImplicitTextCollection" -Value "0" -PropertyType DWORD -Force
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore' -Name "HarvestContacts" -Value "0" -PropertyType DWORD -Force
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Personalization\Settings' -Name "AcceptedPrivacyPolicy" -Value "0" -PropertyType DWORD -Force
    #Envoie que les données de diagnostic requise
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' -Name "AllowTelemetry" -Value "0" -PropertyType DWORD -Force
    #Désactive le suivi des recherche et app lancé
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name "Start_TrackProgs" -Value "0" -PropertyType DWORD -Force
    #Désativer l'historique d'activité
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name "PublishUserActivities" -Value "0" -PropertyType DWORD -Force
    #Ne pas envoyer de feedback
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Siuf\Rules' -Name "NumberOfSIUFInPeriod" -Value "0" -PropertyType DWORD -Force
    # Desactiver tracking edge
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name "PersonalizationReportingEnabled" -Value "0" -PropertyType DWORD -Force
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name "DiagnosticData" -Value "0" -PropertyType DWORD -Force
    #Désactiver les astuces de l'écran de verouillage
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name SubscribedContent-338387Enabled -Value 0 -PropertyType Dword -Force
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name RotatingLockScreenOverlayEnabled -Value 0 -PropertyType Dword -Force
}

function ConfigWSL {
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
    }
}

function InstallWinget {
    if (-not (Get-Module -Name Microsoft.WinGet.Client)) {
        Write-Host "Winget is not installed. Launching Winget installation..."
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
        Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
        Repair-WinGetPackageManager -AllUsers
        Write-Host "Installation completed"
    } else {
        Write-Host "Winget is already installed"
    }
}

function WinPersonalization {
    ## Théme system sombre
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name SystemUsesLightTheme -Value 0 -Force
    ## Théme sombre
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name AppsUseLightTheme -Value 0 -Force
    ## Bare des tâches gauche
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name TaskbarAl -Value "0" -PropertyType DWORD -Force
    #Icon loupe bare des tâches
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name SearchboxTaskbarMode -Value 1 -PropertyType Dword -Force
    #Désactive l'icon pour afficher les apps ouverte et les bureaux
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowTaskViewButton -Value 0 -PropertyType Dword -Force
    #désactivier Widget bare des tâches
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name TaskbarDa -Value 0 -PropertyType Dword -Force
    #Personnalisation explorer
    # Afficher les fichier cachés
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Value 1 -PropertyType Dword -Force
    # Afficher les extensions
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideFileExt -Value 0 -PropertyType Dword -Force
    # Désactiver "Afficher plus d'option"
    reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f
}

function InstallMinimalApp {
    Write-Output "Installation 7Zip"
    winget install 7zip.7zip
    Write-Output "Installation Notepad++"
    winget install Notepad++
    Write-Output "Installation Keepass"
    winget install DominikReichl.KeePass
    Write-Output "Installation VLC"
    winget install VideoLAN.VLC
    Write-Output "Installation Firefox Developper edition"
    winget install Mozilla.Firefox.DeveloperEdition.fr
    Write-Output "Installation Thunderbird"
    winget install Mozilla.Thunderbird.fr
    Write-Output "Installation Discord"
    winget install Discord.Discord
    Write-Output "Installation Obsidian"
    winget install Obsidian.Obsidian
    Write-Output "Installation Adobe Acrobat Reader"
    winget install Adobe.Acrobat.Reader.64-bit
}

function InstallOptionalApp {
    Write-Output "Installation WinSCP"
    winget install WinSCP.WinSCP
    Write-Output "Installation OBS Studio"
    winget install OBSProject.OBSStudio
    Write-Output "Installation Git"
    winget install Git.Git
    Write-Output "Installation VsCode"
    winget install Microsoft.VisualStudioCode
    Write-Output "Installation Docker"
    winget install Docker.DockerDesktop
}

$OSVersion = Get-WmiObject win32_operatingsystem | Select-Object Version

## Lancement du script 
Write-Output "1. Nettoyage des applications de Windows"
Write-Output "2. Configuration et personnalisation de Windows"
Write-Output "3. Installation des logiciels de base"
Write-Output "4. Installation de tout mes logiciels"
Write-Output "5. Configuration et installation compléte"
$choice = Read-Host "Taper le numéro de l'action : "

switch ($choice) {
    "1" { 
        ## Nettoyage des app de Windows
        ClearWindowsApp
    }
    "2" {
        Write-Output "Lancement de la config..."
        ConfigPrivacy
        Write-Output "Configuration Confidentialité : OK"
        WinPersonalization
        Write-Output "Personnalisation Windows : OK"
        InstallWinget
        Write-Output "Installation WinGet : OK"
        ConfigWSL
        Write-Output "Installation WSL : OK"
        Copy-Item .\settings.json "C:\users\$env:UserName\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
        Write-Output "Personnalisation Terminal : OK"
    }
    "3" {
        InstallMinimalApp
    }
    "4" {
        InstallOptionalApp
    }
    "5" {
        ClearWindowsApp
        Write-Output "Lancement de la config..."
        ConfigPrivacy
        Write-Output "Configuration Confidentialité : OK"
        WinPersonalization
        Write-Output "Personnalisation Windows : OK"
        InstallWinget
        Write-Output "Installation WinGet : OK"
        ConfigWSL
        Write-Output "Installation WSL : OK"
        Import-StartLayout -LayoutPath ".\StartLayout.json" -MountPath "C:\"
        Write-Output "Personnalisation StartMenu : OK"
        InstallMinimalApp
        InstallOptionalApp
        Write-Output "Redémarrer l'ordinateur"
    }
    Default {
        Write-Output "Option inconnue"
    }
}