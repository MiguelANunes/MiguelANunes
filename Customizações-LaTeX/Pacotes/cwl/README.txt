COMO GERAR UM .JSON A PARTIR DE UM .CWL

- Clonar o repositório do LaTeX Workshop no GitHub e copiar para essa pasta;
- Copiar o arquivo .cwl para a pasta /dev/cwl/, criando a pasta cwl/ caso ela não exista;
- Executar o comando npx ts-node parse-cwl.ts <arquivo>.cwl;
- O arquivo .json resultante vai estar na pasta /dev/packages/;
- Instruções originais: https://github.com/James-Yu/LaTeX-Workshop/tree/master/dev#parse-cwlts

EM CASO DE ERRO:

- Conferir se npm e typescript estão instaldos
- TypeScript não é automaticamente instalado junto com npm, deve ser instalado separadamente!
- Executar o comando acima dentro da pasta dev/ da estrutura de arquivos do pacote Latex Workshop, executar fora não dá certo;
- Caso nada dê certo, abandonar o doutorado, comprar um terreno no Mato Grosso do Sul e virar agricultor de mandioca.
