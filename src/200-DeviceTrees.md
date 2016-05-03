# Device Tree

_Device Tree_ (DT) é uma estrutura de dados com topologia em árvore que descreve os elementos físicos de um sistema. Cada nó dessa árvore recebe um nome e contém propriedades no formato chave/valor. Os nós possuem, cada um, apenas um pai, exceto pelo nó raiz, que não possui nenhum. Assim, cada dispositivo é identificado de forma única: um caminho partindo do nó raiz e percorrendo todos os seus descendentes. [@specEPAPR p.14]

A DT pode descrever: CPUs do sistema, localização e tamanho da memória RAM, referências a outros nós (_aliases_), barramentos -- por exemplo populares I²C, SPI, PCI --, memória mapeada diretamente pela CPU, parâmetros personalizados pelo fabricante para uso pelo programa cliente, entre outros.

O padrão da _Device Tree_ (literalmente "árvore de dispositivos") foi criado pelo grupo de trabalho IEEE 1275 [@specIEEE1275] Open Firmware (OF) [@urlOF], para permitir que um só firmware provesse interface do Sistema Operacional a diferentes arquiteturas de hardware [@urlOFWelcome and @urlFW].

Essa mesma idéia foi então expandida para utilização em sistemas que não utilizam Open Firmware. Assim, criou-se o que se conhece hoje por _Flattened Device Tree_ (FDT), uma estrutura compilada como um binário independente. Esta passou a integrar arquiteturas como a do PowerPC [@paperSymphonyOfFlavors], o que a levou a ser incluída no código-fonte do Linux.

Segundo o _log_ do Kernel oficial, a primeira DT incluída no código-fonte do Linux foi o `mpc8641_hpcn.dts`, da linha PowerPC, em agosto de 2006.

## Justificativa

Durante o _boot_, o programa de inicialização (_bootloader_) carrega a FDT em memória e fornece ao cliente o endereço de seu nó-raiz, o que permite ao kernel navegar por toda a árvore. A FDT é, portanto, independente do cliente. Seu binário pode ser modificado e reintegrado ao sistema sem que seja necessário modificar e recompilar o kernel. Uma definição de hardware pode, ainda, ser carregada em tempo de execução utilizando _overlays_, como será explicado mais adiante.

Além disso, por concentrar o detalhamento do hardware na FDT, um mesmo kernel poderia ser compilado de forma genérica para mais de um sistema. Ainda que, dada a abrangência de plataformas alcançadas por seu código-fonte, seja necessário ou ao menos recomendável um ajuste de parâmetros de compilação.

Segundo [@pptVWoolELC09], desvantagens como o código adicionado ao kernel para decomposição da árvore de dispositivos e ciclos de _clock_ adicionais que elevariam o tempo de _boot_ seriam desprezíveis. Estas seriam compensadas pela eliminação de código específico da plataforma (os já citados `board-*`) e possibilidade de paralelização.

## DT para arquitetura ARM

A multiplicidade de placas com SoC baseados na arquitetura ARM, e a variedade de dispositivos periféricos a elas conectados, levou a proposições iniciais da adaptação da DT, já integrada ao Linux, para o ARM [@urlEmailLikely]. A dificuldade de adaptação, porém, estava ligada a essa mesma característica: recursos como multiplexação de pinos de I/O [@docPinctrl] ainda não haviam sido portados [@pptVWoolELC09].

Multiplexação de pinos é uma técnida adotada por fabricantes de SoC para reduzir a quantidade de pinos de I/O e, consequentemente, o espaço físico por eles ocupado. Isso, ao mesmo tempo, mantendo o número de expansões. É um recurso específico e complexo, composto de hardware (_pin controller_) e software (_device driver_) [@docPinctrl and @docBeagleboneAnd38Kernel].

Outra característica de sistemas embarcados e que motivou o aprimoramento da FDT é o uso de dispositivos de plataforma. Um controlador de plataforma, ou _platform driver_, conforme explica Prado em [@urlSergioDT2], "é uma abstração que permite que um controlador de dispositivo possa se registrar em um 'barramento virtual' do sistema, já que fisicamente o barramento não existe". Seu uso é necessário quando o hardware não está conectado a barramentos auto-enumeráveis como o PCI ou o USB  [@paperCorbetPlatform1].

Como relatado por L. K. C. Leighton em um e-mail à comunidade Debian [@emailLKCL], a DT não seria a bala de prata para a padronização na arquitetura ARM, na qual fabricantes e grupos de trabalho independentes utilizavam diferentes periféricos, barramentos e conexões. "O problema seria transferido do Kernel para a Device Tree".

