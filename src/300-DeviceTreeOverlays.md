# Device Tree Overlays

Uma árvore completa de um sistema embarcado é tão complexa quanto é a topologia de seu hardware. O uso de diversos arquivos-fonte para compor uma _Device Tree_ é, assim, um facilitador.

Por exemplo, o já citado DTSI `am335x-bone-common.dtsi` (vide Figura \ref{imgBBBDTSFiles}) serve tanto à BeagleBone Black quanto à BeagleBone, e aos demais modelos que se seguirão.

No entanto, a forma como esses arquivos são combinados é o que garante a flexibilidade dessa solução.

## Sobreposição de nós

A diretiva `/include/` (ou `#include`) em um arquivo .dts, como já mencionado, anexa o arquivo .dtsi a ela vinculado. A forma como o _parser_ do kernel analisa o arquivo final faz com que a posição desta diretiva no código seja determinante.

Quando um caminho é definido mais de uma vez na DT eles são combinados. Isso se dá da seguinte maneira:

1- Propriedades similares são sobrepostas, prevalecendo a última.

2- Propriedades diferentes são combinadas.

Assim, um nó pode ser redefinido para que uma propriedade possa a ele ser adicionada, ou para que uma propriedade já definida tenha seu valor alterado.

A Figura \ref{imgDTNodeDefinition} ilustra esse caso.

Esta sobreposição acontece "fora do kernel", durante a construção do DTB.

## Sobreposição durante a execução

Algumas situações requerem que novos elementos sejam conectados ao sistema -- por exemplo a portas de GPIO ou a dispositivos de plataforma -- com uma frequência que não justifica a manutenção de DTB separados, uma para cada configuração. Mesmo que já não seja mais preciso recompilar o Kernel, tal procedimento exigiria se alterar e substituir o DTB.

Para os casos em que mesmo a sobreposição pré-DTB não é suficientemente flexível, há a sobreposição "no kernel", ou _in-kernel overlay_. Esta funcionalidade reside no Kernel, no arquivo `drivers/of/overlay.c` [@docDTOverlayNotes].

O conceito de _Device Tree Overlay_ (DTO) foi criado com o intuito de se agregar à DTB existente uma nova descrição de hardware, sobrecarregando nós já definidos por aquela [@urlEmailDTOverlay].

Uma DTS de _overlay_ possui alguns elementos peculiares:

* `fragment` -- Nó que define um bloco de sobreposição. Sua propriedade `target` estipula qual o nó que será sobreposto.

* `__overlay__` -- Nó que contém as propriedades a serem sobrescritas.

* `/plugin/` -- Instrução que informa ao compilador que ele deve poder gerar informações de linquedição [@urlRaspberryDT]. Isso para que o compilador não retorne erros de símbolos não encontrados (como o _phandle_ da propriedade `target`).

As demais regras para criação de arquivos de _overlay_ estão documentadas em [@docDTOverlayNotes].

Uma aplicação dessa técnica está listada na Figura \ref{imgDTOverlayExample}. Neste exemplo, extraído de [@urlTestCapeMgr], a configuração de multiplexação do pino P9-42 da BeagleBone Black está sendo alterada. Isso fica evidente se observado que: (1) este _overlay_ faz referência não apenas aos nomes de dispositivos (propriedade `compatible`); e (2) o multiplexador do _target_ am33xx é diretamente referenciado pelo _phandle_ `&am33xx_pinmux`.

As células `<0x164 0x07>` significam _offset_ de memória (164h), e a configuração de direção, tempo de subida e descida do sinal e modo de operação do multiplexador (que, combinados, formam 7h).

![Exemplo de _in-kernel overlay_.\label{imgDTOverlayExample}](src/images/imgDTOverlayExample.png)

## Gerenciador de Capes

Kits didáticos e de múltiplos propósitos como a BeagleBone Black e Arduíno, entre outros, são projetados de modo a suportarem expansões via linhas de comunicação analógica, digital, GPIO etc. Alguns projetistas então utilizam a pinagem padrão desses kits para criar expansões com funcionalidades completas, específicas e de fácil utilização. Na BeagleBone, tais produtos são conhecidos como _capes_.

Valendo-se da facilidade de conexão desses acessórios e da DTO, foi criado o _Cape Manager_, um utilitário capaz de listar, carregar e descarregar uma _cape_. [@urlCapeManagerCommit]

Cada _cape_ é representada por um arquivo de extensão `.dtbo`. Quando ela é conectada à BBB, o DTBO correto deve ser carregado para que configure os pinos de expansão (P8 e P9). Os DTBO, durante a execução, se encontram no diretório `/lib/firmware`. Lá podem haver binários referentes a extensões físicas e virtuais (elementos já presentes na placa).

A Figura \ref{imgCapesFirstBoot} mostra o estado inicial dos _slots_ disponíveis no dispositivo de teste. Nota-se que os _slots_ `4` e `5` estão ocupados com, respectivamente, os conectores eMMC (cartão de expansão de memória) e HDMI.

Há atualmente um número incontável de arquivos DTS para _capes_, como os que podem ser encontrados em [@urlCapeOverlays].

![Listagem dos _slots_, fornecida pelo _Cape Manager_.\label{imgCapesFirstBoot}](src/images/imgCapesFirstBoot.png)

Esta ferramenta será utilizada durante o experimento para carregar um hardware customizado em tempo de execução.
