# Configurando permissões

{% embed url="https://drive.google.com/file/d/1hVJ0CyLbB25b17H7ouWOLFxEPhE-Xh4Y/view?usp=sharing" %}
Ajustando permissões
{% endembed %}



## **Permissões de Pastas**

Assim como em uma rede neural, onde cada nó (neurônio) interage com outros através de sinapses, o script PowerShell abaixo cria uma arquitetura de permissões onde grupos de usuários (nós) conectam-se a pastas (vértices) através de regras de acesso (sinapses). Abaixo, vamos dissecar cada trecho do script, explorando como ele cria uma topologia de segurança adaptativa e modular para as pastas **Compras**, **RH** e **Informatica**.

***

### **Objetivo do Script**

Este script configura permissões específicas para cada grupo de usuários, seguindo as seguintes diretrizes:

* **Pasta `Compras`:**\
  O grupo **GCompras** tem permissão de leitura e gravação, enquanto **GRH** e **GInformatica** podem apenas visualizar o conteúdo.
* **Pasta `RH`:**\
  O grupo **GRH** tem leitura e gravação, **GCompras** também, mas **GInformatica** fica de fora (sem acesso nenhum).
* **Pasta `Informatica`:**\
  Apenas o grupo **GInformatica** tem permissão de leitura e gravação. Os outros grupos são barrados totalmente.

***

### **1. Inicializando o Grafo: Definição dos Caminhos das Pastas**

```powershell
$comprasPath    = "C:\Compras"
$rhPath         = "C:\RH"
$informaticaPath= "C:\Informatica"
```

#### **O Que Isso Significa?**

Essas variáveis representam os vértices principais do grafo, onde cada pasta é um ponto de conexão para as permissões dos grupos. Imagine-as como hubs que distribuem informações para os nós conectados.

***

### **2. Função `Ensure-Folder`**

```powershell
function Ensure-Folder {
    param(
        [string]$FolderPath
    )
    if (-not (Test-Path -Path $FolderPath)) {
        Write-Host "Pasta '$FolderPath' não encontrada. Criando..."
        New-Item -Path $FolderPath -ItemType Directory | Out-Null
    }
}
```

Essa função age como o observador quântico do sistema. Antes da execução, cada pasta está em um estado de superposição — ela pode existir ou não. Ao rodar o **Test-Path**, o script "observa" o estado da pasta. Se ela não existir, o **New-Item** colapsa o estado potencial em realidade, materializando o diretório no sistema.

***

### **3. Preparando o Campo: Garantindo as Pastas**

```powershell
Ensure-Folder -FolderPath $comprasPath
Ensure-Folder -FolderPath $rhPath
Ensure-Folder -FolderPath $informaticaPath
```

#### **Sincronização Neural**

Cada chamada da função **Ensure-Folder** mapeia um nó no grafo, assegurando que os vértices estejam prontos para receber conexões (permissões) dos grupos de usuários.

Basicamente uma classe que carrega a função icacls, para atribuir as permissões aos nós (objetos carregados na memoria).

***

### **4. Configuração das Permissões: Sinapses de Acesso**

#### **Pasta `Compras`**

```powershell
icacls $comprasPath /inheritance:r
icacls $comprasPath /grant "GCompras:(OI)(CI)M"
icacls $comprasPath /grant "GRH:(OI)(CI)R"
icacls $comprasPath /grant "GInformatica:(OI)(CI)R"
```

#### **Decodificando as Permissões**

* `(OI)(CI)`: Aplicação recursiva em arquivos (Object Inherit) e pastas (Container Inherit).
* **`M` (Modify):** GCompras pode ler, escrever e modificar.
* **`R` (Read):** GRH e GInformatica podem apenas visualizar o conteúdo.

***

#### **Pasta `RH`**

```powershell
icacls $rhPath /inheritance:r
icacls $rhPath /grant "GRH:(OI)(CI)M"
icacls $rhPath /grant "GCompras:(OI)(CI)M"
icacls $rhPath /deny "GInformatica:(OI)(CI)F"
```

#### **Negações e Acessos**

* **Permissão Total (M)** para **GRH** e **GCompras**.
* **Acesso Negado (`F` - Full Control)** para **GInformatica**, eliminando qualquer interação com a pasta.

***

#### **Pasta `Informatica`**

```powershell
icacls $informaticaPath /inheritance:r
icacls $informaticaPath /grant "GInformatica:(OI)(CI)M"
icacls $informaticaPath /deny "GRH:(OI)(CI)F"
icacls $informaticaPath /deny "GCompras:(OI)(CI)F"
```

#### **Blindagem Cognitiva**

Aqui, o script cria um espaço isolado, onde apenas **GInformatica** pode acessar a pasta. Os outros grupos são barrados pela negação total (`F`), criando um ambiente seguro e confidencial.
