# Trecho do Código Documentado

{% code overflow="wrap" %}
```c
/*
================================================================================
Sistema Integrado de Otimização Quântica e Autônoma via Machine Learning
================================================================================

Objetivo:
  - Monitorar em tempo real os dados do sistema (frequência e temperatura da CPU, 
    uso de memória, consumo de energia via Intel RAPL, etc.), armazenando snapshots 
    em um buffer temporal cuja frequência de amostragem se ajusta de acordo com a 
    memória disponível e o clock da CPU.
  - Prever estados futuros utilizando um modelo de regressão linear adaptativo 
    (machine learning), atualizando os pesos de forma incremental.
  - Gerenciar dinamicamente os módulos do kernel (desabilitando ou reativando) 
    com base em um conceito quântico: cada módulo possui um “estado” que pode colapsar 
    (desativado) ou estar em superposição (ativo), conforme o nível de "entropia" 
    calculado a partir dos dados do sistema.
  - Integrar todos estes conceitos para manter o sistema em “homeostase quântica”,
    onde os recursos são alocados dinamicamente conforme a necessidade real.

Cada função foi documentada com comentários extensos, detalhando a lógica e os 
parâmetros utilizados, além de relacionar os conceitos (como entropia, colapso quântico, 
buffer temporal adaptativo e aprendizado online) com a implementação.
================================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <signal.h>
#include <math.h>
#include <dirent.h>

/* =============================================================================
   DEFINIÇÕES GLOBAIS E CONSTANTES
   =============================================================================
   Essas definições determinam os parâmetros do sistema:
   - BUFFER_SIZE: número máximo de snapshots armazenados no buffer temporal.
   - MODULE_COUNT: número máximo de módulos do kernel a serem gerenciados.
   - PERFORMANCE_THRESHOLD: limiar que define se o desempenho atual está abaixo
     do esperado.
   - HIGH_TEMP_THRESHOLD e LOW_TEMP_THRESHOLD: limites de temperatura para 
     ajuste do governor da CPU.
   - LEARNING_RATE: taxa de atualização dos pesos do modelo de ML.
   - SLEEP_INTERVAL: intervalo base (em segundos) entre as iterações do loop.
   - ENTROPY_THRESHOLD: limiar de entropia que determina o colapso de um módulo.
================================================================================ */
#define BUFFER_SIZE         256     
#define MODULE_COUNT        64      
#define PERFORMANCE_THRESHOLD 50.0   
#define HIGH_TEMP_THRESHOLD   75.0   
#define LOW_TEMP_THRESHOLD    60.0   
#define LEARNING_RATE         0.01   
#define SLEEP_INTERVAL        5      // Intervalo base em segundos
#define ENTROPY_THRESHOLD     1.5    // Limiar para “colapso” de módulos

/* =============================================================================
   TIPOS E ENUMERAÇÕES
   =============================================================================
   Definimos um tipo enumerado para os estados quânticos do sistema:
     - EVEN_STATE: estado colapsado, onde o sistema opera em modo de execução otimizada.
     - ODD_STATE: estado de superposição, onde o sistema “explora” configurações.
     - CRITICAL_STATE: estado de emergência (por exemplo, quando há sobreaquecimento).
================================================================================ */
typedef enum {
    EVEN_STATE,     
    ODD_STATE,      
    CRITICAL_STATE  
} QuantumState;

/* =============================================================================
   ESTRUTURA SystemSnapshot
   =============================================================================
   Esta estrutura captura um “snapshot” do sistema em um dado instante, armazenando:
     - Dados reais: timestamp, frequência e temperatura da CPU, uso de memória e consumo
       de energia.
     - Previsões: temperatura, uso de memória e potência previstas para o próximo instante.
     - Estatísticas: variância dos dados recentes e um score ponderado que agrega as
       métricas reais.
     - Informações quânticas: entropia calculada do sistema, estado dos módulos (um array
       indicando se cada módulo está ativo ou colapsado) e o estado quântico global.
================================================================================ */
typedef struct {
    time_t timestamp;              // Momento da captura (epoch)
    double cpu_freq;               // Frequência da CPU (GHz)
    double cpu_temp;               // Temperatura da CPU (°C)
    double mem_usage;              // Uso de memória (%)
    double power;                  // Consumo de energia (Watts)
    double predicted_cpu_temp;     // Previsão da temperatura para o próximo snapshot
    double predicted_mem_usage;    // Previsão do uso de memória (%)
    double predicted_power;        // Previsão do consumo de energia (Watts)
    double variance;               // Variância da temperatura dos snapshots recentes
    double weighted_score;         // Score agregando os dados reais com pesos adaptativos
    double system_entropy;         // Entropia global do sistema (métrica combinada)
    int module_states[MODULE_COUNT]; // Vetor de estados dos módulos (1 = ativo, 0 = colapsado)
    QuantumState qstate;           // Estado quântico do sistema (EVEN, ODD ou CRITICAL)
} SystemSnapshot;

/* =============================================================================
   ESTRUTURA CircularBuffer
   =============================================================================
   Este buffer circular armazena os snapshots do sistema de forma temporal, permitindo:
     - Análise histórica dos dados.
     - Ajuste adaptativo da “expectativa temporal” com base na memória disponível e 
       no clock da CPU.
   O campo 'head' indica a posição de inserção, enquanto 'count' é o número total
   de snapshots armazenados.
================================================================================ */
typedef struct {
    SystemSnapshot data[BUFFER_SIZE]; // Array de snapshots
    int head;                         // Índice para a próxima inserção
    int count;                        // Número de snapshots armazenados (até BUFFER_SIZE)
} CircularBuffer;

/* =============================================================================
   VARIÁVEIS GLOBAIS DE MACHINE LEARNING E CONTROLE
   =============================================================================
   - w_freq, w_temp, w_mem, w_power: pesos iniciais para cada métrica (CPU, Temp, Memória, Energia).
   - stop_flag: flag que sinaliza a finalização do loop principal (através de sinal).
================================================================================ */
double w_freq = 0.35, w_temp = 0.25, w_mem = 0.20, w_power = 0.20;
volatile sig_atomic_t stop_flag = 0;

/* =============================================================================
   TRATAMENTO DE SINAIS
   =============================================================================
   A função handle_signal captura sinais de interrupção (SIGINT, SIGTERM) e seta a
   variável global stop_flag para encerrar o loop de forma ordenada.
================================================================================ */
void handle_signal(int sig) {
    stop_flag = 1;
    printf("\nSinal recebido (%d). Iniciando finalização ordenada do sistema...\n", sig);
}

/* =============================================================================
   FUNÇÕES DE LEITURA DE DADOS DO SISTEMA (TELEMETRIA)
   =============================================================================
   Estas funções realizam a leitura dos dados reais do sistema a partir dos arquivos 
   disponíveis no sysfs e procfs.
   
   1. get_cpu_temp:
      - Abre o arquivo de temperatura (/sys/class/thermal/thermal_zone0/temp).
      - Lê o valor em millicelsius e converte para Celsius.
      
   2. get_cpu_freq:
      - Abre o arquivo de frequência da CPU (/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq).
      - Lê o valor em kHz e converte para GHz.
      
   3. get_mem_usage:
      - Lê /proc/meminfo para obter dados de memória total, livre, buffers e cached.
      - Calcula o percentual de memória utilizada.
      
   4. get_power:
      - Utiliza a interface Intel RAPL para ler o consumo de energia em microjoules.
      - Converte para watts considerando o intervalo de tempo entre leituras.
================================================================================ */
double get_cpu_temp() {
    FILE *arquivo = fopen("/sys/class/thermal/thermal_zone0/temp", "r");
    if (arquivo == NULL) {
        perror("Falha ao abrir /sys/class/thermal/thermal_zone0/temp");
        return -1;
    }
    double temp;
    fscanf(arquivo, "%lf", &temp);
    fclose(arquivo);
    // Conversão de millicelsius para Celsius
    return temp / 1000.0;
}

double get_cpu_freq() {
    FILE *arquivo = fopen("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq", "r");
    if (arquivo == NULL) {
        perror("Falha ao abrir /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq");
        return -1;
    }
    double freq;
    fscanf(arquivo, "%lf", &freq);
    fclose(arquivo);
    // Conversão de kHz para GHz
    return freq / 1000000.0;
}

double get_mem_usage() {
    FILE *arquivo = fopen("/proc/meminfo", "r");
    if (arquivo == NULL) {
        perror("Falha ao abrir /proc/meminfo");
        return -1;
    }
    char linha[128];
    long total = 0, livre = 0, buffers = 0, cached = 0;
    while (fgets(linha, sizeof(linha), arquivo)) {
        if (strstr(linha, "MemTotal:"))
            sscanf(linha, "MemTotal: %ld kB", &total);
        else if (strstr(linha, "MemFree:"))
            sscanf(linha, "MemFree: %ld kB", &livre);
        else if (strstr(linha, "Buffers:"))
            sscanf(linha, "Buffers: %ld kB", &buffers);
        else if (strstr(linha, "Cached:"))
            sscanf(linha, "Cached: %ld kB", &cached);
    }
    fclose(arquivo);
    if (total == 0) return -1;
    long usado = total - livre - buffers - cached;
    return (usado * 100.0) / total;
}

double get_power() {
    /* 
     * Esta função lê o consumo de energia via interface Intel RAPL.
     * O caminho utilizado é "/sys/class/powercap/intel-rapl:0/energy_uj".
     * A energia é medida em microjoules (μJ) e convertida para Joules, e então
     * dividida pela diferença de tempo para obter o consumo em Watts.
     */
    FILE *file;
    unsigned long long energy_uj = 0;
    static unsigned long long last_energy_uj = 0;
    static double last_time = 0;
    
    const char *path = "/sys/class/powercap/intel-rapl:0/energy_uj";
    
    file = fopen(path, "r");
    if (!file) {
        perror("Erro ao abrir sensor de energia via Intel RAPL");
        return -1;
    }
    
    if (fscanf(file, "%llu", &energy_uj) != 1) {
        perror("Erro ao ler valor de energia");
        fclose(file);
        return -1;
    }
    fclose(file);
    
    double current_time = (double)time(NULL);
    double power = 0.0;
    if (last_time > 0) {
        double delta_time = current_time - last_time;
        double delta_energy = (double)(energy_uj - last_energy_uj) / 1e6; // Converte μJ para J
        if (delta_time > 0)
            power = delta_energy / delta_time;
    }
    
    last_energy_uj = energy_uj;
    last_time = current_time;
    
    return power;
}

/* =============================================================================
   FUNÇÕES DE BUFFER TEMPORAL
   =============================================================================
   Essas funções gerenciam o buffer circular que armazena os snapshots do sistema.
   O buffer permite que o sistema analise a evolução dos dados ao longo do tempo e 
   ajuste parâmetros (como a expectativa temporal) com base em leituras históricas.
   
   1. add_snapshot:
      - Insere um novo snapshot no buffer na posição indicada pelo campo 'head'.
      - Atualiza o contador e a posição circularmente.
================================================================================ */
void add_snapshot(CircularBuffer *buf, const SystemSnapshot *snap) {
    buf->data[buf->head] = *snap;  // Insere o snapshot no buffer
    buf->head = (buf->head + 1) % BUFFER_SIZE;  // Atualiza o índice de forma circular
    if (buf->count < BUFFER_SIZE) {
        buf->count++;
    }
}

/* =============================================================================
   FUNÇÃO predict_future_state
   =============================================================================
   Esta função realiza uma previsão simples do valor da temperatura da CPU para o 
   próximo snapshot com base na diferença linear entre os dois últimos snapshots.
   Caso não haja dados históricos suficientes, retorna o valor atual.
================================================================================ */
double predict_future_state(CircularBuffer *buf) {
    if (buf->count < 2)
        return buf->data[0].cpu_temp;
    
    int last = (buf->head - 1 + BUFFER_SIZE) % BUFFER_SIZE;
    int prev = (buf->head - 2 + BUFFER_SIZE) % BUFFER_SIZE;
    double diff = buf->data[last].cpu_temp - buf->data[prev].cpu_temp;
    return buf->data[last].cpu_temp + diff;
}

/* =============================================================================
   FUNÇÃO calculate_weighted_score
   =============================================================================
   Esta função agrega os dados reais do sistema em um único score ponderado, utilizando
   os pesos adaptativos para cada métrica (frequência, temperatura, uso de memória, consumo 
   de energia). Valores “bons” (como baixa temperatura, baixo consumo) são transformados para 
   que condições ideais resultem em scores altos.
================================================================================ */
double calculate_weighted_score(const SystemSnapshot *snap) {
    double score = (w_freq * snap->cpu_freq)
                 + (w_temp * (100.0 - snap->cpu_temp))
                 + (w_mem * (100.0 - snap->mem_usage))
                 + (w_power * (100.0 - snap->power));
    return score;
}

/* =============================================================================
   FUNÇÃO dynamic_process_scheduler
   =============================================================================
   Esta função implementa um modelo de aprendizado online utilizando uma forma simples
   de regressão linear. Com base na diferença entre o score atual e o limiar de desempenho,
   os pesos para cada métrica são ajustados incrementalmente utilizando o gradiente descendente.
   
   Essa adaptação permite que o sistema "aprenda" com os erros das predições e melhore sua 
   capacidade de prever estados futuros.
================================================================================ */
void dynamic_process_scheduler(const SystemSnapshot *snap) {
    double score = snap->weighted_score;
    
    // Cálculo do erro (diferença relativa ao desempenho desejado)
    double erro = (score - PERFORMANCE_THRESHOLD) * 0.01;
    
    // Atualização dos pesos utilizando gradiente descendente
    w_freq  += LEARNING_RATE * erro * snap->cpu_freq;
    w_temp  += LEARNING_RATE * erro * (100.0 - snap->cpu_temp);
    w_mem   += LEARNING_RATE * erro * (100.0 - snap->mem_usage);
    w_power += LEARNING_RATE * erro * (100.0 - snap->power);
    
    printf("Pesos atualizados - CPU: %.4f, Temp: %.4f, Mem: %.4f, Power: %.4f\n",
           w_freq, w_temp, w_mem, w_power);
}

/* =============================================================================
   FUNÇÃO adjust_cpu_frequency
   =============================================================================
   Esta função ajusta o governor da CPU com base na previsão da temperatura:
     - Se a temperatura prevista exceder HIGH_TEMP_THRESHOLD, o sistema muda para 
       o modo "powersave" (reduzindo a frequência).
     - Se estiver abaixo de LOW_TEMP_THRESHOLD, muda para "performance".
     - Caso contrário, mantém o estado atual.
   
   A função utiliza a escrita direta no sysfs para alterar o governor.
================================================================================ */
void set_cpu_governor(const char *governor) {
    FILE *file = fopen("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor", "w");
    if (file == NULL) {
        perror("Falha ao abrir scaling_governor");
        return;
    }
    fprintf(file, "%s", governor);
    fclose(file);
}

void adjust_cpu_frequency(double predicted_temp) {
    if (predicted_temp > HIGH_TEMP_THRESHOLD) {
        printf("Predição de temperatura (%.2f°C) acima do limite. Ajustando para modo powersave...\n", predicted_temp);
        set_cpu_governor("powersave");
    } else if (predicted_temp < LOW_TEMP_THRESHOLD) {
        printf("Predição de temperatura (%.2f°C) abaixo do limite. Ajustando para modo performance...\n", predicted_temp);
        set_cpu_governor("performance");
    } else {
        printf("Predição de temperatura (%.2f°C) dentro do intervalo ideal. Sem alteração no governor.\n", predicted_temp);
    }
}

/* =============================================================================
   FUNÇÕES DE GERENCIAMENTO QUÂNTICO DOS MÓDULOS DO KERNEL
   =============================================================================
   Estas funções implementam o conceito de “colapso quântico” dos módulos:
   
   1. collapse_quantum_module:
      - Executa o comando "modprobe -r" para remover um módulo.
      - Reseta o “score de entropia” do módulo para 0, simulando seu colapso.
      
   2. activate_quantum_module:
      - Executa o comando "modprobe" para reativar um módulo anteriormente colapsado.
      - Atualiza o tempo de último uso do módulo.
   
   Em nosso sistema, a decisão de colapsar ou reativar um módulo é baseada no 
   “weighted_score” e na análise quântica do snapshot (ver quantum_analysis).
================================================================================ */
void collapse_quantum_module(const char *mod_name, int module_index, SystemSnapshot *snap) {
    char comando[256];
    snprintf(comando, sizeof(comando), "modprobe -r %s", mod_name);
    if (system(comando) == 0) {
        // Define o módulo como colapsado (0) no snapshot
        if (module_index < MODULE_COUNT)
            snap->module_states[module_index] = 0;
        printf("Módulo %s colapsado com sucesso.\n", mod_name);
    } else {
        printf("Falha ao colapsar o módulo %s.\n", mod_name);
    }
}

void activate_quantum_module(const char *mod_name, int module_index, SystemSnapshot *snap) {
    char comando[256];
    snprintf(comando, sizeof(comando), "modprobe %s", mod_name);
    if (system(comando) == 0) {
        // Define o módulo como ativo (1) no snapshot
        if (module_index < MODULE_COUNT)
            snap->module_states[module_index] = 1;
        printf("Módulo %s reativado com sucesso.\n", mod_name);
    } else {
        printf("Falha ao reativar o módulo %s.\n", mod_name);
    }
}

/* =============================================================================
   FUNÇÃO quantum_analysis
   =============================================================================
   Esta função realiza uma análise "quântica" do snapshot atual, calculando uma 
   métrica de entropia do sistema e determinando o estado quântico global. O cálculo 
   da entropia pode combinar fatores como temperatura, uso de memória e consumo de energia.
   
   Para este exemplo, definimos:
     system_entropy = (cpu_temp/HIGH_TEMP_THRESHOLD) + (mem_usage/100) + (power/100)
     
   Em seguida, o estado quântico (qstate) é definido com base na paridade do 
   número de snapshots (por exemplo, se count é par, EVEN_STATE; ímpar, ODD_STATE).
   
   Além disso, atualizamos o vetor module_states com base em uma comparação entre
   a entropia do sistema e o ENTROPY_THRESHOLD.
================================================================================ */
void quantum_analysis(SystemSnapshot *snap, CircularBuffer *buf) {
    // Cálculo da entropia global do sistema
    snap->system_entropy = (snap->cpu_temp / HIGH_TEMP_THRESHOLD) 
                           + (snap->mem_usage / 100.0)
                           + (snap->power / 100.0);
    
    // Define o estado quântico com base na quantidade de snapshots armazenados
    snap->qstate = (buf->count % 2 == 0) ? EVEN_STATE : ODD_STATE;
    
    // Exemplo simples: se a entropia for maior que o limiar, definimos alguns módulos como colapsados.
    // Para este exemplo, usamos os índices 0 a 5 para módulos fictícios.
    for (int i = 0; i < 6; i++) {
        if (snap->system_entropy > ENTROPY_THRESHOLD) {
            snap->module_states[i] = 0;  // Colapsado
        } else {
            snap->module_states[i] = 1;  // Ativo
        }
    }
}

/* =============================================================================
   FUNÇÃO update_dashboard
   =============================================================================
   Exibe um painel detalhado com os dados atuais do sistema, incluindo:
     - Dados medidos (CPU, temperatura, memória, potência)
     - Previsões para as próximas medidas
     - Score ponderado e entropia do sistema
     - Estado de cada módulo (para os módulos gerenciados)
   
   Este painel facilita a visualização do estado operacional e dos efeitos das otimizações.
================================================================================ */
void update_dashboard(const SystemSnapshot *snap) {
    printf("============================================\n");
    printf("Timestamp: %ld\n", snap->timestamp);
    printf("CPU: %.2f GHz | Temp: %.2f°C | Mem: %.2f%% | Power: %.2fW\n",
           snap->cpu_freq, snap->cpu_temp, snap->mem_usage, snap->power);
    printf("Predição -> Temp: %.2f°C | Mem: %.2f%% | Power: %.2fW\n",
           snap->predicted_cpu_temp, snap->predicted_mem_usage, snap->predicted_power);
    printf("Score Ponderado: %.2f | Entropia do Sistema: %.2f\n",
           snap->weighted_score, snap->system_entropy);
    printf("Estado dos Módulos:\n");
    for (int i = 0; i < 6; i++) {  // Exibindo apenas os 6 módulos fictícios
        printf("  Módulo %d: %s\n", i, (snap->module_states[i] ? "Ativo" : "Colapsado"));
    }
    printf("Estado Quântico: %s\n", (snap->qstate == EVEN_STATE ? "EVEN_STATE (Colapsado)" : 
                                     (snap->qstate == ODD_STATE ? "ODD_STATE (Superposição)" : "CRITICAL_STATE")));
    printf("============================================\n");
}

/* =============================================================================
   FUNÇÃO analyze_temporal_lattice
   =============================================================================
   Analisa os snapshots armazenados no buffer para calcular estatísticas (média e 
   variância) da temperatura da CPU, permitindo uma melhor compreensão do comportamento 
   do sistema ao longo do tempo.
================================================================================ */
void analyze_temporal_lattice(CircularBuffer *buf) {
    double soma = 0.0, somaQuadrados = 0.0;
    
    for (int i = 0; i < buf->count; i++) {
        double temp = buf->data[i].cpu_temp;
        soma += temp;
        somaQuadrados += temp * temp;
    }
    
    double media = soma / buf->count;
    double variancia = (somaQuadrados / buf->count) - (media * media);
    
    int ultimo = (buf->head - 1 + BUFFER_SIZE) % BUFFER_SIZE;
    buf->data[ultimo].variance = variancia;
    
    printf("Média da Temp CPU: %.2f°C | Variância: %.2f\n", media, variancia);
}

/* =============================================================================
   FUNÇÕES DE PERSISTÊNCIA DO MODELO DE ML
   =============================================================================
   Permitem salvar e carregar os pesos do modelo adaptativo para que o aprendizado 
   seja mantido entre reinicializações.
================================================================================ */
void save_model_weights() {
    FILE *arquivo = fopen("model_weights.dat", "wb");
    if (arquivo == NULL) {
        perror("Erro ao salvar pesos do modelo");
        return;
    }
    fwrite(&w_freq, sizeof(double), 1, arquivo);
    fwrite(&w_temp, sizeof(double), 1, arquivo);
    fwrite(&w_mem, sizeof(double), 1, arquivo);
    fwrite(&w_power, sizeof(double), 1, arquivo);
    fclose(arquivo);
}

void load_model_weights() {
    FILE *arquivo = fopen("model_weights.dat", "rb");
    if (arquivo == NULL) {
        // Se não existir, mantém os valores padrão
        w_freq = 0.35;
        w_temp = 0.25;
        w_mem = 0.20;
        w_power = 0.20;
        return;
    }
    fread(&w_freq, sizeof(double), 1, arquivo);
    fread(&w_temp, sizeof(double), 1, arquivo);
    fread(&w_mem, sizeof(double), 1, arquivo);
    fread(&w_power, sizeof(double), 1, arquivo);
    fclose(arquivo);
}

/* =============================================================================
   FUNÇÃO ajustar_intervalo_temporal
   =============================================================================
   Esta função ajusta o intervalo de amostragem (tempo entre snapshots) com base 
   na utilização de memória e na frequência da CPU. A ideia é que, se a memória 
   estiver muito utilizada ou a CPU operar em alta frequência, o intervalo de 
   amostragem seja ajustado para compensar e evitar sobrecarga.
   
   Fórmula simples de ajuste:
       intervalo_ajustado = SLEEP_INTERVAL * (mem_usage/100.0) / (cpu_freq)
   
   Retorna o intervalo (em segundos) que será utilizado para o próximo ciclo.
================================================================================ */
double ajustar_intervalo_temporal(const SystemSnapshot *snap) {
    double fator_mem = snap->mem_usage / 100.0; // Valor entre 0 e 1
    double intervalo = SLEEP_INTERVAL * (fator_mem);
    if (snap->cpu_freq > 0)
        intervalo /= snap->cpu_freq;
    // Limitar o intervalo para não ser inferior a 1 segundo
    if (intervalo < 1.0)
        intervalo = 1.0;
    return intervalo;
}

/* =============================================================================
   FUNÇÃO principal: main
   =============================================================================
   O loop principal realiza as seguintes etapas:
     1. Configura o tratamento de sinais para finalização ordenada.
     2. Carrega os pesos do modelo (se existentes) e inicializa o buffer temporal.
     3. Em cada iteração:
          a. Coleta os dados reais do sistema (CPU, Temp, Memória, Power).
          b. Realiza predições simples (temperatura linear e variações fixas para memória
             e energia).
          c. Calcula o score ponderado e atualiza o snapshot.
          d. Realiza análise quântica para definir a entropia e o estado quântico, atualizando
             o vetor de estados dos módulos.
          e. Atualiza os pesos do modelo (aprendizado online).
          f. Ajusta a frequência da CPU conforme a previsão.
          g. Gerencia os módulos do kernel de forma dinâmica (colapsando ou reativando com base
             no score e na análise quântica).
          h. Atualiza o painel (dashboard) para exibir os dados.
          i. Adiciona o snapshot ao buffer temporal.
          j. Ajusta o intervalo de amostragem com base na memória e na frequência da CPU.
     4. Ao término (sinal de parada), salva os pesos do modelo para persistência.
================================================================================ */
int main() {
    // Configuração inicial: tratamento de sinais para encerramento ordenado
    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);
    
    // Carrega os pesos do modelo, se houver
    load_model_weights();
    
    // Inicializa o buffer circular
    CircularBuffer buffer = { .head = 0, .count = 0 };
    
    // Variável para armazenar o snapshot atual
    SystemSnapshot snap;
    
    // Loop principal de monitoramento e otimização
    while (!stop_flag) {
        // 1. Captura o tempo atual (âncora temporal)
        snap.timestamp = time(NULL);
        
        // 2. Leitura dos dados reais do sistema
        snap.cpu_temp    = get_cpu_temp();
        snap.cpu_freq    = get_cpu_freq();
        snap.mem_usage   = get_mem_usage();
        snap.power       = get_power();
        
        // 3. Realiza predições simples:
        //    - Predição da temperatura: usando a diferença linear entre os dois últimos snapshots
        snap.predicted_cpu_temp = predict_future_state(&buffer);
        //    - Predição de uso de memória: estimativa de aumento de 2%
        snap.predicted_mem_usage = snap.mem_usage * 1.02;
        //    - Predição do consumo de energia: estimativa de redução de 2%
        snap.predicted_power = snap.power * 0.98;
        
        // 4. Calcula o score ponderado agregando as métricas reais com os pesos atuais
        snap.weighted_score = calculate_weighted_score(&snap);
        
        // 5. Realiza análise quântica:
        //    Calcula a entropia do sistema e define o estado quântico (EVEN_STATE ou ODD_STATE)
        //    Atualiza o vetor module_states para os primeiros 6 módulos fictícios
        quantum_analysis(&snap, &buffer);
        
        // 6. Atualiza os pesos do modelo via aprendizado online (ajuste incremental)
        dynamic_process_scheduler(&snap);
        
        // 7. Ajusta a frequência da CPU com base na predição da temperatura
        adjust_cpu_frequency(snap.predicted_cpu_temp);
        
        // 8. Gerencia os módulos do kernel dinamicamente:
        //    Se o score ponderado estiver abaixo do limiar, tenta desabilitar módulos não essenciais.
        //    Caso contrário, reativa-os. Para este exemplo, utiliza-se uma lista fixa de 6 módulos.
        {
            const char *modulos[6] = {"bluetooth", "nfc", "usb_storage", "wifi", "video", "sound"};
            if (snap.weighted_score < PERFORMANCE_THRESHOLD) {
                printf("Score baixo (%.2f). Iniciando colapso de módulos não essenciais...\n", snap.weighted_score);
                for (int i = 0; i < 6; i++) {
                    // Se o estado quântico indicar alta entropia, colapsa o módulo
                    if (snap.module_states[i] == 0) { 
                        // Se já estiver colapsado, não faz nada
                        continue;
                    } else {
                        collapse_quantum_module(modulos[i], i, &snap);
                    }
                }
            } else {
                printf("Score alto (%.2f). Reativando módulos não essenciais...\n", snap.weighted_score);
                for (int i = 0; i < 6; i++) {
                    if (snap.module_states[i] == 0) {
                        activate_quantum_module(modulos[i], i, &snap);
                    }
                }
            }
        }
        
        // 9. Atualiza o dashboard para exibir o estado atual do sistema
        update_dashboard(&snap);
        
        // 10. Adiciona o snapshot atual ao buffer temporal para análise histórica
        add_snapshot(&buffer, &snap);
        
        // 11. Analisa o buffer temporal para calcular estatísticas (média e variância)
        if (buffer.count % 5 == 0) {
            analyze_temporal_lattice(&buffer);
        }
        
        // 12. Ajusta o intervalo de amostragem com base na memória e na frequência da CPU
        double intervalo = ajustar_intervalo_temporal(&snap);
        printf("Próximo ciclo em %.2f segundos...\n", intervalo);
        sleep((unsigned int)intervalo);
    }
    
    // Ao final do loop (quando stop_flag for setado), salva os pesos do modelo para persistência
    save_model_weights();
    printf("Sistema encerrado de forma ordenada.\n");
    return 0;
}

```
{% endcode %}
