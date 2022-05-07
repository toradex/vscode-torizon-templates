using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using dotnetAvaloniaFrameBuffer.ViewModels;
using dotnetAvaloniaFrameBuffer.Views;
using Avalonia.LinuxFramebuffer;

using System;

namespace dotnetAvaloniaFrameBuffer
{
    public partial class App : Application
    {
        public override void Initialize()
        {
            AvaloniaXamlLoader.Load(this);
        }

        public override void OnFrameworkInitializationCompleted()
        {
            if (ApplicationLifetime is ISingleViewApplicationLifetime control)
            {
                control.MainView = new MainWindow {
                    DataContext = new MainWindowViewModel(),
                };
            }

            base.OnFrameworkInitializationCompleted();
        }
    }
}
