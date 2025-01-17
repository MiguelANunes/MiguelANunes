#!/bin/bash

# Script que converte arquivos .tex (opcionalmente com referências em um arquivo .bib) em arquivos .docx

# Baseado em https://tex.stackexchange.com/questions/653972/convert-latex-to-word-with-pandoc-including-citations-and-bibliography

# Variável global que indica se vou rodar o pandoc no modo verboso ou não
verbose=0
# Variável global que indica se vai incluir um arquivo .bib na conversão
no_bib=0

### Menu de ajuda
print_help(){
	clear
	echo "\t\t*****************************************"
	echo "\t\t*\tConversor de LaTeX para Docx\t*"
	echo "\t\t*****************************************\n"
	echo "Converte arquivos .tex acompanhados de bibliografia em um .bib em um .docx com o pandoc"
	echo "Para converter, copie esse script para uma pasta contendo um arquivo .tex e execute ele com sh pelo terminal"
	echo "Caso hajam múltiplos arquivos .tex/.bib na pasta, é necessário fornecer o nome deles quando for executar, da seguinte forma:"
	echo "\tsh Latex2Docx.sh arquivo.tex arquivo.bib"
	echo "O nome do arquivo .docx resultante pode opcionalmente ser informado da mesma maneira"
	echo "É necessário informar o nome do arquivo .tex caso informe o nome de algum dos outros arquivos"
	echo "\n\nFlags:"
	echo "\t-h  --help\tAjuda, imprime esse texto e sai do programa"
	echo "\t-v  --verbose\tHabilitar modo verbose do pandoc"
	echo "\t-nb --no-bib\tNão inclui arquivo .bib na conversão"
}

# Acabei não precisando dessa função, mas vou manter ela aqui por via das dúvidas
print_colored(){
	# Função que recebe dois argumentos
	# O primeiro é a cor do texto a ser printado
	# O Segundo é o texto a ser printado
	echo "${1}${2}\e[0m"
}

print_error(){
	print_colored "\e[1;31m" ""["ERRO"]" ${1}"
}

print_warning(){
	print_colored "\e[1;33m" ""["AVISO"]" ${1}"
}

print_success(){
	print_colored "\e[1;32m" "${1}"
}

conversion(){
	# Função que recebe a string de argumentos para ser passada para o Pandoc
	# Printa na tela se a conversão deu certo 

	msg=$(pandoc ${1})
	ret=$?

	# Verificando resultado da conversão
	if [ ${ret} -eq 0 ]; then

		print_success "Arquivo convertido com sucesso!"
		
		exit 0
	else
		print_error "Erro ao converter! Veja saída do pandoc."

		exit 1
	fi
}

generate_conversion_str(){
	# Função que gera a string contendo os nomes dos arquivos para serem convertidos pelo pandoc
	# Primeiro argumento é o nome do arquivo .tex
	# Segundo argumento é o nome do arquivo .bib
	# Terceiro argumento é o nome do arquivo .docx

	base_str="-o "${3}" "${1}""
	# String que contém a parte referente a bibliografia
	bib_str1="--bibliography="${2}" "
	bib_str2=" --citeproc"

	# Caso queira converter com bibliografia, inclui isso na string de conversão
	if [ ${no_bib} -eq 0 ]; then 
		base_str=${bib_str1}${base_str}${bib_str2} 
	fi

	# Caso queira modo verboso, inclui isso na string de conversão
	if [ ${verbose} -eq 1 ]; then 
		base_str=${base_str}" --verbose "
	fi

	echo "${base_str}"
}

find_files(){
	# Função que busca os nomes dos arquivos com uma extensão específica
	# Recebe uma extensão, caso tenha achado apenas um arquivo com essa extensão, retorna o nome desse arquivo
	# Caso tenha achado múltiplos, retorna um erro dependendo do tipo de arquivo

	# TODO: Ver se há alguma forma de fazer isso sem ter que fazer duas chamadas ao ls
	files=$(ls | grep "${1}" | wc -l)

	# Caso não tenha achado nenhum arquivo...
	if [ ${files} -eq 0 ]; then
		# .tex então aborta
		if [ "${1}" = ".tex" ]; then
			print_error "Nenhum arquivo .tex encontrado!" >&2
			exit 1
		# .bib e queira converter com bibliografia, então avisa
		elif [ "${1}" = ".bib" ] && [ ${no_bib} -eq 0 ]; then
			print_warning "Nenhum arquivo .bib encontrado, conversão será feita sem a bibliografia!" >&2
			exit 1
		fi
	fi

	# Caso tenha achado mais de 1 arquivo...
	if [ ${files} -gt 1 ]; then
		# .tex então aborta
		if [ "${1}" = ".tex" ]; then
			print_error "Mais de 1 arquivo .tex encontrado nessa pasta, é necessário especificar o nome do arquivo a ser convertido." >&2
			exit 1
		# .bib então avisa
		elif [ "${1}" = ".bib" ]; then
			print_warning "Vários arquivos .bib encontrados, conversão será feita sem a bibliografia!" >&2
			exit 1
		fi
	fi

	# Se achou apenas 1, pega o nome dele
	file=$(ls | grep "${1}")
	echo ${file}
}

