## Script de désinstallation des apps et paramètre par defaut
Get-AppxPackage *WindowsMaps* | Remove-AppxPackage
Get-AppxPackage *BingWeather* | Remove-AppxPackage
Get-AppxPackage *skype* | Remove-AppxPackage
Get-AppxPackage *zunemusic* | Remove-AppxPackage