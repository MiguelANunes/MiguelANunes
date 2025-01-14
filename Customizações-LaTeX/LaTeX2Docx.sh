#!/bin/bash

# Script que converte arquivos .tex (opcionalmente com referências em um arquivo .bib) em arquivos .docx

# Baseado em https://tex.stackexchange.com/questions/653972/convert-latex-to-word-with-pandoc-including-citations-and-bibliography

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
	echo "\t-h  --help\tAjuda, imprime esse texto e sai do programa"
	echo "\t-v  --verbose\tHabilitar modo verbose do pandoc"
	echo "\t-a  --auto\tConverte automaticamente o arquivo .tex presente na pasta atual"
	echo "\t-nb --no-bib\tNão inclui arquivo .bib na conversão"
}

print_error(){
	echo "\e[1;31m"["ERRO"]" ${1}\e[0m"
}

print_warning(){
	echo "\e[1;33m"["AVISO"]" ${1}\e[0m"
}

# Sanity
if [ $# -gt 10 ]; then 
	print_error "Excesso de argumentos!"
	exit 1
fi

### Processando as entradas

# Argumentos
verbose=0
no_bib=0
auto_convert=0
# Nomes de arquivo padrão
arquivo_tex="Main.tex"
arquivo_bib="referencias.bib"
arquivo_docx="Main.docx"

# Iterando pelos argumentos e realizando processamento necessário
	# A variável $# contém o número de argumentos passado para o processo 
	# A variável ${n} contém o n-ésimo argumento na sequência de argumentos
	# O comando shift move o argumento ${n+1} para o argumento ${n}
	# O seja, esse loop vai iterar por cada argumento passado para o processo, descartando todo argumento que já foi processado
while [ $# -gt 0 ]; do
# Isso é uma maneira de pegar todo texto depois do "." no nome do arquivo
#			 ||
#			 \/
	if [ "${1##*.}" = "tex" ]; then
		arquivo_tex=$1
		shift
	elif [ "${1##*.}" = "docx" ]; then
		arquivo_docx=$1
		shift
	elif [ "${1##*.}" = "bib" ]; then
		arquivo_bib=$1
		shift
	elif [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
		print_help
		exit 0
	elif [ "${1}" = "-v" ] || [ "${1}" = "--verbose" ]; then
		verbose=$((verbose+1))
		shift
	elif [ "${1}" = "-a" ] || [ "${1}" = "--auto" ]; then
		auto_convert=$((auto_convert+1))
		shift
	elif [ "${1}" = "-nb" ] || [ "${1}" = "--no-bib" ]; then
		no_bib=$((no_bib+1))
		shift
	else
		print_error "Argumento não reconhecido: ${1}"
		exit 1
	fi
done

### Realizando a conversão

	## Caso seja conversão automática
	if [ ${auto_convert} -gt 0 ]; then
		# Aparentemente usar ls em scripts bash não é uma boa ideia, mas isso é um problema para depois

		# Conferindo se não foi passado nenhum nome não padrão, caso tenha aborta
		if [ "${arquivo_tex}" != "Main.tex" ] || [ "${arquivo_bib}" != "referencias.bib" ] || [ "${arquivo_docx}" != "Main.docx" ]; then
			print_error "Conversão automática não aceita nomes especiais para arquivos!"
			exit 1
		fi

		# Buscando por arquivos .tex na pasta atual
# 	Procurar por arquivos .tex
#	 		  ||   Contar o resultado	
#			  ||	      ||
#			  \/          \/
		tex_files=$(ls | grep .tex | wc -l)

		# Caso tenha achado mais que 1 arquivo .tex aborta
		if [ ${tex_files} -gt 1 ]; then
			print_error "Mais de 1 arquivo .tex encontrado nessa pasta, conversão automática abortada!"
			exit 1
		fi

		# Se achou apenas 1, pega o nome dele
		arquivo_tex=`ls | grep .tex`

		# Gerando o nome do arquivo .docx
		arquivo_docx="${arquivo_tex%.*}"".docx"
#						           /\
#								   ||
#		Isso é uma maneira de pegar todo texto antes do "." no nome do arquivo

		# Agora procura por um arquivo .bib
		bib_files=$(ls | grep .bib | wc -l)

		# Caso tenha achado mais que 1 arquivo .bib faz a conversão sem bibliografia
		if [ ${bib_files} -gt 1 ]; then
			print_warning "Vários arquivos .bib encontrados, conversão será feita sem a bibliografia!"
			no_bib=1
		# Se não, recupera o nome dele
		else
			arquivo_bib=`ls | grep .bib`
		fi
	fi

	# Agora sigo com a conversão como já tinha

	# String que contém os nomes dos arquivos de entrada e saída
	base_str="-o "${arquivo_docx}" "${arquivo_tex}""
	# String que contém a parte referente a bibliografia
	bib_str1="--bibliography="${arquivo_bib}" "
	bib_str2=" --citeproc"

	if [ ${no_bib} -lt 1 ]; then 
		base_str=${bib_str1}${base_str}${bib_str2}
	fi

	if [ ${verbose} -gt 0 ]; then
		base_str=${base_str}" --verbose "
	fi
	

pandoc ${base_str}

### Verificando resultado da conversão

ret=$?

if [ "${ret}" -eq 0 ]; then

	echo "Arquivo convertido com sucesso! Resultado em ${arquivo_docx}"
	
	exit 0
else
	print_error "Erro ao converter! Veja saída do pandoc."

	exit 1
fi