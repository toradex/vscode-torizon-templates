
$tasksFileContent = Get-Content $PSScriptRoot/tasks.json
$settingsFileContent = Get-Content $PSScriptRoot/settings.json
$json = $tasksFileContent | ConvertFrom-Json
$settings = $settingsFileContent | ConvertFrom-Json
$inputs = $json.inputs
$inputValues = @{}
$cliInputs = [System.Collections.ArrayList]@()
$runDeps = $true;

function settingsToGlobal () {
    foreach ($set in $settings | Get-Member -MemberType Properties) {
        if (-not (Test-Path "variable:Global:$($set.Name)")) {
            New-Variable `
                -Scope Global `
                -Name "config:$($set.Name)" -Value $settings.($set.Name)
        } else {
            Set-Variable `
                -Scope Global `
                -Name "config:$($set.Name)" -Value $settings.($set.Name)
        }
    }
}

function write-error () {
    Write-Host -ForegroundColor Red `
        $args[0]
    exit $args[1]
}

function getTasksLabels () {
    $labels = [System.Collections.ArrayList]@()

    for ($i = 0; $i -le $json.tasks.length; $i++) {
        [void]$labels.Add($json.tasks[$i].label)
    }

    return $labels
}

function listTasksLabel () {
    for ($i = 0; $i -le $json.tasks.length; $i++) {
        if ($null -ne $json.tasks[$i].label) {
            Write-Host -NoNewline "$($i + 1).`t"
            Write-Host $json.tasks[$i].label
        }
    }
}

