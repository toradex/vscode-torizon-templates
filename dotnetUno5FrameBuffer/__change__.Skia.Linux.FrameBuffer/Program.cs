using Microsoft.UI.Xaml;
using Uno.UI.Runtime.Skia.Linux.FrameBuffer;
using Windows.UI.Core;
using Windows.ApplicationModel.Core;

namespace __change__.Skia.Framebuffer;

public class Program
{
    public static void Main(string[] args)
    {
        // if the args[0] is -debug wait for the debugger to attach
        if (args.Length > 0 && args[0] == "-debug")
        {
            while (!System.Diagnostics.Debugger.IsAttached)
            {
                System.Threading.Thread.Sleep(100);
            }
        }

        try
        {
            Console.CursorVisible = false;

            var host = new FrameBufferHost(() =>
            {
                if (CoreWindow.GetForCurrentThread() is { } window)
                {
                    // Framebuffer applications don't have a WindowManager to rely
                    // on. To close the application, we can hook onto CoreWindow events
                    // which dispatch keyboard input, and close the application as a result.
                    // This block can be moved to App.xaml.cs if it does not interfere with other
                    // platforms that may use the same keys.
                    window.KeyDown += (s, e) =>
                    {
                        if (e.VirtualKey == Windows.System.VirtualKey.F12)
                        {
                            Application.Current.Exit();
                        }
                    };

                    // also handle the console case
                    // To close the application press F12 to the debug terminal
                    // attached to the application stdout and press F12
                    new Thread(async () =>
                    {
                        var canExit = false;
                        while (!canExit)
                        {
                            var key = Console.ReadKey(true);
                            if (key.Key == ConsoleKey.F12)
                            {
                                await CoreApplication.MainView.CoreWindow.Dispatcher.RunAsync(
                                    CoreDispatcherPriority.Normal,
                                    () => {
                                        Application.Current.Exit();
                                    }
                                );
                                canExit = true;
                            }
                        }
                    }).Start();
                }

                return new AppHead();
            });
            host.Run();
        }
        finally
        {
            Console.CursorVisible = true;
        }
    }
}
