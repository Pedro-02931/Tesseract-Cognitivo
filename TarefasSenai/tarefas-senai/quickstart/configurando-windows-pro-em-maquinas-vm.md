---
description: >-
  Consigo automatizar isso, mas devo fazer em video e documentando por convenção
  socia, que saco kkkkk
---

# Configurando Windows Pro em Máquinas VM

## Inicio

Bom, vou tentar mapear as estruturas semanticas de significado das tela, em que atravez de um LLM, vou gerando o conhecimento tecnico ~~(também não consigo fazer nada pequeno kkk)~~

***

## 1 Chamando botão novo() do VirtualBox

Usei o VirtualBox para criar minha nova máquina virtual com as configurações:

* Windows 10 Pro;&#x20;
* 56 GB de disco;&#x20;
* 3072 MB de RAM;
* 1 thread de processador;

***

### **1.1 Hub Inicial: Criando a VM**

1. **Tela "Novo"**
   * **Nome e Diretório:** Aqui, dou um nome para a VM (no meu caso, “Windows 10 PRO v”) e escolho a pasta onde ela vai ficar salva. Basicamente aqui indica ao SO os pontos de blocos que serão usados, vazios ~~(o vazio para mim é espaço de construção, em que cada bloco pode ser uma rede de significados, mas bora voltar)~~, permitindo o SO interagir através do filesystem que armazena metadados.
   * **Tipo e Versão do Sistema Operacional Convidado:** Seleciono “Windows 10 (64-bit)”. Isso orienta o VirtualBox a definir configurações padrão compatíveis com o Windows 10, talvez por conta das syscalls.
   * **ISO de Instruções:** Aponto o arquivo ISO do Windows 10 que eu tenho (ele chama “pt\_windows\_10\_consumer\_editions\_version\_1909\_updated\_aug\_2020...”). Essa ISO é tipo o “binário-mãe” que contém todos os dados de instalação do sistema, onde através de um condensado se expande em possibilidades de criação, gerando uma rede ramificada de possibilidades.
   * **Instalação em Background (Desassistida):** O VirtualBox até oferece a opção de fazer uma instalação autônoma, pré-configurada. Mas, nesse caso, **desabilitei**.

Nessa tela inicial, estou definindo a **identidade** da máquina virtual e de onde ela vai extrair as “ordens” (ISO). É um momento quase ~~uma trepada~~ “cerimonial”: escolher o nome, o caminho, o sistema.

***

### **1.2 Configuração de Hardware**

Depois de definir o nome e a ISO, aparece uma segunda tela que me pergunta sobre as configurações de hardware virtual. Aqui tem um leque de possibilidades:

1. **Memória Principal (RAM):** Coloquei **3072 MB** (mais ou menos 3 GB).
   * _Como funciona?_ O VirtualBox vai “reservar” esse espaço da memória do meu host enquanto a VM roda. Porém, diferentemente de uma instalação física, isso acontece de forma dinâmica: se a VM precisar, ela usa. Caso contrário, não afeta tanto, ou seja, escalável e simbólico.
2. **Processador(es) / Número de Threads:** Configurei apenas **1**.
   * _E se eu colocasse mais?_ Eu estaria literalmente **emprestando** mais núcleos/threads do meu processador físico para a VM, o que poderia dar mais performance, mas também “roubar” desempenho do meu computador principal, bom, um trade-off que permite uma analise de mais dimensões dentro do espaço global.
3. **Habilitar EFI:** Está **desativado** (“false”).
   * _O que é isso?_ EFI (ou UEFI) é um tipo de firmware moderno, substituto do BIOS tradicional. Ele pode ser necessário para alguns SOs mais novos ou configurações específicas de boot.
   * A versão do Windows 10 que estou instalando não requer explicitamente EFI, e normalmente o VirtualBox usa o BIOS padrão.

