# ===================================================================
# FraicheInstall.ps1
# Script d'installation automatisée Windows
# Prérequis : PowerShell 5.1+, exécuter en tant qu'Administrateur
#
# Usage :
#   .\FraicheInstall.ps1           # installation réelle
#   .\FraicheInstall.ps1 -WhatIf  # simulation sans rien installer
# ===================================================================
[CmdletBinding()]
param(
    [switch]$WhatIf
)

#region Configuration
$Script:LogDir    = Join-Path ([Environment]::GetFolderPath("Desktop")) "InstallLogs"
$Script:LogFile   = Join-Path $Script:LogDir ("InstallLog_{0}.log" -f (Get-Date -Format "yyyy-MM-dd_HH-mm-ss"))
$Script:StatePath = Join-Path ([Environment]::GetFolderPath("Desktop")) "FraicheInstall.state.json"
$Script:PkgJson   = Join-Path $PSScriptRoot "packages.json"
$Script:SimMode   = $WhatIf.IsPresent
#endregion

#region Logging
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","OK","WARN","ERROR")]
        [string]$Level = "INFO"
    )
    if (-not (Test-Path $Script:LogDir)) {
        New-Item -ItemType Directory -Path $Script:LogDir | Out-Null
    }
    $ts   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$ts] [$Level] $Message"
    Add-Content -Path $Script:LogFile -Value $line -Encoding UTF8
    $color = switch ($Level) {
        "OK"    { "Green" }
        "WARN"  { "Yellow" }
        "ERROR" { "Red" }
        default { "Gray" }
    }
    Write-Host $line -ForegroundColor $color
}
#endregion

#region State Management
function New-InstallState {
    param([string[]]$Selected)
    return [PSCustomObject]@{
        startedAt = (Get-Date -Format "o")
        selected  = [array]$Selected
        completed = [array]@()
        failed    = [array]@()
        pending   = [array]$Selected
    }
}

