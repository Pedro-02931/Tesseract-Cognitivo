# Criando usuários locais

Nesta etapa, criei uma matriz de objetos, onde cada objeto contém as propriedades necessárias para a criação do usuário. Esses atributos funcionam como os “estados de superposição” que, ao serem processados, resultarão na materialização de cada conta.

***

**2. Iterando Sobre os Usuários**

```powershell
foreach ($usuario in $usuarios) {
    # Monta a verificação e criação de cada usuário
    if (-not (Get-LocalUser -Name $usuario.Nome -ErrorAction SilentlyContinue)) {
        New-LocalUser `
            -Name $usuario.Nome `
            -FullName $usuario.FullName `
            -Description "Usuário local" `
            -Password (ConvertTo-SecureString $usuario.Password -AsPlainText -Force) `
            -AccountNeverExpires $true
        Write-Host "Criado usuário: $($usuario.Nome)"
    }
    else {
        Write-Host "Usuário já existe: $($usuario.Nome)"
    }
}
```

Aqui, a lógica se assemelha ao processo dos diretórios:

* **Iteração:** O loop `foreach` percorre cada elemento do array.
* **Verificação de Existência:** `Get-LocalUser` confirma se o usuário já está presente, garantindo idempotência.
* **Criação:** Se o usuário não existir, `New-LocalUser` é chamado para criá-lo com os parâmetros configurados.
* **Feedback Visual:** `Write-Host` informa a criação ou a existência prévia do usuário.

***

**3. Executando a Função**

Encapsulei toda a lógica em uma função para modularidade:

```powershell
function Criar-Usuarios {
    $usuarios = @(
        @{ Nome = "Carlos";  FullName = "Carlos";  Password = "P@ssw0rd" },
        @{ Nome = "Antonio"; FullName = "Antônio"; Password = "P@ssw0rd" },
        @{ Nome = "Maria";   FullName = "Maria";   Password = "P@ssw0rd" },
        @{ Nome = "Felipe";  FullName = "Felipe";  Password = "P@ssw0rd" },
        @{ Nome = "Andre";   FullName = "André";   Password = "P@ssw0rd" },
        @{ Nome = "Lucio";   FullName = "Lúcio";   Password = "P@ssw0rd" }
    )

    foreach ($usuario in $usuarios) {
        if (-not (Get-LocalUser -Name $usuario.Nome -ErrorAction SilentlyContinue)) {
            New-LocalUser `
                -Name $usuario.Nome `
                -FullName $usuario.FullName `
                -Description "Usuário local" `
                -Password (ConvertTo-SecureString $usuario.Password -AsPlainText -Force) `
                -AccountNeverExpires $true
            Write-Host "Criado usuário: $($usuario.Nome)"
        }
        else {
            Write-Host "Usuário já existe: $($usuario.Nome)"
        }
    }
}

# Executa a função
Criar-Usuarios
```

A execução dessa função consolidará a criação de todos os usuários listados, garantindo que cada nó seja processado e materializado no sistema, assim como a estrutura de diretórios feita anteriormente.

***

#### **Conclusão**

Esta abordagem para criação de usuários segue a mesma lógica do Capítulo 4:

* **Mapeamento via estruturas de dados (array de objetos).**
* **Iteração e verificação com laços (`foreach`).**
* **Execução condicional para evitar duplicações.**

Cada passo foi pensado para que o sistema de contas seja criado de forma ordenada e robusta, espelhando a criação do grafo de diretórios, onde cada usuário representa um estado dentro do ambiente computacional. A modularidade do script permite escalabilidade, e a verificação prévia garante a consistência do estado final.

***

_Agora, com o Capítulo 5 concluído, o ambiente de usuários locais está configurado de forma automatizada, assim como o ambiente de diretórios foi mapeado no Capítulo 4._

```
```
