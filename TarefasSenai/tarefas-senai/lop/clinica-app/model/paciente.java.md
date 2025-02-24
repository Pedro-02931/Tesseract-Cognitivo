---
description: 'Representação:'
---

# Paciente.java

{% code overflow="wrap" %}
````java

package br.sp.senai.jandira.clinica.model;

import java.time.LocalDate;
import java.time.Period;

/**
 * Classe Paciente representa os dados de um paciente e contém métodos para
 * agendamento de consulta, cálculo de IMC, classificação do IMC e concatenação dos dados.
 *
 * Foram adicionadas otimizações e comentários detalhados explicando o uso de operadores ternários
 * e referências (ponteiros) no código.
 *
 * Para impressão colorida, os métodos que exibem dados agora incorporam ANSI Escape Codes.
 */
public class Paciente {

    // Atributos públicos e privados do paciente
		public String nome;
		private double peso;
		private double altura;
		private String genero;
		private String telefone;
		private LocalDate dataNascimento;

    // Constantes ANSI para formatação de saída no terminal
		public static final String ANSI_RESET = "\u001B[0m";
		public static final String ANSI_CYAN = "\u001B[36m";
		public static final String ANSI_YELLOW = "\u001B[33m";

    
    public void setGenero(String genero) {
       if (genero.equalsIgnoreCase("m") || genero.equalsIgnoreCase("f") || genero.equalsIgnoreCase("o")) {
          this.genero = genero.toUpperCase();
       } else {
          System.out.println(ANSI_YELLOW + "O gênero deve ser \"M\", \"F\" ou \"O\"" + ANSI_RESET);
       }
    }


    public void setNome(String nome) {
       this.nome = (nome.length() > 3) ? nome : this.nome;
       if (nome.length() <= 3) {
          System.out.println(ANSI_YELLOW + "O nome deve conter mais do que 3 caracteres" + ANSI_RESET);
       }
    }

    public void setPeso(double peso) {
       this.peso = (peso > 0) ? peso : this.peso;
       if (peso <= 0) {
          System.out.println(ANSI_YELLOW + "O peso deve ser maior do que ZERO!" + ANSI_RESET);
       }
    }


    public double getPeso() {
       return this.peso;
    }


    public void setAltura(double altura) {
       this.altura = (altura > 0.5) ? altura : this.altura;
       if (altura <= 0.5) {
          System.out.println(ANSI_YELLOW + "A altura deve ser maior que 0,5m!" + ANSI_RESET);
       }
    }

    public double getAltura() {
       return this.altura;
    }


    public void setTelefone(String telefone) {
		/**
		 * Define o telefone do paciente.
		 *
		 * @param telefone String com o número de telefone
		 */
		/**
		 * Define o telefone do paciente, aceitando formatos fixo, celular e internacional.
		 *
		 * Formatos aceitos:
		 * - Telefone fixo: (XX) XXXX-XXXX
		 * - Telefone celular: (XX) 9XXXX-XXXX
		 * - Celular internacional: +55 (XX) 9XXXX-XXXX
		 *
		 * Otimizações:
		 * - Validação e atribuição inline usando operador ternário.
		 * - Uso de lambda para exibir mensagens de erro dinâmicas e coloridas (ANSI).
		 * - Toda a lógica está concentrada no próprio setter.
		 */
       final String ANSI_RESET = "\u001B[0m";
       final String ANSI_RED = "\u001B[31m";

       // Expressões regulares para cada tipo de telefone
       String regexFixo = "^\\(\\d{2}\\)\\s\\d{4}-\\d{4}$";                // (XX) XXXX-XXXX
       String regexCelular = "^\\(\\d{2}\\)\\s9\\d{4}-\\d{4}$";             // (XX) 9XXXX-XXXX
       String regexInternacional = "^\\+55\\s\\(\\d{2}\\)\\s9\\d{4}-\\d{4}$"; // +55 (XX) 9XXXX-XXXX

       // Interface funcional para formatação de mensagens de erro com lambda inline
       ErroTelefoneFormatter erroFormatter = tipo -> String.format(
             ANSI_RED + "Número de telefone inválido: '%s'. " +
                   "O formato esperado para %s é:\n" +
                   " - Fixo: (XX) XXXX-XXXX\n" +
                   " - Celular: (XX) 9XXXX-XXXX\n" +
                   " - Internacional: +55 (XX) 9XXXX-XXXX" + ANSI_RESET,
             telefone, tipo
       );

       // Operador ternário aninhado para validação, atribuição ou exibição de erro
       this.telefone = telefone.matches(regexFixo) ? telefone
             : telefone.matches(regexCelular) ? telefone
             : telefone.matches(regexInternacional) ? telefone
             : System.out.println(erroFormatter.formatar(
             telefone.startsWith("+55") ? "Celular Internacional"
                   : telefone.startsWith("(") ? "Celular ou Fixo"
                   : "Formato Desconhecido"
       )) == null ? "" : ""; // Essa gambiarra final(? "" : "") é para que a expressão toda retorne "", garantindo que o this.telefone não receba um valor inválido.
    }

 
    public String getTelefone() {
       return this.telefone;
    }

