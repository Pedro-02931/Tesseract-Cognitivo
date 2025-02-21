# Montando o Grafo com Splatting (DAG dos Parâmetros)

```powershell
$dirParams = @{
    ItemType = "Directory"
    Force    = $true
}
New-Item @dirParams -Path $BASE_DIR
New-Item @dirParams -Path $PUBLIC_DIR
```

* A técnica de splatting permite criar um dicionário de parâmetros que são aplicados uniformemente aos nós do grafo.&#x20;
* Cada diretório é tratado como um "neurônio" em uma rede neural, recebendo as mesmas instruções sem decisão de inferência, apenas executando sua função.
  * O uso do New-Item for para através do esqueleto, criar duas instancias com um denominador comum para relação tensorial
