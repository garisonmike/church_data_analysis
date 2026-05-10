# Windows Build Notes

## sqlite3.dll

`sqlite3_flutter_libs` bundles sqlite3.dll automatically via the CMake build.
No manual copying needed. The DLL ships with the app bundle on Windows.

## Minimum Windows Version

The app targets Windows 10 and later (as set in `CMakeLists.txt`).
Windows 7/8/8.1 are not supported by Flutter.

## Supported Windows Architectures

- x64 (primary)
- ARM64 (Flutter 3.x supports this)

## File Picker on Windows

`file_picker` uses the Win32 common dialog (IFileOpenDialog / IFileSaveDialog).
This works on all Windows 10+ versions without extra dependencies.

## HardwareKeyboard (Ctrl+scroll zoom)

The ctrl_scroll_zoom_wrapper uses HardwareKeyboard, which is desktop-only.
It is guarded with a `_isDesktop` check so it does not activate on mobile/web.
