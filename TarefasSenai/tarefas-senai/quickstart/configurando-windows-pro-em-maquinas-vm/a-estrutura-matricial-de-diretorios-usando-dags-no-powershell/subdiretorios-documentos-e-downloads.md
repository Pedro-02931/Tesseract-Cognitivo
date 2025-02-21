# Subdiretórios Documentos e Downloads

```powershell
$docDir = Join-Path $USER_DIR "Documentos"
$dlDir  = Join-Path $USER_DIR "Downloads"
New-Item @dirParams -Path $docDir
New-Item @dirParams -Path $dlDir
```

* Cada usuário cria duas novas dimensões (Documentos e Downloads), permitindo o acesso otimizado aos recursos do sistema, como se cada subdiretório fosse um tensor acessado por uma operação matricial simples.
* Cada dimensão, que contem regras próprias, tipo formatação, são criadas isoladas e conteinerizadas, podendo ser considerados agentes dentro da simulação.
  * O New-Item seria o equivalente a criação de um agente
