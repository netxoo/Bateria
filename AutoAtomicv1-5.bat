@echo off
setlocal enabledelayedexpansion

md registros

for %%f in (T1027.txt T1036.003.txt T1036.004.txt) do (

	set "archivo=%%f"
	
	  for /f "tokens=*" %%a in ('type "!archivo!"') do (
	    set "linea=%%a"
	    set "linea=!linea:```=!"

	    if "!linea!" == "%%a" (
		echo !linea!
	        echo !linea! >> registros\log_%%f
	    ) else (
		echo Ejecutando %DATE% %TIME%: !linea!
		echo Ejecutando %DATE% %TIME%: !linea! >>  registros\log_%%f
		cmd /c !linea! >>  registros\log_%%f
		
    	   )

	  )
)

endlocal
