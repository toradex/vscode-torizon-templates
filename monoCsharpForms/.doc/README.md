# Mono .NET 4.7 C# Windows Forms template specific documentation

All projects follow the pipeline of tasks described in the [common contributing documentation](https://github.com/toradex/vscode-torizon-templates/blob/bookworm/CONTRIBUTING.md#contributing-templates). However, each project has its own specificities in terms of technologies and methods used to compile, deploy, and debug the code. Therefore, each of them has their own specific tasks in the **tasks.json** file.

## Install NuGet packages

To install NuGet packager use the `install-nuget` task. This task will ask for the input of the NuGet package name and version, also a pick list of the target framework will be presented. The task will use the `nuget` CLI and will install
the package and their dependencies in the `libs` folder.

![install-nuget task](https://github.com/toradex/vscode-torizon-templates-documentation/blob/bookworm/monoCsharpForms/install-nuget.png?raw=true)

## Open MWF Designer

If you don't have access to Visual Studio, for example if you are using bare Linux OS instead WSL 2, you can use `Mono Windows Forms Designer` to help you edit a `Form` in graphical mode. To open the designer use the `open-mono-designer` task. This task will use the `Form` class in focus from the VS Code editor as reference to open it on the designer:

> ⚠️ Make sure you have a `Form` class in focus in the VS Code editor before running the task.

![open-mono-designer task](https://github.com/toradex/vscode-torizon-templates-documentation/blob/bookworm/monoCsharpForms/open-mwf-designer.gif?raw=true)

> ⚠️ The `Mono Windows Forms Designer` is for simple editing of the form, it is not a full featured designer like the one in Visual Studio. Also is not possible to edit the code behind the form in the designer. For more information about the `Mono Windows Forms Designer` please refer to the [Mono documentation](https://www.mono-project.com/archived/winforms_designer/).
