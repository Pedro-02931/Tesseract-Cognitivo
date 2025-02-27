# Script

{% code overflow="wrap" %}
```powershell
<# 
    Function: New-CustomUsers
    Description: Cria automaticamente os usuários locais definidos em uma hash table.
    Essa abordagem usa vetores aninhados (hash tables dentro de arrays) para criar os usuários
    com consistência e padronização, especialmente em ambientes corporativos.
#>
function New-CustomUsers {
    # Define os usuários e suas informações em uma hash table
    $users = @(
        @{ Name = "Terra";   FullName = "Admin Terra";     Password = "P@ssw0rd" },
        @{ Name = "Vênus";   FullName = "Comum Vênus";     Password = "P@ssw0rd" },
        @{ Name = "Marte";   FullName = "Comum Marte";     Password = "P@ssw0rd" },
        @{ Name = "Júpiter"; FullName = "Restrito Júpiter"; Password = "P@ssw0rd" },
        @{ Name = "Saturno"; FullName = "Restrito Saturno"; Password = "P@ssw0rd" },
        @{ Name = "Netuno";  FullName = "Convidado Netuno"; Password = "P@ssw0rd" },
        @{ Name = "Urano";   FullName = "Convidado Urano";  Password = "P@ssw0rd" }
    )

    # Itera sobre os usuários e cria cada um, se não existir
    foreach ($user in $users) {
        if (-not (Get-LocalUser -Name $user.Name -ErrorAction SilentlyContinue)) {
            New-LocalUser -Name $user.Name -FullName $user.FullName `
                -Password (ConvertTo-SecureString $user.Password -AsPlainText -Force)
            
            Set-LocalUser -Name $user.Name -PasswordNeverExpires $true
            Write-Host "Usuário criado: $($user.Name)"
        } else {
            Write-Host "Usuário já existe: $($user.Name)"
        }
    }
}

<# 
    Function: New-CustomFolders
    Description: Cria as pastas necessárias no diretório C:\, utilizando hash tables para
    modularidade e fácil expansão. A criação automatizada de diretórios evita a necessidade de
    configuração manual, acelerando o processo de setup do ambiente.
#>
function New-CustomFolders {
    # Define as pastas como chaves em uma hash table
    $folders = @{
        "C:\publica"      = $true
        "C:\trabalho"     = $true
        "C:\documentos"   = $true
        "C:\confidencial" = $true
        "C:\convidados"   = $true
    }

    # Cria as pastas se não existirem
    foreach ($path in $folders.Keys) {
        if (-not (Test-Path -Path $path)) {
            New-Item -Path $path -ItemType Directory
            Write-Output "Diretório criado: $path"
        } else {
            Write-Output "Diretório já existe: $path"
        }
    }
}

<# 
    Function: Set-CustomNTFSPermissions
    Description: Aplica as permissões NTFS em cada pasta usando o icacls.
    As permissões são definidas através de hash tables, garantindo flexibilidade para ajustes futuros.
#>
function Set-CustomNTFSPermissions {
    # Define as permissões para cada pasta em uma hash table
    $permissions = @{
        "C:\publica" = @(
            "Terra:(OI)(CI)F",
            "Vênus:(OI)(CI)M",
            "Marte:(OI)(CI)M",
            "Júpiter:(OI)(CI)R",
            "Saturno:(OI)(CI)R",
            "Netuno:(OI)(CI)R",
            "Urano:(OI)(CI)R"
        )
        "C:\trabalho" = @(
            "Terra:(OI)(CI)F",
            "Vênus:(OI)(CI)M",
            "Marte:(OI)(CI)M"
        )
        "C:\documentos" = @(
            "Vênus:(OI)(CI)M",
            "Marte:(OI)(CI)M"
        )
        "C:\confidencial" = @(
            "Terra:(OI)(CI)F"
        )
        "C:\convidados" = @(
            "Terra:(OI)(CI)F",
            "Netuno:(OI)(CI)R",
            "Urano:(OI)(CI)R"
        )
    }

    # Aplica as permissões utilizando o icacls
    foreach ($path in $permissions.Keys) {
        icacls $path /reset
        foreach ($permission in $permissions[$path]) {
            icacls $path /grant:r $permission
            Write-Output "Permissão aplicada: $permission em $path"
        }
    }
}

<# 
    Function: New-CustomSMBShares
    Description: Cria os compartilhamentos SMB e garante que estejam visíveis na rede.
    Usa splatting para evitar parâmetros nulos, ajustando dinamicamente os acessos.
#>
function New-CustomSMBShares {
    $shares = @(
        @{ Name = "publica";     Path = "C:\publica";     FullAccess = @("Terra"); ChangeAccess = @("Vênus","Marte"); ReadAccess = @("Júpiter","Saturno","Netuno","Urano") },
        @{ Name = "trabalho";    Path = "C:\trabalho";    FullAccess = @("Terra"); ChangeAccess = @("Vênus","Marte"); ReadAccess = @() },
        @{ Name = "documentos";  Path = "C:\documentos";  FullAccess = @();       ChangeAccess = @("Vênus","Marte"); ReadAccess = @() },
        @{ Name = "confidencial";Path = "C:\confidencial";FullAccess = @("Terra"); ChangeAccess = @();               ReadAccess = @() },
        @{ Name = "convidados";  Path = "C:\convidados";  FullAccess = @("Terra"); ChangeAccess = @();               ReadAccess = @("Netuno","Urano") }
    )

    foreach ($share in $shares) {
        if (Get-SmbShare -Name $share.Name -ErrorAction SilentlyContinue) {
            Remove-SmbShare -Name $share.Name -Force
        }

        $params = @{
            Name = $share.Name
            Path = $share.Path
        }
        
        foreach ($perm in 'FullAccess', 'ChangeAccess', 'ReadAccess') {
            if ($share[$perm] -and $share[$perm].Count -gt 0) {
                $params[$perm] = $share[$perm]
            }
        }

        New-SmbShare @params
        Write-Output "Compartilhamento criado: $($share.Name) em $($share.Path)"
    }
}

<# 
    Function: Restart-SMBServiceAndTestConnectivity
    Description: Reinicia o serviço SMB e testa a conectividade na porta 445.
#>
function Restart-SMBServiceAndTestConnectivity {
    Restart-Service -Name "LanmanServer"
    Test-NetConnection -ComputerName localhost -Port 445
}

# Execução do script em sequência lógica
New-CustomUsers
New-CustomFolders
Set-CustomNTFSPermissions
New-CustomSMBShares
Restart-SMBServiceAndTestConnectivity

```
{% endcode %}
