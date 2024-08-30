
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

    [Console]::SetCursorPosition(0 + 5, $CursorTop)
    Write-Host "✅ ::    TASK COMPLETED    :: ✅" -ForegroundColor Green

    Write-Host ""
    Write-Host ""

    # get the output
    $_output = Receive-Job -Job $Global:__waitingAnimationJob__
    Remove-Job -Job $Global:__waitingAnimationJob__

    return $_output
}

function RunCommandInBackgroundWithWaitAnimationAsync() {
    param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock] $ScriptBlock,
        [Parameter(Mandatory=$false)]
        [object[]] $args
    )

    $animaFrames = @(
        "🕐","🕑","🕒","🕓","🕔","🕕","🕖","🕗","🕘","🕙","🕚","🕛"
    )

    Write-Host ""
    Write-Host ""

    $CursorTop = [Console]::CursorTop
    $NextLine = [Console]::GetCursorPosition()
    $NextLine = [Tuple]::Create($NextLine.Item1, $NextLine.Item2 + 1)

    $Global:__waitingAnimationJob__ =
        Start-Job -ScriptBlock $ScriptBlock -ArgumentList $args

    while ($Global:__waitingAnimationJob__.State -eq "Running") {
        foreach ($item in $animaFrames) {
            [Console]::SetCursorPosition(0 + 5, $CursorTop)
            Write-Host "$item :: RUNNING PLEASE WAIT :: $item" -ForegroundColor Yellow
            Start-Sleep -Milliseconds 100
        }

        # check if there already data to be presented
        if ($Global:__waitingAnimationJob__.HasMoreData) {
            $data = Receive-Job -Job $Global:__waitingAnimationJob__ -Keep

            # position the cursor to the next line
            [Console]::SetCursorPosition(
                5,
                $CursorTop + 2
            )

            if ($null -ne $data) {
                $data.Split("`n") | ForEach-Object {
                    Write-Host $_
                }
            }
        }
    }

    [Console]::SetCursorPosition(0 + 5, $CursorTop)
    Write-Host "✅ ::    TASK COMPLETED    :: ✅" -ForegroundColor Green
    # position the cursor to the next line
    [Console]::SetCursorPosition($NextLine.Item1, $NextLine.Item2)

    # last check if there is any data to be presented
    if ($Global:__waitingAnimationJob__.HasMoreData) {
        $data = Receive-Job -Job $Global:__waitingAnimationJob__

        # position the cursor to the next line
        [Console]::SetCursorPosition(
            5,
            $CursorTop + 2
        )

        if ($null -ne $data) {
            $data.Split("`n") | ForEach-Object {
                Write-Host $_
            }
        }
    }

    Remove-Job -Job $Global:__waitingAnimationJob__
}