function Get-InstallState {
    if (Test-Path $Script:StatePath) {
        return Get-Content $Script:StatePath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    return $null
}

function Save-InstallState {
    param($State)
    $State | ConvertTo-Json -Depth 3 | Set-Content $Script:StatePath -Encoding UTF8
}

function Update-InstallState {
    param($State, [string]$PackageId, [string]$Status)
    $State.pending = @($State.pending | Where-Object { $_ -ne $PackageId })
    if ($Status -eq "OK") {
        $State.completed = @($State.completed) + $PackageId
    } else {
        $State.failed = @($State.failed) + $PackageId
    }
    Save-InstallState -State $State
    return $State
}

function Remove-InstallState {
    if (Test-Path $Script:StatePath) {
        Remove-Item $Script:StatePath -Force
    }
}
#endregion

#region Menu
function Get-FlatMenuItems {
    param([array]$Categories, [hashtable]$CatExpanded)
    $items = [System.Collections.ArrayList]::new()
    for ($i = 0; $i -lt $Categories.Count; $i++) {
        $null = $items.Add([PSCustomObject]@{
            Type     = "category"
            CatIndex = $i
            PkgId    = $null
            Label    = $Categories[$i].name
            PkgCount = $Categories[$i].packages.Count
        })
        if ($CatExpanded[$i]) {
            foreach ($pkg in $Categories[$i].packages) {
                $null = $items.Add([PSCustomObject]@{
                    Type     = "package"
                    CatIndex = $i
                    PkgId    = $pkg.id
                    Label    = $pkg.label
                    PkgCount = 0
                })
            }
        }
    }
    return $items
}

function Render-PackageMenu {
    param(
        [System.Collections.ArrayList]$Items,
        [int]$Cursor,
        [hashtable]$CatSelected,
        [hashtable]$CatExpanded,
        [hashtable]$PkgSelected
    )
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║           FraicheInstall — Sélection             ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [↑↓] Naviguer  [ESPACE] Sélectionner  [ENTRÉE] Ouvrir/Fermer  [I] Installer  [A] Tout  [N] Rien" -ForegroundColor DarkGray
    Write-Host ""

    for ($idx = 0; $idx -lt $Items.Count; $idx++) {
        $item    = $Items[$idx]
        $pointer = if ($idx -eq $Cursor) { "▶" } else { " " }

        if ($item.Type -eq "category") {
            $checked = if ($CatSelected[$item.CatIndex]) { "[x]" } else { "[ ]" }
            $arrow   = if ($CatExpanded[$item.CatIndex]) { "▼" } else { "►" }
            $text    = "  $pointer $checked $arrow $($item.Label.PadRight(30)) ($($item.PkgCount) packages)"
            $color   = if ($idx -eq $Cursor) { "White" } elseif ($CatSelected[$item.CatIndex]) { "Green" } else { "Gray" }
            Write-Host $text -ForegroundColor $color
        } else {
            $key     = "{0}:{1}" -f $item.CatIndex, $item.PkgId
            $checked = if ($PkgSelected[$key]) { "[x]" } else { "[ ]" }
            $text    = "  $pointer      $checked  $($item.Label)"
            $color   = if ($idx -eq $Cursor) { "White" } elseif ($PkgSelected[$key]) { "Green" } else { "DarkGray" }
            Write-Host $text -ForegroundColor $color
        }
    }
    Write-Host ""
}

function Show-PackageMenu {
    param([array]$Categories)

    $catSelected = @{}
    $catExpanded = @{}
    $pkgSelected = @{}

    for ($i = 0; $i -lt $Categories.Count; $i++) {
        $catSelected[$i] = $false
        $catExpanded[$i] = $false
        foreach ($pkg in $Categories[$i].packages) {
            $pkgSelected["{0}:{1}" -f $i, $pkg.id] = $false
        }
    }

    $cursor    = 0
    $confirmed = $false

    while (-not $confirmed) {
        $items = Get-FlatMenuItems -Categories $Categories -CatExpanded $catExpanded
        if ($cursor -ge $items.Count) { $cursor = $items.Count - 1 }

        Render-PackageMenu -Items $items -Cursor $cursor `
            -CatSelected $catSelected -CatExpanded $catExpanded -PkgSelected $pkgSelected

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 { # Flèche haut
                if ($cursor -gt 0) { $cursor-- }
            }
            40 { # Flèche bas
                if ($cursor -lt ($items.Count - 1)) { $cursor++ }
            }
            32 { # Espace — toggle sélection
                $item = $items[$cursor]
                if ($item.Type -eq "category") {
                    $i = $item.CatIndex
                    $catSelected[$i] = -not $catSelected[$i]
                    foreach ($pkg in $Categories[$i].packages) {
                        $pkgSelected["{0}:{1}" -f $i, $pkg.id] = $catSelected[$i]
                    }
                } else {
                    $k = "{0}:{1}" -f $item.CatIndex, $item.PkgId
                    $pkgSelected[$k] = -not $pkgSelected[$k]
                    $allPkgs      = $Categories[$item.CatIndex].packages
                    $checkedCount = ($allPkgs | Where-Object { $pkgSelected["{0}:{1}" -f $item.CatIndex, $_.id] }).Count
                    $catSelected[$item.CatIndex] = ($checkedCount -eq $allPkgs.Count)
                }
            }
            13 { # Entrée — expand/collapse catégorie
                $item = $items[$cursor]
                if ($item.Type -eq "category") {
                    $catExpanded[$item.CatIndex] = -not $catExpanded[$item.CatIndex]
                }
            }
            73 { # I — confirmer et lancer
                $confirmed = $true
            }
            65 { # A — tout sélectionner
                for ($i = 0; $i -lt $Categories.Count; $i++) {
                    $catSelected[$i] = $true
                    foreach ($pkg in $Categories[$i].packages) {
                        $pkgSelected["{0}:{1}" -f $i, $pkg.id] = $true
                    }
                }
            }
            78 { # N — tout désélectionner
                for ($i = 0; $i -lt $Categories.Count; $i++) {
                    $catSelected[$i] = $false
                    foreach ($pkg in $Categories[$i].packages) {
                        $pkgSelected["{0}:{1}" -f $i, $pkg.id] = $false
                    }
                }
            }
        }
    }

    return @($pkgSelected.Keys | Where-Object { $pkgSelected[$_] } | ForEach-Object { $_.Split(':', 2)[1] })
}
#endregion

#region Chocolatey
function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Log "Chocolatey déjà installé."
        return
    }
    Write-Log "Installation de Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Échec de l'installation de Chocolatey." "ERROR"
        exit 1
    }
    Write-Log "Chocolatey installé." "OK"
}

function Install-SinglePackage {
    param(
        [string]$PackageId,
        [string]$Label,
        [int]$MaxRetries = 3
    )

    if ($Script:SimMode) {
        Write-Log "[SIMULATION] $Label — OK" "OK"
        Start-Sleep -Milliseconds 150
        return [PSCustomObject]@{
            Package  = $Label
            Status   = "OK"
            Duration = [TimeSpan]::FromMilliseconds(150)
            Note     = "Simulation"
        }
    }

    $alreadyInstalled = choco list --local-only 2>$null | Select-String "^$([regex]::Escape($PackageId))\s"
    if ($alreadyInstalled) {
        Write-Log "$Label est déjà installé — ignoré." "WARN"
        return [PSCustomObject]@{
            Package  = $Label
            Status   = "SKIP"
            Duration = [TimeSpan]::Zero
            Note     = "Déjà installé"
        }
    }

    $sw           = [System.Diagnostics.Stopwatch]::StartNew()
    $lastExitCode = 1

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            Write-Log "[$PackageId] Tentative $attempt/$MaxRetries..."
            choco install $PackageId -y --no-progress 2>&1 | Add-Content $Script:LogFile -Encoding UTF8
            $lastExitCode = $LASTEXITCODE
            if ($lastExitCode -eq 0) {
                $sw.Stop()
                Write-Log "$Label installé avec succès." "OK"
                return [PSCustomObject]@{
                    Package  = $Label
                    Status   = "OK"
                    Duration = $sw.Elapsed
                    Note     = ""
                }
            }
            Write-Log "[$PackageId] Tentative $attempt échouée (code $lastExitCode)." "WARN"
        } catch {
            Write-Log "[$PackageId] Exception : $_" "WARN"
        }
    }

    $sw.Stop()
    Write-Log "$Label n'a pas pu être installé après $MaxRetries tentatives." "ERROR"
    return [PSCustomObject]@{
        Package  = $Label
        Status   = "FAIL"
        Duration = $sw.Elapsed
        Note     = "Code $lastExitCode"
    }
}
#endregion

#region Updates
function Invoke-ChocoUpgrade {
    Write-Log "Mise à jour de tous les packages Chocolatey existants..."
    if ($Script:SimMode) {
        Write-Log "[SIMULATION] choco upgrade all — ignoré." "WARN"
        return
    }
    choco upgrade all -y --no-progress 2>&1 | Add-Content $Script:LogFile -Encoding UTF8
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Packages Chocolatey mis à jour." "OK"
    } else {
        Write-Log "Erreur lors de la mise à jour Chocolatey (code $LASTEXITCODE)." "WARN"
    }
}

function Invoke-WindowsUpdate {
    Write-Log "Recherche et installation des mises à jour Windows..."
    if ($Script:SimMode) {
        Write-Log "[SIMULATION] Windows Update — ignoré." "WARN"
        return
    }
    try {
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Write-Log "Installation du module PSWindowsUpdate..."
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
            Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
        }
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -AcceptAll -Install -AutoReboot 2>&1 | Add-Content $Script:LogFile -Encoding UTF8
        Write-Log "Mises à jour Windows installées." "OK"
    } catch {
        Write-Log "Erreur lors des mises à jour Windows : $_" "ERROR"
    }
}
#endregion

#region Reports
function Show-AsciiSummary {
    param(
        [System.Collections.ArrayList]$Results,
        [TimeSpan]$TotalDuration
    )

    $maxPkg = ($Results | ForEach-Object { $_.Package.Length } | Measure-Object -Maximum).Maximum
    $col1   = [Math]::Max($maxPkg, 7)
    $col2   = 8
    $col3   = 9
    $col4   = 16
    $innerW = $col1 + $col2 + $col3 + $col4 + 9

    $hTop = "╔{0}╦{1}╦{2}╦{3}╗" -f ('═' * ($col1+2)), ('═' * ($col2+2)), ('═' * ($col3+2)), ('═' * ($col4+2))
    $hDiv = "╠{0}╬{1}╬{2}╬{3}╣" -f ('═' * ($col1+2)), ('═' * ($col2+2)), ('═' * ($col3+2)), ('═' * ($col4+2))
    $hBot = "╚{0}╩{1}╩{2}╩{3}╝" -f ('═' * ($col1+2)), ('═' * ($col2+2)), ('═' * ($col3+2)), ('═' * ($col4+2))

    $ok      = ($Results | Where-Object { $_.Status -eq "OK"   }).Count
    $fail    = ($Results | Where-Object { $_.Status -eq "FAIL" }).Count
    $skip    = ($Results | Where-Object { $_.Status -eq "SKIP" }).Count
    $durStr  = "{0}m {1:D2}s" -f [int]$TotalDuration.TotalMinutes, $TotalDuration.Seconds
    $summary = "Total : $($Results.Count)   OK : $ok   Fail : $fail   Skip : $skip   Durée : $durStr"

    Write-Host ""
    Write-Host $hTop -ForegroundColor Cyan
    Write-Host ("║ {0} ║" -f "Résumé d'installation".PadRight($innerW)) -ForegroundColor Cyan
    Write-Host $hDiv -ForegroundColor Cyan
    Write-Host ("║ {0} ║ {1} ║ {2} ║ {3} ║" -f "Package".PadRight($col1), "Statut".PadRight($col2), "Durée".PadRight($col3), "Note".PadRight($col4)) -ForegroundColor Cyan
    Write-Host $hDiv -ForegroundColor Cyan

    foreach ($r in $Results) {
        $statusColor = switch ($r.Status) { "OK" { "Green" } "FAIL" { "Red" } default { "DarkGray" } }
        $statusSym   = switch ($r.Status) { "OK" { "✓ OK" } "FAIL" { "✗ FAIL" } default { "⚠ SKIP" } }
        $dur         = if ($r.Duration.TotalSeconds -lt 0.1) { "-" } else { "{0}m {1:D2}s" -f [int]$r.Duration.TotalMinutes, $r.Duration.Seconds }
        $note        = if ($r.Note.Length -gt $col4) { $r.Note.Substring(0, $col4 - 3) + "..." } else { $r.Note }

        Write-Host "║ " -ForegroundColor Cyan -NoNewline
        Write-Host $r.Package.PadRight($col1) -ForegroundColor White -NoNewline
        Write-Host " ║ " -ForegroundColor Cyan -NoNewline
        Write-Host $statusSym.PadRight($col2) -ForegroundColor $statusColor -NoNewline
        Write-Host " ║ " -ForegroundColor Cyan -NoNewline
        Write-Host $dur.PadRight($col3) -ForegroundColor White -NoNewline
        Write-Host " ║ " -ForegroundColor Cyan -NoNewline
        Write-Host $note.PadRight($col4) -ForegroundColor DarkGray -NoNewline
        Write-Host " ║" -ForegroundColor Cyan
    }

    Write-Host $hDiv -ForegroundColor Cyan
    Write-Host ("║ {0} ║" -f $summary.PadRight($innerW)) -ForegroundColor Cyan
    Write-Host $hBot -ForegroundColor Cyan
    Write-Host ""
}

function New-HtmlReport {
    param(
        [System.Collections.ArrayList]$Results,
        [TimeSpan]$TotalDuration,
        [string]$ReportPath
    )

    $ok     = ($Results | Where-Object { $_.Status -eq "OK"   }).Count
    $fail   = ($Results | Where-Object { $_.Status -eq "FAIL" }).Count
    $skip   = ($Results | Where-Object { $_.Status -eq "SKIP" }).Count
    $durStr = "{0}m {1:D2}s" -f [int]$TotalDuration.TotalMinutes, $TotalDuration.Seconds
    $date   = (Get-Date).ToString("dd/MM/yyyy HH:mm")

    $rows = $Results | ForEach-Object {
        $cls = $_.Status.ToLower()
        $dur = if ($_.Duration.TotalSeconds -lt 0.1) { "-" } else { "{0}m {1:D2}s" -f [int]$_.Duration.TotalMinutes, $_.Duration.Seconds }
        $pkg  = $_.Package -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;'
        $note = $_.Note    -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;'
        "<tr class='$cls'><td>$pkg</td><td>$($_.Status)</td><td>$dur</td><td>$note</td></tr>"
    }

    $html = @"
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>FraicheInstall — Rapport</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: #0f0f1a; color: #e0e0e0; font-family: 'Segoe UI', Tahoma, sans-serif; padding: 2rem; }
  h1   { color: #00d4ff; margin-bottom: .5rem; font-size: 1.6rem; }
  .meta { color: #888; margin-bottom: 1.5rem; font-size: .9rem; display: flex; flex-wrap: wrap; gap: .5rem 1.5rem; }
  .ok   { color: #4caf50; font-weight: 600; }
  .fail { color: #f44336; font-weight: 600; }
  .skip { color: #757575; }
  table { border-collapse: collapse; width: 100%; max-width: 860px; }
  th { background: #1a1a2e; color: #00d4ff; padding: 10px 16px; text-align: left; font-weight: 500; }
  td { padding: 8px 16px; border-bottom: 1px solid #1e1e30; }
  tr:hover td { background: #16213e; }
  tr.ok   td:nth-child(2) { color: #4caf50; font-weight: 600; }
  tr.fail td:nth-child(2) { color: #f44336; font-weight: 600; }
  tr.skip td              { color: #757575; }
</style>
</head>
<body>
<h1>FraicheInstall — Rapport d'installation</h1>
<div class="meta">
  <span>📅 $date</span>
  <span>📦 Total : $($Results.Count)</span>
  <span class="ok">✓ OK : $ok</span>
  <span class="fail">✗ Échec : $fail</span>
  <span class="skip">⚠ Ignoré : $skip</span>
  <span>⏱ Durée : $durStr</span>
</div>
<table>
  <thead>
    <tr><th>Package</th><th>Statut</th><th>Durée</th><th>Note</th></tr>
  </thead>
  <tbody>
    $($rows -join "`n    ")
  </tbody>
</table>
</body>
</html>
"@
    $html | Set-Content -Path $ReportPath -Encoding UTF8
}
#endregion

#region Main
function Main {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Error "Ce script doit être exécuté avec des privilèges administratifs."
        exit 1
    }

    if (-not (Test-Path $Script:LogDir)) {
        New-Item -ItemType Directory -Path $Script:LogDir | Out-Null
    }

    Write-Log "===== Début de FraicheInstall =====$(if ($Script:SimMode) { ' [MODE SIMULATION]' })"

    if (-not (Test-Path $Script:PkgJson)) {
        Write-Log "packages.json introuvable : $Script:PkgJson" "ERROR"
        exit 1
    }
    $config = Get-Content $Script:PkgJson -Raw -Encoding UTF8 | ConvertFrom-Json

    $labelMap = @{}
    foreach ($cat in $config.categories) {
        foreach ($pkg in $cat.packages) { $labelMap[$pkg.id] = $pkg.label }
    }

    # Vérifier fichier d'état (reprise après reboot)
    $existingState = Get-InstallState
    $selectedIds   = @()

    if ($existingState) {
        $completed = @($existingState.completed)
        $failed    = @($existingState.failed)
        $pending   = @($existingState.pending)

        Write-Host ""
        Write-Host "  ⚠ Installation précédente interrompue ($($existingState.startedAt))." -ForegroundColor Yellow
        Write-Host "    $($completed.Count) installés, $($failed.Count) échoués, $($pending.Count) en attente." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  [R] Reprendre   [N] Nouvelle installation   [Q] Quitter" -ForegroundColor Cyan
        Write-Host ""

        $choice = ""
        while ($choice -notin @("R","N","Q")) {
            $k      = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            $choice = ([char]$k.Character).ToString().ToUpper()
        }

        switch ($choice) {
            "R" {
                Write-Log "Reprise — $($pending.Count) packages restants + $($failed.Count) en échec."
                $selectedIds = @($pending) + @($failed)
            }
            "N" { Remove-InstallState; $existingState = $null }
            "Q" { Write-Log "Annulé par l'utilisateur."; exit 0 }
        }
    }

    if (-not $existingState) {
        $selectedIds = Show-PackageMenu -Categories $config.categories
        if ($selectedIds.Count -eq 0) {
            Write-Log "Aucun package sélectionné. Fin du script."
            exit 0
        }
    }

    $state = if ($existingState) { $existingState } else { New-InstallState -Selected $selectedIds }
    Save-InstallState -State $state

    Install-Chocolatey

    $results     = [System.Collections.ArrayList]::new()
    $globalWatch = [System.Diagnostics.Stopwatch]::StartNew()

    foreach ($pkgId in $selectedIds) {
        if ($existingState -and (@($existingState.completed) -contains $pkgId)) {
            $null = $results.Add([PSCustomObject]@{
                Package  = if ($labelMap.ContainsKey($pkgId)) { $labelMap[$pkgId] } else { $pkgId }
                Status   = "SKIP"
                Duration = [TimeSpan]::Zero
                Note     = "Déjà installé (reprise)"
            })
            continue
        }

        $label  = if ($labelMap.ContainsKey($pkgId)) { $labelMap[$pkgId] } else { $pkgId }
        $result = Install-SinglePackage -PackageId $pkgId -Label $label
        $null   = $results.Add($result)
        $state  = Update-InstallState -State $state -PackageId $pkgId -Status $result.Status
    }

    Invoke-ChocoUpgrade
    Invoke-WindowsUpdate

    $globalWatch.Stop()

    Show-AsciiSummary -Results $results -TotalDuration $globalWatch.Elapsed

    $stamp      = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $reportPath = Join-Path $Script:LogDir "InstallReport_$stamp.html"
    New-HtmlReport -Results $results -TotalDuration $globalWatch.Elapsed -ReportPath $reportPath
    Write-Log "Rapport HTML : $reportPath" "OK"
    Start-Process $reportPath

    Remove-InstallState
    Write-Log "===== FraicheInstall terminé ====="
}
#endregion

# Point d'entrée
Main
