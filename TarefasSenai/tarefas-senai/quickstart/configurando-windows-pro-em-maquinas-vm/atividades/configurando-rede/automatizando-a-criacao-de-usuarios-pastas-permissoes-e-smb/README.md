# Automatizando a Criação de Usuários, Pastas, Permissões e SMB

Bom, a atividade era pra ser simples: configurar permissões de pastas e usuários no ambiente Windows 10 Pro utilizando o VirtualBox. MAS dado que não gosto de fazer nada pequeno, decidi ampliar a abordagem para automatizar a criação de usuários, pastas, permissões NTFS, compartilhamentos SMB e validação de conectividade.&#x20;

Fiz uma gambiarra com o PowerShell para trabalhar com OOP, e dado sua capacidade de gerenciar o sistema operacional Windows de maneira granular, me economizou muito tempo. No caso, usei IA para fazer as correções e e criar o esqueleto, mas decidi documentar a logica para eu não virar um "engenheiro de prompt", embora meu uso de IA seja bem diferente da maioria

## **1. Criação Automática de Usuários: `New-CustomUser`**

Ao invés de adicionar cada usuário manualmente, o script cria uma rotina que lê uma lista de usuários pré-definidos usando hash table para criar um vetor que carrega vetor dentro de vetor (falando como um humano, imagina uma tabela com colunas e linhas)

A criação automatizada também garante padronização, especialmente em ambientes corporativos onde a consistência das credenciais de acesso e políticas de senha são cruciais. Nesse caso, todos os usuários são criados com uma senha padrão e configurados para que a senha nunca expire, o que é ideal para ambientes de teste e laboratório.

#### **Usuários a serem criados:**

* **Admin:** Terra (Controle total sobre o sistema)
* **Comuns:** Vênus, Marte (Acesso moderado a determinadas pastas)
* **Restritos:** Júpiter, Saturno (Permissão apenas para leitura em algumas pastas)
* **Convidados:** Netuno, Urano (Acesso extremamente limitado, apenas leitura em áreas específicas)

