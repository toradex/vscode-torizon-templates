#!/usr/bin/env pwsh

$errorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true

Write-Host "📦 :: CREATE FROM TEMPLATE :: 📦"

try {
    Add-Type -Path /root/.tui/Terminal.Gui.dll
    Add-Type -Path /root/.tui/tui.dll

    # initialization
    [Terminal.Gui.Application]::UseSystemConsole = $true
    [Terminal.Gui.Application]::Init()

    $_win = [tui.Tui]::new()
    $_win.Title = "Torizon IDE Extension TUI"
    $env:__tgui_cancel = $true

    # get the metadata from repo
    $_metadata = 
        Get-Content "${env:HOME}/.apollox/templates.json" | ConvertFrom-Json
    $_templates = [System.Collections.ArrayList]::new()
    $_bigchar = 0

    foreach ($_template in $_metadata.Templates) {
        if ($_template.description.Length -gt $_bigchar) {
            $_bigchar = $_template.description.Length
        }

        $_templates.Add($_template.description) | Out-Null
    }

    # Toradex colorscheme
    $_colorSchemeToradex = [Terminal.Gui.ColorScheme]::new()
    $_colorSchemeToradex.Normal = [Terminal.Gui.Attribute]::new(
        [Terminal.Gui.Color]::BrightGreen,
        [Terminal.Gui.Color]::Blue
    )

    # Community colorscheme
    $_colorSchemeCommon = [Terminal.Gui.ColorScheme]::new()
    $_colorSchemeCommon.Normal = [Terminal.Gui.Attribute]::new(
        [Terminal.Gui.Color]::DarkGray,
        [Terminal.Gui.Color]::Blue
    )

    # Partner colorscheme
    $_colorSchemePartner = [Terminal.Gui.ColorScheme]::new()
    $_colorSchemePartner.Normal = [Terminal.Gui.Attribute]::new(
        [Terminal.Gui.Color]::BrightCyan,
        [Terminal.Gui.Color]::Blue
    )

    # set the data to the listView
    $_win.listView.Source = [Terminal.Gui.ListWrapper]::new($_templates)
    $_win.scrollBarView.ContentSize = 
        [Terminal.Gui.Size]::new($_bigchar, $_templates.Count)
    $_win.listView.Add_OpenSelectedItem({
        param([Terminal.Gui.ListViewItemEventArgs]$_event)
        # fetch the data from metadata
        $_selected = $_metadata.Templates[$_event.Item]
        
        # set the labels
        $_win.label.Text  = "Template:    " + $_selected.folder
        $_win.label2.Text = "Description: " + $_selected.description
        $_win.label3.Text = "Language:    " + $_selected.language
        $_win.label4.Text = "Runtime:     " + $_selected.runtime
        $_win.label5.Text = "Maintainer:  " + $_selected.support

        # change the label color depending on the support
        switch ($_selected.support) {
            "Toradex" {
                $_win.label5.ColorScheme = $_colorSchemeToradex
            }
            "Community" {
                $_win.label5.ColorScheme = $_colorSchemeCommon
            }
            "Partner" {
                $_win.label5.ColorScheme = $_colorSchemePartner
            }
            Default {}
        }

        $_win.scrollBarView2.ContentSize = [Terminal.Gui.Size]::new(
            $_win.frameView2.Frame.Width - 2,
            $_win.frameView2.Frame.Height - 2
        )

        $_win.textValidateField.SetFocus()
    })

    # ok, we can create the project
    $_win.button.Add_Clicked({
        # check if they are valid
        if ($_win.textValidateField.IsValid -eq $false) {
            [Terminal.Gui.MessageBox]::ErrorQuery(
                "Project name is not valid",
                "`n" +
                "Project name must start with a letter, `n" +
                "it not allow special characters, spaces, `n" + 
                "or any other characters except letters and digits.",
                @(
                    "Ok"
                )
            )
            $_win.textValidateField.SetFocus()
            return
        }

        if ($_win.textValidateField2.IsValid -eq $false) {
            [Terminal.Gui.MessageBox]::ErrorQuery(
                "Container name is not valid",
                "`n" +
                "Container name must contain only lowercase `n" +
                "letters (a-z), digits (0-9), underscores (_), `n" + 
                "hyphens (-), and forward slashes (/). `n" + 
                "No uppercase letters or special characters are allowed.",
                @(
                    "Ok"
                )
            )
            $_win.textValidateField2.SetFocus()
            return
        }

        [Terminal.Gui.Application]::RequestStop()
        $env:__tgui_cancel = $false
    })

    # nok, we cannot create the project
    $_win.button2.Add_Clicked({
        [Terminal.Gui.Application]::RequestStop()
    })

    # running the application
    [Terminal.Gui.Application]::Run($_win)

    # shutdown the application
    [Terminal.Gui.Application]::Shutdown()

    # check if the user cancel the operation
    if ($env:__tgui_cancel -eq $true) {
        Write-Host "The user cancel the operation"
        exit 0
    }

    # get data from the application
    $_templateFolder = $_metadata.Templates[$_win.TemplateSelected].folder
    $_appName = $_win.textValidateField.Text.ToString()
    $_containerName = $_win.textValidateField2.Text.ToString()

    # call the createFromTemplate.ps1
    # Write-Host "Creating project from template: $_templateFolder"
    # Write-Host "Project name: $_appName"
    # Write-Host "Container name: $_containerName"

    pwsh -nop -File `
        "${env:HOME}/.apollox/scripts/createFromTemplate.ps1" `
        "${env:HOME}/.apollox/$_templateFolder" `
        "$_appName" `
        "$_containerName" `
        "/workspace/" `
        "$_templateFolder" `
        "false" `
        "true"

} catch {
    Write-Host $_.Exception.Message -Foreground "Red"
    Write-Host ""
    $lines = $_.ScriptStackTrace.Split("`n")

    foreach ($line in $lines) {
        Write-Host "`t$line" -Foreground "DarkGray"
    }

    Write-Host ""

    [Terminal.Gui.Application]::Shutdown()

    exit 69
}
