<#
.SYNOPSIS
    One-time migration for ReadR vault: merge benchmarks into datasets,
    add generated/verified trust signals, update entry YAML fields.

.DESCRIPTION
    Phase 3 migration:
    - Move benchmark files to library/datasets/ with type: benchmark
    - Merge duplicate benchmark/dataset files into type: both
    - Add type/generated/verified to all dataset files
    - Update entry YAML: add metrics, github, generated, verified
    - Run 'pwsh scripts/ReadR.ps1 -Validate' after migration

.PARAMETER Root
    Vault root directory. Defaults to parent of scripts/.

.PARAMETER DryRun
    Show what would change without making changes.
#>
[CmdletBinding()]
param(
    [string]$Root = (Join-Path $PSScriptRoot '..'),
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = [System.IO.Path]::GetFullPath($Root)
$datasetsDir = Join-Path $Root 'library/datasets'
$benchmarksDir = Join-Path $Root 'library/benchmarks'
$entriesDir = Join-Path $Root 'library/entries'

function Add-YamlField($content, $field, $value) {
    # Check if field already exists in YAML frontmatter (before closing ---)
    $lines = $content -split "\r?\n"
    $endYaml = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -gt 0 -and $lines[$i] -eq '---') { $endYaml = $i; break }
    }
    if ($endYaml -lt 0) { return $content }

    # Check existing
    for ($i = 0; $i -lt $endYaml; $i++) {
        if ($lines[$i] -match "^\s*$field\s*:") { return $content }
    }

    # Insert field before closing ---
    $fieldLine = $field + ": " + $value
    $newLines = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -eq $endYaml) { $newLines += $fieldLine }
        $newLines += $lines[$i]
    }
    $newLines -join "`r`n"
}

function Add-YamlListField($content, $field) {
    Add-YamlField $content $field "[]"
}

function Add-YamlStringField($content, $field, $value) {
    Add-YamlField $content $field $value
}

function Add-YamlEnumField($content, $field, $value) {
    Add-YamlField $content $field $value
}

function Migrate-BenchmarkFile($benchmarkFile, $existingDatasetFile) {
    $destName = [System.IO.Path]::GetFileName($benchmarkFile)
    $destPath = Join-Path $datasetsDir $destName

    if ($existingDatasetFile) {
        # Merge: dataset version is primary, add benchmark fields and type: both
        $datasetContent = Get-Content -LiteralPath $existingDatasetFile -Raw

        # Parse benchmark YAML for fields to merge
        $benchContent = Get-Content -LiteralPath $benchmarkFile -Raw
        $match = [regex]::Match($benchContent, '(?s)\A---\r?\n(.*?)\r?\n---')
        if ($match.Success) {
            $bmLines = $match.Groups[1].Value -split "\r?\n"
            foreach ($line in $bmLines) {
                if ($line -match '^\s*([\w_]+):\s*(.*)$') {
                    $key = $Matches[1]
                    $val = $Matches[2].Trim().Trim('"').Trim("'")
                    if ($key -eq 'type') { continue } # will set to 'both'
                    if ($datasetContent -match "\r?\n$key\s*:") { continue } # already in dataset
                    $datasetContent = Add-YamlField $datasetContent $key $val
                }
            }
        }

        # Update type to both, add trust signals
        $datasetContent = $datasetContent -replace "(?m)type:\s*dataset", "type: both"
        $datasetContent = $datasetContent -replace "(?m)type:\s*benchmark", "type: both"
        if (-not ($datasetContent -match "\r?\ntype\s*:")) {
            $datasetContent = Add-YamlField $datasetContent "type" "both"
        }
        $datasetContent = Add-YamlStringField $datasetContent "github" '""'
        $datasetContent = Add-YamlEnumField $datasetContent "generated" "human"
        $datasetContent = Add-YamlEnumField $datasetContent "verified" "unverified"

        if ($DryRun) { Write-Host "[MERGE] $destName (dataset + benchmark -> type: both)"; return }
        Set-Content -LiteralPath $existingDatasetFile -Value $datasetContent -Encoding utf8
        Write-Host "[MERGED] $destName -> type: both"
    }
    else {
        # Unique benchmark: add type, github, generated, verified
        $content = Get-Content -LiteralPath $benchmarkFile -Raw
        $content = Add-YamlEnumField $content "type" "benchmark"
        $content = Add-YamlStringField $content "github" '""'
        $content = Add-YamlEnumField $content "generated" "human"
        $content = Add-YamlEnumField $content "verified" "unverified"

        if ($DryRun) { Write-Host "[MOVE] $destName (benchmark)"; return }
        Set-Content -LiteralPath $destPath -Value $content -Encoding utf8
        Write-Host "[MOVED] $destName -> library/datasets/ (type: benchmark)"
    }
}

