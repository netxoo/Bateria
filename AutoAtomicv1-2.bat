@echo off
setlocal enabledelayedexpansion

set "archivo=T1003.001.txt"

echo %archivo%

for /f "tokens=*" %%a in ('findstr /c:"```" "%archivo%"') do (
    set "linea=%%a"
    set "linea=!linea:```=!"
    if not "!linea!" == "%%a" (
        echo Ejecuntando %DATE% %TIME%: !linea! 
	!linea!
    )
)

endlocal