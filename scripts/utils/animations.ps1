
$errorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true

$Global:__waitingAnimationJob__ = $null

function RunCommandInBackgrounWithWaitAnimation() {
    param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock] $ScriptBlock,
        [Parameter(Mandatory=$false)]
        [object[]] $args
    )

    #$anim = @("|","/","-","`\","|")
    $animaFrames = @(
        "🕐","🕑","🕒","🕓","🕔","🕕","🕖","🕗","🕘","🕙","🕚","🕛"
    )

    Write-Host ""
    Write-Host ""

    $CursorTop= [Console]::CursorTop

    $Global:__waitingAnimationJob__ =
        Start-Job -ScriptBlock $ScriptBlock -ArgumentList $args

    while ($Global:__waitingAnimationJob__.State -eq "Running") {
        foreach ($item in $animaFrames) { 
            [Console]::SetCursorPosition(0 + 5, $CursorTop)
            Write-Host "$item :: RUNNING PLEASE WAIT :: $item" -ForegroundColor Yellow
            Start-Sleep -Milliseconds 100
        }
    }

    Write-Host ""
    Write-Host ""

    # get the output
    $_output = Receive-Job -Job $Global:__waitingAnimationJob__
    Remove-Job -Job $Global:__waitingAnimationJob__

    return $_output
}