```powershell
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
    if (-not (Get-LocalUser -Name $user.Name)) {
        New-LocalUser -Name $user.Name -FullName $user.FullName `
        -Password (ConvertTo-SecureString $user.Password -AsPlainText -Force)
        
        Set-LocalUser -Name $user.Name -PasswordNeverExpires $true
        Write-Host "Usuário criado: $($user.Name)"
    } else {
        Write-Host "Usuário já existe: $($user.Name)"
    }
}
```

#### **Pontos-Chave:**

* A variável `$users` é uma coleção de objetos para evitar a necessidade de múltiplas chamadas ao `New-LocalUser`, centralizando os dados em uma única estrutura, veja ela como uma tabela, em que a chave é a coluna, e o valor é a lista.
* O `Get-LocalUser` é usada para verificar se o usuário já existe no sistema antes de tentar criá-lo.&#x20;
* A senha é convertida em uma `SecureString` utilizando o `ConvertTo-SecureString`. [Nunca que uma empresa não usaria uma tabela sem criptografia basica rsrsrs](https://g1.globo.com/economia/tecnologia/noticia/2021/01/28/vazamento-de-dados-de-223-milhoes-de-brasileiros-o-que-se-sabe-e-o-que-falta-saber.ghtml)
* O comando `Set-LocalUser -PasswordNeverExpires $true` foi definido por ser um ambiente controlado.

***

## **2. Criação de Pastas: `New-CustomFolders`**

Bom, automatizei a criação de pastas no diretório `C:` seguindo o conceito: Cada pasta criada representa um nó dentro da rede de permissões que será configurada posteriormente, garantindo que cada usuário tenha o acesso adequado conforme as políticas estabelecidas.

#### **Pastas Criadas:**

* **C:\publica:** Acesso amplo, leitura e gravação para a maioria dos usuários.
* **C:\trabalho:** Espaço colaborativo para usuários comuns e administradores.
* **C:\documentos:** Repositório de documentos para usuários comuns.
* **C:\confidencial:** Acesso restrito apenas ao administrador.
* **C:\convidados:** Pastas específicas para usuários convidados, com permissões limitadas.

```powershell
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
```

#### **Análise Técnica:**

* **O `Test-Path`** valida a existência do diretório antes de tentar criá-lo.
* **Estrutura de Dados via Hash Table:** dado que sou preguiçoso, adicionei novas pastas através da tabela `$folders` com o uso de laços de repetição.&#x20;

***

***

## **3. Aplicação de Permissões NTFS: `Set-CustomNTFSPermissions`**

O sistema de arquivos NTFS (New Technology File System) permite a configuração detalhada de permissões em nível de pasta e arquivo através de alocação de blocos e metadados.&#x20;

Essas permissões são aplicadas diretamente aos blocos do sistema de arquivos de acordo com o espaço de alocação do sistema formatados, o que permite um controle preciso sobre quem pode acessar, modificar ou visualizar cada recurso.&#x20;

Usei a função `Set-CustomNTFSPermissions` automatiza essa tarefa utilizando o utilitário **icacls e tabelas**, garantindo que as permissões sejam atribuídas corretamente a cada pasta criada anteriormente.

#### **Permissões Definidas:**

Bom, segui como a atividade orientou: Cada pasta tem um conjunto específico de permissões:

* **Pasta "publica":** Controle total para o administrador, leitura e gravação para usuários comuns e apenas leitura para restritos e convidados.
* **Pasta "trabalho":** Controle total para o administrador e leitura/gravação para usuários comuns.
* **Pasta "documentos":** Apenas leitura e gravação para usuários comuns.
* **Pasta "confidencial":** Acesso exclusivo ao administrador.
* **Pasta "convidados":** Controle total para o administrador e leitura para usuários convidados.

```powershell
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
```

#### **Análise Detalhada:**

* O comando `icacls $path /reset` redefine as permissões do diretório, removendo heranças ou permissões pré-existentes que poderiam interferir no novo modelo de controle de acesso.
* Cada permissão é aplicada através do comando `icacls $path /grant:r $permission`, onde `:r` indica que as permissões anteriores serão substituídas pelas novas.
* **Parâmetros de Permissão:**
  * `(OI)` (Object Inherit): Permissões aplicáveis a arquivos dentro da pasta.
  * `(CI)` (Container Inherit): Permissões aplicáveis a subpastas dentro da pasta.
  * `(IO)` (Inherit Only): Aplicável apenas aos objetos filhos, não ao próprio diretório.
  * **F** (Full control): Controle total, incluindo gerenciamento de permissões.
  * **M** (Modify): Permissão de leitura, gravação e modificação de arquivos.
  * **R** (Read): Somente leitura, impedindo qualquer alteração no conteúdo.

***

## **4. Compartilhamento SMB: `New-CustomSMBShares`**

O protocolo **SMB (Server Message Block)** é amplamente utilizado para compartilhamento de arquivos e pastas em redes Windows. No caso automatizei a criação de compartilhamentos SMB garante que os usuários remotos possam acessar os recursos conforme as permissões definidas anteriormente. Fiz de forma modular seguindo as regras da atividade.

### **Lógica de Compartilhamento:**

Cada compartilhamento é definido com um nome, caminho e permissões específicas de acesso. A função `Remove-ExistingSMBShare` é chamada antes de criar um novo compartilhamento, garantindo que não haja conflitos de nome ou permissões. ~~Isso me deu uma dor de cabeça rsrsrs~~

{% code overflow="wrap" %}
```powershell
function Remove-ExistingSMBShare {
    param (
        [string]$ShareName
    )
    # O Get-SmbShare verifica se o compartilhamento já existe, evitando exceções desnecessárias.
    if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
        Remove-SmbShare -Name $ShareName -Force
        Write-Output "Compartilhamento removido: $ShareName"
    }
}
```
{% endcode %}

***

#### **Criação dos Compartilhamentos:**

```powershell
function New-CustomSMBShares {
    $shares = @(
        @{ Name = "publica";     Path = "C:\publica";     FullAccess = @("Terra"); ChangeAccess = @("Vênus","Marte"); ReadAccess = @("Júpiter","Saturno","Netuno","Urano") },
        @{ Name = "trabalho";    Path = "C:\trabalho";    FullAccess = @("Terra"); ChangeAccess = @("Vênus","Marte"); ReadAccess = @() },
        @{ Name = "documentos";  Path = "C:\documentos";  FullAccess = @();       ChangeAccess = @("Vênus","Marte"); ReadAccess = @() },
        @{ Name = "confidencial";Path = "C:\confidencial";FullAccess = @("Terra"); ChangeAccess = @();               ReadAccess = @() },
        @{ Name = "convidados";  Path = "C:\convidados";  FullAccess = @("Terra"); ChangeAccess = @();               ReadAccess = @("Netuno","Urano") }
    )

    foreach ($share in $shares) {
        Remove-ExistingSMBShare -ShareName $share.Name
        New-SmbShare -Name $share.Name -Path $share.Path -FullAccess $share.FullAccess -ChangeAccess $share.ChangeAccess -ReadAccess $share.ReadAccess
        Write-Output "Compartilhamento criado: $($share.Name) em $($share.Path)"
    }
}
```

* Usando tabelas, o script pode ser facilmente ajustado para adicionar ou remover compartilhamentos sem a necessidade de alterar a lógica do código.
* &#x20;As permissões de `FullAccess`, `ChangeAccess` e `ReadAccess` são atribuídas diretamente via `New-SmbShare`, garantindo consistência entre as permissões NTFS e o acesso via rede.
* A função `Remove-ExistingSMBShare` é sempre chamada antes da criação do novo compartilhamento, eliminando riscos de conflito.

***

## **5. Validação da Conectividade SMB: `Restart-SMBServiceAndTestConnectivity`**

Após configurar os compartilhamentos SMB, é fundamental garantir que o serviço **LanmanServer** (responsável pelo SMB) esteja operando corretamente. Além disso, a conectividade na porta **445** precisa ser testada para validar o acesso remoto aos compartilhamentos.

```powershell
function Restart-SMBServiceAndTestConnectivity {
    Restart-Service -Name "LanmanServer"
    Test-NetConnection -ComputerName localhost -Port 445
}
```

* O `Restart-Service` reinicia o serviço **LanmanServer**, aplicando todas as novas configurações de compartilhamento e permissões.
* O `Test-NetConnection` valida a conectividade na porta **445**, essencial para o funcionamento do SMB. Se o teste falhar, pode indicar problemas no firewall ou nas permissões de rede.
