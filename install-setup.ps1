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
# choco install powerbi-desktop -y
choco install powerbi -y

# Instalar Docker
choco install docker-desktop -y
# Instalar PowerToys
choco install powertoys -y

# Instalar Logparser
choco install logparser -y

# Instalar TreeFolderSize
choco install tree-size-free -y

choco install vagrant -y
choco install virtualbox -y -f  
# choco upgrade virtualbox -y

choco install insomnia -y
choco install python3 -y
choco install ffmpeg -y
choco install wiremock -y
choco install soapui -y
choco install restsharp -y
choco install drawio
choco install mRemoteNG
choco install sqlitebrowser
choco install linqpad # .NET Scratchpad
choco install winmerge
choco install beyondcompare
# choco install glogg # logviewer

## Cleanup
#choco install bleachbit
choco install treesizefree
#choco install dupeguru # duplicate finder gui
#choco install revo-uninstaller

## Runtimes / Languages
# choco install doxygen
# choco install pyenv-win # python version manager - breaks wsl when in PATH --> bash\r

## CLI Tools
# choco install ConEmu
# choco install far # cli file editor / explorer

choco install curl
choco install wget

# choco install youtube-dl

## FileSync
choco install synctrayzor


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
