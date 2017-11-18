
if not exist "c:\b2Search" mkdir c:\b2Search
rem /y suppress prompt to confirm that file already exists and overwrite it
xcopy b2Search.exe c:\b2Search /y
xcopy b2SearchCfg.txt c:\b2Search /y
xcopy Search.ico c:\b2Search /y

REG DELETE HKCR\Folder\shell\bbSearch /f
REG ADD HKCR\Folder\shell\b2Search /f
REG ADD HKCR\Folder\shell\b2Search /v Icon /d "C:\b2Search\Search.ico" /f
REG ADD HKCR\Folder\shell\b2Search\command /ve /d "C:\b2Search\b2Search.exe "\"%1\""" /f