auto_generate_str(){
	# Função que gera a string de conversão automáticamente

	# Verificando se há apenas 1 arquivo .tex
	arquivo_tex=$(find_files ".tex")
	if [ $? -eq 1 ]; then
		# Se não, retorna erro
		exit 1
	fi

	# Gerando o nome do arquivo .docx a partir do nome do arquivo .tex
	arquivo_docx="${arquivo_tex%.*}"".docx"

	# Verificando quantos arquivos .bib tem na pasta
	arquivo_bib=$(find_files ".bib")

	# Caso tenha achado mais que 1 arquivo .bib faz a conversão sem bibliografia
	if [ $? -eq 1 ]; then
		no_bib=1
		# Como a função find_files não retorna nenhum nome de arquivo, preciso definir um nome dummy para evitar que a variável não fique unset
		arquivo_bib="temp"
	fi

	# Retorna a string gerada que será passada ao pandoc
	echo "$(generate_conversion_str ${arquivo_tex} ${arquivo_bib} ${arquivo_docx})"
}

main(){
	# Sanity
	if [ $# -gt 10 ]; then 
		print_error "Excesso de argumentos!" >&2
		exit 1
	fi

	### Processando as entradas

	# Nomes de arquivo padrão
	arquivo_tex="temp"
	arquivo_bib="temp"
	arquivo_docx="temp"

	# Iterando pelos argumentos e realizando processamento necessário
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
		elif [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
			print_help
			exit 0
		elif [ "${1}" = "-v" ] || [ "${1}" = "--verbose" ]; then
			verbose=$((verbose+1))
			shift
		elif [ "${1}" = "-nb" ] || [ "${1}" = "--no-bib" ]; then
			no_bib=$((no_bib+1))
			shift
		else
			print_error "Argumento não reconhecido: ${1}" >&2
			exit 1
		fi
	done

	# Caso nenhum nome de arquivo tenha sido passado, busca pelos arquivos na pasta onde está esse script e converte esses arquivos encontrados

	# Caso tenha passado nome de arquivo, busca pelos arquivo específicos e converte eles
	
	# Caso tenha passado nome de algum arquivo, mas não do arquivo .tex, dá erro

	if [ "${arquivo_tex}" = "temp" ] && [ "${arquivo_tex}" = "${arquivo_docx}" ] && [ "${arquivo_tex}" = "${arquivo_bib}" ]; then
		# Se não passou nenhum nome de arquivo, faz a conversão automática
		convert_str=$(auto_generate_str)

	elif [ "${arquivo_tex}" != "temp" ]; then
		# Se passou, monta a string de conversão com base nos nomes de arquivos passados

		# Caso não tenha passado nome para o arquivo .docx, gera a partir do nome do arquivo .tex
		if [ "${arquivo_docx}" = "temp" ]; then 
			arquivo_docx="${arquivo_tex%.*}"".docx"
		fi

		# Caso não tenha passado nome para o arquivo .bib e queira converter com bibliografia, procura pelo arquivo .bib
		if  [ "${arquivo_bib}" = "temp" ] && [ ${no_bib} -lt 1 ]; then 
			# Procuro por arquivos .bib na pasta
			arquivo_bib=$(find_files ".bib")

			# Qualquer erro referente aos arquivos sendo procurados já é tratado dentro da função de busca
			# Então se ela retornar erro basta setar a flag que não vai usar bibliografia
			if [ $? -eq 1 ]; then
				no_bib=1
			fi
		fi
		convert_str=$(generate_conversion_str ${arquivo_tex} ${arquivo_bib} ${arquivo_docx})

	else
		# Caso passou algum nome de arquivo mas nenhum .tex
		print_error "Arquivos não reconhecidos -- forneceça o nome de um arquivo .tex com a extensão para realizar a conversão" >&2
		exit 1
	fi

	# Após, realiza a conversão com o pandoc
	conversion "${convert_str}"
}

main "$@"