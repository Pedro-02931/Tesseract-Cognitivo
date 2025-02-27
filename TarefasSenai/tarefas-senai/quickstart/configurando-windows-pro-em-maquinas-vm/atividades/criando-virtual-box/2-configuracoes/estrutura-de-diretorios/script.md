# Script

```powershell
function Criar-Pastas {
    # Define a estrutura de pastas usando uma Hashtable:
    # As chaves são as pastas principais e os valores, se houver, são arrays com as subpastas.
    $estrutura = @{
        "Compras"     = @("Internas", "Externas")
        "RH"          = @()         # Sem subpastas, array vazio
        "Informatica" = @("softwares", "documentos")
    }

    # Itera sobre cada chave (pasta principal) na estrutura
    foreach ($pasta in $estrutura.Keys) {
        $caminhoPrincipal = "C:\$pasta"
        if (-not (Test-Path $caminhoPrincipal)) {
            New-Item -Path $caminhoPrincipal -ItemType Directory -Force | Out-Null
            Write-Host "Criada pasta: $caminhoPrincipal"
        } else {
            Write-Host "Pasta já existe: $caminhoPrincipal"
        }
        
        # Se houver subpastas (o valor não for nulo ou vazio), cria cada uma delas
        $subPastas = $estrutura[$pasta]
        if ($subPastas.Count -gt 0) {
            foreach ($sub in $subPastas) {
                $caminhoSub = Join-Path -Path $caminhoPrincipal -ChildPath $sub
                if (-not (Test-Path $caminhoSub)) {
                    New-Item -Path $caminhoSub -ItemType Directory -Force | Out-Null
                    Write-Host "Criada subpasta: $caminhoSub"
                } else {
                    Write-Host "Subpasta já existe: $caminhoSub"
                }
            }
        }
    }
}

# Executa a função
Criar-Pastas

```
