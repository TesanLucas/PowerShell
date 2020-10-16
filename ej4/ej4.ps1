<#
.SYNOPSIS
"**** MENU DE AYUDA ****"
 "--------------------------------------------------------------------------------"
 "este script corre un demonio el cual mata cualquier proceso que este especificado dentro del archivo de texto BLACKLIST"
 "dejando un archivo log en el directorio DIRDESTINO"

.PARAMETER $blacklist
Path del archivo blacklist

.PARAMETER $directorioResultado
Directorio donde se guardan los LOG.

.EXAMPLE
        ejemplo de uso: .\ej4.ps1 -blacklist .\blacklist.txt -directorioResultado .
            -ejecuta el trabajo, creando el archivo log en el directorio .
            si el trabajo ya esta corriendo, lo cierra.

.NOTES
        TRABAJO PRACTICO 2 Ejercicio 4
        Nombre script:  .\Ejercicio4.ps1
        Autor: Tesan, Lucas
        Fecha: 14/10/2020

#>

param(
[parameter(mandatory = $true)]
[string]$blacklist,
[parameter()]
[string]$directorioResultado = "."
)

#----------------------------------------------MAIN-------------------------------------------------------------

#creo el timer
$timer = New-Object System.Timers.Timer
$timer.Interval = 2000
$timer.Enabled = $true


$accion = {
    #obtengo los parametros
    Get-Content "./scriptBlockDatos.txt" | ForEach-Object {
        $archivoBlacklist = $_.Split('|')[0]
        $nombreArchivoDestino = $_.Split('|')[1] 
    }
    #Llamo al matador de procesos
    Get-Content "$archivoBlacklist" | ForEach-Object{
        ./matador.ps1 "$_" "$nombreArchivoDestino"
    }
}

Get-Job | Where-Object {$_.Name -eq "Matador"} | ForEach-Object{
    if($_.State -eq "running" -or $_.State -eq "Failed"){
        write-host "el trabajo ya esta corriendo!, matandolo...."
        Unregister-Event matador
        write-host "el trabajo fue terminado"
        exit 1
    }
}

    $fechaArchivo = Get-Date -UFormat "%Y-%m-%d_%H-%M-%S" #fecha para el nombre del archivo
    $pathArchivo = "$directorioResultado/blacklist_$fechaArchivo.txt"
    New-Item -path $pathArchivo | Out-Null    
#el cmdlet que registra el evento necesita un sckript-block, al cual tengo que pasarle parametros.
#como al cmdlet no se le puede pasar parametretros para que ejecute el script con parametros (y si se puede no se como)
#tuve que poner los parametros en un archivo de texto para accederlos dentro del scriptblock
    Write-Output "$blacklist|$pathArchivo" > "./scriptBlockDatos.txt"

    Register-ObjectEvent $timer Elapsed -SourceIdentifier Matador -Action $accion | Out-Null
    $timer.Start()
    write-host "trabajo activado"

#------------------------------------------FIN DE ARCHIVO-------------------------------------------------------