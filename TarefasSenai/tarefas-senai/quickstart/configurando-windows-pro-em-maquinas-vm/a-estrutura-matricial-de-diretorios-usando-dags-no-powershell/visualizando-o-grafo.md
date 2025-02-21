# Visualizando o Grafo

```powershell
Write-Host "Estrutura de diretórios criada com sucesso: " -ForegroundColor Green
cmd /c "tree `"$BASE_DIR`" /F | more"
```

* A função `tree` mostra a topologia final do grafo, projetando matriz do sistema de arquivos.&#x20;
* Essa visualização permite contemplar o colapso do estado do nosso DAG, trazendo uma perspectiva a nossas próprias heurisitcas.
