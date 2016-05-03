---
abstract-en: >
  Embedded computer systems differ themselves by allowing, at the same time, complex hardware topologies with devices connected directly to the SoC, and a simpler booting system, with no in-betweens. Hence, the Linux kernel must be informed, during the boot, about the memory addresses and other features of the board peripherals. That was usually accomplished using header files, which were compiled with the Kernel. However, given the growing variety of architectures and boards available, a new approach should be taken. A data structure for hardware description, called Device Tree, was then employed. Eventually, that led to a model in which new elements could be integrated dynamically, even after boot time. This work shows how this can be done using the BeagleBone Black.

index-terms-en: embedded systems, device tree, linux, beaglebone, device drivers

abstract-pt: >
  Sistemas computacionais embarcados diferenciam-se dos demais por contemplarem, ao mesmo tempo, topologias de hardware complexas, com dispositivos conectados diretamente ao SoC, e um sistema de carregamento mais simples, sem a presença de intermediários. Por isso, no Linux é necessário se informar ao Kernel, no momento do boot, o endereço e demais características dos periféricos. Inicialmente, eram utilizados arquivos de cabeçalho compilados com o Kernel, mas a crescente variedade de arquiteturas e placas tornou necessária a adoção de outra abordagem. Assim, uma estrutura de dados para descrição de hardware chamada Device Tree foi empregada. Futuramente, isso deu origem a um modelo no qual novos elementos pudessem ser integrados dinamicamente, mesmo após a inicialização da placa. Este trabalho mostra como isso pode ser feito com a BeagleBone Black.

index-terms-pt: sistemas embarcados, device tree, linux, beaglebone, controladores de dispositivos
...
