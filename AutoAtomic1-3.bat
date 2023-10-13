@echo off
setlocal enabledelayedexpansion

set "archivo=T1010.x"
set "imprimir=0"

for /f "tokens=*" %%a in ('type "%archivo%"') do (
    set "linea=%%a"
    if "!linea!" == "## Atomic Test" (
        set "imprimir=1"
        echo !linea!
    ) else if "!linea!" == "```" (
        set "imprimir=0"
    ) else if !imprimir! == 1 (
        echo !linea!
        call :EjecutarComando "!linea!"
    )
)

endlocal
goto :eof

:EjecutarComando
set "comando=%~1"
set "comando=!comando:```=!"
if not "!comando!" == "" (
    echo Ejecutando comando entre ``` : !comando!
    !comando!
)
