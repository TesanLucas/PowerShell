<#
.SYNOPSIS
en base a un archivo CSV con los datos de origen y destino, este script mueve archivos de un directorio a otro
y registra en un log con formato CSV la hora en la que se movió cada uno de esos archivos.

.PARAMETER $entrada
Path del archivo CSV de entrada.

.PARAMETER $salida
Path del archivo CSV de salida (log). Incluye nombre del archivo.

.EXAMPLE
        ejemplo: .\Ejercicio3.ps1 C:\Wabash\Logfiles\mar1604.log.txt" "C:\Destination.txt"
        
.NOTES
        TRABAJO PRACTICO 2 Ejercicio 5
        Nombre script:  .\ejercicio5.ps1
        Autor: Tesan, Lucas
#>

param(
[parameter(mandatory = $true, Position = 0)]
[string]$entrada
,
[parameter(mandatory = $true, Position = 1)]
[string]$salida
)

#Declaro una clase para poder pasarla como objeto a los comandos import-csv ; convertTo-csv
Class CsvSalida
{
    [string]$archivo
    [string]$fecha
}

#verifico el path de entrada
if(!(Test-Path -Path $entrada -PathType leaf))
   {
    Write-Host "el path de entrada o no es un archivo o no existe!"
    exit 0
   }

#verifico path salida
if(!(Test-Path -Path $salida -PathType leaf))
   {
   #el archivo de salida no existe, verifico que se pueda crear correctamente
   if((Test-Path $salida -PathType Container) -or !(Split-Path -path $salida | Test-Path -PathType Container))
   {
        Write-Output "el path de salida no existe!"
        exit 0
   }
   else
   {
         #el archivo no existe pero el directorio si, entonces debo crear el archivo csv yo mismo
         $existe = 0
   }
}
else
  {
   #el archivo existe, seteo el flag para sobreescribir luego
   $existe = 1
  }


$delimCampos = ','
#importo el csv
$csv = Import-Csv $entrada -Delimiter  $delimCampos
#instancio una clase para poder exportar
$registro = New-Object -TypeName CsvSalida

for($i=0; $i -lt $csv.Count ; $i++){
    #realizo la operacion de copiar-pegar
    $origen = $csv[$i].origen
    $destino = $csv[$i].destino
    Copy-Item  -LiteralPath $origen -Destination $destino

    #exporto
    $registro.archivo = $destino
    $registro.fecha = get-date -DisplayHint date -Format G

    #si el archivo existe, agrego
    #si no existia, lo creo y agrego
    if($existe -eq 1)
    {
        $registro | Export-Csv $salida -Append
    }
    else
    {
        $registro | ConvertTo-Csv -NoTypeInformation | Out-File $salida
        $existe = 1
    }
}