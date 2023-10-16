@echo off
setlocal enabledelayedexpansion

for %%f in (example1.txt) do (

	set "archivo=%%f"

	  for /f "tokens=*" %%a in ('type "!archivo!"') do (
	    set "linea=%%a"
	    set "linea=!linea:```=!"

	    if "!linea!" == "%%a" (
	        echo !linea!
	    ) else (
		echo Ejecutando %DATE% %TIME%: !linea!
	 	!linea!  
    	   )

	  )
)

endlocal
