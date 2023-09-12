# How To Contribute

There are lots of ways to contribute to the Torizon IDE Extension (formerly codenamed ApolloX) project templates, and we appreciate the help from the community. You can provide feedback, report bugs, give suggestions, contribute templates, and participate in the platform discussions.

## Providing Feedback

You can use the [issues section](https://github.com/toradex/vscode-torizon-templates/issues) from this Github repository to provide feedback on features, ask for new features, discuss issues and ask for help.

Also feel free to do so in the Toradex community: https://community.toradex.com/

## Contributing Templates

Torizon IDE Extension project templates are in their nature VS Code workspaces, with multiple [VS Code tasks](https://code.visualstudio.com/docs/editor/tasks) predefined in their `.vscode` folder. In summary the tasks execute the follow:

> ℹ️ The best way to start creating a new project template is taking one of the already published templates as reference. Check the [cppConsole/.vscode/tasks.json](./cppConsole/.vscode/tasks.json) to see an example.

![](https://github.com/toradex/vscode-torizon-templates/blob/dev/assets/img/vscodetasksDiagram.png?raw=true&v=6)

> ⚠️ To trigger the Torizon IDE Extension `build/deploy start` event the first dependency tasks from the pipeline needs to be labeled `validate-settings-*`.
> 
> Check the common tasks to use the right validate settings task for the architecture that is being added  [assets/tasks/common.json](./assets/tasks/common.json)

> ⚠️ To trigger the Torizon IDE Extension `build/deploy end` event the last task to be executed from the pipeline needs to be labeled `deploy-torizon-*`.

This pattern is replicated for each architecture supported by the template:

> ⚠️ Remember to split task groups adding the architecture prefix to the task label: `-arm64`, `-arm`, `-riscv64` and `-amd64`

![](https://github.com/toradex/vscode-torizon-templates/blob/dev/assets/img/vscodeTasksMultiArch.png?raw=true)

> ℹ️ Check the [cppConsole/.vscode/tasks.json](./cppConsole/.vscode/tasks.json) to see an example.

Some tasks are exceptions and are common to all architectures, the identified tasks that can be used for all templates are defined in [assets/tasks/common.json](./assets/tasks/common.json)

> ⚠️ Define the tasks in a way that is easy to reuse them for the CI/CD pipeline. The idea is to use the `tasks.json` definitions to also execute and generate CI/CD pipelines. Check the [tasks.ps1](./scripts/tasks.ps1) script for reference.

### Docker/Container Files

Torizon IDE Extension projects templates were designed to automate creation and development of containerized applications. So a project template must have 3 types of Docker/Container files in their root:

- [Dockerfile](./cppConsole/Dockerfile): Dockerfile with instructions to generate production ready image;

- [Dockerfile.debug](./cppConsole/Dockerfile.debug): Dockerfile with instructions to generate development image for Torizon IDE Extension tasks;

- [Dockerfile.sdk](./cppConsole/Dockerfile.sdk): Dockerfile to  create a cross toolchain image;

#### Dockerfile

It is recommended to be a multi-stage `Dockerfile` with the instructions to build the application artifacts in the `build` stage and generate the production ready image in the `deploy` stage. With multi stage we also guarantee that it will be easy to use during the development cycle in the user CI/CD pipeline.

#### Dockerfile.debug

The purpose of `Dockerfile.debug` is to create an image with the application's dependencies and also to setup a `ssh` server to the container generated from the image. The project template tasks will upload the debug release artifacts to the debug container running, through `ssh`. The `ssh` server is also needed to create the remote debug session on VS Code.

> ⚠️ The public and "private" keys used in the `Dockerfile.debug` are expected to be located in the [.conf](./cppConsole/.conf) folder of the template.

#### Dockerfile.sdk

The purpose of `Dockerfile.sdk` is to create an image with the cross toolchain SDK to build the application to a target architecture. This is used to output the build artifacts to be deployed on the `Dockferfile.debug` container.

> ⚠️ The `Dockerfile.sdk` file is needed only if the application framework or runtime only runs machine code.

#### Scripts

For some templates, complex and very specific tasks are required. For these cases add a new script in the [scripts](./scripts) folder.

The idea is that the project created from the template should be independent of this repository and the creation mechanisms. So, when creating a new template that needs a script, copy the script to the `.conf` folder of the created project.

> ⚠️ Check the [createFromTemplate.ps1](./scripts/createFromTemplate.ps1) script for reference.

#### Substitution tags

Substitution tags can be used inside files and as folders names to rename stuff needed by the project template. There are two substitution tags used by Torizon IDE Extension:

- `__change__`: that will be substituted to the project name;

- `__container__`: that will be substituted to the project container name service;

> ⚠️ Check the [createFromTemplate.ps1](./scripts/createFromTemplate.ps1) script for reference.

#### Dot VS Code Folder

In the `.vscode` folder the following files are expected:

- `settings.json`: define configurations about the host and the target device;
  
  - ```json
    {
      "torizon_psswd": "", // remote device psswd
      "torizon_login": "", // remote device login
      "torizon_ip": "", // remote device hostname or ip address
      "host_ip": "", // development pc ip address
      "torizon_workspace": "${workspaceFolder}",
      "torizon_debug_port": "", // debug port used by the framework
      "torizon_debug_ssh_port": "2230", // ssh port used by debug container
      "torizon_debug_port2": "", // second port used by the framework
      "torizon_debug_port3": "", // third port used by the framework
      "torizon_gpu": "", // remote device specific gpu vendor
      "torizon_arch": "" // remote device machine architecture
    }
    ```

- `tasks.json`: define tasks to run the pipeline to build and remote deploy/debug application;

- `launch.json`: define the launch tasks to remote debug the application. Is in this file that the `deploy-torizon-*` labeled tasks will be called;

- `extensions.json`:  define the extensions recommended to handle the files and the application framework;

> ℹ️ All these are VS Code related files, check the Microsoft official documentation to know more: [Documentation for Visual Studio Code](https://code.visualstudio.com/docs)

#### Dot Conf Folder

In the `.conf` folder the following files are expected:

- `id_rsa`: private key used for debug purposes, to remote deploy/debug the application inside a container;

- `id_rsa.pub`: public key used for debug purposes, to remote deploy/debug the application inside a container;

- `deps.json`: define an array with the Debian/Ubuntu packages that are dependency for compile and/or run the application locally. Torizon IDE Extension extension will check and will try to install it if they are not installed:
  
  - ```json
    {
        "packages": [
            "openssh-client",
            "sshpass",
            "build-essential",
            "make",
            "gdb",
            "g++"
        ]
    }
    ```

> ⚠️ The "private" and public keys used on Torizon IDE Extension projects are only for debug purposes!

## Creating a Pull Request

For Torizon IDE Extension project templates we are using [Github platform](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).

### Pull Request Guidelines:

- Fork the https://github.com/toradex/vscode-torizon-templates repo;

- Create a new development branch for your contributions;

- Follow this commits format:
  
  - ```git
    <template Folder>: <description>
    
    [optional body] <detailed description>
    
    
    Signed-off-by: your-e-mail@your-provider.com
    ```

- Create a pull request to the `dev` branch of https://github.com/toradex/vscode-torizon-templates

## Maintainence Policy

The project templates labeled with `"support": "Toradex",` are maintained by the IDE Torizon team from Toradex and accept contributions from the community. The templates must be updated to support new versions of the TorizonCore OS and new versions of the application frameworks. The release cycle is monthly.

The project templates labeled with `"support": "Partner",` are maintained by Toradex partners and accept contributions from the IDE Torizon team from Toradex and community. The templates must be updated to support new versions of the TorizonCore OS and new versions of the application frameworks. The release cycle is monthly.

The project templates labeled with `"support": "Community",` are maintained by the community and accept contributions from the IDE Torizon team from Toradex. The templates must be updated to support new versions of the TorizonCore OS and new versions of the application frameworks. The release cycle is not fixed and depends on the community main contributors.

### Deprecation Policy

For Toradex and Partner maintained project templates, the deprecation policy is to keep the template working for the last long term supported TorizonCore OS, from the date that the template was released. After the TorizonCore OS end of life, the template is considered deprecated if it's not working anymore in the latest TorizonCore OS version and no maintainence effort is being done to fix it in the next release cycle.

A community maintained project template is not commited to keep working until the EOF of the last LTS. It will be considered deprecated when it's known that is not working anymore in the latest LTS TorizonCore OS version and no maintainence effort is being done to fix it in the last 3 release cycles.
