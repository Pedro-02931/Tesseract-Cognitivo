# Gerando Arquivos de Dados

```powershell
"Informações do usuario$u" | Out-File -FilePath (Join-Path $docDir "info.txt") -Encoding UTF8
"Dados do usuario$u"       | Out-File -FilePath (Join-Path $dlDir "dados.txt") -Encoding UTF8
```

* Os arquivos de texto são os nós terminais do DAG.&#x20;
* Eles contêm dados que validam o ciclo do grafo, funcionando como a memória de curto prazo do sistema, onde cada nó carrega consigo uma fatia da realidade (dados do usuário).
  * Respeitando cada dimensão, eled tem contruções proprias virando um colapso de onde, que pode ser renderizado com as features certas, tipo chaves de criptografia
