@echo off
setlocal enabledelayedexpansion

for %%f in (T1012.txt T1021.001.txt T1021.002.txt) do (

	set "archivo=%%f"

	  for /f "tokens=*" %%a in ('type "!archivo!"') do (
	    set "linea=%%a"
	    set "linea=!linea:```=!"

	    if "!linea!" == "%%a" (
	        echo !linea!
	    ) else (
		echo Ejecutando %DATE% %TIME%: !linea!
	 	cmd /c !linea!
    	   )

	  )
)

endlocal
