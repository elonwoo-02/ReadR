[CmdletBinding()]
param(
    [switch]$Validate,
    [switch]$UpdateIndex,
    [string]$Root = (Join-Path $PSScriptRoot '..')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-Issue {
    param([string]$Level, [string]$File, [string]$Message)
    [pscustomobject]@{ Level = $Level; File = $File; Message = $Message }
}

function Get-Frontmatter {
    param([string]$Path)
    $content = Get-Content -LiteralPath $Path -Raw
    $match = [regex]::Match($content, '(?s)\A---\r?\n(.*?)\r?\n---')
    if (-not $match.Success) { return $null }

    $values = @{}
    $lines = $match.Groups[1].Value -split "\r?\n"
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -notmatch '^([A-Za-z][A-Za-z0-9_-]*):(?:\s*(.*))?$') { continue }
        $key = $Matches[1]
        $value = $Matches[2].Trim()
        if ($value -eq '') {
            $items = [System.Collections.Generic.List[string]]::new()
            $next = $index + 1
            while ($next -lt $lines.Count -and $lines[$next] -match '^\s+-\s+(.+?)\s*$') {
                $items.Add($Matches[1].Trim().Trim('"').Trim("'"))
                $next++
            }
            if ($items.Count -gt 0) {
                $values[$key] = @($items)
                $index = $next - 1
            } else { $values[$key] = '' }
        } elseif ($value -eq '[]') {
            $values[$key] = @()
        } elseif ($value -match '^\[(.*)\]$') {
            $values[$key] = @($Matches[1].Split(',') | ForEach-Object { $_.Trim().Trim('"').Trim("'") } | Where-Object { $_ })
        } else {
            $values[$key] = $value.Trim('"').Trim("'")
        }
    }
    $values
}

function Test-ValuePresent {
    param([hashtable]$Frontmatter, [string]$Key)
    if (-not $Frontmatter.ContainsKey($Key)) { return $false }
    $value = $Frontmatter[$Key]
    if ($value -is [array]) { return $value.Count -gt 0 }
    -not [string]::IsNullOrWhiteSpace([string]$value)
}

function Get-StatusTags {
    param([hashtable]$Frontmatter)
    if (-not $Frontmatter.ContainsKey('tags')) { return @() }
    @($Frontmatter['tags'] | Where-Object { $_ -is [string] -and $_ -match '^status/(to-read|browsed|close-read)$' })
}

function Get-ResearchNotes {
    param([string]$VaultRoot)
    $notes = foreach ($folder in @('library', 'annotations', 'reviews')) {
        $path = Join-Path $VaultRoot $folder
        if (Test-Path -LiteralPath $path) {
            Get-ChildItem -LiteralPath $path -Recurse -File -Filter '*.md' | Where-Object {
                $_.FullName -notmatch '[\\/]_template[\\/]' -and
                $_.Name -notin @('README.md', '_index.md', '_generated-index.md', 'dashboard.md', 'dataview-queries.md')
            }
        }
    }
    @($notes)
}

function Test-WikiTarget {
    param([string]$Target, [System.IO.FileInfo]$Source, [string]$VaultRoot, [hashtable]$ByName)
    $clean = (($Target -split '[#|]', 2)[0]).Trim()
    if ([string]::IsNullOrWhiteSpace($clean) -or $clean -match '^[a-z]+://') { return $true }
    if ($clean -match '[\\/]') {
        foreach ($candidate in @((Join-Path $Source.DirectoryName $clean), (Join-Path $VaultRoot $clean))) {
            $candidate = if ([System.IO.Path]::GetExtension($candidate)) { $candidate } else { "$candidate.md" }
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $true }
        }
        return $false
    }
    $ByName.ContainsKey($clean.ToLowerInvariant())
}

