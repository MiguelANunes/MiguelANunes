FLAGS  = -f -pdf -pv -quiet
CLEANFLAG = -c -bibtex
TARGET = Main.tex
EXTRACLEAN = *.maf *.mtc* *.tdo *.nls *.nlo *.brf *.nav *.snm *.vrb

all: 
	latexmk ${FLAGS} ${TARGET}

cleanall: changevar clean

changevar:
	$(eval CLEANFLAG=-C)

clean:
	latexmk ${CLEANFLAG}; rm ${EXTRACLEAN}
