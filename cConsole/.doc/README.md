# C Console Template Specific Documentation

All projects follow the pipeline of tasks described in the [common contributing documentation](https://github.com/toradex/vscode-torizon-templates/blob/bookworm/CONTRIBUTING.md#contributing-templates). However, each project has its own specificities in terms of technologies and methods used to compile, deploy, and debug the code. Therefore, each of them has their own specific tasks in the **tasks.json** file.

This C console template uses Makefile to compile the code, with tasks named **build-makedir-\${architecture}** (creates the destination directory for the future compiled code) and **build-debug-\${architecture}** (compiles the code). It also uses an SDK container to cross-compile the code. This container image is built using the **Dockerfile.sdk** file, and the tasks that build the containers are named **build-container-image-sdk-\${architecture}**.

The compiled code is then copied into the running debug container using **scp**, in the task named **deploy-torizon-\${architecture}**. This task contains the entire sequence of tasks executed by the pipeline and, therefore, is unique to each template.

Finally, remote debugging is performed by attaching to the GDB on the running container on the device using a [VSCode feature called Pipe Transport](https://code.visualstudio.com/docs/cpp/pipe-transport). For local debugging, the [VSCode method for C/C++ Debugging](https://code.visualstudio.com/docs/cpp/launch-json-reference) is used. The tasks that perform the debugging are those present in the **launch.json** file.

The source code of the template is a simple Hello World (Hello Torizon, actually) in C, using Makefile as build system.