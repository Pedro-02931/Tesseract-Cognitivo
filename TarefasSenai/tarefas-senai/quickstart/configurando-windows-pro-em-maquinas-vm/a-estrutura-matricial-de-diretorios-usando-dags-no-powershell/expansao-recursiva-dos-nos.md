# Expansão Recursiva dos Nós

```powershell
foreach ($u in $users) {
    $USER_DIR = Join-Path $BASE_DIR "usuario$u"
    New-Item @dirParams -Path $USER_DIR
}
```

O laço `foreach` cria a expansão recursiva do grafo.&#x20;

Para cada nó (usuário), novos nós filhos (pastas e arquivos) são gerados.&#x20;

Essa iteração é o ciclo sem volta, como a roda de samsara a cada backpropagation.

* Cada numero monta uma classe com as regras pré estabelecidas nos 2 tensores, dado que há n possibilidades dependendo do que quero