Nesse momento, sinto que estou definindo a **espinha dorsal** da máquina: quanta memória, quantos processadores, e se ela vai ter um firmware mais moderno (EFI) ou tradicional (BIOS).

***

### **1.3 Disco Rígido Virtual**

Na próxima tela, o VirtualBox me mostra como vou criar ou apontar um disco rígido para essa máquina:

1. **Tipo de Arquivo do Disco (VDI, VHD, VMDK):**
   * Escolhi **VDI** (VirtualBox Disk Image), que é o formato nativo do VirtualBox.
   * Ele é mais simples de gerenciar para mim e tem boa compatibilidade com snapshots.
2. **Tamanho do Disco:** Configurei **56 GB**.
   * Aqui decidi que, dentro do meu sistema host, essa máquina virtual vai ter um arquivo (ou conjunto de arquivos) que vai agir como um disco de 56 GB.
3. **Alocação Dinâmica vs. Pré-Alocar Tamanho:**
   * Deixei **pré-alocação = false**, ou seja, alocação **dinâmica**.
   * _Qual a diferença?_
     * **Dinâmica:** O arquivo começa pequeno e vai crescendo à medida que armazeno dados dentro da VM. Ou seja, ele não consome imediatamente todos os 56 GB do meu HD físico, apenas o necessário.
     * **Pré-Alocado:** Se eu marcasse essa opção, o VirtualBox criaria um arquivo com 56 GB cheios de uma vez, mesmo que a VM esteja vazia. Isso pode dar uma performance ligeiramente melhor, mas consome espaço do host imediatamente.
     * **Um segue o principio de quantização, o outro é formação de estado bruto**, tipo a consciencia é apenas uma percepção atradada do que o corpo já fez.
4. **Apontar para Disco Existente ou Criar Novo:**
   * Eu optei por **criar um novo VDI** do zero, porque quero um ambiente “limpo” para o Windows 10.
   * Se eu tivesse já um disco virtual com um sistema instalado, poderia ter apontado aqui.
   * Também existe a opção de **“Não adicionar disco”**, caso eu quisesse criar o disco depois ou usar apenas um Live CD sem persistência.

Nessa etapa, visualizo que estou, de certa forma, **criando a dimensão tensorial** onde o Windows 10 vai nascer. Escolho o tamanho, o formato e se o espaço no meu HD host vai ser consumido logo de cara ou conforme a VM precisar.

***

### **4. Resultado Final: Cenário Semântico**

* **Nome da Máquina**: “Windows 10 PRO v”
* **Pasta da Máquina**: “E:/Users/25132658/VirtualBox VMs/Windows 10 PRO v”
* **Imagem ISO**: “E:/ISOs/pt\_windows\_10\_consumer\_editions\_version\_1909\_updated\_aug\_2020...”
* **Sistema Convidado**: Windows 10 (64-bit)
* **Memória**: 3072 MB
* **Processador**: 1 thread
* **Habilitar EFI**: false
* **Disco Virtual**: 56 GB no formato VDI, alocação dinâmica

Neste estado final, a VM está pronta para ser iniciada e instalar o Windows 10 Pro. Quando eu der o “Iniciar”, o VirtualBox vai montar aquela ISO como se fosse um DVD real e começar o processo de boot. A partir daí, rola aquela tela do Windows Setup, onde vou criar partições, selecionar idioma, configurar conta de usuário etc.

**Em termos de “cadeias semânticas”:**

* Cada escolha de **memória, processador, disco** forma a base do _“modelo cognitivo”_ do hardware virtual.
* A **ISO** carrega todos os _“conceitos”_ (os arquivos de instalação) que serão mapeados para esse hardware.
* A decisão sobre **EFI**, **pré-alocação**, **diretório**, entre outras, são _"parâmetros de inferência"_ que afetam como o VirtualBox orquestra recursos do meu sistema físico.

Agora que terminei a criação da classe de superposição que é a VM, vou instalar o windows:
