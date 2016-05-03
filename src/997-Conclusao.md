# Conclusões

Adotar, modificar e expandir a _Device Tree_ é hoje, indubitavelmente, o caminho a se seguir quando se deseja integrar o software de um novo dispositivo à linha de desenvolvimento do Linux.

Quando se trata de desenvolver um equipamento que se pretende conectar facilmente a placas de desenvolvimento como a BeagleBone Black, o caso dos _capes_ aqui mencionados, a _DT overlay_ e ferramentas como o _Cape Manager_ parecem ser também a alternativa mais aceita.

Porém, em um cenário no qual se deseja que o kernel seja o mais genérico possível, o corpo de conhecimento para desenvolvimento de controladores de dispositivos ancorado apenas na DT ainda é pequeno. Quando só recentemente o Linux 2.6 chegou ao fim da vida (EOL) [@emailEndOfKernel26], deixando ainda ativas 2 versões _longterm_ anteriores à adoção da DT na arquitetura ARM, a relutância em se dar o "salto da fé" pode ser considerada natural.

Programada para fins de 2017, a 4ª edição do livro _Linux Device Drivers_, sucessor de uma referência obrigatória para o desenvolvedor de controladores de dispositivos, deverá preencher essas lacunas, ajudando a consolidar o caminho para o Kernel Único.

Uma lista atualizada com documentos e apresentações sobre Device Tree pode ser acessada em [@urlELinuxDTUsefulLinks].
