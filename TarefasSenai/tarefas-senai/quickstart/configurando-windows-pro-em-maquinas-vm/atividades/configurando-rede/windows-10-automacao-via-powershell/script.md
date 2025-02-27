# Script

{% code overflow="wrap" %}
```powershell
<# 
    Function: New-CustomUsers
    Description: Cria os usuários locais necessários para o ambiente, caso ainda não existam.
    Usuários a serem criados:
        - Terra (Admin)
        - Vênus (Comum)
        - Marte (Comum)
        - Júpiter (Restrito)
        - Saturno (Restrito)
        - Netuno (Convidado)
        - Urano (Convidado)
    Cada usuário é criado com uma senha padrão e configurado para que sua senha nunca expire,
    garantindo que os vértices da rede (usuários) estejam prontos para interagir com os compartilhamentos.
#>
function New-CustomUsers {
    $users = @(
        @{ Name = "Terra";   FullName = "Admin Terra";     Password = "P@ssw0rd" },
        @{ Name = "Vênus";   FullName = "Comum Vênus";     Password = "P@ssw0rd" },
        @{ Name = "Marte";   FullName = "Comum Marte";     Password = "P@ssw0rd" },
        @{ Name = "Júpiter"; FullName = "Restrito Júpiter";  Password = "P@ssw0rd" },
        @{ Name = "Saturno"; FullName = "Restrito Saturno";  Password = "P@ssw0rd" },
        @{ Name = "Netuno";  FullName = "Convidado Netuno"; Password = "P@ssw0rd" },
        @{ Name = "Urano";   FullName = "Convidado Urano";  Password = "P@ssw0rd" }
    )

    foreach ($user in $users) {
        if (-not (Get-LocalUser -Name $user.Name -ErrorAction SilentlyContinue)) {
            # Cria o usuário com a senha fornecida
            New-LocalUser -Name $user.Name -FullName $user.FullName `
                -Password (ConvertTo-SecureString $user.Password -AsPlainText -Force)
            # Configura o usuário para que a senha nunca expire
            Set-LocalUser -Name $user.Name -PasswordNeverExpires $true
            Write-Host "Usuário criado: $($user.Name)"
        } else {
            Write-Host "Usuário já existe: $($user.Name)"
        }
    }
}

<# 
    Function: New-CustomFolders
    Description: Cria as pastas necessárias no diretório C:\, caso elas não existam.
    Estas pastas representam os vértices da nossa rede de permissões.
    Pastas criadas:
        - C:\publica
        - C:\trabalho
        - C:\documentos
        - C:\confidencial
        - C:\convidados
#>
function New-CustomFolders {
    if (-not (Test-Path -Path "C:\publica")) {
        New-Item -Path "C:\publica" -ItemType Directory
    }
    if (-not (Test-Path -Path "C:\trabalho")) {
        New-Item -Path "C:\trabalho" -ItemType Directory
    }
    if (-not (Test-Path -Path "C:\documentos")) {
        New-Item -Path "C:\documentos" -ItemType Directory
    }
    if (-not (Test-Path -Path "C:\confidencial")) {
        New-Item -Path "C:\confidencial" -ItemType Directory
    }
    if (-not (Test-Path -Path "C:\convidados")) {
        New-Item -Path "C:\convidados" -ItemType Directory
    }
}

<# 
    Function: Set-CustomNTFSPermissions
    Description: Configura as permissões NTFS para cada pasta usando o comando icacls.
    Cada conjunto de permissões é aplicado conforme as regras estabelecidas:
    
    - Pasta "publica":
        • Terra (Admin): Controle Total (F)
        • Vênus e Marte (Comum): Leitura e Gravação (M)
        • Júpiter e Saturno (Restrito): Leitura (R)
        • Netuno e Urano (Convidado): Leitura (R)
    
    - Pasta "trabalho":
        • Terra (Admin): Controle Total (F)
        • Vênus e Marte (Comum): Leitura e Gravação (M)
    
    - Pasta "documentos":
        • Vênus e Marte (Comum): Leitura e Gravação (M)
    
    - Pasta "confidencial":
        • Terra (Admin): Controle Total (F)
    
    - Pasta "convidados":
        • Terra (Admin): Controle Total (F)
        • Netuno e Urano (Convidado): Leitura (R)
