# ===================================================================
# Script d'installation automatisée + mises à jour Windows
# avec progress bar, log et upgrade complet
# ===================================================================

# Vérification des privilèges administratifs
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Ce script doit être exécuté avec des privilèges administratifs."
    exit 1
}

# Création du dossier et du fichier log sur le Bureau
$LogDir = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "InstallLogs")
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}
$LogFile = Join-Path $LogDir ("InstallLog_{0}.log" -f (Get-Date -Format "yyyy-MM-dd_HH-mm-ss"))

# Fonction de log centralisée
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $formatted = "[$timestamp] [$Level] $Message"
    Write-Host $formatted
    Add-Content -Path $LogFile -Value $formatted
}

# Fonction d'installation de Chocolatey
function Install-Chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Log "Chocolatey n'est pas installé. Installation en cours..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        if ($LASTEXITCODE -ne 0) {
            Write-Log "L'installation de Chocolatey a échoué." "ERROR"
            exit 1
        }
        Write-Log "Chocolatey a été installé avec succès."
    } else {
        Write-Log "Chocolatey est déjà installé."
    }
}

# Fonction d'installation des packages avec progress bar
function Install-Packages {
    param ([string[]]$Packages)
    $total = $Packages.Count
    $i = 0

    foreach ($package in $Packages) {
        $i++
        $percent = [int](($i / $total) * 100)
        Write-Progress -Activity "Installation des applications..." -Status "$package ($i/$total)" -PercentComplete $percent

        if (-not (choco list --local-only | Select-String "^$package")) {
            Write-Log "Installation du package : $package..."
            choco install $package -y --no-progress | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Log "L'installation du package $package a échoué." "ERROR"
            } else {
                Write-Log "$package a été installé avec succès."
            }
        } else {
            Write-Log "$package est déjà installé."
        }
    }

    Write-Progress -Activity "Installation des applications..." -Completed -Status "Terminé"
}

# Fonction de mise à jour des applications Chocolatey existantes
function Upgrade-AllPackages {
    Write-Log "Mise à jour de tous les packages Chocolatey existants..."
    choco upgrade all -y --no-progress | Out-File -FilePath $LogFile -Append
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Tous les packages Chocolatey ont été mis à jour avec succès."
    } else {
        Write-Log "Une erreur est survenue lors de la mise à jour des packages Chocolatey." "ERROR"
    }
}

# Fonction de mise à jour de Windows avec log
function Update-Windows {
    Write-Log "Recherche et installation des mises à jour Windows..."
    try {
        # Installation du module PSWindowsUpdate si nécessaire
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Write-Log "Installation du module PSWindowsUpdate..."
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
            Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
        }

        Import-Module PSWindowsUpdate
        Write-Log "Module PSWindowsUpdate prêt."

        # Téléchargement et installation des mises à jour + redémarrage auto si nécessaire
        Write-Log "Téléchargement et installation des mises à jour (redémarrage automatique si nécessaire)..."
        Get-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-File -FilePath $LogFile -Append

        Write-Log "Les mises à jour Windows ont été installées (redémarrage automatique si nécessaire)."
    }
    catch {
        Write-Log "Une erreur est survenue lors de la mise à jour de Windows : $_" "ERROR"
    }
}

# ===================================================================
# EXÉCUTION DU SCRIPT
# ===================================================================

Write-Log "===== Début du script d'installation ====="

Install-Chocolatey

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
    #"docker-desktop", # à adapter manuellement
    "bitwarden",
    "keepassxc",
    "microsoft365",
    "wireguard",
    "wireshark"
)

Install-Packages -Packages $packages

# Mise à jour de tous les packages Chocolatey déjà installés
Upgrade-AllPackages

# Mises à jour Windows
Update-Windows

Write-Log "===== Fin du script d'installation ====="
Write-Log "Fichier de log enregistré dans : $LogFile"
