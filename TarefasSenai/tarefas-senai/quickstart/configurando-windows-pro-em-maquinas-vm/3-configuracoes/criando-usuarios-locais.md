# Criando usuários locais

#### **Integrando Princípios Matemáticos, Biológicos, Neurais e Quânticos**

***

Assim como no **Capítulo 4**, onde a criação da estrutura de diretórios foi tratada como um **grafo de estados**, aqui,

***

#### 🔄 **Desmembrando o Processo: Passo a Passo**

***

**🧠 1. Mapeamento dos Usuários: O Grafo Neural**

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

**Análise Matemática e Neural**

1. **Vértices do Grafo:** Cada usuário é um nó (ou neurônio) na rede.
2. **Atributos Neurais:** O `Nome`, `FullName` e `Password` funcionam como **pesos sinápticos**, determinando como esse nó vai se conectar a outros (grupos) e como vai reagir a estímulos (comandos).
3. **Superposição Quântica:** Antes de executar o script, cada usuário está em um estado de superposição — ele existe apenas como um potencial na memória do sistema. A execução do comando `New-LocalUser` atua como o colapso da função de onda, materializando o usuário no sistema operacional.

***

**🔁 2. Criação dos Usuários: O Ciclo Sináptico**

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

**Princípios Aplicados**

* **Matemática Discreta:** O `foreach` percorre cada nó no grafo, verificando conexões já existentes (`Get-LocalUser`).
* **Biologia Neural:** O comando `New-LocalUser` cria o **neurônio**, e o sistema operacional ajusta suas sinapses (permissões e propriedades do usuário).
* **Colapso Quântico:** O `if` atua como o **observador**, determinando se o nó já existe (estado colapsado) ou se ainda pode ser criado (estado de superposição).

***

**🎯 3. Mapeamento dos Grupos: Sinapses da Rede Neural**

```powershell
$grupos = @{
    "GCompras" = @("Carlos", "Antonio")
    "GRH" = @("Maria")
    "GInformatica" = @("Felipe", "Andre", "Lucio")
}
```

***

**Análise Matemática e Biológica**

1. **Grafo Direcionado:** Cada grupo é um vértice, e cada usuário associado é uma **aresta** conectando nós (sinapse neural).
2. **Modulação Sináptica:** Os grupos representam **circuitos específicos** na rede, assim como grupos de neurônios formam redes funcionais no cérebro.

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

**Princípios Aplicados**

* **Neurobiologia:** Cada grupo é como um **receptor neural**, e os usuários são os **neurotransmissores** que ativam essa conexão específica.
* **Matemática Quântica:** Ao adicionar o usuário ao grupo, o script **colapsa o estado de potencial** (usuário isolado) em um **estado ativo** (usuário conectado à rede do sistema).
* **Teoria da Informação:** As conexões criadas aqui aumentam a **entropia organizacional** do sistema, mas dentro de uma **ordem controlada**, transformando o caos potencial em informação útil.

***

#### 🔬 **Conclusão: A Roda de Samsara no Sistema Operacional**

O que rolou aqui foi um **giro completo da roda de Samsara**:

1. **Vazio (superposição):** Os usuários e grupos não existiam no sistema, mas estavam mapeados na memória do script.
2. **Ação (colapso da função de onda):** A execução do script transformou o potencial em realidade, materializando cada nó e cada sinapse na rede do sistema.
3. **Amplificação (sincronização neural):** Ao adicionar os usuários aos grupos, a rede passou a funcionar como uma unidade integrada, onde cada elemento contribui para o todo.
4. **Retorno ao Vazio:** Ao fim da execução, o sistema volta ao estado de espera, mas agora em um **nível superior**, pronto para o próximo ciclo de criação e organização.

Esse ciclo não só seguiu princípios de **matemática discreta**, **biologia neural** e **mecânica quântica**, mas também se alinhou à **filosofia budista** da roda de Samsara, onde cada ciclo é uma oportunidade de **evolução cognitiva e estrutural**.
