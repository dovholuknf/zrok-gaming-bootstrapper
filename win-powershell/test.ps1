param (
    [string]$PathTozrok = "c:\path\to\zrok.exe",
    [string]$TargetHost = "localhost",
    [string]$TargetPort = "25565",
    [string]$GameName   = "Generic_TCP_Server"
)

$zrokexe = $PathTozrok
if(!$zrokexe) {
    $zrokexe=$env:PATH_TO_ZROK
    if($zrokexe) {
        Write-Host "PATH_TO_ZROK found in environment. Using $zrokexe"
    } else {
        Write-Host "no"
    }
}

function Check-ProgramInPath {
    param (
        [string]$program
    )

    # Check if the program exists in any directory in the PATH
    $paths = $env:PATH -split ';'
    foreach ($path in $paths) {
        if($path) {
            if (Test-Path (Join-Path $path $program)) {
                Write-Host "$program is found in the PATH at: $path."
                return $true
            }
        }
    }
    return $false
}
$endsInExe = ($zrokexe.ToLower().EndsWith("zrok.exe"))

if (($endsInExe -and (Check-ProgramInPath -program $zrokexe))) {
    "good $zrokexe"
} elseif ($zrokexe) {
    if (($endsInExe) -and (Test-Path $zrokexe)) {
        # $zrokexe directly set
    } else {
        Write-Host "The path to zrok is set but does not exist or does not end with zrok.exe" -ForegroundColor Yellow
        Write-Host "    $zrokexe" -ForegroundColor Yellow
        $show = $true
        do {
            if (Test-Path $zrokexe -PathType Leaf) {
                break
            } else {
                Write-Host -ForegroundColor Red "==== zrok.exe not on path and PathTozrok param was not set or was incorrect! ===="
                if($show)
                {
                    Write-Host -ForegroundColor Red "     to avoid seeing this message in the future: "
                    Write-Host -ForegroundColor Red "     - pass the correct value to the PathTozrok param"
                    Write-Host -ForegroundColor Red "     - set the PATH_TO_ZROK environment variable"
                    Write-Host -ForegroundColor Red "     - hardcode it in this script"
                    Write-Host ""
                    $show = $false
                }

                $zrokexeInput = Read-Host "Enter the correct path"
                if ($zrokexeInput) {
                    $zrokexe = $zrokexeInput
                }
            }
        } while ($true)
    }
} else {
    Write-Host "ERROR: $zrokexe does not seem to point to zrok.exe." -ForegroundColor Red
}

Write-Host "Using zrok.exe at: " -NoNewline
Write-Host "$zrokexe" -ForegroundColor Green

