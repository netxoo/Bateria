# Edición Paulo Ruiz, Mónica Canizo


# Establecemos los parámetros
param (
    [string]$TestFile="ttps.txt",
    [switch]$Help
)

# Explicación del menú ayuda
function Show-Help {
    Write-Host "Este script realiza de forma automática, la ejecución de TTPs de Atomic Red Team `ncon el framework de invoke-atomicredteam, generando logs de cada TTP `ny lo guarda en formato .json"  -ForegroundColor White -BackgroundColor Blue
    Write-Host "`nPara ejecutar este script es necesario tener permisos de ejecución de scripts: `npowershell -ep bypass .\AutoAtomic.ps1 `npowershell -ExecutionPolicy Bypass .\AutoAtomic.ps1"  -ForegroundColor Red -BackgroundColor Black
   
    # set-executionpolicy remotesigned para habilitar script tambien funciona

    Write-Host "`n<---------------------- Instrucciones --------------------->"
    Write-Host "AutoAtomic.ps1 [-t] [-h]"
    Write-Host "  -t,-TestFile              Establece una ruta diferente a 'ttps.txt'."
    Write-Host "                            Con otros TTPs definidos por el usuarios."
    Write-Host "                            **Si nó se especifica, su valor por defecto es 'ttps.txt'."
    Write-Host "  -h,-Help                  Muestra este texto de ayuda."
    Write-Host "`n`n<---------------------- Ejemplos --------------------->"
    Write-Host "Para installar framework de Atomic Red Team con Payloads: `n$.\AutoAtomic.ps1 -i -p "
    Write-Host "`nPara ejecución normal de las TTP `n$.\AutoAtomic.ps1"
    Write-Host "$ powershell -ep bypass .\AutoAtomic.ps1"
    Write-Host "`nPara La ejecución de este escript, se requiere de un archivo llamado ttps.txt `ndonde se contenga en forma de lista las TTP en número.`nCada TTP puede tener '-Numero' al final para indicar el numero de test a ejecutar, P/E:"
    Write-Host "`n[File ttps.txt], `nT1033, `nT1087.002, `nT1497.001-2"
    

}

#Llamado de funciones

if ($Help) {
    Show-Help
    exit
}


#<---------------------- Auto Atomic --------------------->
# Obtención de datos

# Perfil de usuario
$admin = [bool](New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
# Direccionamiento de red del usuario

$networkInterface = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.PhysicalMediaType -ne 'Loopback' }

if ($networkInterface) {
    $ipAddress = (Get-NetIPAddress -InterfaceIndex $networkInterface.ifIndex -AddressFamily IPv4).IPAddress
} else {
    $ipAddress = "0.0.0.0"
}

# Ruta absoluta del directorio que contiene el script
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Configuración del nombre de la carpeta de logs
$logFolder = Join-Path $dir "AtomicLog-$(Get-Date -UFormat %Y-%m-%d)"
if (-not (Test-Path -Path $logFolder -PathType Container)) {
    New-Item -Path $logFolder -ItemType Directory
}
$archivo = Join-Path $dir $TestFile


# Impresión en pantalla
# Inicio
Write-Host "<---------------------- Auto Atomic --------------------->"
Write-Host ""
Write-Host "[i] Ejecutando TTP 1 x 1" -ForegroundColor DarkCyan -BackgroundColor Gray
Write-Host "[+] Iniciando Atomic Red team" -ForegroundColor DarkCyan -BackgroundColor Gray
# Nombre del archivo de logs
Write-Host "[+] Archivo de logs en: '$logFolder'." -ForegroundColor DarkCyan -BackgroundColor Gray
# Archivo de TTPs
Write-Host "[i] Usando archivo de TTPs: '$archivo'." -ForegroundColor DarkCyan -BackgroundColor Gray


# Validando cuantas TTPs se van a ejecutar
$totalTTPS = (Get-Content $archivo).Count
$stream = [System.IO.StreamReader] $archivo


# Inicio de ejecución
$count = 1