function checkInput () {
    $ret = [System.Collections.ArrayList]@()

    foreach ($arg in $args[0]) {
        if (-not $arg.Contains("`${input:")) {
            [void]$ret.Add($arg)
        } else {
            $maches = ($arg |
                            Select-String `
                                -Pattern "(?<=\`${input:).*?(?=\s*})" `
                                -AllMatches
                        ).Matches

            foreach ($matchValue in $maches) {
                $inputObj = $null

                foreach ($inp in $inputs) {
                    if ($inp.id -eq $matchValue.Value) {
                        $inputObj = $inp
                    }
                }

                $fromUser = $null
                if ($inputValues.ContainsKey($matchValue.Value)) {
                    $fromUser = $inputValues[$matchValue.Value]
                } else {
                    $desc = $inputObj.description
                    $default = $inputObj.default

                    if ($cliInputs.Count -gt 0) {
                        $fromUser = $cliInputs[0]
                        $cliInputs.RemoveAt(0)
                    }

                    # cli input is nothing
                    if ($null -eq $fromUser) {
                        if ($inputObj.password -eq $true) {
                            $fromUser = Read-Host `
                                        -AsSecureString `
                                        -Prompt "$desc [***]"

                            # TODO: so much security wow
                            $fromUser = ConvertFrom-SecureString `
                                -SecureString $fromUser `
                                -AsPlainText
                        } else {
                            $fromUser = Read-Host `
                                        -Prompt "$desc [$default]"
                        }
                    }

                    if ($fromUser -eq [String]::Empty) {
                        $fromUser = $default
                    }

                    $inputValues.Add($matchValue.Value, $fromUser)
                }

                $matchValue = $matchValue.Value
                $arg = $arg.Replace("`${input:${matchValue}}", $fromUser)
            }

            [void]$ret.Add($arg)
        }
    }

    return $ret
}

function checkConfig ([System.Collections.ArrayList] $list) {
    $ret = [System.Collections.ArrayList]@()

    foreach ($item in $list) {
        # TODO: Add variable expand recursive
        if ($item.Contains("config:")) {
            $item = $item.Replace("config:", "global:config:")

            $value = Invoke-Expression "echo $item"

            if ($value.Contains("`${workspaceFolder")) {
                $item = $value
            }
        }

        [void]$ret.Add($item)
    }

    return $ret
}

function taskArgumentExecute ($label, [ScriptBlock]$fnExec, $message) {
    if ($null -eq $label -or $label -eq [String]::Empty) {
        write-error $message 10
    } else {
        $taskLabel = $label

        if ($taskLabel -match "^\d+$") {
            Invoke-Command -ScriptBlock $fnExec `
                -ArgumentList $json.tasks[[int]::Parse($taskLabel) -1].label
        } elseif ((getTasksLabels).Contains($taskLabel)) {
            Invoke-Command -ScriptBlock $fnExec `
                -ArgumentList $taskLabel
        } else {
            write-error "Undefined task <$taskLabel>" 10
        }
    }
}

function descTask () {
    for ($i = 0; $i -le $json.tasks.length; $i++) {
        if ($json.tasks[$i].label -eq $args[0]) {
            $task = $json.tasks[$i]
            $task | ConvertTo-Json
        }
    }
}

function runTask () {
    for ($i = 0; $i -le $json.tasks.length; $i++) {
        if ($json.tasks[$i].label -eq $args[0]) {
            $task = $json.tasks[$i]
            $taskCmd = $task.command
            $taskArgs = checkInput($task.args)
            $taskArgs = checkConfig($taskArgs)
            $taskDepends = $task.dependsOn
            $taskEnv = $task.options.env

            # inject env
            if ($null -ne $taskEnv) {
                $envs = $taskEnv
                    | get-member -MemberType NoteProperty
                    | Select-Object -ExpandProperty Name

                foreach ($env in $envs) {
                    $value = $task.options.env
                                | Select-Object -ExpandProperty $env

                    Write-Host -ForegroundColor Yellow `
                        "Env: $env=$value"

                    $expValue = checkConfig(checkInput($value)).ToString()

                    [System.Environment]::SetEnvironmentVariable(
                        $env, $expValue
                    )
                }
            }

            # run dependencies
            if ($runDeps -eq $true) {
                for ($j = 0; $j -lt $taskDepends.Count; $j++) {
                    runTask $taskDepends[$j]
                }
            }

            Write-Host -ForegroundColor Green `
                "> Executing task: $($json.tasks[$i].label) <"
            Invoke-Expression "$taskCmd $taskArgs"

            # abort we had a error
            if ($LASTEXITCODE -ne 0) {
                Write-Host -ForegroundColor Red `
                    "> TASK $($json.tasks[$i].label) exited with error code <"
                exit 69
            }
        }
    }
}

function getCliInputs () {
    $argsS = $args[0]
    # args[0] command / args[1] task name
    for ($i = 2; $i -lt $argsS.Length; $i++) {
        # inputs
        [void]$cliInputs.Add($argsS[$i])
    }
}

# main()
# set the relative workspaceFolder (following the pattern that VS Code expects)
$Global:workspaceFolder = Join-Path $PSScriptRoot ../
settingsToGlobal

switch ($args[0]) {
    "list" {
        listTasksLabel
    }
    "desc" {
        taskArgumentExecute `
            $args[1] ${function:descTask} "Argument expected desc <task_label>"
    }
    "run" {
        getCliInputs $args
        taskArgumentExecute `
            $args[1] ${function:runTask} "Argument expected run <task_label>"
    }
    "run-nodeps" {
        $runDeps = $false;
        getCliInputs $args
        taskArgumentExecute `
            $args[1] ${function:runTask} "Argument expected run <task_label>"
    }
    Default {
        Write-Host "usage:"
        Write-Host "    list                    : list the tasks.json labels defined"
        Write-Host "    desc <task_label>       : describe the task <task_label>"
        Write-Host "    desc <task_index>       : describe the task <task_index>"
        Write-Host "    run <task_label>        : run the task <task_label>"
        Write-Host "    run <task_index>        : run the task <task_index>"
        Write-Host "    run-nodeps <task_label> : run the tasks without dependencies <task_label>"
    }
}
