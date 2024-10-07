.PHONY: clean

clean:
	rm -rf figures
	rm -rf models

.created-dirs:
	mkdir -p figures
	mkdir -p models

report.pdf: \
	report.Rmd \
	.created-dirs 
		R -e "rmarkdown::render(\"report.Rmd\", output_format=\"pdf_document\")"