while ($null -ne ($ttp = $stream.ReadLine())) {
    Write-Host ""
    Write-Host "[i] Probando $count de $totalTTPS" -ForegroundColor DarkCyan -BackgroundColor Gray
    Write-Host "`n<---------------------- $ttp Informacion--------------------->" -ForegroundColor DarkRed -BackgroundColor White
    Invoke-AtomicTest $ttp -ShowDetails
    
        $respuesta = ""
        while ($respuesta -notin @("y", "n", "e")) {
            $respuesta = Read-Host "[i] Desea ejecutar? (y[yes]/n[no]/e[exit])"
            $respuesta = $respuesta.ToLower()
        }

        if ($respuesta -eq "e") {
            break
        } elseif ($respuesta -eq "n") {
            Write-Host "<---------------------- $ttp Test omitido --------------------->" -ForegroundColor DarkCyan -BackgroundColor Gray
            $count++
            continue
        }
    
    
    ### -------------------------------- Pre requisitos -------------------------
    Write-Host ""
    Write-Host "<---------------------- $ttp Pre requisitos--------------------->" -ForegroundColor DarkGreen -BackgroundColor Gray
    
    $atomlogpath = Join-Path $logFolder "${ttp}_GetPrereqs_log.json"
   
    Invoke-AtomicTest $ttp -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath $atomlogpath -GetPrereqs -Confirm:$false

	### -------------------------------- Execution -------------------------
    Write-Host ""
    Write-Host "<---------------------- $ttp Ejecucion--------------------->" -ForegroundColor Magenta -BackgroundColor Gray
    $atomlogpath = Join-Path $logFolder "${ttp}_Execute_log.json"
    $init = Get-Date

    Invoke-AtomicTest $ttp -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath $atomlogpath -Confirm:$false
    
    $end = Get-Date

    if ($admin) {
        Write-Host "[$ttp] TTP ejecutada con permisos de administrador"
    } 

    Write-Host "`n---------------------------------------------------------------------"
    Write-Host "- D A T O S   E J E C U C I O N   D E   P R U E B A S"
    Write-Host "- [$ttp] Logs: $atomlogpath"
    Write-Host "- [$ttp] Inicio: $init"
    Write-Host "- [$ttp] Fin: $end"
    Write-Host "- [$ttp] IP: $ipAddress"
    Write-Host "- [$ttp] User: $env:USERNAME"
    Write-Host "- [$ttp] Hostname: $env:COMPUTERNAME"
    Write-Host "---------------------------------------------------------------------"

    Write-Host "Presiona 'c' para continuar..."
    do {
        $key = [System.Console]::ReadKey($true)
    } while ($key.Key -ne 'c')

    Write-Host "Continuando..."
    ### -------------------------------- Clean -------------------------
    Write-Host ""
    Write-Host "<---------------------- $ttp Limpieza--------------------->" -ForegroundColor Magenta -BackgroundColor Gray
    
    $atomlogpath = Join-Path $logFolder "${ttp}_Clean_log.json"
    $init = Get-Date

    Invoke-AtomicTest $ttp -Cleanup -LoggingModule "Attire-ExecutionLogger" -ExecutionLogPath $atomlogpath -Confirm:$false
    
    $end = Get-Date

    Write-Host "`n---------------------------------------------------------------------"
    Write-Host "- D A T O S   E J E C U C I O N   D E   L I M P I E Z A"
    Write-Host "- [$ttp] Logs: $atomlogpath"
    Write-Host "- [$ttp] Inicio: $init"
    Write-Host "- [$ttp] Fin: $end"
    Write-Host "- [$ttp] IP: $ipAddress"
    Write-Host "- [$ttp] User: $env:USERNAME"
    Write-Host "- [$ttp] Hostname: $env:COMPUTERNAME"
    Write-Host "---------------------------------------------------------------------"

    Write-Host "`n<---------------------- $ttp Fin --------------------->" -ForegroundColor DarkRed -BackgroundColor White
    $count++
}

# Cerrar el archivo
$stream.Close()