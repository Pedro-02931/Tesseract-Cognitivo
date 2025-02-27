# 2. Expandindo ISO e Definição de Heurísticas

### **2. Expandindo ISO e Definição de Heurísticas**

{% embed url="https://drive.google.com/file/d/1OGT3vschZPdSlDhLvPMu7ab4Q6eOXC27/view?usp=sharing" %}
Video de instalação
{% endembed %}



Agora, com tudo pronto, iniciei a VM para instalar o Windows 10 Pro. Enquanto o instalador carregava, fui registrando os pontos num DAG mental (ou seja, uma sequência de passos encadeados) no caderno e, por conta de performance, movi toda a pasta (ISO + VDI) para o disco C por conta de otimização.&#x20;

No caso, planejo documentar e gerar um script que automatiza isso.

***

#### **2.1 Boot a Partir do CD (ISO)**

Assim que dou “Iniciar” na VM, o VirtualBox monta a ISO como se fosse um CD real:

1. **Ativação de Licença**
   * **Pergunta**: “Deseja inserir a chave de produto agora?”
   * **O que rola internamente?**
     * O Windows faz uma checagem inicial de hash e verificação da licença, baseada em _algoritmos criptográficos_ (SHA, RSA, etc.).
       * Por isso pode ser ativada offlinte, dado que ele pega a integridade de parametros fixos e geram um hash unico e computacionalmente impossivel de repetição~~(a menos que você use uma malha de qubits, mas ai tem que me pagar para fazer(E CONSIGO).~~
     * No caso, eu deixei o periodo de teste.
2. **Uso dos Blocos (Particionamento Automático)**
   * Cliquei em “Criar” no espaço não alocado, sem mexer manualmente nas partições. O instalador criou a “Partição 0” de sistema, e depois a partição principal.
   * **Como o filesystem opera?**
     * O Windows utiliza NTFS (ou às vezes GPT com EFI, mas aqui estou no BIOS/MBR). Ele gera uma **pequena partição reservada** para armazenar bootloader e dados de recuperação.
     * Esse “Partição 0” contém arquivos fundamentais de inicialização.
3.  **Função Matemática (Cápsula) para Criar Partições**\
    Abaixo um pseudo-script imaginário, **super resumido**, para representar essa criação automática:

    ```c
    CreatePartitionsAuto(int totalSizeGB) {
        // 1) Definir partição de sistema (500 MB ~ 0.5 GB, arredondado)
        // 2) Definir partição principal (restante do espaço)
        // 3) Aplicar formatação NTFS
        // 4) Ajustar flags de boot

        // Explicação inferencial:
        //   - Passo (1) => Cria "Partição 0" (bootloader)
        //   - Passo (3) => NTFS com MBR ou GPT (dependendo do firmware)
        //   - "colapso de estados" = Alocar efetivamente os blocos no disco virtual

        // Aqui retorna 0 se deu tudo certo, ou outro valor se algo falhou
        return 0;
    }
    ```

    **Inferência resumida**: O instalador mede o espaço livre, reserva \~500 MB para a partição de sistema e formata o restante. Isso ocorre em milissegundos, mas, sob o capô, envolve checagem de blocos e criação de metadados (MFT para NTFS).

***

#### **2.2 Instalação Automática**

1. **Copiando Arquivos**
   * O instalador lê a ISO e transfere o conteúdo para o disco virtual.
   * Em termos de “hash mapping”, ele verifica a integridade de cada arquivo (CAB, WIM etc.), gerando checksums para garantir que não haja corrompimento.
2. **Preparando os Arquivos para Instalação**
   * Esse passo é mais demorado, pois o sistema expande o arquivo principal (Install.wim) e extrai todos os binários do Windows para o disco.
   * As “regras heurísticas” do instalador identificam drivers básicos e ajustam registro (Registry) inicial.
3. **Reinicio?**
   * Após esses processos, o Windows Setup instala o bootloader na Partição 0 e precisa de um reboot para ativar o _mini-SO_ que faz a continuidade da instalação (configurações de rede, drivers, etc.).
   * No reinício, a VM boota diretamente do disco (não mais da ISO), finalizando a instalação de recursos.
4. **Instalação de Recursos**
   * Aqui, rola a detecção de hardware virtual (placa de rede, som, vídeo) e a aplicação de configurações padrão do Windows.
   * Sem grandes intervenções manuais, é basicamente a reta final da instalação.

***

### **3. Configurando Exibição**

Com o Windows 10 agora rodando, inseri o “CD de Adicionais para Convidados” do VirtualBox. Isso melhora drasticamente a experiência dentro da VM:

1. **VirtualBox Guest Additions**
   * Este pacote injeta **drivers otimizados** e ferramentas que permitem redimensionamento de tela, mouse integrado, compartilhamento de área de transferência e pastas.
   * Sem isso, a VM fica bem limitada em termos de interação.
2. **Direct3D Support**
   * Ativa aceleração de vídeo 3D quando suportado, melhorando performance gráfica e a responsividade de janelas.
   * Essencial se você quer rodar aplicações 3D ou apenas ter o sistema mais fluido.
3. **Start Menu Entries**
   * Cria atalhos no sistema convidado para acessar as ferramentas do VirtualBox (ex.: “VirtualBox Guest Additions” no painel de programas).
   * Ou seja, fica prático reinstalar ou atualizar esses complementos.

Depois disso, decidi usar **tela cheia** em outro workspace. A integração fica muito mais “transparente”, quase como se o Windows 10 estivesse rodando direto no meu hardware.

***

#### **Resumo Rápido**

* **Movi tudo para SSD** para acelerar a instalação.
* **Boot** e **Licença**: Selecionei teste e segui adiante.
* **Particionamento**: Deixei na forma automática, gerando a Partição 0 de sistema e a principal.
* **Copiando & Preparando**: Expansão dos arquivos do Windows, verificação de hashes, criação de metadados.
* **Reinício**: Bootloader configurado na Partição 0.
* **Guest Additions**: Drivers e recursos que otimizam a experiência de uso, incluindo Direct3D e atalhos no menu.

Tudo pronto, Windows 10 Pro rodando lisinho na VM, com desempenho melhor após migração para SSD e instalação das Guest Additions.

> **No final das contas**, a “Definição de Heurísticas” envolve deixar o instalador cuidar das partições, os blocos serem gerenciados automaticamente, e a migração do VDI/ISO para SSD trouxe um ganho notável de performance para esta atividade.
