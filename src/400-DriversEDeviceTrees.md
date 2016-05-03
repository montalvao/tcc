# Ativação de controladores

Segundo [@bookDT4Dummies], a DT se incumbe apenas da descrição do hardware, e não de sua configuração. Ou seja: é uma boa pratica escrever a _Device Tree_ descrevendo todas as funcionalidades e acessos disponíveis para o dispositivo em questão, apresentando-os como possibilidades a serem gerenciadas pelo controlador de dispositivo (_device driver_).

Controlador de dispositivos é o código que, valendo-se da instância de execução privilegiada do kernel, acessa diretamente um dispositivo, abstraindo suas peculiaridades e as de seu barramento e expondo suas funcionalidades ao usuário. Usuário, nesta acepção, refere-se a um programa sendo executado no espaço de usuário. No Linux, normalmente essa exposição se dá através de arquivos de sistema. Idealmente, o controlador se encarrega apenas de tornar o dispositivo disponível para um ou mais usuários (já que pode gerenciar concorrência). O usuário, então, o utiliza da forma como desejar [@bookLDD].

## O lado da DT

A forma pela qual um controlador de dispositivos se conecta à DT é através de _bindings_, convenções sobre como as características do hardware devem aparecer na árvore. Sempre que possível, a descrição do hardware deve ser feita utilizando convenções já existentes, reaproveitando o código de suporte [@docDTUsageModel].

Quando um gerenciador de dispositivos suporta essa funcionalidade, ele é integrado ao Kernel juntamente com um documento de _binding_. Esses documentos ficam agrupados no diretório `Documentation/devicetree/bindings/`. Eles servem como guia para a integração da solução à DT.

Um exemplo é o expansor de I/O PCF857x. Seu documento, `gpio/gpio-pcf857x.txt`, define, entre outras características, as strings que devem ser utilizadas na propriedade `compatible` da árvore, para cada um dos modelos suportados.

## O lado do controlador

Conforme explicado por Prado em [@urlSergioDT2], "durante o boot, o kernel irá procurar um driver que tenha sido registrado com a propriedade `compatible` idêntica à registrada no device tree. [..] Quando ele encontrar, a função `probe()` do driver será chamada!". E complementa: "para um driver ser compatível com o device tree, é necessária a definição da estrutura `of_device_id`". Essa estrutura registra os valores que serão comparados com a propriedade. Ela está definida no arquivo de cabeçalho `mod_devicetable.h`.

Para que esta ligação tenha sucesso, no entanto, devem-se incluir todos os elementos obrigatórios constantes no documento de _binding_.

É isso que torna desnecessária a alteração do código do kernel para inclusão de mais um dispositivo, o que será demonstrado no experimento a seguir.
