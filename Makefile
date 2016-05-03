LATEX_TEMPLATE=inatel-tcc.latex
BIBLIOGRAPHY_FILE=src/biblio.yaml
CSL_FILE=style/ieee-modified.csl
OUTPUT_FILENAME=artigo

ifeq ($(PANDOC_HOME),)
	PANDOC_HOME=/usr/bin
endif

PANDOC=$(PANDOC_HOME)/pandoc

all: clean build-pdf build-docx done

pdf: clean build-pdf done

docx: clean build-docx done

pre:
	@mkdir -p out

build-pdf: pre
	$(info Building PDF document...)
	@$(PANDOC) -V lang=portuguese \
		--smart \
		--number-sections \
		--bibliography $(BIBLIOGRAPHY_FILE) \
		--csl $(CSL_FILE) \
		--template style/$(LATEX_TEMPLATE) \
		--output out/$(OUTPUT_FILENAME).pdf \
		src/[0-9]*md

build-docx: pre
	$(info Building DOCX document...)
	@$(PANDOC) -V lang=portuguese \
		--smart \
		--number-sections \
		--bibliography $(BIBLIOGRAPHY_FILE) \
		--csl $(CSL_FILE) \
		--output out/$(OUTPUT_FILENAME).docx \
		src/[0-9]*md

clean:
	@$(RM) -v out/$(OUTPUT_FILENAME).*

done:
	$(info Done making targets! Check out/ directory.)

