
function ShowStackTrace($pipeLine) {
    Write-Host $pipeLine.Exception.Message -Foreground "Red"
    Write-Host ""
    $lines = $pipeLine.ScriptStackTrace.Split("`n")

    foreach ($line in $lines) {
        Write-Host "`t$line" -Foreground "DarkGray"
    }

    Write-Host ""
}
