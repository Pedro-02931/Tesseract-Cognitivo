# Definindo os Nós Raízes

```powershell
$BASE_DIR   = Join-Path $env:USERPROFILE "Desktop\Usuarios"
$PUBLIC_DIR = Join-Path $env:USERPROFILE "Desktop\Pasta_Pública"
```

* Esses diretórios principais funcionam como os nós de entrada no DAG do sistema de arquivos.&#x20;
* Eles representam o ponto zero do espaço vetorial, de onde todas as ramificações lógicas (pastas e arquivos) surgirão.
  * Criam variaveis derivadas do variável de ambiente `$env:USERPROFILE`
