# Trecho do Código Cocumentado

```c
#include <stdio.h>         // Inclui a biblioteca padrão de I/O (printf, fopen, etc.). // Linha 1
#include <stdlib.h>        // Inclui funções de alocação e controle de memória (malloc, free). // Linha 2
#include <string.h>        // Inclui funções para manipulação de strings (memset, memcpy). // Linha 3
#include <math.h>          // Inclui funções matemáticas padrão (pow, sqrt, etc.). // Linha 4
#include <time.h>          // Inclui funções para manipulação de data/hora (time, localtime). // Linha 5
#include <unistd.h>        // Inclui funções de POSIX (sleep, usleep). // Linha 6
#include <dirent.h>        // Inclui funções para manipulação de diretórios. // Linha 7

#define BUFFER_SIZE 256    // Define o tamanho máximo do buffer circular. // Linha 8
#define CRITICAL_TEMP 358.15 // Define a temperatura crítica em Kelvin (85°C ≈ 358.15 K). // Linha 9
#define SAMPLING_INTERVAL 2 // Define o intervalo de coleta de métricas em segundos. // Linha 10
#define ALPHA 0.15         // Constante ALPHA para cálculo da derivada térmica. // Linha 11
#define BETA  0.05         // Constante BETA para cálculo da derivada térmica. // Linha 12
```
