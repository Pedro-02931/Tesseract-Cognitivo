---
description: Simbolica
---

# ClinicaApp.java

{% code overflow="wrap" %}
```java
package br.sp.senai.jandira.clinica;

import br.sp.senai.jandira.clinica.model.Paciente;
import java.time.LocalDate;
import java.util.function.Function; // Import para arrow functions (lambda)

/**
 * Classe ClinicaApp representa o ponto de entrada da aplicação.
 *
 * Nesta versão, são usadas arrow functions para:
 * - Mapear a impressão de mensagens com formatação ANSI.
 * - Converter objetos Paciente em suas representações concatenadas.
 *
 * Para impressão com formatação de cores no terminal, utiliza-se ANSI Escape Codes.
 * Caso queira aprimorar visualizações, bibliotecas como JANSI podem ser integradas.
 */
public class ClinicaApp {

    public static void main(String[] args) {
       // --- Arrow Function: AnsiPrinter ---
       // Definindo uma interface funcional para impressão com formatação ANSI.
       // Esta lambda (arrow function) recebe uma String e imprime-a com cor amarela.
       AnsiPrinter ansiPrinter = message -> System.out.println("\u001B[33m" + message + "\u001B[0m");

       // Impressão utilizando o lambda definido.
       ansiPrinter.print(">>> Instâncias criadas: ");

       // Instanciação de dois objetos Paciente.
       Paciente p1 = new Paciente();
       Paciente p2 = new Paciente();

       // Exibe as referências dos objetos (ponteiros para os objetos).
       ansiPrinter.print(p1.toString());
       ansiPrinter.print(p2.toString());
       System.out.println();

       // Configuração dos dados do primeiro paciente
       p1.setNome("Ana Maria");
       p1.setPeso(68);
       p1.setAltura(1.60);
       p1.setGenero("f");
       p1.setDataNascimento(LocalDate.of(1990, 5, 15));
       p1.setTelefone("(11) 91234-5678");

       // Configuração dos dados do segundo paciente
       p2.setNome("Jó");
       p2.setPeso(83);
       p2.setAltura(1.80);
       p2.setGenero("m");
       p2.setDataNascimento(LocalDate.of(1985, 8, 20));
       p2.setTelefone("(21) 99876-5432");

       // Exibe os dados formatados de cada paciente
       p1.exibirDados();
       p2.exibirDados();

       // Demonstração dos métodos implementados
       p1.marcarConsulta();
       p2.marcarConsulta();

       p1.calcularIdade();
       p2.calcularIdade();

       p1.CalcularImc();
       p2.CalcularImc();

       p1.classificarImc();
       p2.classificarImc();

       // --- Arrow Function: mapeando a concatenação de dados ---
       // Usamos a interface Function para mapear um objeto Paciente à sua String de dados concatenados.
       Function<Paciente, String> mapPaciente = paciente -> paciente.concatDados();

       ansiPrinter.print(">>> Dados concatenados:");
       // Uso da arrow function para converter e imprimir os dados dos pacientes.
       ansiPrinter.print(mapPaciente.apply(p1));
       ansiPrinter.print(mapPaciente.apply(p2));
    }
}

/**
 * Interface funcional para impressão com formatação ANSI.
 * Representa uma arrow function que recebe uma mensagem (String) e a imprime.
 */
@FunctionalInterface
interface AnsiPrinter {
    void print(String message);
}
```
{% endcode %}
