<#
.SYNOPSIS
"**** MENU DE AYUDA ****"
 "--------------------------------------------------------------------------------"
"Este script realiza el analisis de un texto, incluyendo el pre-procesamiento que consta de:"
    1. Eliminación de stop words
    2. Convertir a mayúsculas"
luego, contabiliza la frecuencia de aparición de cada palabra en el texto y genera un reporte ordenando los resultados de mayor a menor frecuencia en un
archivo de salida frecuencias_{Nombre archivo entrada}_{yyyy-mm-dd_hh:mm:ss}.out con formato CSV y mostrando por pantalla sólo las 5 palabras con mayor frecuencia.

.PARAMETER $archivoStopwords
Path del archivo stopwords

.PARAMETER $directorioResultado
Path del directorio donde se guardara el informe de frecuencias

.PARAMETER $archivo
Path del archivo a analizar

.EXAMPLE
        ejemplo1: ./frecuencias.ps1 -archivoStopwords '.\lote de pruebas\lote1\stopwords.txt' -archivo '.\lote de pruebas\lote1\archivoEntrada.txt' -directorioResultado '.\lote de pruebas\lote1'
            -ejecuta el script con el lote de pruebas 1
        ejemplo2: ./frecuencias.ps1 -archivoStopwords '.\lote de pruebas\lote2\stopwords.txt' -archivo '.\lote de pruebas\lote2\archivoEntrada.txt' -directorioResultado '.\lote de pruebas\lote2'
            -ejecuta el script con el lote de pruebas 2
		
.NOTES
        TRABAJO PRACTICO 2 ejercicio 2
        Nombre script:  .\frecuencias.ps1
        Autor: Tesan, Lucas
        Fecha: 14/10/2020
#>


param(
[parameter(mandatory = $true)]
[string]$archivoStopwords
,
[parameter()]
[string]$directorioResultado = "."
,
[parameter(mandatory = $true)]
[string]$archivo
)

#----------------------------------------------FUNCIONES-------------------------------------------------------------

function chequearDir([String] $dir) {
    if (!(Test-Path $dir)) {
        return $false
    } else {
        return $true
    }
}


Function eliminarStopwords{
Param (
[string]$archivoStopwords,
[string]$archivoEntrada
)
    Copy-Item -Path $archivoEntrada -Destination "archAuxiliar.txt"
    $stopwords = Get-Content $archivoStopwords

    foreach ($stopWordActual in $stopwords){
        $contenidoArchivo = (Get-Content "archAuxiliar.txt")
        $contenidoArchivo | ForEach-Object { "$_" -replace "$stopWordActual", "" } | Set-Content archPreProcesado.txt
        Remove-Item ".\archAuxiliar.txt"
        Move-Item "./archPreProcesado.txt" -Destination ".\archAuxiliar.txt"
    }
}


Function convertirAMayusculas{
    $contenidoArchivo = (Get-Content "archAuxiliar.txt")
    $contenidoArchivo | ForEach-Object { $_.ToString().ToUpper() } | Set-Content archPreProcesado.txt
    Remove-Item ".\archAuxiliar.txt"
    Move-Item "archPreProcesado.txt" ".\archAuxiliar.txt"
    #quito los espacios
    $origen = get-content ".\archAuxiliar.txt"
    $resultado = ""
    $origen | %{$resultado += $_ ; $resultado += " "}
    $resultado | out-file ".\archPreProcesado.txt"
    Remove-Item ".\archAuxiliar.txt"
}



Function contarPalabras([string]$directorioResultado, [string] $archivo){

$fechaArchivo = Get-Date -UFormat "%Y-%m-%d_%H-%M-%S" #fecha para el nombre del archivo

    Get-Content ".\archPreProcesado.txt" -Delimiter " " | ForEach-Object  {}{
            $palabra = $_.ToString().Trim()   #si hay mas de un espacio junto, lo reemplazo por 1 solo
            actualizar_key $palabra.ToString()
        }

    #muestro lo pedido por pantalla y guardo el resultado total en el archivo de texto
    $cont = 1
    foreach($item in $palabras.GetEnumerator() | Sort-Object value -Descending)
    {
        if($cont -le 5){
            $item
            $cont++
        }
        $item | Export-Csv "$directorioResultado/frecuencias_$archivo_$fechaArchivo.out" -Append -NoTypeInformation
    }
}

function actualizar_key{
param
(
[string]$palabra 
)
     if($palabra -eq " " -or $palabra -eq "" -or $palabra -contains "`n"){
        #no hago nada, asi no agrego a la hast-table espacios ni palabras vacias ni saltos de linea si es que los hay   
     }
     elseif(!$palabras.ContainsKey($palabra))
        {
            $palabras.Add($palabra, 1)    #si la palabra no existe, la inicializo en 1
        }
        else
        {
            $palabras.$palabra++          #si la palabra ya existe, le sumo 1
        }
}

#----------------------------------------------MAIN-------------------------------------------------------------

if(!(chequearDir $directorioResultado)){
    Write-Host "ERROR: el directorio resultado no existe"
    exit 1
}

if(!(chequearDir $archivoStopwords)){
    Write-Host "ERROR: el archivo stopwords no existe"
    exit 1
}

if(!(chequearDir $archivo)){
    Write-Host "ERROR: el archivo a analizar no existe"
    exit 1
}

eliminarStopwords $archivoStopwords $archivo
convertirAMayusculas
$global:palabras = @{}  #declaracion de Hash-Table
contarPalabras $directorioResultado $archivo

#------------------------------------------FIN DE ARCHIVO-------------------------------------------------------