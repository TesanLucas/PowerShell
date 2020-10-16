param([string]$procesoAMatar,
[String]$archivo
)
    if (!(Test-Path $archivo)) {
        ErrorDir $archivo
        return $false
        }
     Get-Process | ForEach-Object{
        if($_.ProcessName.Equals($procesoAMatar)){
            Write-Host - proceso a matar: nombre: $_.ProcessName  ID: $_.Id
            $nombreProceso = $_.ProcessName
            $pidProceso = $_.Id
            $fechaYHora = Get-Date -UFormat "%Y-%m-%d_%H:%M:%S"
            "$nombreProceso    $pidProceso    $fechaYHora" | Format-List | Out-File -FilePath $archivo -Append
            
            Stop-Process -Name $_.ProcessName
        }
     }
 #----------------------------------------------MAIN-------------------------------------------------------------