    public void setDataNascimento(LocalDate dataNascimento) {
       this.dataNascimento = dataNascimento;
    }

    /**
     * Retorna a data de nascimento do paciente.
     *
     * @return LocalDate data de nascimento
     */
    public LocalDate getDataNascimento() {
       return this.dataNascimento;
    }

    /**
     * Método para agendar uma consulta para o paciente.
     * Simula o agendamento exibindo uma mensagem com formatação ANSI.
     */
    public void marcarConsulta() {
       System.out.println(ANSI_CYAN + ">>> Consulta marcada com sucesso para o paciente: " + this.nome + ANSI_RESET);
    }

    /**
     * Calcula e exibe a idade do paciente com base na data de nascimento.
     *
     * Utiliza um operador ternário para verificar se a data de nascimento está definida.
     */
    public void calcularIdade() {
       int idade = (this.dataNascimento != null) ?
             Period.between(this.dataNascimento, LocalDate.now()).getYears() : 0;
       System.out.println(ANSI_CYAN + ">>> Idade do paciente " + this.nome + ": " +
             (idade > 0 ? idade + " anos" : "Data de nascimento não definida") + ANSI_RESET);
    }

    /**
     * Calcula o IMC (Índice de Massa Corporal) do paciente e exibe o valor formatado.
     * Utiliza operador ternário para evitar divisão por zero.
     */
    public void CalcularImc() {
       double imc = (this.altura > 0) ? this.peso / (this.altura * this.altura) : 0;
       System.out.printf(ANSI_CYAN + ">>> IMC do paciente %s: %.2f\n" + ANSI_RESET, this.nome, imc);
    }

    /**
     * Classifica o IMC do paciente de acordo com os padrões reconhecidos.
     * Utiliza operadores ternários aninhados para determinar a classificação.
     */
    public void classificarImc() {
       if (this.altura > 0) {
          double imc = this.peso / (this.altura * this.altura);
          String classificacao = imc < 18.5 ? "Abaixo do peso" :
                (imc < 25 ? "Peso normal" :
                      (imc < 30 ? "Sobrepeso" : "Obesidade"));
          System.out.printf(ANSI_CYAN + ">>> Classificação do IMC do paciente %s: %s\n" + ANSI_RESET, this.nome, classificacao);
       } else {
          System.out.println(ANSI_YELLOW + ">>> Altura inválida para classificação do IMC para o paciente: " + this.nome + ANSI_RESET);
       }
    }

    /**
     * Exibe os dados do paciente de forma formatada no terminal.
     * As saídas são mapeadas com cores usando ANSI Escape Codes.
     */
    public void exibirDados() {
       String unidadePeso = "Kg.";
       String unidadeAltura = "m.";
       System.out.println(ANSI_CYAN + "------------------------------------" + ANSI_RESET);
       System.out.println(ANSI_CYAN + "DADOS DO PACIENTE" + ANSI_RESET);
       System.out.println(ANSI_CYAN + "------------------------------------" + ANSI_RESET);
       System.out.println("Nome: " + this.nome);
       System.out.printf("Peso: %.2f %s\n", this.peso, unidadePeso);
       System.out.printf("Altura: %.2f %s\n", this.altura, unidadeAltura);
       System.out.println("Gênero: " + this.genero);
       System.out.println(ANSI_CYAN + "------------------------------------\n" + ANSI_RESET);
    }

    /**
     * Retorna uma string que concatena os dados principais do paciente.
     *
     * @return String com os dados concatenados do paciente.
     */
    public String concatDados() {
       return "Paciente: " + this.nome
             + " | Peso: " + this.peso + " Kg"
             + " | Altura: " + this.altura + " m"
             + " | Gênero: " + this.genero;
    }

    /**
     * Getter para o nome do paciente.
     *
     * @return String nome
     */
    public String getNome() {
       return this.nome;
    }
}
```
````
{% endcode %}
