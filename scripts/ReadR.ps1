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

function Get-StatusValue {
    param([hashtable]$Frontmatter)
    if (-not $Frontmatter.ContainsKey('status')) { return $null }
    $value = [string]$Frontmatter['status']
    if ($value -match '^(to-read|browsed|close-read)$') { return $value }
    $null
}

function Get-DirectionValue {
    param([hashtable]$Frontmatter)
    if (-not $Frontmatter.ContainsKey('direction') -or [string]::IsNullOrWhiteSpace([string]$Frontmatter['direction'])) { return 'uncategorized' }
    [string]$Frontmatter['direction']
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

function Get-WikiLinkTarget {
    param([string]$Value)
    # Returns the cleaned target inside [[ ... ]] if $Value is a wiki-link, else $null.
    # Accepts [[Target]], [[Target|Alias]], [[Target#Heading]], [[Target^block]].
    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    if ($Value -notmatch '^\[\[(.+)\]\]$') { return $null }
    $target = (($Matches[1] -split '[#|]', 2)[0]).Trim()
    if ([string]::IsNullOrWhiteSpace($target)) { return $null }
    $target
}

function Build-BasenameIndex {
    param([string]$DirectoryPath)
    # Returns a hashtable keyed by lowercased basename — both WITH extension and
    # WITHOUT extension — mapping to a list of full paths. Dual keys let both
    # [[file.pdf]] (with ext) and [[Note Name]] (without ext) resolve.
    $index = @{}
    if (-not (Test-Path -LiteralPath $DirectoryPath)) { return $index }
    foreach ($file in (Get-ChildItem -LiteralPath $DirectoryPath -Recurse -File)) {
        $withExt = $file.Name.ToLowerInvariant()
        $withoutExt = [System.IO.Path]::GetFileNameWithoutExtension($file.Name).ToLowerInvariant()
        foreach ($key in @($withExt, $withoutExt)) {
            if ([string]::IsNullOrWhiteSpace($key)) { continue }
            if (-not $index.ContainsKey($key)) { $index[$key] = [System.Collections.Generic.List[string]]::new() }
            $index[$key].Add($file.FullName)
        }
    }
    $index
}

function Resolve-VaultLink {
    param([string]$Target, [string]$VaultRoot, [string]$RestrictDir, [hashtable]$ByBasename)
    # Resolves a wiki-link target to an absolute path under $RestrictDir, or $null.
    # Name-style links resolve via $ByBasename; path-style links resolve relative
    # to the vault root. URL targets are not vault files.
    if ([string]::IsNullOrWhiteSpace($Target)) { return $null }
    if ($Target -match '^[a-z]+://') { return $null }
    if ($Target -match '[\\/]') {
        $restrictFull = [System.IO.Path]::GetFullPath((Join-Path $VaultRoot $RestrictDir))
        $restrictPrefix = $restrictFull.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
        $candidate = Join-Path $VaultRoot $Target
        if (-not [System.IO.Path]::GetExtension($candidate)) { $candidate = "$candidate.md" }
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            $resolved = [System.IO.Path]::GetFullPath($candidate)
            if ($resolved.StartsWith($restrictPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { return $resolved }
        }
        return $null
    }
    $key = $Target.ToLowerInvariant()
    if ($ByBasename.ContainsKey($key) -and $ByBasename[$key].Count -gt 0) { return @($ByBasename[$key])[0] }
    $null
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

    # Basename indices for resolving wiki-link fields (source -> sources/,
    # annotation -> annotations/). Dual-keyed (with/without extension).
    $sourcesByName = Build-BasenameIndex (Join-Path $VaultRoot 'sources')
    $annotationsByName = Build-BasenameIndex (Join-Path $VaultRoot 'annotations')

    $records = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $entries) {
        $relative = $entry.FullName.Substring($VaultRoot.Length).TrimStart('\', '/')
        $frontmatter = Get-Frontmatter $entry.FullName
        if ($null -eq $frontmatter) {
            $issues.Add((New-Issue Error $relative 'Missing YAML frontmatter.'))
            continue
        }
        foreach ($key in @('title', 'authors', 'venue', 'source', 'method', 'task', 'status', 'direction')) {
            if (-not (Test-ValuePresent $frontmatter $key)) { $issues.Add((New-Issue Error $relative "Missing required field: $key.")) }
        }
        foreach ($key in @('annotation', 'concepts', 'datasets', 'github', 'generated', 'verified')) {
            if (-not $frontmatter.ContainsKey($key)) {
                $msg = if ($key -eq 'datasets') { "Recommended relationship field is absent: $key (use type field to distinguish dataset/benchmark)." }
                       else { "Recommended relationship field is absent: $key." }
                $issues.Add((New-Issue Warning $relative $msg))
            }
        }

        # Backward compatibility: if 'datasets' is absent but 'benchmarks' exists, merge into 'datasets'
        if ((-not $frontmatter.ContainsKey('datasets') -or
             ($frontmatter['datasets'] -is [array] -and $frontmatter['datasets'].Count -eq 0)) -and
            $frontmatter.ContainsKey('benchmarks')) {
            $frontmatter['datasets'] = $frontmatter['benchmarks']
            $issues.Add((New-Issue Warning $relative "Deprecated field 'benchmarks' used; merged into 'datasets'. Please migrate."))
        }

        # Validate generated field
        if ($frontmatter.ContainsKey('generated')) {
            $genValue = [string]$frontmatter['generated']
            if (-not ($genValue -match '^(human|ai|agent)$')) {
                $issues.Add((New-Issue Error $relative "Invalid generated value: '$genValue'. Must be human, ai, or agent."))
            }
        }

        # Validate verified field
        if ($frontmatter.ContainsKey('verified')) {
            $verValue = [string]$frontmatter['verified']
            if (-not ($verValue -match '^(unverified|machine-confirmed|human-reviewed)$')) {
                $issues.Add((New-Issue Error $relative "Invalid verified value: '$verValue'. Must be unverified, machine-confirmed, or human-reviewed."))
            }
        }

        $statusValue = Get-StatusValue $frontmatter
        if (-not $statusValue) {
            $issues.Add((New-Issue Error $relative 'Valid status field is required: to-read, browsed, or close-read.'))
        }

        if (Test-ValuePresent $frontmatter 'source') {
            $sourceTarget = Get-WikiLinkTarget ([string]$frontmatter['source'])
            if ($null -eq $sourceTarget) {
                $issues.Add((New-Issue Error $relative 'Source must be a wiki-link [[...]] resolving to a file under sources/.'))
            } else {
                $resolved = Resolve-VaultLink $sourceTarget $VaultRoot 'sources' $sourcesByName
                if (-not $resolved) {
                    $issues.Add((New-Issue Error $relative "Source wiki-link does not resolve to a file under sources/: [[$sourceTarget]]."))
                }
            }
        }

        $hasAnnotation = Test-ValuePresent $frontmatter 'annotation'
        if ($hasAnnotation) {
            $annotationTarget = Get-WikiLinkTarget ([string]$frontmatter['annotation'])
            if ($null -eq $annotationTarget) {
                $issues.Add((New-Issue Error $relative 'annotation must be a wiki-link [[...]] resolving to a file under annotations/.'))
            } else {
                $resolved = Resolve-VaultLink $annotationTarget $VaultRoot 'annotations' $annotationsByName
                if (-not $resolved) {
                    $issues.Add((New-Issue Error $relative "annotation wiki-link does not resolve to a file under annotations/: [[$annotationTarget]]."))
                }
            }
        }
        if ($statusValue -eq 'close-read' -and -not $hasAnnotation) {
            $issues.Add((New-Issue Error $relative 'A close-read entry requires an annotation.'))
        }
        $records.Add([pscustomobject]@{
            File = $relative; Title = [string]$frontmatter['title']; Venue = [string]$frontmatter['venue']
            Status = if ($statusValue) { $statusValue } else { '' }
            Direction = Get-DirectionValue $frontmatter
        })
    }

    foreach ($note in $notes) {
        $relative = $note.FullName.Substring($VaultRoot.Length).TrimStart('\', '/')
        $raw = Get-Content -LiteralPath $note.FullName -Raw
        # Scan only the note body, not the YAML frontmatter — field-value wiki-links
        # (source, annotation) are validated by their own field logic.
        $fmMatch = [regex]::Match($raw, '(?s)\A---\r?\n.*?\r?\n---')
        $body = if ($fmMatch.Success) { $raw.Substring($fmMatch.Length) } else { $raw }
        foreach ($match in [regex]::Matches($body, '(?<!\!)\[\[([^\]]+)\]\]')) {
            if (-not (Test-WikiTarget $match.Groups[1].Value $note $VaultRoot $byName)) {
                $issues.Add((New-Issue Error $relative "Broken wiki link: [[$($match.Groups[1].Value)]]."))
            }
        }
    }

    # De-duplicate detection across knowledge directories
    foreach ($dedupDir in @('authors', 'concepts', 'datasets')) {
        $dirPath = Join-Path $VaultRoot (Join-Path 'library' $dedupDir)
        $dupIssues = Invoke-DuplicateDetection $dirPath $VaultRoot
        foreach ($di in $dupIssues) { $issues.Add($di) }
    }

    [pscustomobject]@{ Issues = @($issues); Records = @($records) }
}

function Convert-MarkdownCell {
    param([string]$Value)
    ($Value -replace '\|', '\\|' -replace '[\r\n]+', ' ')
}

<#
.SYNOPSIS
    Detect potential duplicate knowledge notes across a library subdirectory.
.DESCRIPTION
    Checks for same-title entries, author name format variations
    ("Last, First" vs "First Last"), and aliases that reference another note's title.
.PARAMETER DirectoryPath
    The directory to scan (e.g. library/authors/).
.PARAMETER VaultRoot
    The vault root for relative path computation.
#>
function Invoke-DuplicateDetection {
    param([string]$DirectoryPath, [string]$VaultRoot)

    $issues = [System.Collections.Generic.List[object]]::new()
    if (-not (Test-Path -LiteralPath $DirectoryPath)) { return $issues }

    $files = Get-ChildItem -LiteralPath $DirectoryPath -File -Filter '*.md' | Where-Object { $_.Name -ne 'README.md' }
    $noteData = [System.Collections.Generic.List[object]]::new()

    foreach ($file in $files) {
        $fm = Get-Frontmatter $file.FullName
        if (-not $fm -or -not $fm.ContainsKey('title')) { continue }
        $rel = $file.FullName.Substring($VaultRoot.Length).TrimStart('\', '/')
        $title = [string]$fm['title'].Trim('"').Trim("'")
        $aliases = @()
        if ($fm.ContainsKey('aliases') -and $fm['aliases'] -is [array]) { $aliases = @($fm['aliases']) }
        $noteData.Add([pscustomobject]@{ File = $rel; Title = $title; Aliases = $aliases })
    }

    # Build normalized title set for alias cross-checking
    $titleIndex = @{}
    foreach ($n in $noteData) {
        $norm = $n.Title.ToLowerInvariant().Trim()
        if ($titleIndex.ContainsKey($norm)) {
            $issues.Add((New-Issue Warning $n.File "Potential duplicate: same title '$($n.Title)' also at $($titleIndex[$norm])."))
        } else {
            $titleIndex[$norm] = $n.File
        }
    }

    # Detect author name format collisions: "Last, First" vs "First Last"
    foreach ($n in $noteData) {
        $t = $n.Title
        # If title contains a comma, extract Last+First
        if ($t -match '^([^,]+),\s*(.+)$') {
            $last = $Matches[1].Trim()
            $first = $Matches[2].Trim()
            $altForm = "$first $last"
            $altNorm = $altForm.ToLowerInvariant().Trim()
            if ($altNorm -ne $t.ToLowerInvariant().Trim() -and $titleIndex.ContainsKey($altNorm)) {
                $issues.Add((New-Issue Warning $n.File "Potential author duplicate: '$($n.Title)' may match '$($titleIndex[$altNorm])' (different name format)."))
            }
        } else {
            # Title is "First Last" — check for "Last, First" variant
            $parts = $t.Trim().Split(' ')
            if ($parts.Count -ge 2) {
                $last = $parts[-1]
                $first = ($parts[0..($parts.Count - 2)]) -join ' '
                $altForm = "$last, $first"
                $altNorm = $altForm.ToLowerInvariant().Trim()
                if ($altNorm -ne $t.ToLowerInvariant().Trim() -and $titleIndex.ContainsKey($altNorm)) {
                    $issues.Add((New-Issue Warning $n.File "Potential author duplicate: '$($n.Title)' may match '$($titleIndex[$altNorm])' (different name format)."))
                }
            }
        }
    }

    # Detect aliases referencing another note's title
    foreach ($n in $noteData) {
        foreach ($alias in $n.Aliases) {
            $aliasNorm = $alias.ToLowerInvariant().Trim()
            foreach ($other in $noteData) {
                if ($other.File -eq $n.File) { continue }
                if ($other.Title.ToLowerInvariant().Trim() -eq $aliasNorm) {
                    $issues.Add((New-Issue Warning $n.File "Alias '$alias' matches title of another note at $($other.File). Consider merging or updating the alias."))
                }
            }
        }
    }

    $issues
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
    foreach ($status in @('to-read', 'browsed', 'close-read')) {
        $lines.Add("| $status | $(@($Records | Where-Object Status -eq $status).Count) |")
    }
    $lines.Add('')
    $lines.Add('## Papers by Direction')
    $lines.Add('')
    foreach ($group in @($Records | Group-Object { $_.Direction } | Sort-Object Name)) {
        $lines.Add("### $($group.Name)")
        $lines.Add('')
        $lines.Add('| Paper | Venue | Status |')
        $lines.Add('| --- | --- | --- |')
        foreach ($record in @($group.Group | Sort-Object Title, File)) {
            $link = '[[' + ($record.File -replace '\\', '/' -replace '\.md$', '') + '|' + (Convert-MarkdownCell $record.Title) + ']]'
            $lines.Add("| $link | $(Convert-MarkdownCell $record.Venue) | $($record.Status) |")
        }
        $lines.Add('')
    }
    $lines.Add('## Research Asset Counts')
    $lines.Add('')
    $lines.Add('| Asset type | Notes |')
    $lines.Add('| --- | ---: |')
    foreach ($folder in @('concepts', 'authors', 'datasets', 'comparisons', 'syntheses', 'projects')) {
        $path = Join-Path $VaultRoot (Join-Path 'library' $folder)
        $count = if (Test-Path -LiteralPath $path) { @(Get-ChildItem -LiteralPath $path -File -Filter '*.md' | Where-Object Name -ne 'README.md').Count } else { 0 }
        $lines.Add("| $folder | $count |")
    }
    # Count benchmarks within datasets/ (merged directory)
    $datasetsPath = Join-Path $VaultRoot 'library/datasets'
    $benchCount = 0
    if (Test-Path -LiteralPath $datasetsPath) {
        foreach ($df in (Get-ChildItem -LiteralPath $datasetsPath -File -Filter '*.md')) {
            $dm = Get-Frontmatter $df.FullName
            if ($dm -and $dm.ContainsKey('type') -and [string]$dm['type'] -eq 'benchmark') { $benchCount++ }
        }
    }
    if ($benchCount -gt 0) { $lines.Add("| benchmarks (in datasets/) | $benchCount |") }
    $lines.Add('')
    # Potential duplicates section
    $dupWarnings = @($Issues | Where-Object { $_.Level -eq 'Warning' -and $_.Message -match 'duplicate' })
    $lines.Add('## Potential Duplicates')
    $lines.Add('')
    if ($dupWarnings.Count -gt 0) {
        $lines.Add('| File | Issue |')
        $lines.Add('| --- | --- |')
        foreach ($dw in $dupWarnings) {
            $lines.Add("| $($dw.File) | $($dw.Message) |")
        }
    } else {
        $lines.Add('_No potential duplicates detected._')
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