No entanto, a acomodação de todas essas novas arquiteturas levara a um grande volume de submissões de _patches_ específicos por terceiros. Isso fez com que Linus Torvalds, o principal mantenedor da distribuição oficial do sistema por ele criado, passasse a rejeitar a inclusão de novos sistemas baseados em ARM.

A solução para eliminação de código específico de _boards_ tounou-se premente. Assim, os arquivos de DT para a arquitura ARM foram, finalmente, integrados na versão 3.7 do Kernel, e são desde então mantidos por sua comunidade de desenvolvedores.

## Organização no Linux

Por padrão, arquivos de código-fonte da DT levam extensão DTS (_device tree source_) e DTSI (_device tree source includes_). Esses arquivos têm formato texto e são legíveis por humanos. Compilados, os binários levam a extensão DTB (_device tree blob_). Há ainda os arquivos DTBO (_device tree blob overlay_), que serão tratados mais adiante.

A árvore de dispositivos no Linux foi criada como uma série de arquivos DTS e DTSI, organizados conforme a hierarquia de hardware que ela descreve, conforme ilustrado na Figura \ref{imgDTHierarchy}.

O DTS da placa inclui arquivos DTSI mais genéricos como o do SoC.

![Uma forma de hierarquizar arquivos da DT via _includes_, adaptado de [@bookDT4Dummies] p. 18\label{imgDTHierarchy}](src/images/imgDTHierarchy.png)

No código-fonte do Linux, os DTS para a plataforma ARM podem ser encontrados em `arch/arm/boot/dts`. O `Makefile` neste diretório determina quais as DTBs geradas com o kernel [@bookDT4Dummies p. 11 and @srcArchArmBootDtsMakefile].

## FDT para Beaglebone Black

Baseadas em ARM, as placas Beagleboard tiveram seu hardware descrito em FDT à partir do modelo BeagleBone Black (BBB), lançada em abril de 2013 com a versão 3.8 do Kernel [@urlAdafruitIntroduction and @urlDigikeyPR201304].

Na distribuição do Kernel para esta placa, os seguintes arquivos formam o código-fonte de sua _Device Tree_. A ordem é do mais para o menos específico:

* `am335x-boneblack.dts` -- DTS do modelo Beaglebone Black. Configurações específicas dessa placa, como a do GPIO1[20].

* `am335x-bone-common.dtsi` -- DTS da TI AM335x BeagleBone. Descrição do hardware desse dispositivo, como: região de memória, multiplexação de pinos (deslocamento e configuração), LEDs, localização dos barramentos I²C, memória MMC entre outros.

* `am33xx.dtsi` -- DTS dos SoC AM33xx. Descrição das CPUs e conexões deste SoC, muitas das quais serão sobrescritas pelos DTS especializados.

* `skeleton.dtsi` -- Apenas um _stub_ com o mínimo necessário para o funcionamento da DT. Os valores serão preenchidos por DTS mais específicas.

A Figura \ref{imgBBBDTSFiles} ilustra as relações entre esses arquivos. Eles serão compilados e, compostos, formarão um arquivo DTB a ser embarcado na memória da BBB.

![Hierarquia da _device tree_ da Beaglebone Black, segundo os arquivos .dts e .dtsi de seu Kernel. As setas representam a instrução `include`\label{imgBBBDTSFiles}](src/images/imgBBBDTSFiles.png)

## Sintaxe

Os componentes básicos da árvore são: nó (dispositivo ou subsistema de um dispositivo); e propriedade de nó (seu endereço na memória física, por exemplo).

Para ser compatível com o padrão ePAPR, uma árvore deve conter ao menos dois nós em sua raiz: um nó `cpus`, e ao menos um nó `memory`. [@specEPAPR p. 37]

Uma relação abrangente dos nós padronizados pode ser obtida em [@urlDTUsage] e em [@specEPAPR].

O nome de um nó deve ser algo genérico, que reflita a função do dispositivo. [@specEPAPR p.17] Nomes como `cpu`, `i2c`, `serial`, `display` e `usb`, por exemplo, estão entre os sugeridos na especificação.

Nós irmãos, filhos de um mesmo elemento genérico, são individualmente identificados por seu endereço de unidade (`unit-address`), e o supra-citado caminho de um dispositivo até o elemento raiz é separado por `/`.

Um exemplo simplificado da sintaxe utilizada pode ser visto na Figura \ref{imgGenericDTExample}. Esses e outros elementos e palavras-chave serão explicados a seguir.

