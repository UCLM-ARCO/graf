

S1: $(wildcard ./xsl/*) \
	$(wildcard ./db/GNU/*) $(wildcard ./db/GNU/exam/*)
	python exam_view-gen.py GNU $@ > a.xml
	sabcmd xsl/exam_latex_view-gen.xsl a.xml exam.tex
	pdflatex exam.tex
	pdflatex exam.tex

20040126: $(wildcard ./xsl/*) \
	$(wildcard ./db/IPe/*) $(wildcard ./db/IPe/exam/*)
	python exam_view-gen.py IPe $@ > a.xml
	sabcmd xsl/exam_latex_view-gen.xsl a.xml exam.tex
	pdflatex exam.tex
	pdflatex exam.tex

clean:
	$(RM) *.tex *~ *.aux *.log *.pdf *.xml
