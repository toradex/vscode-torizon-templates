# GUI with HW Acceleration

This document list the templates and the actual supported hardware acceleration.

> ⚠️ These tables are WIP, feel free to send an MR if you have tested it on a machine that is not listed here.

> ⚠️ Tested on the TorizonCore v6.2.0 with Bookworm based images.

Subtitle:

⚠️ Partial Support;

🚫 Not Supported;

✅ Supported;

## `rustSlint`

| Machine       | Software | OpenGL | OpenGL ES | Vulkan |
| ------------- | -------- | ------ | --------- | ------ |
| Verdin iMX8mm | ✅        | 🚫     | ✅         | 🚫     |
| Apalis iMX8QM | ✅        | 🚫     | ✅         | 🚫     |

## `cppSlint`

| Machine       | Software | OpenGL | OpenGL ES | Vulkan |
| ------------- | -------- | ------ | --------- | ------ |
| Verdin iMX8mm | ✅        | 🚫     | ✅         | 🚫     |

## `dotnetAvalonia`

| Machine       | Software | OpenGL | OpenGL ES | Vulkan |
| ------------- | -------- | ------ | --------- | ------ |
| Verdin iMX8mm | ✅        | 🚫     | 🚫        | 🚫     |

> 🚫 Avalonia does not support Wayland backend for now, so, using Avalonia with Wayland is only possible by XWayland without HW Acceleration.

## `dotnetAvaloniaFrameBuffer`

| Machine       | Software | OpenGL | OpenGL ES | Vulkan |
| ------------- | -------- | ------ | --------- | ------ |
| Verdin iMX8mm | ✅        | 🚫     | ⚠️        | 🚫     |
| Apalis iMX8QM | ✅        | 🚫     | ⚠️        | 🚫     |

> ⚠️ OpenGL ES: is only supported when using `StartLinuxDrm`

## `nodeElectron`

| Machine       | Software | OpenGL | OpenGL ES | Vulkan |
| ------------- | -------- | ------ | --------- | ------ |
| Verdin iMX8mm | ✅        | 🚫     | ✅         | 🚫     |

## `python3Pyside2QML`

| Machine       | Software | OpenGL | OpenGL ES | Vulkan |
| ------------- | -------- | ------ | --------- | ------ |
| Verdin iMX8mm | ✅        | 🚫     | ✅         | 🚫     |

## `cppQML`

| Machine       | Software | OpenGL | OpenGL ES | Vulkan |
| ------------- | -------- | ------ | --------- | ------ |
| Verdin iMX8mm | ✅        | 🚫     | 🚫        | 🚫     |

> 🚫 OpenGL ES: Bookworm does not compile Qt 6 packages with Open GL ES support.

## `dotnetUno`

| Machine       | Software | OpenGL | OpenGL ES | Vulkan |
| ------------- | -------- | ------ | --------- | ------ |
| Verdin iMX8mm | ✅        | 🚫     | 🚫        | 🚫     |
| Apalis iMX8QM | ✅        | 🚫     | ⚠️        | 🚫     |

> ⚠️ .NET Uno uses GTK3 as backend, and Bookworm seems to use a version of it that has an issue with colors, that show inverted, when using `GDK_GL=gles`

> ⚠️ .NET Uno to work correctly needs a build of GTK3, using upstream sources, and a build of libepoxy, using upstream sources

> 🚫 Verdin iMX8MM only supports OpenGL ES 2.0, but GTK3, that is the backend from Uno Platform, needs OpenGL ES 3.0

## `dotnetUnoFrameBuffer`

| Machine       | Software | OpenGL | OpenGL ES | Vulkan |
| ------------- | -------- | ------ | --------- | ------ |
| Verdin iMX8mm | ✅        | 🚫     | 🚫        | 🚫     |
| Apalis iMX8QM | ✅        | 🚫     | 🚫        | 🚫     |

> 🚫 .NET Uno Platform does not support EGL fbdev for now
