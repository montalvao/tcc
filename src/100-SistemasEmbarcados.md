<!--
  TODO:
    (*) Referências adicionais, caso sejam necessárias:
      https://www.kernel.org/doc/Documentation/arm/Booting
      https://lists.ozlabs.org/pipermail/devicetree-discuss/2010-May/002132.html
-->

# Sistemas Embarcados

O sistema operacional GNU Linux comunica-se com hardware através de chamadas de sistema, ou _system calls_. Essas chamadas são, em última instância, tratadas por um sofware específico, o controlador de dispositivos (_device driver_). Para que um _driver_ possa acessar determinado hardware, este precisa, de alguma maneira, conhecer algumas de suas características físicas. Por exemplo: seu endereço físico em um barramento, endereço e tamanho da memória acessível ao usuário, tamanho de blocos de dados, interrupções e modos de operação.

Na arquitetura x86, popular em computadores pessoais (PC), de apliação genérica, o BIOS (_Basic Input Output System_) atua como um sistema intermediário no momento da inicialização. O BIOS identifica o hardware conectado, provendo informação ao software de carregamento (_bootloader_), e de lá ao kernel.

Já sistemas embarcados trabalham com uma topologia de hardware diferente. Nesses sistemas a arquitetura predominante não é x86, mas ARM. Uma comparação entre as topologias de hardware de um sistema PC e embarcado é ilustrada na Figura \ref{imgPCVsEmbedded}.

![Comparação entre sistemas PC (esq) e embarcados (dir). Adaptado de [@bookELDD]\label{imgPCVsEmbedded}](src/images/imgPCVsEmbedded.png)

De maneira geral, um sistema embarcado não pressupõe o uso de unidades intermediárias como BIOS, UEFI ou ACPI. É comum o uso de barramentos de construção e operação mais simples, como I²C, I²S e SPI. Esses barramentos são empregados, por exemplo, na conexão de sensores, atuadores e LEDs indicadores de operação. Finalmente, há os GPIO (_General Purpose Input Output_) com multiplexação de pinos e seus dispositivos diretamente conectados.

Assim, a forma de um kernel conhecer o hardware do sistema embarcado é mais direta. Por exemplo através de parâmetros enviados pelo _bootloader_, ou diretamente em seu código-fonte. Esta foi, aliás, a solução adotada no Linux para ARM.

A Figura \ref{imgMachDirectories} mostra uma listagem dos diretórios `arch/arm/mach-*` no Linux 2.6.39, a última revisão da série 2.6. Em cada um desses diretórios há código-fonte específico para uma ou mais CPUs daquela família, em arquivos `board-*`. Em cada um desses arquivos há, _hardcoded_, a configuração de hardware para um determinado equipamento.

Como exemplo, a Figura \ref{imgBoardFiles} mostra os arquivos _board_ do diretório `mach-omap2`. Neste diretório, além do arquivo genérico `board-generic.c`, estão os códigos para placas como a BeagleBoard (`board-omap3beagle.c`) e PandaBoard (`board-omap4panda.c`).

![Diretórios `mach-*`\label{imgMachDirectories}](src/images/imgMachDirectories.png)

![Arquivos `board-*`\label{imgBoardFiles}](src/images/imgBoardFiles.png)

Assim, soluções de hardware e software embarcado exigem que o desenvolvedor de software tenha conhecimento de todos os aspectos da configuração do hardware. Ou seja, alterações aparentemente simples, como uma mudança na configuração do GPIO de um sensor conectado a um dos pinos da placa, envolveriam alterações no código-fonte do kernel.

A popularização e barateamento de sistemas embarcados fez com que diversos fabricantes desenvolvesem seus dispositivos de forma independente, o que acabou por dificultar a manutenção do Sistema Operacional e seus diversos `board-`, uma vez que a alteração em um arquivo pode causar quebras de compilação ou mal-funcionamento do sistema.

A solução adotada pelos mantenedores do Linux foi, então, adaptar para a arquitetura ARM uma estrutura de dados de descrição de hardware, a chamada _Device Tree_, especificada em um padrão de 1994 [@specIEEE1275]. Essa solução já estava presente no código-fonte do Linux, pois fora adotada anteriormente para a arquitetura PowerPC entre outras.

Sendo Linux um sistema aberto, distribuído sob licença GPL, fabricantes de soluções hardware e software não necessariamente precisam se ater ao Kernel oficial. Tal atitude, porém, priva-o de contar com o apoio dos revisores da comunidade, e a constante correção de bugs e vulnerabilidades.

Assim, é desejável que se utilize o Kernel o mais próximo possível do "oficial".

Um outro ponto a ser considerado em se adotar configuração _hardcoded_ é a complexidade dos ciclos de desenvolvimento do produto. Desenvolvimento profissional de soluções embarcadas envolve equipes mistas e paralelização de atividades a fim de minimizar o _time to market_. Nesse cenário, é melhor que cada unidade do sistema se mantenha, na medida do possível, independente e inalterada, para que possa ser desenvolvida e posteriormente reaproveitada sem necessidade de testes de integração adicionais.

Desse modo, uma vez que as atuais circunstâncias levam novas placas e produtos comerciais a utilizem a _Device Tree_, este trabalho pretende iluminar o caminho para que, em se decidindo manter-se aderente às práticas do mercado, um desenvolvedor possa também a ela integrar seu dispositivo. Uma vez que se possa começar a entender essa dificuldade, será possível ponderar entre partir para a aceitação do Kernel oficial ou para a quebra de compatibilidade.

Seguem-se, assim, uma explicação do conceito de _Device Tree_, sua implantação para arquitetura ARM no Kernel 3.8, além de um experimento simples que servirá, também, como prova de conceito.
