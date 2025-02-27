# Scripts

{% code overflow="wrap" %}
````powershell
# ============================================================
# Script de Configuração de Permissões de Pastas
# ============================================================
# Este script configura as permissões de pastas conforme as regras:
#
# Pasta "Compras":
#   - Grupo [GCompras]: Permissão de leitura e gravação (Modify)
#       em todas as pastas e subpastas.
#   - Grupos [GRH] e [GInformatica]: Permissão de somente leitura.
#
# Pasta "RH":
#   - Grupo [GRH]: Permissão de leitura e gravação (Modify)
#       em todas as pastas e subpastas.
#   - Grupo [GCompras]: Permissão de leitura e gravação (Modify).
#   - Grupo [GInformatica]: Sem nenhum acesso (negação total).
#
# Pasta "Informatica":
#   - Grupo [GInformatica]: Permissão de leitura e gravação (Modify)
#       em todas as pastas e subpastas.
#   - Grupos [GRH] e [GCompras]: Sem acesso (negação total).
#
# Atenção: Execute este script com privilégios administrativos.
# ============================================================

# Definindo os caminhos das pastas principais
$comprasPath    = "C:\Compras"
$rhPath         = "C:\RH"
$informaticaPath= "C:\Informatica"

# Função para verificar e criar a pasta caso ela não exista
function Ensure-Folder {
    param(
        [string]$FolderPath
    )
    if (-not (Test-Path -Path $FolderPath)) {
        Write-Host "Pasta '$FolderPath' não encontrada. Criando..."
        New-Item -Path $FolderPath -ItemType Directory | Out-Null
    }
}

# Garantir que as pastas existam
Ensure-Folder -FolderPath $comprasPath
Ensure-Folder -FolderPath $rhPath
Ensure-Folder -FolderPath $informaticaPath

# ------------------------------------------------------------
# Configuração da pasta Compras
# ------------------------------------------------------------
Write-Host "Configurando permissões na pasta 'Compras'..."
# Remove a herança (para evitar que permissões pré-existentes interfiram)
icacls $comprasPath /inheritance:r

# Concede permissão de leitura e gravação (Modify) para o grupo GCompras
icacls $comprasPath /grant "GCompras:(OI)(CI)M"
# Concede permissão de somente leitura para os grupos GRH e GInformatica
icacls $comprasPath /grant "GRH:(OI)(CI)R"
icacls $comprasPath /grant "GInformatica:(OI)(CI)R"

# ------------------------------------------------------------
# Configuração da pasta RH
# ------------------------------------------------------------
Write-Host "Configurando permissões na pasta 'RH'..."
icacls $rhPath /inheritance:r

# Concede permissão de leitura e gravação para os grupos GRH e GCompras
icacls $rhPath /grant "GRH:(OI)(CI)M"
icacls $rhPath /grant "GCompras:(OI)(CI)M"
# Nega acesso total para o grupo GInformatica
icacls $rhPath /deny "GInformatica:(OI)(CI)F"

# ------------------------------------------------------------
# Configuração da pasta Informatica
# ------------------------------------------------------------
Write-Host "Configurando permissões na pasta 'Informatica'..."
icacls $informaticaPath /inheritance:r

# Concede permissão de leitura e gravação para o grupo GInformatica
icacls $informaticaPath /grant "GInformatica:(OI)(CI)M"
# Nega acesso total para os grupos GRH e GCompras
icacls $informaticaPath /deny "GRH:(OI)(CI)F"
icacls $informaticaPath /deny "GCompras:(OI)(CI)F"

Write-Host "Configuração de permissões concluída."

```
````
{% endcode %}
