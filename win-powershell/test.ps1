$zrokexe = "zrok.exe"
$env:PATH_TO_ZROK="c:\path\to\zrok.exe"

function Check-ProgramInPath {
    param (
        [string]$zrokexe
    )

    # Check if the program exists in any directory in the PATH
    $paths = $env:PATH -split ';'
    foreach ($path in $paths) {
        if($path) {
            if (Test-Path (Join-Path $path $zrokexe)) {
                Write-Host "$zrokexe is found in the PATH at: $path."
                return $true
            }
        }
    }
    return $false
}

if (Check-ProgramInPath -program $zrokexe) {
    # good
} elseif ($env:PATH_TO_ZROK) {
    if (Test-Path $env:PATH_TO_ZROK) {
        Write-Host "$zrokexe is found at the location specified by PATH_TO_ZROK."
    } else {
        Write-Host "The environment variable PATH_TO_ZROK is set, but the file does not exist at $env:PATH_TO_ZROK." -ForegroundColor Red
        do {
            if (Test-Path $env:PATH_TO_ZROK -PathType Leaf) {
                break
            } else {
                Write-Host -ForegroundColor Red "==== zrok.exe not on path and PATH_TO_ZROK incorrect! ===="
                Write-Host -ForegroundColor Red "(set environment var or update PATH_TO_ZROK in this script to avoid seeing this message)"
                
                $env:PATH_TO_ZROK = Read-Host "Enter the correct path"
            }
        } while ($true)
    }
} else {
    Write-Host "ERROR: $zrokexe is not found in the PATH and the environment variable $envVar is not set." -ForegroundColor Red
}

Write-Host "Using zrok.exe at: " -NoNewline
Write-Host "$path" -ForegroundColor Green