#>
function Set-CustomNTFSPermissions {
    icacls "C:\publica" /grant:r "Terra:(OI)(CI)F"
    icacls "C:\publica" /grant "Vênus:(OI)(CI)M" /grant "Marte:(OI)(CI)M"
    icacls "C:\publica" /grant "Júpiter:(OI)(CI)R" /grant "Saturno:(OI)(CI)R"
    icacls "C:\publica" /grant "Netuno:(OI)(CI)R" /grant "Urano:(OI)(CI)R"

    icacls "C:\trabalho" /grant:r "Terra:(OI)(CI)F"
    icacls "C:\trabalho" /grant "Vênus:(OI)(CI)M" /grant "Marte:(OI)(CI)M"

    icacls "C:\documentos" /grant "Vênus:(OI)(CI)M" /grant "Marte:(OI)(CI)M"

    icacls "C:\confidencial" /grant:r "Terra:(OI)(CI)F"

    icacls "C:\convidados" /grant:r "Terra:(OI)(CI)F"
    icacls "C:\convidados" /grant "Netuno:(OI)(CI)R" /grant "Urano:(OI)(CI)R"
}

<# 
    Function: New-CustomSMBShares
    Description: Cria e configura os compartilhamentos SMB para acesso remoto.
    Cada compartilhamento é definido com um nome, caminho e permissões de acesso (Full, Change, Read),
    conforme as regras estabelecidas:
    
    - Compartilhamento "publica":
        • FullAccess: Terra
        • ChangeAccess: Vênus, Marte
        • ReadAccess: Júpiter, Saturno, Netuno, Urano
    
    - Compartilhamento "trabalho":
        • FullAccess: Terra
        • ChangeAccess: Vênus, Marte
    
    - Compartilhamento "documentos":
        • ChangeAccess: Vênus, Marte
    
    - Compartilhamento "confidencial":
        • FullAccess: Terra
    
    - Compartilhamento "convidados":
        • FullAccess: Terra
        • ReadAccess: Netuno, Urano
    
    Caso o compartilhamento já exista, ele é removido antes de ser recriado.
#>
function New-CustomSMBShares {
    $shares = @(
        @{ Name = "publica";     Path = "C:\publica";     FullAccess = @("Terra");       ChangeAccess = @("Vênus","Marte");      ReadAccess = @("Júpiter","Saturno","Netuno","Urano") },
        @{ Name = "trabalho";    Path = "C:\trabalho";    FullAccess = @("Terra");       ChangeAccess = @("Vênus","Marte");      ReadAccess = @() },
        @{ Name = "documentos";  Path = "C:\documentos";  FullAccess = @();             ChangeAccess = @("Vênus","Marte");      ReadAccess = @() },
        @{ Name = "confidencial";Path = "C:\confidencial";FullAccess = @("Terra");       ChangeAccess = @();                  ReadAccess = @() },
        @{ Name = "convidados";  Path = "C:\convidados";  FullAccess = @("Terra");       ChangeAccess = @();                  ReadAccess = @("Netuno","Urano") }
    )

    foreach ($share in $shares) {
        # Se o compartilhamento já existir, remove-o
        if (Get-SmbShare -Name $share.Name -ErrorAction SilentlyContinue) {
            Remove-SmbShare -Name $share.Name -Force
        }

        # Cria um hashtable para os parâmetros do New-SmbShare
        $params = @{
            Name = $share.Name
            Path = $share.Path
        }
        # Adiciona o parâmetro FullAccess se houver valor não vazio
        if ($share.FullAccess -and $share.FullAccess.Count -gt 0) {
            $params.FullAccess = $share.FullAccess
        }
        # Adiciona o parâmetro ChangeAccess se houver valor não vazio
        if ($share.ChangeAccess -and $share.ChangeAccess.Count -gt 0) {
            $params.ChangeAccess = $share.ChangeAccess
        }
        # Adiciona o parâmetro ReadAccess se houver valor não vazio
        if ($share.ReadAccess -and $share.ReadAccess.Count -gt 0) {
            $params.ReadAccess = $share.ReadAccess
        }

        # Cria o compartilhamento SMB com os parâmetros definidos
        New-SmbShare @params
    }
}

<# 
    Function: Restart-SMBServiceAndTestConnectivity
    Description: Reinicia o serviço SMB (LanmanServer) para aplicar as novas configurações,
    e testa a conectividade na porta 445 para confirmar que os compartilhamentos SMB estão ativos.
#>
function Restart-SMBServiceAndTestConnectivity {
    Restart-Service -Name "LanmanServer"
    Test-NetConnection -ComputerName localhost -Port 445
}

<# 
    Main Script Execution:
    Esta seção orquestra a execução das funções em sequência:
        1. Criação dos usuários locais.
        2. Criação dos diretórios necessários.
        3. Configuração das permissões NTFS para cada pasta.
        4. Criação dos compartilhamentos SMB com os acessos definidos.
        5. Reinicialização do serviço SMB e teste de conectividade.
#>

# Cria os usuários
New-CustomUsers

# Cria as pastas
New-CustomFolders

# Configura as permissões NTFS
Set-CustomNTFSPermissions

# Cria os compartilhamentos SMB
New-CustomSMBShares

# Reinicia o serviço SMB e testa a conectividade
Restart-SMBServiceAndTestConnectivity

```
{% endcode %}
