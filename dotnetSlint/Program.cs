using Slint;
using AppWindow;

var win = new Window();
win.RequestIncreaseValue = () => {
    win.counter++;
};

Console.WriteLine("Hello Torizon!");

win.Run();
