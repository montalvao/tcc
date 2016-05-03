# Experimento

Este experimento visa comprovar, na prática, a atuação do gerenciador de _capes_ e do mecanismo de _binding_ da DT. Isso foi feito criando-se um arquivo DTS de _overlay_ e carregando-o em um _slot_ da _cape manager_.

O controlador em questão, ao qual é feita a ligação com a DT, é um expansor de I/O. Tal dispositivo é empregado quando há carência de portas GPIO, pois utiliza apenas 2 pinos -- _clock_ e _data_ -- e direciona os comandos seriais para 8 novas portas. Assim, seu controlador _expande_ a capacidade da placa provendo novos GPIOs que serão, neste caso, utilizados para controlar um display LCD 16x2.

O objetivo desta experimento é, unicamente, comprovar o funcionamento da _cape_. O uso do LCD foi empregado apenas por motivos didáticos. Ele é similar ao realizado por D. Molloy em [@bookExploringBB].

## Configuração

Para a demonstração foi utilizada a placa de desenvolvimento BeagleBone Black Rev. C, equipada com um processador Sitara AM3358BZCZ100 ARM Cortex-A8 de 1GHz, memória RAM de 512MB e memória eMMC de 4GB. Entre outras características de hardware, esta placa possui conectores de expansão para até 69 GPIOs, além de barramentos I²C. [@manualBBBSRM]

O Sistema Operacional utilizado foi o `Linux beaglebone 3.8.13-bone47`, pré-embarcado pelo fabricante.

## Preparação

Os seguintes equipamentos foram conectados à BBB:

* Display de caracteres 16x2 Hitachi HD44780.
* Expansor de I/O para os pinos do LCD, equipado com o controlador Philips PCF8574AT.
* Fonte de alimentação de 5V, ligada à placa para que fosse possível alimentar o LCD pelo pino `VDD_5V`. [@manualBBBSRM p.80]
* Conversor USB-Serial FTDI, para leitura do console da BBB.

Um conversor de nível lógico chegou a ser utilizado mas não foi necessário, pois o PCF8574AT aceitou o nível de 3.3V padrão da BBB [@manualPCF].

Através da ferramenta `i2cdetect` pôde-se conferir que o conjunto foi detectado pelo controlador do barramento I²C. O dispositivo foi conectado ao barramento `1`, no endereço `0x3f`.

Este barramento corresponde aos pinos `19` (SCL) e `20` (SDA) da BBB, devidamente configurados para atuar em MODE 3, conforme determinado no manual [@manualBBBSRM p.80]. A Figura \ref{imgAM33xxPinmuxDTS} mostra o trecho da DTS que indica essa configuração.

![Trecho do arquivo `am335x-bone-common.dtsi` com a configuração dos pinos.\label{imgAM33xxPinmuxDTS}](src/images/imgAM33xxPinmuxDTS.png)

## Execução

O experimento consiste em criar um arquivo de _overlay_ de DT que será carregado pelo _cape manager_. Este fragmento de DT identifica o expansor de I/O da interface I²C conectada ao LCD.

A Figura \ref{imgCapeBoneInatel} mostra a listagem do arquivo DTS criado, que seria compilado para o formato DTBO, de _overlay_. Este arquivo foi criado com base nas regras de _binding_ do controlador `pcf8574a`, disponíveis em [@docPCFDriverBinding]. Dentre as propriedades indicadas nesta DTS, destacam-se:

![Listagem do arquivo `cape-bone-inatel-00A0.dts`.\label{imgI2CBusBeforeAfterCape}](src/images/imgCapeBoneInatel.png)

* `part-number` -- Identificação da _cape_.
* `fragment@0` -- O único fragmento deste _overlay_.
* `target` -- Indica que este fragmento irá sobrescrever dados do nó `i2c2`. Este nó é definido diretamente na DTS do SoC.
* `gpio@3f` -- Novo nó, identificando o dispositivo no endereço `0x3f`. Este valor é apenas um indicativo, pois o endereço está na propriedade `reg`.
* `compatible` -- Identifica o controlador com o texto exatamente como definido na regra de _binding_.
* `reg` -- O endereço do dispositivo no barramento.
* `gpio-controller` -- Indica que o nó é um controlador de GPIO.

O objetivo de se aplicar este _overlay_ é que, uma vez carregado, o mecanismo de _binding_ faça com que o _probe_ do controlador do expansor de I/O seja chamado, e este passe a controlar o dispositivo.

Este controlador em particular [@codePCFDriver] disponibiliza 8 GPIOs virtuais que, como os demais, podem ser acessados através do endereço `/sys/class/gpio`. Desse modo, foi possível enviar comandos aos pinos do LCD através do console.

Um _script_ em _bash_ foi especialmente criado para este fim. Ele foi baseado na biblioteca PyLCD [@urlPyLCD] de autoria de M. Skolaut. No entanto, em vez de utilizar comandos SMBUS, determina o nível lógico de cada GPIO.

A mensagem `gpiochip_add: registered GPIOs 248 to 255 on device: pcf8574a`, vinda do kernel, confirma o registro dos novos GPIOs. `gpiochip_add` é a função do driver de gpio responsável por registrar GPIOs [@docGPIODriver]. Esta função é chamada pelo controlador do pcf8574a [@codePCFDriver].

## Resultados

A Figura \ref{imgI2CBusBeforeAfterCape} mostra o estado do barramento I²C 1 antes e depois de ativada a _cape_. Pode-se notar o endereço `0x3f` passa a indicar `UU`, pois está sendo utilizado. Agora ele é acessível apenas por seu controlador.

![Barramento 1 de I²C, antes e depois de ativada a _cape_.\label{imgI2CBusBeforeAfterCape}](src/images/imgI2CBusBeforeAfterCape.png)

Já as Figuras \ref{imgInatelCape} e \ref{imgPCF857xDriverBinding} mostram que a _cape_ foi carregada e o controlador `pcf8574a`, ativado. O acesso para os GPIOs virtuais `248` a `255` é feito via console exportando-se cada um deles, do mesmo modo que em [@bookExploringBB].

![Cape personalizada carregada no slot 7.\label{imgInatelCape}](src/images/imgInatelCape.png)

![O Kernel mostra que o controlador foi ligado ao dispositivo. Esta imagem foi simplificada para mostrar apenas a informação relevante.\label{imgPCF857xDriverBinding}](src/images/imgPCF857xDriverBinding.png)

Por fim, conforme pode ser visto na Figura \ref{imgFinal}, foi possível se escrever no display.

![LCD 16x2 conectado à BeagleBone Black. O adaptador I²C com o expansor de I/O está localizado atrás do LCD.\label{imgFinal}](src/images/imgFinal.jpg)
