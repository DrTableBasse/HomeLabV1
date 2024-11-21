if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Ce script doit être exécuté avec des privilèges administratifs."
    exit 1
}
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey n'est pas installé. Installation en cours..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        if ($LASTEXITCODE -ne 0) {
            Write-Error "L'installation de Chocolatey a échoué."
            exit 1
        }
        Write-Host "Chocolatey a été installé avec succès."
    } else {
        Write-Host "Chocolatey est déjà installé."
    }
}
function Install-Packages {
    param (
        [string[]]$Packages
    )
    foreach ($package in $Packages) {
        if (-not (choco list --local-only | Select-String $package)) {
            Write-Host "Installation du package : $package..."
            choco install $package -y
            if ($LASTEXITCODE -ne 0) {
                Write-Error "L'installation du package $package a échoué."
            } else {
                Write-Host "$package a été installé avec succès."
            }
        } else {
            Write-Host "$package est déjà installé."
        }
    }
}
# Installation de Chocolatey
Install-Chocolatey

# Liste des packages à installer
$packages = @(
    "firefox",
    "googlechrome",
    "discord",
    "git",
    "xpipe",
    "steam",
    "github-desktop",
    "vscode",
    "obs-studio",
    "teamviewer",
    "anydesk",
    "winscp",
    #"docker-desktop", need some changes because dont install the right docker-desktop
    "bitwarden",
    "keepassxc",
    "microsoft365",
    "wireguard",
    "wireshark"
)
Install-Packages -Packages $packages