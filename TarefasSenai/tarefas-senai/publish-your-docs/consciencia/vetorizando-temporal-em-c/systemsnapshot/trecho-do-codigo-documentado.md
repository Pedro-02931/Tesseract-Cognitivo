# Trecho do Código Documentado

```c
typedef struct {
    SystemSnapshot data[BUFFER_SIZE]; // Vetor de snapshots.
    int head;       // Índice do snapshot mais recente. 
    int count;      // Número de snapshots armazenados.
} CircularBuffer;   // Fim de CircularBuffer. 
```
