---
description: Lógica por trás da quantização
---

# Lidando com o Efeito Borboleta com Quantização Decimal de 4º Ordem

Bom, quando rodei o primeiro prototipo e testei no LLM, decidi usar outro LLM para avaliar a acuracia da previrão, e ele apontou erros como valores absurdos. Então percebi que é por conta de falta de arredondamento, dado que se pequenas mudanças na virgula causam valores absurdos. ~~Bus speed 232434342? Mano, sou inteligente, mas não a ponto de codar a m.aquina de turing kkkkk~~

No caso foi empregado na mão o metodo mindpoint-rouding(quando o número tá exatamente no meio entre dois inteiros (tipo 2.5), ele arredonda ro mais próximo par(no caso, 2.0). Isso evita viés no arredondamento, mantendo a média dos números mais estável em operações repetidas. É tipo jogar uma moeda quântica que sempre escolhe o caminho mais equilibrado no longo prazo.

Bom, isso reduz drasticmente o ruído computacional a uma ordem de magnitude insignificante ($$\Delta_{err} < 1 \cdot 10^{-4}$$(por isso round4) a precisão em cálculos de alta frequência

A maneira imbecil de explicar isso seria só falar que o erro fica tão pequeno que praticamente  não afeta em nada, tipo menor que 0.0001 e cálculos de alta frequência significa operações rápidas e repetidas, o arredondamento não vai distorcer o resultado. Dava para explicar sem física quantica, mas quero demonstrar o quanto sou desumilde

{% code overflow="wrap" %}
```powershell
function round4 {
    param(
        [double]$value
    )
    <#
        Cálculo: round4(x) = ([math]::Round(x * 10000.0)) / 10000.0
        Crítico: 
    #>
    return ([math]::Round($value * 10000.0) / 10000.0)
}
```
{% endcode %}

* No cálculo, ele executa a função `([math]::Round(x * 10000.0)) / 10000.0`, que basicamente multiplica por 10.000 para empurrar as casas decimais para frente e arredonda pro inteiro mais próximo e depois divide de volta para ter 4 dígitos após a virgula.
* Removendo na mão o efeito borboleta para a escala de uso, elimina-se a deriva térmica e estabiliza os valores em modelos de alta performance, como aqueles processados em clusters HPC.
* Lógico, tinha o jeito fácil de fazer com bibliotecas, mas sou preguiçoso, e para mim é mais reiventar a roda. Multiplica o valor por **10.000**, arredonda e divide de volta, garantindo **4 casas decimais** fixas.&#x20;
* Essa abordagem evita que microvariações numéricas causem explosões de valor. É tipo segurar o volante firme numa estrada cheia de buracos: mantém o curso mesmo quando o terreno treme.

