# Survey generated/verified field state across vault
$Root = "E:\WorkSpace\Scientist\readr"

function HasField($path, $field) {
    $content = Get-Content -LiteralPath $path -Raw
    return ($content -match "(?m)^\s*$field\s*:")
}

Write-Host "=== Entries with generated/verified ==="
$entries = Get-ChildItem -LiteralPath (Join-Path $Root 'library/entries') -Recurse -File -Filter '*.md'
foreach ($f in $entries) {
    if (HasField $f.FullName 'generated' -or HasField $f.FullName 'verified') {
        Write-Host "  $($f.Name) :: $(if (HasField $f.FullName 'generated') {'gen'} else {'-'})/$(if (HasField $f.FullName 'verified') {'ver'} else {'-'})"
    }
}

Write-Host "=== Annotations with generated/verified ==="
$ann = Get-ChildItem -LiteralPath (Join-Path $Root 'annotations') -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue
foreach ($f in $ann) {
    if (HasField $f.FullName 'generated' -or HasField $f.FullName 'verified') {
        Write-Host "  $($f.Name) :: $(if (HasField $f.FullName 'generated') {'gen'} else {'-'})/$(if (HasField $f.FullName 'verified') {'ver'} else {'-'})"
    }
}

Write-Host "=== Knowledge notes WITHOUT generated ==="
foreach ($dir in @('concepts','authors','datasets','comparisons','syntheses','projects')) {
    $d = Join-Path $Root (Join-Path 'library' $dir)
    if (-not (Test-Path $d)) { continue }
    $files = Get-ChildItem -LiteralPath $d -File -Filter '*.md' | Where-Object { $_.Name -ne 'README.md' }
    foreach ($f in $files) {
        if (-not (HasField $f.FullName 'generated')) {
            Write-Host "  MISSING gen: $dir/$($f.Name)"
        }
    }
}
