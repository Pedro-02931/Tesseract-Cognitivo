# Poweshell

```
<#
 █████████████████████████████████████████████████████████████████████████████
   CÓDIGO EM POWERSHELL OTIMIZADO – VERSÃO COMPLETA COM ROUND4
   Este script reúne funções de cálculo de pontuação, I/O, RBM, normalização e montagem do CSV,
   utilizando um denominador comum de quatro casas decimais pra manter tudo estável e reduzir o
   efeito borboleta – quanto mais casas, mais cenários variam, velho.
 █████████████████████████████████████████████████████████████████████████████
#>

################################################################################
#                   FUNÇÃO round4 (Arredonda para 4 casas decimais)              #
################################################################################
function round4 {
    param(
        [double]$value
    )
    return ([math]::Round($value * 10000.0) / 10000.0)
}

################################################################################
#            FUNÇÃO Calcular-PontuacaoComponente (Versão Corrigida)             #
################################################################################
function Calcular-PontuacaoComponente {
    param(
        [string]$Category,
        [PSCustomObject]$ComponentData,
        [Hashtable]$Pesos,
        [double]$FourierFactor = 1.0,
        [int]$MarkovDimension = 1,
        [double]$SuperpositionFactor = 1.0
    )
    if ($Pesos.ContainsKey($Category)) {
        $peso = $Pesos[$Category]
    } else {
        $peso = 1
    }
    $mult = $FourierFactor * $SuperpositionFactor
    $v = 0
    switch ($Category) {
        "CPU" {
            # Para a CPU, replicando o cálculo original:
            $clockSpeedGHz = [math]::Round($ComponentData.MaxClockSpeed / 1000.0, 2)
            $freqReal = $ComponentData.CurrentClockSpeed / 1000.0
            $scoreRaiva = $freqReal * $ComponentData.NumberOfCores * [math]::Log($ComponentData.MaxClockSpeed + 1)
            $scoreAvancado = ($ComponentData.NumberOfCores * $clockSpeedGHz) / 8
            if ($ComponentData.NumberOfLogicalProcessors -and $ComponentData.NumberOfCores -gt 0) {
                $logicalFactor = $ComponentData.NumberOfLogicalProcessors / $ComponentData.NumberOfCores
                $scoreAvancado *= $logicalFactor
            }
            $composedScore = (($scoreRaiva + $scoreAvancado) / 2) * $FourierFactor * $SuperpositionFactor
            $v = round4 $composedScore
        }
        "GPU" {
            if ($ComponentData.AdapterRAM) {
                $vram = [math]::Round($ComponentData.AdapterRAM / 1GB, 2)
            } else {
                $vram = 1
            }
            if ($ComponentData.CurrentClockSpeed) {
                $clk = $ComponentData.CurrentClockSpeed / 1000.0
            } else {
                $clk = 1
            }
            if ($ComponentData.MemoryBandwidth) {
                $memBW = $ComponentData.MemoryBandwidth
            } else {
                $memBW = 50
            }
            if ($ComponentData.PCIeVersion) {
                $match = [regex]::Match($ComponentData.PCIeVersion, '[\d\.]+')
                $pcieFactor = $match.Value -as [double]
            } else {
                $pcieFactor = 4.0
            }
            if ($ComponentData.ResizableBAR -eq "True") {
                $barFactor = 1.2
            } else {
                $barFactor = 1
            }
            $scoreVRAM = $vram * $clk * ($memBW / 100) * $pcieFactor * $barFactor
            if ($ComponentData.Name -match "RTX") {
                $scoreVRAM *= 1.5
            }
            if ($ComponentData.VideoProcessor) {
                $videoPeso = $ComponentData.VideoProcessor.Length
            } else {
                $videoPeso = 1
            }
            $scoreAvancado = (($vram * 0.7) + ($videoPeso * 0.3)) / 16
            $v = round4 (($scoreVRAM + $scoreAvancado) / 2 * $mult)
        }
        "SSD" {
            if ($ComponentData.Interface -eq "NVMe") {
                $i = 2
            } else {
                $i = 1
            }
            $baseScore = ($ComponentData.Size / 1GB) * $i
            $v = round4 ($baseScore * $mult)
        }
        "Barramento" {
            if ($ComponentData.Latency -gt 0) {
                $latency = $ComponentData.Latency
            } else {
                $latency = 1
            }
            $base = ($ComponentData.Bandwidth / $latency) * 0.1
            $v = round4 ($base * $mult)
        }
        "BIOS" {
            try {
                $d = [datetime]::ParseExact($ComponentData.ReleaseDate.Split('.')[0], "yyyyMMdd", $null)
                $i = (Get-Date).Year - $d.Year
                $num = ($ComponentData.SMBIOSBIOSVersion -replace "[^\d]", "") -as [double]
                $base = (100 - $i) * $num / 100
                $base = [math]::Round($base, 4)
            }
            catch {
                $base = -1
            }
            $v = round4 ($base * $mult)
        }
        "RAM" {
            if ($ComponentData.CapacityGB) {
                $baseCapacity = [math]::Round($ComponentData.CapacityGB / 16, 4)
            } else {
                $baseCapacity = 0
            }
            if ($ComponentData.SpeedMHz) {
                $speedFactor = $ComponentData.SpeedMHz / 3200
            } else {
                $speedFactor = 1
            }
            if ($ComponentData.ChannelConfiguration) {
                switch ($ComponentData.ChannelConfiguration) {
                    "Dual" { $channelFactor = 1.2 }
                    "Quad" { $channelFactor = 1.5 }
                    default { $channelFactor = 1 }
                }
            } else {
                $channelFactor = 1
            }
            $baseScore = $baseCapacity * $speedFactor * $channelFactor
            $v = round4 ($baseScore * $mult)
        }
        "Device" {
            if ($ComponentData.Manufacturer -match "Intel") {
                $m = 3
            } elseif ($ComponentData.Manufacturer -match "NVIDIA") {
                $m = 4
            } elseif ($ComponentData.Manufacturer -match "Microsoft") {
                $m = 2
            } elseif ($ComponentData.Manufacturer -match "Realtek") {
                $m = 1
            } else {
                $m = 1
            }
            $baseScore = $m / 4
            $v = round4 ($baseScore * $mult)
        }
        "OS" {
            $v = round4 (1 * $mult)
        }
        "Network" {
            $v = round4 (1 * $mult)
        }
        "Thermal" {
            $v = round4 (1 * $mult)
        }
        "Battery" {
            $v = round4 (1 * $mult)
        }
        default { $v = 0 }
    }
    return round4 ($peso * $v)
}

################################################################################
#         FUNÇÃO Calcular-IOEscritaComponente (Versão Corrigida)                 #
################################################################################
function Calcular-IOEscritaComponente {
    param(
        [string]$Category,
        [PSCustomObject]$ComponentData,
        [double]$FourierFactor = 1.0,
        [int]$MarkovDimension = 1,
        [double]$SuperpositionFactor = 1.0
    )
    $mult = $FourierFactor * $SuperpositionFactor
    switch ($Category) {
        "CPU" {
            if ($ComponentData.L2CacheSize) { $l2 = $ComponentData.L2CacheSize } else { $l2 = 0 }
            if ($ComponentData.L3CacheSize) { $l3 = $ComponentData.L3CacheSize } else { $l3 = 0 }
            $cacheMB = ($l2 + $l3) / 1024
            if ($ComponentData.CurrentClockSpeed) { $clk = $ComponentData.CurrentClockSpeed / 1000 } else { $clk = 1 }
            return round4 ($cacheMB * $clk * $mult)
        }
        "GPU" {
            if ($ComponentData.AdapterRAM) { $vram = [math]::Round($ComponentData.AdapterRAM / 1GB, 2) } else { $vram = 1 }
            if ($ComponentData.CurrentClockSpeed) { $clk = $ComponentData.CurrentClockSpeed / 1000 } else { $clk = 1 }
            return round4 ($vram * $clk * $mult)
        }
        "SSD" {
            if ($ComponentData.WriteSpeed -gt 0) { $baseIO = $ComponentData.WriteSpeed } else { $baseIO = ($ComponentData.Size / 1GB) * 0.5 }
            return round4 ($baseIO * $mult)
        }
        "RAM" {
            if ($ComponentData.CapacityGB) { $base = $ComponentData.CapacityGB } else { $base = 0 }
            if ($ComponentData.SpeedMHz) { $speed = $ComponentData.SpeedMHz } else { $speed = 3200 }
            return round4 ($base * ($speed / 3200) * $mult)
        }
        default { return 0 }
    }
}

################################################################################
#                FUNÇÃO Calcular-RBM (Versão Corrigida)                         #
################################################################################
function Calcular-RBM {
    param(
        [PSCustomObject]$ComponentData,
        [string]$Category
    )
    if ($Category -eq "CPU") {
        $cpuClock = $ComponentData.CurrentClockSpeed / 1000
        $cores = $ComponentData.NumberOfCores
        if ($ComponentData.NumberOfLogicalProcessors -and $ComponentData.NumberOfCores -gt 0) {
            $logicalFactor = $ComponentData.NumberOfLogicalProcessors / $ComponentData.NumberOfCores
        } else {
            $logicalFactor = 1
        }
        return round4 ($cpuClock * $cores * $logicalFactor)
    } elseif ($Category -eq "GPU") {
        if ($ComponentData.AdapterRAM) { $vram = [math]::Round($ComponentData.AdapterRAM / 1GB, 2) } else { $vram = 1 }
        if ($ComponentData.CurrentClockSpeed) { $gpuClock = $ComponentData.CurrentClockSpeed / 1000 } else { $gpuClock = 1 }
        if ($ComponentData.MemoryBandwidth) { $memBW = $ComponentData.MemoryBandwidth } else { $memBW = 50 }
        return round4 ($vram * $gpuClock * ($memBW / 100))
    } else {
        return 0
    }
}

################################################################################
#                FUNÇÃO Normalize-Property (Normalização)                      #
################################################################################
function Normalize-Property {
    param(
        [string]$PropName,
        [PSObject[]]$DataSet
    )
    $minVal = ($DataSet | Measure-Object -Property $PropName -Minimum).Minimum
    $maxVal = ($DataSet | Measure-Object -Property $PropName -Maximum).Maximum
    foreach ($item in $DataSet) {
        if (($maxVal - $minVal) -ne 0) {
            $normVal = round4 (10 * (($item.$PropName - $minVal) / ($maxVal - $minVal)))
        } else {
            $normVal = 0
        }
        $item | Add-Member -NotePropertyName ("{0}_Normalizada" -f $PropName) -NotePropertyValue $normVal -Force
    }
}

################################################################################
#              PESOS DINÂMICOS (Matriz de Hiperparâmetros)                     #
################################################################################
$pesosDinamicos = @{
    "CPU"        = 0.275
    "GPU"        = 0.375
    "SSD"        = 0.2
    "Barramento" = 0.1
    "BIOS"       = 0.05
    "RAM"        = 0.2
    "Device"     = 0.1
    "OS"         = 0.05
    "Network"    = 0.05
    "Thermal"    = 0.05
    "Battery"    = 0.05
}

################################################################################
#       COLETA DE DADOS DE HARDWARE E CRIAÇÃO DO ARRAY                         #
################################################################################
$dadosHardware = @()

# CPU
$dadosHardware += Get-CimInstance Win32_Processor | Select-Object @{Name="Category";Expression={"CPU"}}, Name, NumberOfCores, MaxClockSpeed, CurrentClockSpeed, NumberOfLogicalProcessors, L2CacheSize, L3CacheSize, Architecture, ProcessorId

# GPU
$dadosHardware += Get-CimInstance Win32_VideoController | Select-Object @{Name="Category";Expression={"GPU"}}, Name, AdapterRAM, CurrentClockSpeed, VideoProcessor, DriverVersion, @{Name="MemoryBandwidth";Expression={ if ($_.AdapterRAM) { [math]::Round(($_.AdapterRAM/1GB)*50,2) } else { 50 } }}, @{Name="PCIeVersion";Expression={"4.0"}}, @{Name="ResizableBAR";Expression={"True"}}

# SSD/HDD
$dadosHardware += Get-CimInstance Win32_DiskDrive | Where-Object { $_.MediaType -match "SSD|HDD" } | Select-Object @{Name="Category";Expression={"SSD"}}, Model, Size, @{Name="Interface";Expression={ if ($_.InterfaceType -match "SATA") { "SATA" } else { "NVMe" } }}, @{Name="ReadSpeed";Expression={ 550 }}, @{Name="WriteSpeed";Expression={ 520 }}, @{Name="RandomReadIOPS";Expression={ 100000 }}, @{Name="RandomWriteIOPS";Expression={ 90000 }}, @{Name="TrimSupport";Expression={"True"}}, @{Name="WearLeveling";Expression={"Standard"}}

# Barramento
$dadosHardware += Get-CimInstance Win32_Bus | Select-Object @{Name="Category";Expression={"Barramento"}}, BusType, DeviceID, @{Name="Bandwidth";Expression={ 1000 }}, @{Name="Latency";Expression={ 15 }}

# BIOS
$dadosHardware += Get-CimInstance Win32_BIOS | Select-Object @{Name="Category";Expression={"BIOS"}}, Name, Version, ReleaseDate, SMBIOSBIOSVersion, @{Name="SecureBoot";Expression={"Enabled"}}, @{Name="TPMVersion";Expression={"2.0"}}

# RAM
$dadosHardware += Get-CimInstance Win32_PhysicalMemory | ForEach-Object {
    [PSCustomObject]@{
        Category             = "RAM"
        BankLabel            = $_.BankLabel
        Manufacturer         = $_.Manufacturer
        CapacityGB           = [math]::Round($_.Capacity / 1GB, 2)
        SpeedMHz             = $_.Speed
        MemoryType           = $_.MemoryType
        FormFactor           = $_.FormFactor
        ChannelConfiguration = "Dual"
        ECCSupport           = "False"
        XMPProfile           = "Supported"
    }
}

# Dispositivos – filtra apenas os relevantes
$dadosHardware += Get-WmiObject Win32_PnPEntity | Where-Object { $_.Name -match "Chipset|Audio|Network|GPU|Storage" } | Group-Object -Property Name | ForEach-Object {
    if ($_.Group[0].Name -match "Intel") {
        $w = 3
    } elseif ($_.Group[0].Name -match "NVIDIA") {
        $w = 4
    } elseif ($_.Group[0].Name -match "Microsoft") {
        $w = 2
    } elseif ($_.Group[0].Name -match "Realtek") {
        $w = 1
    } else {
        $w = 1
    }
    [PSCustomObject]@{
        Category             = "Device"
        Name                 = $_.Group[0].Name
        Manufacturer         = $_.Group[0].Manufacturer
        Occurrences          = $_.Count
        DriverVersion        = ""
        WeightedScoreInitial = $_.Count * $w
    }
}

# OS
$os = Get-CimInstance Win32_OperatingSystem
$dadosHardware += [PSCustomObject]@{
    Category      = "OS"
    Name          = "SistemaOperacional"
    KernelVersion = $os.Version
    BuildNumber   = $os.BuildNumber
    Architecture  = $os.OSArchitecture
    PowerPlan     = "Balanceado"
    Uptime        = $os.LastBootUpTime
}

# Network
Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object {
    $dadosHardware += [PSCustomObject]@{
        Category           = "Network"
        Name               = $_.Description
        AdapterName        = $_.Caption
        MACAddress         = $_.MACAddress
        IPv4               = ($_.IPAddress | Where-Object { $_ -as [ipaddress] -and $_.AddressFamily -eq 'InterNetwork' }) -join ","
        IPv6               = ($_.IPAddress | Where-Object { $_ -as [ipaddress] -and $_.AddressFamily -eq 'InterNetworkV6' }) -join ","
        LinkSpeed          = "100Mbps"
        WiFiSignalStrength = "N/A"
        Latency            = "N/A"
        DNS                = ($_.DNSServerSearchOrder -join ",")
        FirewallStatus     = "Enabled"
    }
}

# Battery
Get-CimInstance Win32_Battery | ForEach-Object {
    $dadosHardware += [PSCustomObject]@{
        Category     = "Battery"
        Name         = "Bateria"
        BatteryLevel = $_.EstimatedChargeRemaining
        ChargeCycles = "N/A"
        BatteryHealth= "Good"
        PowerSource  = "Battery"
    }
}

# Thermal
Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" 2>$null | ForEach-Object {
    $temp = ($_.CurrentTemperature / 10) - 273.15
    $dadosHardware += [PSCustomObject]@{
        Category          = "Thermal"
        Name              = "ThermalZone"
        CPUTemperature    = [math]::Round($temp,2)
        GPUTemperature    = "N/A"
        FanSpeed          = "N/A"
        ThermalThrottling = "False"
    }
}

################################################################################
#     LOOP PARA CALCULAR A PONTUAÇÃO, IO, E RBM (Motor de Inferência Sinistro)   #
################################################################################
$fourier   = 1.0
$markovDim = 1
$superpos  = 1.0

foreach ($componente in $dadosHardware) {
    $pontuacao = Calcular-PontuacaoComponente -Category $componente.Category -ComponentData $componente -Pesos $pesosDinamicos -FourierFactor $fourier -MarkovDimension $markovDim -SuperpositionFactor $superpos
    $componente | Add-Member -NotePropertyName "Pontuacao" -NotePropertyValue $pontuacao -Force

    $ioEscrita = Calcular-IOEscritaComponente -Category $componente.Category -ComponentData $componente -FourierFactor $fourier -MarkovDimension $markovDim -SuperpositionFactor $superpos
    $componente | Add-Member -NotePropertyName "IO_Escrita" -NotePropertyValue $ioEscrita -Force

    $rbm = Calcular-RBM -ComponentData $componente -Category $componente.Category
    $componente | Add-Member -NotePropertyName "RBM" -NotePropertyValue $rbm -Force
}

################################################################################
#     CÁLCULO DA PONTUAÇÃO TOTAL E CONTRIBUIÇÃO PERCENTUAL                       #
################################################################################
$pTotal = round4 ([math]::Max(($dadosHardware | Measure-Object -Property Pontuacao -Sum).Sum, 0.0001))
foreach ($componente in $dadosHardware) {
    if ($componente.Category -ne "Hardware Geral") {
        $rawContrib = ($componente.Pontuacao / $pTotal) * 100
        $componente | Add-Member -NotePropertyName "ContribuicaoPercentual" -NotePropertyValue (round4 ([math]::Max($rawContrib, 0.01))) -Force
    }
}

################################################################################
#     CÁLCULO DA PONTUAÇÃO DE SINERGIA (Integração dos Componentes Cabulosa)      #
################################################################################
$busComponents = $dadosHardware | Where-Object { $_.Category -eq "Barramento" -and $_.Pontuacao }
if ($busComponents.Count -gt 0) {
    $mediaBus = ($busComponents | Measure-Object -Property Pontuacao -Average).Average
} else {
    $mediaBus = 1
}
$dependentCategories = @("CPU","GPU","SSD","RAM","Device","OS","Network","Thermal","Battery")
foreach ($componente in $dadosHardware) {
    if ($dependentCategories -contains $componente.Category) {
        $sinergia = round4 ($componente.Pontuacao * $mediaBus)
        $componente | Add-Member -NotePropertyName "Sinergia" -NotePropertyValue $sinergia -Force
    }
}
$sinergiaTotal = ($dadosHardware | Where-Object { $dependentCategories -contains $_.Category } | Measure-Object -Property Sinergia -Sum).Sum
$dadosHardware += [PSCustomObject]@{
    Category  = "Hardware Sinérgico"
    Name      = "Pontuação de Sinergia"
    Pontuacao = round4 $sinergiaTotal
}

################################################################################
#     NORMALIZAÇÃO PARA ESCALA 0-10 (Pontuacao, IO_Escrita, Sinergia, RBM)        #
################################################################################
Normalize-Property -PropName "Pontuacao" -DataSet $dadosHardware
Normalize-Property -PropName "IO_Escrita" -DataSet $dadosHardware
$sinergyItems = $dadosHardware | Where-Object { $_.PSObject.Properties.Name -contains "Sinergia" }
if ($sinergyItems) { Normalize-Property -PropName "Sinergia" -DataSet $sinergyItems }
Normalize-Property -PropName "RBM" -DataSet $dadosHardware

################################################################################
#     CABEÇALHO EXPLICATIVO DA ESCALA (0 a 10) PARA A SAÍDA CSV                #
################################################################################
$explanatoryHeader = @"
# Escala dos Valores (0 a 10):
# Pontuacao_Normalizada: 0 = desempenho mínimo; 10 = desempenho máximo
# IO_Escrita_Normalizada: 0 = capacidade mínima de I/O; 10 = capacidade máxima de I/O
# Sinergia_Normalizada: 0 = baixa integração entre os componentes; 10 = integração perfeita
# RBM_Normalizada: 0 = desempenho ruim em renderização/matrizes; 10 = desempenho excelente
"@

################################################################################
#        MONTAGEM FINAL DO CSV (Seleção de Colunas) e Impressão                 #
################################################################################
$csvData = $dadosHardware | Select-Object Category, Name, Pontuacao, Pontuacao_Normalizada, ContribuicaoPercentual, IO_Escrita, IO_Escrita_Normalizada, Sinergia, Sinergia_Normalizada, RBM, RBM_Normalizada, NumberOfCores, MaxClockSpeed, CurrentClockSpeed, L2CacheSize, L3CacheSize, AdapterRAM, VideoProcessor, MemoryBandwidth, PCIeVersion, ResizableBAR, Size, Interface, ReadSpeed, WriteSpeed, RandomReadIOPS, RandomWriteIOPS, TrimSupport, WearLeveling, BusType, DeviceID, Bandwidth, Latency, Version, ReleaseDate, SMBIOSBIOSVersion, SecureBoot, TPMVersion, BankLabel, Manufacturer, CapacityGB, SpeedMHz, MemoryType, FormFactor, ChannelConfiguration, ECCSupport, XMPProfile, Occurrences, WeightedScoreInitial, KernelVersion, BuildNumber, Architecture, PowerPlan, Uptime, AdapterName, MACAddress, IPv4, IPv6, LinkSpeed, WiFiSignalStrength, DNS, FirewallStatus, BatteryLevel, ChargeCycles, BatteryHealth, PowerSource, CPUTemperature, GPUTemperature, FanSpeed, ThermalThrottling

$csvContent = ($csvData | ConvertTo-Csv -NoTypeInformation | ForEach-Object { $_ -replace '"','' }) -join "`n"
$finalOutput = $explanatoryHeader + "`n" + $csvContent
$finalOutput

```
