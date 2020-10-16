<#
.SYNOPSIS
Este script realiza una de las siguientes acciones: 
    *Informar la cantidad de procesos que se encuentran corriendo en ese momento
    *Indicar el tamaño de un directorio.

.PARAMETER $proceso
Parámetro de tipo switch que indica que se mostrará la cantidad de procesos corriendo al momento de ejecutar el script

.PARAMETER $peso
Parámetro de tipo switch que indica que se mostrará el peso de un directorio

.PARAMETER $directorio
Solo se puede usar si se pasó “-Peso”. Indica el directorio a evaluar

.EXAMPLE
        ejemplo1: .\Ejercicio5.ps1 -proceso
            -muestra por pantalla la cantidad de procesos corriendo
        ejemplo2: .\Ejercicio5.ps1 -peso .
            -muestra por pantalla el peso del directorio actual

.NOTES
        TRABAJO PRACTICO 2 Ejercicio 3
        Nombre script:  .\ejercicio3.ps1
        Autor Tesan, Lucas
#>

param(
[parameter(mandatory = $true, Position = 0, ParameterSetName = "proceso" )]
[switch]$proceso
,
[parameter(Position = 0, ParameterSetName = "peso" )]
[switch]$peso
,
[parameter(Position = 1)]
[string]$directorio
)

#-----------------------------FUNCIONES-------------------------------------------#

function cantidad_procesos
{
    $i=0
    Get-Process | foreach {}{
        $i++
    }
Write-Output $i
}


function tamaño_directorio
{
param ([string]$directory)
    $tamaño = 0
    $PathAbsoluto = Resolve-Path -Path $directory
    Write-Host $PathAbsoluto

    #el peso de una carpeta es el peso de todos los archivos que tenga adentro
    #-recurse es para hacerlo recursivamente

    Get-ChildItem -Recurse -LiteralPath $PathAbsoluto -force | ForEach-Object{}{
        if($_.Length -ne 0)
        {
            $tamaño = $tamaño + $_.Length
        }
    }
    Write-host $tamaño bytes
}

#----------------------------------MAIN------------------------------------------#

if($proceso -eq $true -and $directorio -eq "")
{
    cantidad_procesos
    exit 0
}
elseif($peso -eq $true -and $directorio -ne "")
{
    $existe = Test-Path -Path $directorio
     if(!$existe)
     {
        Write-Output "el directorio no existe!"
        exit 1
     }
    tamaño_directorio $directorio
    exit 0
}
else
{
    Write-Host "parametros invalidos, para ayuda get-help ejercicio5.ps1"
}
#---------------------------------------------FIN DEL SCRIPT-------------------------------------------------#