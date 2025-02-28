# Trecho do Código Documentado

<pre class="language-c"><code class="lang-c">#include &#x3C;stdio.h>         // Inclui a biblioteca padrão de I/O (printf, fopen, etc.). // Linha 1
#include &#x3C;stdlib.h>        // Inclui funções de alocação e controle de memória (malloc, free). // Linha 2
#include &#x3C;string.h>        // Inclui funções para manipulação de strings (memset, memcpy). // Linha 3
#include &#x3C;math.h>          // Inclui funções matemáticas padrão (pow, sqrt, etc.). // Linha 4
#include &#x3C;time.h>          // Inclui funções para manipulação de data/hora (time, localtime). // Linha 5
#include &#x3C;unistd.h>        // Inclui funções de POSIX (sleep, usleep). // Linha 6
#include &#x3C;dirent.h>        // Inclui funções para manipulação de diretórios. // Linha 7

#define BUFFER_SIZE 256    // Define o tamanho máximo do buffer circular. // Linha 8
#define CRITICAL_TEMP 358.15 // Define a temperatura crítica em Kelvin (85°C ≈ 358.15 K). // Linha 9
<strong>#define SAMPLING_INTERVAL 2 // Define o intervalo de coleta de métricas em segundos. // Linha 10
</strong>#define ALPHA 0.15         // Constante ALPHA para cálculo da derivada térmica. // Linha 11
#define BETA  0.05         // Constante BETA para cálculo da derivada térmica. // Linha 12
</code></pre>
