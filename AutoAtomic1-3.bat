@echo off
setlocal enabledelayedexpansion

set "archivo=nombre_de_tu_archivo.txt"
set "imprimir=1"

for /f "tokens=*" %%a in ('type "%archivo%"') do (
    set "linea=%%a"

    if "!linea!"=="```" (
        set "imprimir=1"
    )

    if "!imprimir!"=="1" (
        echo !linea!
        call :EjecutarComando "!linea!"
    )
)

endlocal
goto :eof

:EjecutarComando
set "comando=%~1"
set "comando=!comando:```=!"
if not "!comando!"=="" (
    echo Ejecutando comando entre ``` : !comando!
    !comando!
)