function Migrate-DatasetFile($datasetFile) {
    $content = Get-Content -LiteralPath $datasetFile -Raw

    # Add type: dataset if not present
    if ($content -match "\r?\ntype\s*:") {
        $content = $content -replace "(?m)type:\s*\S+", "type: dataset"
    } else {
        $content = Add-YamlEnumField $content "type" "dataset"
    }
    $content = Add-YamlStringField $content "github" '""'
    $content = Add-YamlEnumField $content "generated" "human"
    $content = Add-YamlEnumField $content "verified" "unverified"

    if (-not $DryRun) { Set-Content -LiteralPath $datasetFile -Value $content -Encoding utf8 }

    $name = [System.IO.Path]::GetFileName($datasetFile)
    if ($DryRun) { Write-Host "[UPDATE] $name (type: dataset)" }
}

function Migrate-EntryFile($entryFile) {
    $content = Get-Content -LiteralPath $entryFile -Raw

    $content = Add-YamlListField $content "metrics"
    $content = Add-YamlStringField $content "github" '""'
    $content = Add-YamlEnumField $content "generated" "human"
    $content = Add-YamlEnumField $content "verified" "unverified"

    if (-not $DryRun) { Set-Content -LiteralPath $entryFile -Value $content -Encoding utf8 }

    $rel = $entryFile.Substring($Root.Length).TrimStart('\', '/')
    if ($DryRun) { Write-Host "[UPDATE] $rel" }
}

# --- PHASE 3A: Migrate benchmarks ---
Write-Host ""
Write-Host "=== Phase 3A: Migrating benchmarks to library/datasets/ ==="
if (Test-Path -LiteralPath $benchmarksDir) {
    $benchmarkFiles = Get-ChildItem -LiteralPath $benchmarksDir -File -Filter '*.md' | Where-Object { $_.Name -ne 'README.md' }
    foreach ($bf in $benchmarkFiles) {
        $destName = $bf.Name
        $existingDataset = Join-Path $datasetsDir $destName
        $existing = if (Test-Path -LiteralPath $existingDataset) { $existingDataset } else { $null }
        Migrate-BenchmarkFile $bf.FullName $existing
    }
} else {
    Write-Host "  (no benchmarks directory found)"
}

# --- PHASE 3B: Update datasets with type/generated/verified ---
Write-Host ""
Write-Host "=== Phase 3B: Updating datasets with type/generated/verified ==="
$datasetFiles = Get-ChildItem -LiteralPath $datasetsDir -File -Filter '*.md' | Where-Object { $_.Name -ne 'README.md' }
foreach ($df in $datasetFiles) {
    Migrate-DatasetFile $df.FullName
}

# --- PHASE 3C: Update entries ---
Write-Host ""
Write-Host "=== Phase 3C: Updating entries with metrics/github/generated/verified ==="
$entryFiles = Get-ChildItem -LiteralPath $entriesDir -Recurse -File -Filter '*.md' | Where-Object { $_.FullName -notmatch '[\\/]\.obsidian[\\/]' }
foreach ($ef in $entryFiles) {
    Migrate-EntryFile $ef.FullName
}

# --- Summary ---
Write-Host ""
Write-Host "=== Migration complete ==="
if ($DryRun) { Write-Host "  (DryRun mode -- no changes made)" }
else {
    Write-Host "  Delete library/benchmarks/ directory after verification."
    Write-Host "  Run: pwsh scripts/ReadR.ps1 -Validate"
}
