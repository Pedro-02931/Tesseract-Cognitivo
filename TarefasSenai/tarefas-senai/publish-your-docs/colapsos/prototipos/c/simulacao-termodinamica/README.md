# Simulação termodinamica

````mermaid
flowchart LR
    subgraph YinYang[Diagrama de Classes e Fluxo Quântico]
        
        QuantumOptimizer["QuantumOptimizer
            - buffer : CircularBuffer
            - snapshot : SystemSnapshot
            + main() : Inicia o monitoramento do sistema, coleta dados de CPU, armazena em buffer circular e gera relatório
            + init_buffer() : Inicializa o buffer circular, definindo os índices e limpando os dados
            + read_cpu_frequency() : Lê a frequência da CPU em MHz, acessando o sistema de arquivos
            + read_cpu_temperature() : Lê a temperatura da CPU em °C, convertendo milésimos de grau
            + read_memory_usage() : Calcula o uso de memória do sistema em porcentagem
            + simulate_power_usage() : Estima o consumo de potência baseado em frequência e temperatura da CPU
            + add_snapshot() : Armazena um snapshot no buffer circular, aplicando política FIFO
            + compute_buffer_average() : Calcula a média das métricas no buffer, agregando dados
            + compute_optimization_score() : Gera o score de otimização da CPU baseado em métricas críticas
            + normalize_cpu_score() : Normaliza o score de CPU para uma escala de 0 a 10
            + get_emotional_state() : Mapeia o score global para um estado emocional
            + compute_energy_consumption() : Calcula o consumo energético usando a relação E = P × t
            + calculate_thermal_derivative() : Estima a variação da temperatura com o tempo para controle térmico"]

        CircularBuffer["CircularBuffer
            + data[BUFFER_SIZE] : SystemSnapshot
            + head : int
            + count : int
            + add_snapshot() : Adiciona um snapshot ao buffer circular
            + compute_buffer_average() : Calcula a média das métricas armazenadas no buffer"]

        SystemSnapshot["SystemSnapshot
            + timestamp : time_t : Momento da coleta
            + cpu_freq : double : Frequência da CPU em MHz
            + cpu_temp : double : Temperatura da CPU em °C
            + mem_usage : double : Uso de memória em %
            + power : double : Potência estimada em W"]

        QuantumOptimizer --> CircularBuffer
        QuantumOptimizer --> SystemSnapshot

        Main["Phi_Main(t) → main()"]
        Init["Phi_Init(t) → init_buffer()"]
        Loop["Phi_Loop(t) – Monitoramento Contínuo"]
        
        ReadCPU["f_CPU(t) → read_cpu_frequency()"]
        ReadTemp["T_CPU(t) → read_cpu_temperature()"]
        ReadMem["U_mem(t) → read_memory_usage()"]
        
        SimPower["P_sim(t) → simulate_power_usage()"]
        AddSnap["Psi_add → add_snapshot()"]
        Buffer["CircularBuffer: Superposição de Estados"]

        Markov["Cadeia de Markov → Predição e Rotação"]
        Fourier["Transformada de Fourier → Análise de Frequência"]

        ComputeAvg["Psi_bar → compute_buffer_average()"]
        OptScore["S_raw → compute_optimization_score()"]
        Normalize["S_norm → normalize_cpu_score()"]
        Emotion["E(S_norm) → get_emotional_state()"]
        
        Energy["E = P × t → compute_energy_consumption()"]
        Thermal["dT/dt → calculate_thermal_derivative()"]
        
        Report["Relatório Final"]

        Main --> Init
        Init --> Loop
        Loop --> ReadCPU
        Loop --> ReadTemp
        Loop --> ReadMem
        ReadCPU --> SimPower
        ReadTemp --> SimPower
        ReadMem --> SimPower
        SimPower --> AddSnap
        AddSnap --> Buffer

        Buffer --> Markov
        Buffer --> ComputeAvg
        ReadCPU --> Fourier
        Fourier --> ComputeAvg

        ComputeAvg --> OptScore
        OptScore --> Normalize
        Normalize --> Emotion
        ComputeAvg --> Energy
        ComputeAvg --> Thermal
        ComputeAvg --> Report
        Energy --> Report
        Thermal --> Report
        Emotion --> Report
    end

```
````