function Invoke-Validation {
    param([string]$VaultRoot)
    $issues = [System.Collections.Generic.List[object]]::new()
    $entriesPath = Join-Path $VaultRoot 'library/entries'
    $entries = if (Test-Path -LiteralPath $entriesPath) { @(Get-ChildItem -LiteralPath $entriesPath -Recurse -File -Filter '*.md') } else { @() }
    $notes = Get-ResearchNotes $VaultRoot
    $byName = @{}
    foreach ($note in $notes) {
        $key = [System.IO.Path]::GetFileNameWithoutExtension($note.Name).ToLowerInvariant()
        if (-not $byName.ContainsKey($key)) { $byName[$key] = @() }
        $byName[$key] += $note
    }

    $records = [System.Collections.Generic.List[object]]::new()
    $sourceRoot = [System.IO.Path]::GetFullPath((Join-Path $VaultRoot 'sources'))
    $sourcePrefix = $sourceRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    foreach ($entry in $entries) {
        $relative = $entry.FullName.Substring($VaultRoot.Length).TrimStart('\', '/')
        $frontmatter = Get-Frontmatter $entry.FullName
        if ($null -eq $frontmatter) {
            $issues.Add((New-Issue Error $relative 'Missing YAML frontmatter.'))
            continue
        }
        foreach ($key in @('title', 'authors', 'venue', 'tags', 'pdf', 'rating')) {
            if (-not (Test-ValuePresent $frontmatter $key)) { $issues.Add((New-Issue Error $relative "Missing required field: $key.")) }
        }
        foreach ($key in @('annotation', 'concepts', 'authors_related', 'datasets', 'benchmarks')) {
            if (-not $frontmatter.ContainsKey($key)) { $issues.Add((New-Issue Warning $relative "Recommended relationship field is absent: $key.")) }
        }

        $statusTags = @(Get-StatusTags $frontmatter)
        $allStatusTags = @(if ($frontmatter.ContainsKey('tags')) { @($frontmatter['tags'] | Where-Object { $_ -is [string] -and $_ -match '^status/' }) } else { @() })
        if ($statusTags.Count -ne 1 -or $allStatusTags.Count -ne 1) {
            $issues.Add((New-Issue Error $relative 'Exactly one valid status tag is required: status/to-read, status/browsed, or status/close-read.'))
        }

        if (Test-ValuePresent $frontmatter 'pdf') {
            $pdfPath = [System.IO.Path]::GetFullPath((Join-Path $entry.DirectoryName ([string]$frontmatter['pdf'])))
            if (-not $pdfPath.StartsWith($sourcePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                $issues.Add((New-Issue Error $relative 'PDF path must resolve inside sources/.'))
            } elseif (-not (Test-Path -LiteralPath $pdfPath -PathType Leaf)) {
                $issues.Add((New-Issue Error $relative "PDF file does not exist: $($frontmatter['pdf'])."))
            }
        }

        $hasAnnotation = Test-ValuePresent $frontmatter 'annotation'
        if ($hasAnnotation) {
            $annotationPath = [System.IO.Path]::GetFullPath((Join-Path $entry.DirectoryName ([string]$frontmatter['annotation'])))
            if (-not (Test-Path -LiteralPath $annotationPath -PathType Leaf)) {
                $issues.Add((New-Issue Error $relative "Annotation does not exist: $($frontmatter['annotation'])."))
            }
        }
        if ($statusTags -contains 'status/close-read' -and -not $hasAnnotation) {
            $issues.Add((New-Issue Error $relative 'A close-read entry requires an annotation path.'))
        }
        $records.Add([pscustomobject]@{
            File = $relative; Title = [string]$frontmatter['title']; Venue = [string]$frontmatter['venue']
            Rating = [string]$frontmatter['rating']; Status = if ($statusTags.Count -eq 1) { $statusTags[0] } else { '' }
            Tags = @($frontmatter['tags'])
        })
    }

    foreach ($note in $notes) {
        $relative = $note.FullName.Substring($VaultRoot.Length).TrimStart('\', '/')
        foreach ($match in [regex]::Matches((Get-Content -LiteralPath $note.FullName -Raw), '(?<!\!)\[\[([^\]]+)\]\]')) {
            if (-not (Test-WikiTarget $match.Groups[1].Value $note $VaultRoot $byName)) {
                $issues.Add((New-Issue Error $relative "Broken wiki link: [[$($match.Groups[1].Value)]]."))
            }
        }
    }
    [pscustomobject]@{ Issues = @($issues); Records = @($records) }
}

function Get-Direction {
    param([object[]]$Tags)
    $tag = @($Tags | Where-Object { $_ -is [string] -and $_ -match '^direction/' } | Select-Object -First 1)
    if ($tag.Count -eq 0) { return 'uncategorized' }
    $tag[0].Substring('direction/'.Length)
}

function Convert-MarkdownCell {
    param([string]$Value)
    ($Value -replace '\|', '\\|' -replace '[\r\n]+', ' ')
}

function Write-GeneratedIndex {
    param([string]$VaultRoot, [object[]]$Records, [object[]]$Issues)
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add('# Generated Research Index')
    $lines.Add('')
    $lines.Add('> Generated by scripts/ReadR.ps1 -UpdateIndex. Do not edit this file manually.')
    $lines.Add('')
    $lines.Add('## Reading Status')
    $lines.Add('')
    $lines.Add('| Status | Papers |')
    $lines.Add('| --- | ---: |')
    foreach ($status in @('status/to-read', 'status/browsed', 'status/close-read')) {
        $lines.Add("| $status | $(@($Records | Where-Object Status -eq $status).Count) |")
    }
    $lines.Add('')
    $lines.Add('## Papers by Direction')
    $lines.Add('')
    foreach ($group in @($Records | Group-Object { Get-Direction $_.Tags } | Sort-Object Name)) {
        $lines.Add("### $($group.Name)")
        $lines.Add('')
        $lines.Add('| Paper | Venue | Status | Rating |')
        $lines.Add('| --- | --- | --- | --- |')
        foreach ($record in @($group.Group | Sort-Object Title, File)) {
            $link = '[[' + ($record.File -replace '\\', '/' -replace '\.md$', '') + '|' + (Convert-MarkdownCell $record.Title) + ']]'
            $lines.Add("| $link | $(Convert-MarkdownCell $record.Venue) | $($record.Status) | $(Convert-MarkdownCell $record.Rating) |")
        }
        $lines.Add('')
    }
    $lines.Add('## Research Asset Counts')
    $lines.Add('')
    $lines.Add('| Asset type | Notes |')
    $lines.Add('| --- | ---: |')
    foreach ($folder in @('concepts', 'authors', 'datasets', 'benchmarks', 'comparisons', 'syntheses', 'projects')) {
        $path = Join-Path $VaultRoot (Join-Path 'library' $folder)
        $count = if (Test-Path -LiteralPath $path) { @(Get-ChildItem -LiteralPath $path -File -Filter '*.md' | Where-Object Name -ne 'README.md').Count } else { 0 }
        $lines.Add("| $folder | $count |")
    }
    $lines.Add('')
    $lines.Add('## Validation Summary')
    $lines.Add('')
    $lines.Add("- Errors: $(@($Issues | Where-Object Level -eq 'Error').Count)")
    $lines.Add("- Warnings: $(@($Issues | Where-Object Level -eq 'Warning').Count)")
    Set-Content -LiteralPath (Join-Path $VaultRoot 'library/_index.md') -Value $lines -Encoding utf8
}

$Root = [System.IO.Path]::GetFullPath($Root)
if (-not (Test-Path -LiteralPath $Root -PathType Container)) { throw "Vault root does not exist: $Root" }
if (-not $Validate -and -not $UpdateIndex) { $Validate = $true }
$result = Invoke-Validation $Root
foreach ($issue in $result.Issues | Sort-Object File, Level, Message) {
    Write-Host "[$($issue.Level)] $($issue.File): $($issue.Message)"
}
$errorCount = @($result.Issues | Where-Object Level -eq 'Error').Count
$warningCount = @($result.Issues | Where-Object Level -eq 'Warning').Count
Write-Host "Validation complete: $errorCount error(s), $warningCount warning(s)."
if ($UpdateIndex) {
    if ($errorCount -gt 0) { Write-Host 'Index was not generated because validation failed.' }
    else {
        Write-GeneratedIndex $Root $result.Records $result.Issues
        Write-Host 'Generated library/_index.md.'
    }
}
if ($errorCount -gt 0) { exit 1 }

