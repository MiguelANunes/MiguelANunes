#!/bin/bash

# Script que converte arquivos .tex (opcionalmente com referências em um arquivo .bib) em arquivos .docx

### Menu de ajuda
print_help(){
	echo "\t\t*****************************************"
	echo "\t\t*\tConversor de LaTeX para Docx\t*"
	echo "\t\t*****************************************\n"
	echo "Dado um arquivo .tex e opcionalmente um arquivo .bib, retorna um arquivo .docx correspondente convertido pelo pandoc."
	echo "Se nenhum arquivo for infomado quando o programa for chamado, usará os seguintes nomes padrão:"
	echo "\t Main.tex para o arquivo .tex"
	echo "\t referencias.bib para o arquivo .bib"
	echo "\t Main.docx para o arquivo .docx"
	echo "\n\nFlags:"
	echo "\t-h\t\tAjuda, imprime esse texto e sai do programa"
	echo "\t-v\t\tHabilitar modo verbose do pandoc"
}

# Sanity
if [ $# -gt 5 ]; then 
	>&2 echo "Erro! Não aceito mais que cinco argumentos!"
	exit 1
fi

### Processando as entradas

# Nomes padrão
arquivo_tex="Main.tex"
arquivo_bib="referencias.bib"
arquivo_docx="Main.docx"
verbose=0

# Iterando pelas entradas e realizando processamento necessário
while [ $# -gt 0 ]; do

	if [ "${1##*.}" = "tex" ]; then
		arquivo_tex=$1
		shift
	elif [ "${1##*.}" = "docx" ]; then
		arquivo_docx=$1
		shift
	elif [ "${1##*.}" = "bib" ]; then
		arquivo_bib=$1
		shift
	elif [ "${1}" = "-h" ]; then
		print_help
		exit 0
	elif [ "${1}" = "-v" ]; then
		verbose=$((verbose+1))
		shift
	fi

done

### Realizando a conversão

# O pandoc não gostava de forma alguma que a variável pandoc_verbose fosse uma string vazia ou não estivesse setada
# Qualquer uma das duas causava erro
# Vou fazer dessa forma até achar uma maneira mais elegante de resolver esse problema	
if [ ${verbose} -gt 0 ]; then
	pandoc --bibliography="${arquivo_bib}" -o "${arquivo_docx}" "${arquivo_tex}" --citeproc --verbose
else
	pandoc --bibliography="${arquivo_bib}" -o "${arquivo_docx}" "${arquivo_tex}" --citeproc
fi

### Verificando resultado da conversão

ret=$?

if [ "${ret}" -eq 0 ]; then

	echo "Arquivo convertido com sucesso! Resultado em ${arquivo_docx}"
	
	exit 0
else
	>&2 echo "Erro ao converter! Veja saída do pandoc."

	exit 1
fi