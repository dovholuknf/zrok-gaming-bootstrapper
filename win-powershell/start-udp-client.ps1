$PATH_TO_ZROK="C:\minecraft\zrok.exe"
CheckNetIsolation.exe LoopbackExempt -a -p=S-1-15-2-1958404141-86561845-1752920682-3514627264-368642714-62675701-733520436

do {
    if (Test-Path $PATH_TO_ZROK -PathType Leaf) {
        break
    } else {
        Write-Host -ForegroundColor Red "==== PATH_TO_ZROK incorrect! ===="
        Write-Host -ForegroundColor Red "(update PATH_TO_ZROK in this script to avoid seeing this message)"
        
        $PATH_TO_ZROK = Read-Host "Enter the correct path"
    }
} while ($true)

$PRIVATE_ACCESS_TOKEN = Read-Host "Enter the private access token"

Start-Process -FilePath "$PATH_TO_ZROK" `
    -ArgumentList "access private $PRIVATE_ACCESS_TOKEN --bind 127.0.0.1:19132" `
    -PassThru