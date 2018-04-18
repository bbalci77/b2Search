
perl version.plx
call pp -g -o b2Search.exe b2SearchGui.plx

timeout /t 1

rem /y suppress prompt to confirm that file already exists and overwrite it
xcopy b2Search.exe ..\bin\windows /y
xcopy b2SearchCfg.txt ..\bin\windows /y
xcopy b2SearchHistory.txt ..\bin\windows /y
xcopy Search.ico ..\bin\windows /y
xcopy install_b2Search.bat ..\bin\windows /y
xcopy Readme.txt ..\bin\windows /y
xcopy versionInfo.txt ..\bin\windows /y
xcopy b2SearchDirHistory.txt ..\bin\windows /y

rem linux files
xcopy b2SearchGui.plx ..\bin\linux /y
xcopy b2SearchCfg.txt ..\bin\linux /y
xcopy b2SearchHistory.txt ..\bin\linux /y
xcopy Readme.txt ..\bin\linux /y
xcopy versionInfo.txt ..\bin\linux /y
xcopy installScript_linux ..\bin\linux /y
xcopy b2SearchDirHistory.txt ..\bin\linux /y