![Exemplo simplificado de um arquivo de _Device Tree_. Fonte: [@bookDT4Dummies] p. 10\label{imgGenericDTExample}](src/images/imgGenericDTExample.png)

* **Node name --** Um nó especificado ou criado pelo fabricante, a ser referenciado no código-fonte.

* **Unit address --** O endereço na memória relativo a este nó. Este endereço é o endereço-base de `reg`, quando o nó possui essa propriedade, ou o endereço base + _offset_.

* **Property name --** Uma propriedade especificada ou criada pelo fabricante.

* **Property value --** O valor da propriedade pode ser uma string. A propriedade `compatible`, por exemplo, define em uma lista de strings o hardware compatível com o nó em questão, ordenada a partir do mais compatível (o próprio equipamento) até o menos compatível [@urlDTUsage].

* **Bytestring --** O valor de uma propriedade pode ser também uma sequência de bytes expressos em hexadecimal.

* **Phandle --** O _phandle_ é uma construção peculiar à DT, e referencia um outro nó por meio um endereço. Por exemplo, `&cape_eeprom0` é uma referência ao nó `cape_eeprom0`, ou melhor, ao seu endereço único.

* **Label --** Um rótulo para um nó em particular. Desta forma, o nó `node@1` pode ser referenciado no restante da árvore como `&node1`.

* **Cell --** Uma célula é um `uint32` [@urlDTUsage]. Um exemplo notável de utilização desses valores é a propriedade `reg`, para posições ou regiões de memória. Uma região de memória em uma arquitetura 32-bit é definida por conjuntos de 2 células: uma para a memória-base e outra para o seu tamanho. Por exemplo, `<0x80000000 0x10000000>`. Já em arquiteturas 64-bit esse valor é expresso em 4 células, pois o endereço-base e tamanho ocupam, cada um, 64 bits.

* **Include --** Include é uma diretiva que anexa ao DTS final o arquivo a que ele se refere.

O valor de uma propriedade, quando vazio, indica que esta é booleana e possui valor verdadeiro. Por exemplo, a propriedade `gpio-controller`, que será utilizada no experimento.

Uma propriedade pode, ainda, ter valor composto por diferentes tipos de dados, separados por vírgulas [@urlDTUsage].

Outros valores podem ser encontrados em [@specEPAPR pp. 19-20].

## A FDT na imagem do sistema

Código-fonte de DT é compilado utilizando o _Device Tree Compiler_ (DTC). Essa ferramenta recebe arquivos-fonte, binários ou até mesmo uma representação como sistema de arquivos (_fs_), e os compila em um binário (DTB) ou instruções ASM [@docDTCManual].

A ferramenta `fdtdump`, distribuída junto com o DTC, é capaz de interpretar a FDT (no formato DTB) e exibi-la de forma legível [@docDTCManual], equivalente a um DTS. Desse modo pode-se ver, antes de carregar o binário na placa, como os nós de diversos DTB e DTBI foram combinados.

O DTB é então carregado na memória _flash_ (ou seu equivalente), da mesma forma que as imagens do kernel, _bootloader_, sistema de arquivos etc.

Segundo [@pptARMArchPetazzoni2012], dois cenários devem ser considerados ao se embarcar o DTB:

1- **O _bootloader_ possui suporte a DT --** caso normal em que, como já mencionado, o endereço do arquivo DTB é passado ao kernel pelo registrador `r2`, no caso do ARM.
2- **O _bootloader_ _não_ possui suporte a DT --** o DTB nesse caso poderá ser concatenado à imagem do Kernel, desde que este tenha sido compilado com a opção `CONFIG_ARM_APPENDED_DTB` (mais detalhes em [@urlLKDDBConfigARMAppendedDTB]).

Durante o processo de _boot_, o _bootloader_ reservará memória RAM e nela carregará o arquivo DTB. Então, pelo registrador, fornecerá ao kernel seu endereço físico. O kernel então validará esse endereço de modo a reconhecer que trata-se de uma FDT [@docArmBooting and @docBootingWithoutOF].

Uma forma de se visualizar a FDT atualmente em memória é através de uma das abstrações do kernel, quando ativada a opção `CONFIG_PROC_DEVICETREE` [@urlLKDDBProcDeviceTree] ativa. A Figura \ref{imgProcDeviceTree} mostra uma pequena parte da DT da BeagleBone Black abstraída como um sistema de arquivos em `/proc/device-tree`.

![Parte da árvore da BeagleBone Black, mostrando os 4 LEDs acessíveis via GPIO.\label{imgProcDeviceTree}](src/images/imgProcDeviceTree.png)
