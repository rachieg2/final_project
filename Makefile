.PHONY: clean

clean:
	rm -rf figures
	rm -rf models
	rm -rf data

.created-dirs:
	mkdir -p figures
	mkdir -p models
	mkdir -p data

# The following code takes 8+ hours to run if you do not have cached data- 
# I would suggest just using the dataset from data/
# I did not add the cached data folder to clean in order to avoid re-running for hours.
data/plane_data.csv: \
	data_cleaning/scrape_data.py \
	.created-dirs 
		python3 data_cleaning/scrape_data.py

report.pdf: \
	data/plane_data.csv \
	report.Rmd \
	.created-dirs 
		R -e "rmarkdown::render(\"report.Rmd\", output_format=\"pdf_document\")"

