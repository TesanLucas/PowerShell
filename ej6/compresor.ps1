<# 
.SYNOPSIS
    Permite comprimir, descomprimir historiales clinicos de pacientes para reducir tamaño en disco
.DESCRIPTION 
    este script comprime los historiales medicos de todas las personas que no hayan visitado el centro medico en los ultimos 30 dias.
	tambien permite descomprimir el historial de cada paciente de forma individual.
.PARAMETER directorioZip
    Indica el directorio en donde se guardan los archivos comprimidos
.PARAMETER descomprimir
    Indica que el modo a trabajar es el modo de descompresión.
.PARAMETER comprimir
    Indica que el modo a trabajar es el modo de compresión.
.PARAMETER paciente
    Indica el nombre del paciente cuya historia clinica hay que descomprimir
.PARAMETER directorioHistorias
    Indica el directorio donde se almacenan las historias clinicas
.EXAMPLE 
    Para comprimir un directorio: 
    .\compresor.ps1 -directorioZip .\lote\comprimidos -directorioHistorias '.\lote\ultimasVisitas' -comprimir
.EXAMPLE 
    Para descomprimir un historial clinico determinado: 
    .\compresor.ps1 -directorioZip .\lote\comprimidos -directorioHistorias '.\lote\ultimasVisitas' -descomprimir -paciente "Lucas Tesan"
.NOTES
        TRABAJO PRACTICO 2 ejercicio 6
        Nombre script:  .\conversor.ps1
        Autor: Tesan, Lucas Brian
        Fecha: 14/10/2020
#>

param(
[parameter(mandatory = $true)]
[String] $directorioZip,
[parameter(mandatory = $true)]
[String] $directorioHistorias,
[Switch] $descomprimir,
[Switch] $comprimir,
[String] $paciente
)

#----------------------------------------------FUNCIONES-------------------------------------------------------------

function ChequearDir([String] $dir) {
    if (!(Test-Path $dir)) {
        ErrorDir $dir
        return $false
    } else {
        return $true
    }
}


function ErrorDir([String] $dir) {
    Write-Host "Error, el directorio: $dir, no se existe o no puede ser leido."
}


function Descomprimir([String] $directorioHistorias, [String] $directorioZip, [String] $paciente) {
    ChequearDir($directorioZip){
        $path = Resolve-Path $directorioZip
        $path = -join($path, "\$paciente", ".zip")
        if (!(ChequearDir($path))){
            exit 1
        }
        Write-Host $path
        $pathDestino = Resolve-Path $directorioHistorias
        Expand-Archive -Path $path -DestinationPath $pathDestino
        Write-Host "Archivo descomprimido en el directorio $directorio"
        Remove-Item -Path $path -Recurse
    }
}

function Comprimir([String] $directorio, [String] $directorioZip) {

#para comparar las fechas, primero tengo que obtener la fecha actual y restarle 30 dias.
#pero si le resto 30 dias con el metodo addDays, no me deja formatear la salida.
#al formatear la salida, PWSH ya no reconoce el resultado como un DateTime, sino como string
#por lo tanto tengo que parsear el string y volver a convertirlo a date, asi le puedo sumar 30 dias.
#lo mismo para las fechas proveniente del archivo

$fechaActual = (Get-Date -UFormat "%Y-%m-%d")
$anioActual = $fechaActual.Split('-')[0]
$mesActual = $fechaActual.Split('-')[1]
$diaActual = $fechaActual.Split('-')[2]
$fechaActual = get-date -Year $anioActual -Month $mesActual -Day $diaActual -Hour 0 -Minute 0 -Second 0
$fechaAComparar = $fechaActual.AddDays(-30)

    Get-Content "$directorio/ultimas visitas.txt" |  ForEach-Object {
        #parseo la fecha de todos los pacientes
        $fechaPaciente = $_.Split(‘|‘)[-1]
        $nombrePaciente = $_.Split(‘|‘)[0]
        $anioPaciente = $fechaPaciente.Split('-')[0]
        $mesPaciente = $fechaPaciente.Split('-')[1]
        $diaPaciente = $fechaPaciente.Split('-')[2]
        $fechaPaciente = get-date -Year $anioPaciente -Month $mesPaciente -Day $diaPaciente -Hour 0 -Minute 0 -Second 0        

        if($fechaPaciente.CompareTo($fechaAComparar) -eq -1){
            $path = "$directorio/$nombrePaciente"
            $dirDestino = "$directorioZip/$nombrePaciente.zip"

             try {
                if(ChequearDir $path){
                    Write-Host "comprimiendo el archivo $path al destino $dirDestino..."
                    Compress-Archive -Path $path -DestinationPath $dirDestino
                    Remove-Item -Path $path -Recurse
                }
             }
             catch [System.IO.IOException] {
                Write-Host "       el archivo ya existe!"
            } 
        }
    }
}

#----------------------------------------------MAIN-------------------------------------------------------------

if (!(ChequearDir($directorioZip))) {
    exit 1
}

if (!(ChequearDir($directorioHistorias))) {
    exit 1
}

if ($descomprimir) {
    if($paciente -eq ""){
        Write-Host "falta el nombre del paciente!"
        exit 1
    }
    Descomprimir $directorioHistorias $directorioZip $paciente
}elseif ($comprimir) {
    Comprimir $directorioHistorias $directorioZip
}else {
        Write-Host "No se especifico ninguna accion."
        exit 1
    }

#------------------------------------------FIN DE ARCHIVO-------------------------------------------------------