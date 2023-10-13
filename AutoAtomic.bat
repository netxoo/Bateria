@echo off
setlocal enabledelayedexpansion

set "archivo=T1003.001.x"
set "comando="

for /f "tokens=*" %%a in ('findstr /c:"```" "%archivo%"') do (
    set "linea=%%a"
    set "linea=!linea:```=!"
    if not "!linea!" == "%%a" (
        set "comando=!linea!"
    )
)

if not "!comando!" == "" (
    echo Ejecutando comando entre ```: !comando!
    !comando!
) else (
    echo No se encontraron comandos entre ``` en el archivo.
)

endlocal