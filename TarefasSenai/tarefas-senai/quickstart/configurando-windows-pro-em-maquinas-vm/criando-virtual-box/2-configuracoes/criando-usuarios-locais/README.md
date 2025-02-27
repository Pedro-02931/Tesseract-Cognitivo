# Criando usuários locais

{% embed url="https://drive.google.com/file/d/1d9rwWNyE7PTzNqAkcWJUNy4kisVQRUvp/view?usp=sharing" %}
Criando Usuarios e Grupos
{% endembed %}



Bom, aqui eu basicamente segui o aamesmo principio de multidimensionalidade por hashtable~~(é o melhor que se dá com esse notebook capenga).~~ então vou fazer a logica de forma resumida.

***

**1. Mapeamento dos Usuários: O Grafo Neural**

```powershell
$usuarios = @(
    @{ Nome = "Carlos";  FullName = "Carlos";  Password = "P@ssw0rd" },
    @{ Nome = "Antonio"; FullName = "Antônio"; Password = "P@ssw0rd" },
    @{ Nome = "Maria";   FullName = "Maria";   Password = "P@ssw0rd" },
    @{ Nome = "Felipe";  FullName = "Felipe";  Password = "P@ssw0rd" },
    @{ Nome = "Andre";   FullName = "André";   Password = "P@ssw0rd" },
    @{ Nome = "Lucio";   FullName = "Lúcio";   Password = "P@ssw0rd" }
)
```

***

1. **Vértices do Grafo:** Cada usuário é um nó (ou neurônio) na rede.
2. **Atributos:** O `Nome`, `FullName` e `Password` funcionam como **pesos**, determinando como esse nó vai se conectar a grupos e como vai reagir a comandos.
3. **Superposição Quântica:** Antes de executar o script, cada usuário está em um estado de superposição — ele existe apenas como um potencial na memória do sistema. A execução do comando `New-LocalUser` atua como o colapso da função de onda, materializando o usuário no sistema operacional.

***

**2. Criação dos Usuários: O Ciclo Sináptico**

```powershell
foreach ($usuario in $usuarios) {
    if (-not (Get-LocalUser -Name $usuario.Nome -ErrorAction SilentlyContinue)) {
        New-LocalUser -Name $usuario.Nome -FullName $usuario.FullName `
            -Password (ConvertTo-SecureString $usuario.Password -AsPlainText -Force) `
            -AccountNeverExpires $true
        Write-Host "Usuário criado: $($usuario.Nome)"
    } else {
        Write-Host "Usuário já existe: $($usuario.Nome)"
    }
}
```

***

* O `foreach` percorre cada nó no grafo, verificando conexões já existentes (`Get-LocalUser`).
* O comando `New-LocalUser` cria a instancia, e o sistema operacional ajusta suas permissões e propriedades.
* O `if` atua como o **observador**, determinando se o nó já existe (estado colapsado) ou se ainda pode ser criado (estado de superposição).

***

**3. Mapeamento dos Grupos: Sinapses da Rede Neural**

```powershell
$grupos = @{
    "GCompras" = @("Carlos", "Antonio")
    "GRH" = @("Maria")
    "GInformatica" = @("Felipe", "Andre", "Lucio")
}
```

***

1. **Grafo Direcionado:** Cada grupo é um vértice, e cada usuário associado é um nó na aresta que se expande.
2. Os grupos representam **circuitos específicos** na rede.

***

**🔗 4. Associação de Usuários aos Grupos: Sincronização Neural**

```powershell
foreach ($grupo in $grupos.Keys) {
    if (-not (Get-LocalGroup -Name $grupo -ErrorAction SilentlyContinue)) {
        New-LocalGroup -Name $grupo
        Write-Host "Grupo criado: $grupo"
    }

    foreach ($usuario in $grupos[$grupo]) {
        if (-not (Get-LocalGroupMember -Group $grupo -Member $usuario -ErrorAction SilentlyContinue)) {
            Add-LocalGroupMember -Group $grupo -Member $usuario
            Write-Host "Usuário $usuario adicionado ao grupo $grupo"
        }
    }
}
```

***

* Cada grupo é como um **receptor**, e os usuários são os pacotes que ativam essa conexão específica.
* Ao adicionar o usuário ao grupo, o script **colapsa o estado de potencial** (usuário isolado) em um **estado ativo** (usuário conectado à rede do sistema).
* As conexões criadas aqui aumentam a **entropia organizacional** do sistema, mas dentro de uma **ordem controlada**, transformando o caos potencial em informação útil~~(tipo a gravidade, mas não arrasta o pequeno pro grande mas o desconhecido pro conhecido)~~.

***

Os usuários e grupos não existiam no sistema, mas estavam mapeados na memória do script, onde o vazio representa possibilidade de criação~~(energia potencial se você fez ensino médio)~~, onde a execução do script transformou o potencial em realidade, materializando cada nó e cada sinapse na rede do sistema.

Ao adicionar os usuários aos grupos, a rede passa a funcionar como uma unidade integrada, onde cada elemento contribui para o todo e ao fim da execução, o sistema volta ao estado de espera, mas agora em um **nível superior**, pronto para o próximo ciclo de criação e organização.

