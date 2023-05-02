# Activar Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# Activar WSL
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# Activar Telnet
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient

# Activar ASP.NET 4.8
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45

# Activar IIS
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Instalar Chocolatey si no está instalado
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Instalar navegadores
choco install microsoft-edge chromium firefox opera brave vivaldi -y

# Instalar Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Instalar Visual Studio Community 2022, Visual Studio Code y Python con Chocolatey
choco install visualstudio2022community -y
choco install visualstudiocode -y
choco install python -y

# Instalar herramientas de bases de datos y API
choco install -y sql-server-management-studio azure-data-studio dbeaver postman

# Instalar VLC, Audacity, Notepad++, KeePass, WinSCP, y Yed
choco install vlc audacity notepadplusplus keepass winscp yed -y

# Instalar Power BI, Docker y PowerToys con Chocolatey

# Instalar Chocolatey si no está instalado
if (-not(Get-Command choco -ErrorAction SilentlyContinue)) {
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Instalar Power BI
choco install powerbi-desktop -y
# Instalar Docker
choco install docker-desktop -y
# Instalar PowerToys
choco install powertoys -y

# Instalar Logparser
choco install logparser -y

# Instalar TreeFolderSize
choco install tree-size-free -y

# winget install Microsoft.VisualStudioCode
# winget install Google.Chrome
# winget install Firefox
# winget install VLC
# winget install Audacity
# winget install NotepadPlusPlus
# winget install 7zip
# winget install KeePass
# winget install WinSCP
# winget install PowerToys


# Desinstalar Xbox y Xbox Game Bar
Get-AppxPackage *xbox* | Remove-AppxPackage -AllUsers
Get-AppxPackage *gamebar* | Remove-AppxPackage -AllUsers

# Desinstalar juegos
Get-AppxPackage *bing* | Remove-AppxPackage -AllUsers
Get-AppxPackage *solitairecollection* | Remove-AppxPackage -AllUsers
Get-AppxPackage *minecraft* | Remove-AppxPackage -AllUsers
