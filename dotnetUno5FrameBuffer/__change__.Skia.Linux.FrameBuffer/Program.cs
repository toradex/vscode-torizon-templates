using Microsoft.UI.Xaml;
using System;
using Uno.UI.Runtime.Skia.Linux.FrameBuffer;
using Windows.UI.Core;

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
