# C++ Console Template Specific Documentation

All projects follow the pipeline of tasks described in the [common contributing documentation](https://github.com/toradex/vscode-torizon-templates/blob/bookworm/CONTRIBUTING.md#contributing-templates). However, each project has its own specificities in terms of technologies and methods used to compile, deploy, and debug the code. Therefore, each of them has their own specific tasks in the `tasks.json` file.

This C++ console template uses Makefile to compile the code, with tasks named `build-makedir-\${architecture}` (creates the destination directory for the future compiled code) and `build-debug-\${architecture}` (compiles the code). It also uses an SDK container to cross-compile the code. This container image is built using the `Dockerfile.sdk` file, and the tasks that build the containers are named `build-container-image-sdk-\${architecture}`.

The compiled code is then copied into the container, in the `torizon_app_root` (which is automatically passed to the `APP_ROOT` variable in the `Dockerfiles`) directory defined at `settings.json`, through the Docker `COPY` command.

The task that has the entire pipeline of executed tasks, from the first step to the last step before the debugging, is the `deploy-torizon-\${architecture}` task.

Finally, remote debugging is performed by attaching to the GDB on the running container on the device using a [VSCode feature called Pipe Transport](https://code.visualstudio.com/docs/cpp/pipe-transport). For local debugging, the [VSCode method for C/C++ Debugging](https://code.visualstudio.com/docs/cpp/launch-json-reference) is used. The tasks that perform the debugging are those present in the `launch.json` file.

The source code of the template is a simple Hello World (Hello Torizon, actually) in C++, using Makefile as build system.

## Makefile Tools (Extension) Pop-up Message

If the project is stuck when trying to debug it, check if the pop-up message below is shown on the bottom-right corner of VSCode. If it doesn't, press `F1` and type `Developer: Reload Window`, and then it will be shown. If it does, click on the `Yes (don't show again)` option.

  ![](https://raw.githubusercontent.com/toradex/vscode-torizon-templates-documentation/bookworm/cppConsole/dryRunPopUp.png)


## Adding And Debugging Extra Files

### Adding Extra Files

If you want to add extra files (like a shared library binary for example) that are not included automatically in the compiled final directory, you can add it also with the `COPY` command in the `Dockerfile.debug` (also valid for `Dockerfile`). 
For example, to add custom shared libraries binaries that are in your workspace in the `mylib` directory to the `APP_ROOT/lib` directory inside the container add this command to the `Dockerfile.debug`: 
```
...
COPY mylib ${APP_ROOT}/lib
...
```

To avoid needing to copy again this `mylib` every time the something on rest of the application source code changes, add the line above on the `Dockerfiles` before the copy of the rest of the application source code (which is something like `COPY build-${IMAGE_ARCH}/bin ${APP_ROOT}`).


### Debugging Extra Files

Then, you can debug this extra files code together with your project's code by adding them to the `sourceFileMap` variable of the debug task in the `launch.json`. For example, for the shared libraries binaries added in the previous task, your `Torizon ARMv8` task will look like this:
```
...
"sourceFileMap": {
    "${config:torizon_app_root}": "${workspaceFolder}",
    "${config:torizon_app_root}/lib": "${workspaceFolder}/mylib"
},
...
```


### Adding Extra Files Shared Between Projects

If for example you have a custom library that is shared between more than one project, this library will be in some directory outside of the project's workspace that will be accessed by this many projects.

For example, you may have two projects at `/home/projects/myproject1` and `/home/projects/myproject2` , and a custom library used in both projects at `/home/libraries/mylib`: 

```
home
├── libraries
│   └── mylib
└── projects
    ├── myproject1
    └── myproject2
```

To access this library (or compile it's source code if necessary) and debug the library's source code together with your project's code, you need to add an extra task at the `tasks.json` to synchronize this library's folder with a folder inside de project's workspace. 

Using `rsync` and synchronizing the `/home/libraries/mylib` folder with a `mylib` folder inside project1 workspace (`/home/projects/myproject1/libraries/mylib` path), the task called `rsync-mylib` will like this for example:
```
        ...
        {
            "label": "rsync-lib",
            "detail": "",
            "hide": true,
            "command": "rsync",
            "type": "process",
            "args": [
                "-av",
                "/home/libraries/mylib",
                "./libraries"
            ],
            "dependsOrder": "sequence",
            "problemMatcher": "$msCompile",
            "icon": {
                "id": "layers",
                "color": "terminal.ansiCyan"
            }
        },
        ...
```

And then, to perform this `rsync` everytime you run the debug pipeline, add this to the pipeline of tasks (`dependsOn` parameter) of the `deploy-torizon-\${architecture}` task, like this for the arm64 for example:
```
        ...
            "dependsOn": [
                "validate-settings",
                "validate-arch-arm64",
                "copy-docker-compose",
                "pre-cleanup",
                "rsync-mylib",
                "build-debug-arm64",
                "build-container-torizon-debug-arm64",
                "push-container-torizon-debug-arm64",
                "pull-container-torizon-debug-arm64",
                "run-container-torizon-debug-arm64"
            ],
        ...
```

For local debugging, check the local debugging task on `launch.json` (in this case named `Local AMD64`) and get the name of task the defined in the `preLaunchTask` parameter:
```
        {
            "name": "Local AMD64",
            ...
            "preLaunchTask": "build-debug-amd64-local"
        },
```

Then, find this `build-debug-amd64-local` task on `tasks.json` and add the `rsync-mylib` task to the `dependsOn` parameter of this task.