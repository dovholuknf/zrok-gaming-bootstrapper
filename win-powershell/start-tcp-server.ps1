param (
    [string]$PathTozrok = "c:\path\to\zrok.exe",
    [string]$TargetHost = "localhost",
    [string]$TargetPort = "25565",
    [string]$GameName   = "GenericTCPServer",
    [switch]$RecreateShare
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
















if (Test-Path "$env:USERPROFILE\.zrok\environment.json" -PathType Leaf) {
} else {
    Write-Host -ForegroundColor Red "zrok not enabled! enable zrok before continuing!"
    return
}

# Convert JSON content to a PowerShell object
$jsonObject = Get-Content -Path "$env:USERPROFILE\.zrok\environment.json" -Raw | ConvertFrom-Json

# get the name of your identity
$zid = $jsonObject.ziti_identity

# Strip anything not alphanumeric
$ReservedShareName=(($GameName -replace '[^a-zA-Z0-9]', '')).ToLower()
$RESERVED_SHARE = (($zid -replace '[^a-zA-Z0-9]', '') + "$ReservedShareName").ToLower()

# Convert JSON to PowerShell object
$jsonObject = Invoke-Expression "$zrokexe overview" | ConvertFrom-Json
$targetEnvironment = $jsonObject.environments | Where-Object { $_.environment.zId -eq $zid }

if ($targetEnvironment) {
    $shares = $targetEnvironment.shares | Where-Object { $_.token -eq $RESERVED_SHARE }
    if ($shares) {
        if (!$RecreateShare) {
            Write-Host "Found share with token $RESERVED_SHARE in environment $zid. No need to reserve..."
        } else {
            Write-Host -ForegroundColor Yellow "Found share with token $RESERVED_SHARE in environment $zid. Releasing share..."
            & "$zrokexe" release $RESERVED_SHARE
        }
    } else {
        Write-Host "Reserving share: $RESERVED_SHARE"
        Invoke-Expression "$zrokexe reserve private ${TargetHost}:${TargetPort} --backend-mode tcpTunnel --unique-name $RESERVED_SHARE"
    }
} else {
	Write-Host "UNEXPECTED. Trying to reserve share: $RESERVED_SHARE"
  Invoke-Expression "$zrokexe reserve private ${TargetHost}:${TargetPort} --backend-mode tcpTunnel --unique-name $RESERVED_SHARE"
}

Write-Host "Verifying server is listening at: ${TargetHost}:${TargetPort}"
$OriginalProgressPreference = $Global:ProgressPreference
$Global:ProgressPreference = 'SilentlyContinue'
while (-not (Test-NetConnection -ComputerName $TargetHost -Port $TargetPort -InformationLevel Quiet -WarningAction SilentlyContinue)) {
    Write-Host -ForegroundColor Yellow "  ${TargetHost}:${TargetPort} not responding. Make sure the server is on and the host/port are correct."
    Start-Sleep -Seconds 5
}
$Global:ProgressPreference = $OriginalProgressPreference

Write-Host "Port $TargetPort is now open. Starting zrok share"

Start-Process -FilePath "$zrokexe" `
    -ArgumentList "share reserved $RESERVED_SHARE" `
    -PassThru

Write-Host ""
Write-Host ""
Write-Host "To stop, click in the zrok window, press 'ctrl-c', and wait for the window to disappear"
Write-Host ""
Write-Host ""