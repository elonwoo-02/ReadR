$scriptPath = Join-Path $PSScriptRoot '..\scripts\ReadR.ps1'

function New-EntryFixture {
    param(
        [string]$Root,
        [string]$Name = 'Valid (Test 2026)',
        [string]$Status = 'status/to-read',
        [string]$Extra = ''
    )
    $entryDir = Join-Path $Root 'library/entries/example'
    $sourceDir = Join-Path $Root 'sources/papers'
    New-Item -ItemType Directory -Force -Path $entryDir, $sourceDir | Out-Null
    Set-Content -LiteralPath (Join-Path $sourceDir 'valid.pdf') -Value 'fixture'
    $content = @(
        '---',
        ('title: "' + $Name + '"'),
        'authors:',
        '  - Test, Author',
        'venue: "TestConf 2026"',
        'tags:',
        '  - direction/example',
        ('  - ' + $Status),
        'pdf: ../../../sources/papers/valid.pdf',
        'doi: 10.0000/test',
        'rating: ⭐⭐⭐',
        'annotation:',
        'concepts: []',
        'authors_related: []',
        'datasets: []',
        'benchmarks: []',
        '---',
        '',
        ('# ' + $Name),
        $Extra
    )
    Set-Content -LiteralPath (Join-Path $entryDir ($Name + '.md')) -Value $content
}

function Invoke-ReadRValidation {
    param([string]$Root, [switch]$UpdateIndex)
    $arguments = @('-NoProfile', '-File', $scriptPath, '-Validate', '-Root', $Root)
    if ($UpdateIndex) { $arguments += '-UpdateIndex' }
    $output = & pwsh @arguments 2>&1 | Out-String
    [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
}

Describe 'ReadR validator' {
    BeforeEach {
        $vault = Join-Path $TestDrive 'vault'
        New-Item -ItemType Directory -Force -Path $vault | Out-Null
    }

    It 'accepts a valid entry' {
        New-EntryFixture -Root $vault
        (Invoke-ReadRValidation -Root $vault).ExitCode | Should Be 0
    }

    It 'reports a missing required field' {
        New-EntryFixture -Root $vault
        $path = Join-Path $vault 'library/entries/example/Valid (Test 2026).md'
        (Get-Content -LiteralPath $path) -replace 'venue: "TestConf 2026"', 'venue: ""' | Set-Content -LiteralPath $path
        (Invoke-ReadRValidation -Root $vault).ExitCode | Should Be 1
    }

    It 'reports invalid and duplicate status tags' {
        New-EntryFixture -Root $vault -Status 'status/unknown'
        (Invoke-ReadRValidation -Root $vault).ExitCode | Should Be 1

        New-EntryFixture -Root $vault -Name 'Duplicate (Test 2026)'
        $path = Join-Path $vault 'library/entries/example/Duplicate (Test 2026).md'
        (Get-Content -LiteralPath $path) -replace '  - status/to-read', @('  - status/to-read', '  - status/browsed') | Set-Content -LiteralPath $path
        (Invoke-ReadRValidation -Root $vault).ExitCode | Should Be 1
    }

    It 'reports a missing PDF and a broken wiki link' {
        New-EntryFixture -Root $vault -Extra '[[Missing Note]]'
        Remove-Item -LiteralPath (Join-Path $vault 'sources/papers/valid.pdf')
        $result = Invoke-ReadRValidation -Root $vault
        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'PDF file does not exist'
        $result.Output | Should Match 'Broken wiki link'
    }

    It 'requires an annotation for close-read entries' {
        New-EntryFixture -Root $vault -Status 'status/close-read'
        $result = Invoke-ReadRValidation -Root $vault
        $result.ExitCode | Should Be 1
        $result.Output | Should Match 'requires an annotation'
    }

    It 'writes a stable generated index after valid validation' {
        New-EntryFixture -Root $vault -Name 'Zeta (Test 2026)'
        New-EntryFixture -Root $vault -Name 'Alpha (Test 2026)'
        (Invoke-ReadRValidation -Root $vault -UpdateIndex).ExitCode | Should Be 0
        $indexPath = Join-Path $vault 'library/_generated-index.md'
        $before = Get-Content -LiteralPath $indexPath -Raw
        (Invoke-ReadRValidation -Root $vault -UpdateIndex).ExitCode | Should Be 0
        (Get-Content -LiteralPath $indexPath -Raw) | Should Be $before
        $before.IndexOf('Alpha (Test 2026)') | Should BeLessThan $before.IndexOf('Zeta (Test 2026)')
    }
}


