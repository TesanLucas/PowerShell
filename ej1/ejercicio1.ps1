<#
.SYNOPSIS
Este script informa cuáles de los procesos que se encuentran corriendo en el sistema tiene más de -cantidad instancias

.PARAMETER $cantidad
Cantidad mínima de instancias que debe tener un proceso para ser reportado. Este parámetro debe ser obligatorio y mayor a 1

.EXAMPLE
        .\Ejercicio2.ps1 3
		
.NOTES
        TRABAJO PRACTICO 2 Ejercicio 1
        Nombre script:  .\ejercicio1.ps1
        Autor: Tesan, Lucas
#>


Param(
[parameter(Mandatory = $true , position = 0)]
    [int] $cantidad
)


    if($cantidad -le 0){
        Write-Output "la cantidad pedida tiene que ser mayor a 0! para mas info get-help ejercicio1"
        exit 1
    }

#Declaramos una hash table donde key = ProcessName ; value = cantidad de veces iniciado ese proceso
$proceso = @{}

Get-Process | ForEach-Object {}{

    $nombre = $_.ProcessName
    #if($proceso.$nombre -eq "false")

    #si el proceso no está en la hashtable, lo insertamos con valor 1. y si está le sumamos 1
    if(!$proceso.ContainsKey($nombre))
    {
        $proceso.Add($nombre, 1)
    }
    else
    {
        $proceso.$nombre++
    }
}

write-host "
resultado:
"
#Mostramos lo pedido
foreach($actual in $proceso.Keys)
    {
    if($proceso.$actual -ge $cantidad){
        Write-Host $actual $proceso.$actual
    }

}