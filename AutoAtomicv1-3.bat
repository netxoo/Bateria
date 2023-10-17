@echo off
setlocal enabledelayedexpansion

set "archivo=T1003.001.txt"

for /f "tokens=*" %%a in ('type "%archivo%"') do (
    set "linea=%%a"
    set "linea=!linea:```=!"

    if "!linea!" == "%%a" (
        echo !linea!
    ) else (
	echo Ejecutando %DATE% %TIME%: !linea!
 	!linea!  
    )

)

endlocal
