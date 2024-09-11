# TorizonCore Builder Template Specific Documentation

This is a special type of template which is meant to ease the use of the [TorizonCore Builder tool](https://developer.toradex.com/torizon/os-customization/torizoncore-builder-tool-customizing-torizoncore-images), with the help of the [TorizonCore Builder Extension](https://marketplace.visualstudio.com/items?itemName=Toradex.tcb-vscode).

You can also find other useful information about this template and how to use it on the [TorizonCore Builder VSCode Integration Toradex's developer page](https://developer.toradex.com/torizon/os-customization/torizoncore-builder-vs-code-integration).

> ⚠️ **WARNING:**  At the moment the [TorizonCore Builder Extension](https://marketplace.visualstudio.com/items?itemName=Toradex.tcb-vscode), and therefore this template, are experimental, so it is not guaranteed that everything will work fine ⚠️

Although different than the other templates, this templates shares some similarities with the other templates in some tasks, some scripts and the workspace structure of some files. Therefore, it is highly recommended that you go through the [Torizon IDE Extension documentation](https://developer.toradex.com/torizon/application-development/ide-extension/) before starting to use this template.

On this template the TCB commands are intended to be used through the [TASK RUNNER tab](https://developer.toradex.com/torizon/application-development/ide-extension/reference-documentation/workspace-tasks#execute-a-task). To check details about about each task, go to the `.vscode/tasks.json` file and find the name of the task, like this `tcb-deploy` task for example:
```
        {
            "label": "tcb-deploy",
            "detail": "Run the torizoncore-builder deploy command to the default target device",
            "command": "DOCKER_HOST=",
            "type": "shell",
            "options": {
                "cwd": "${workspaceFolder}",
                "env": {
                    "VSCODE_CMD": "--verbose deploy --remote-host ${config:torizon_ip} --remote-username ${config:torizon_login} --remote-password '${config:torizon_psswd}' --reboot"
                }
            },
            "args": [
                "source",
                "./.conf/tcb-env-setup.sh",
                "-s",
                "${workspaceFolder}/storage",
                "-t",
                "${config:tcb.version}"
            ],
            "problemMatcher": [
                "$tsc"
            ],
            "dependsOrder": "sequence",
            "dependsOn": [
                "tcb-unpack"
            ],
            "icon": {
                "id": "export",
                "color": "terminal.ansiYellow"
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": true,
                "panel": "shared",
                "group": "tcb-deploy"
            }
        },
```

The TCB command being executed is at the `VSCODE_CMD` parameter. The `${config:...}` parameters are values defined at `.vscode/settings.json`. Also, if you see values with `${input:...}` those are defined in the `input` section of `tasks.json`. And values with `${command:...}` are commands that are being executed by an extension, generally by the **TorizonCore Builder or the Torizon IDE extensions** (those with `${command:tcb...}` are for sure being executed by the **TorizonCore Builder extension**).

Also, for more details on the VSCode tasks structure, check the [VSCode tasks documentation](https://code.visualstudio.com/docs/editor/tasks).

> ⚠️ **WARNING:**  If you intend also to run `torizoncore-builder` commands on the terminal, make sure to [Remove Default any device](https://developer.toradex.com/torizon/application-development/ide-extension/connect-a-torizoncore-target-device#set-a-torizon-os-device-as-default) before and open a new terminal or reload the VSCode workspace. Another option is to include `DOCKER_HOST=` before each command that you run on the terminal  ⚠️
