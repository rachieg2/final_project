.PHONY: clean
.PHONY: make_data
.PHONY: full_clean

full_clean:
	rm -rf data
	rm -rf page_cache
	rm -rf figures
	rm -rf models
	rm -rf cleaned_data

clean:
	rm -rf figures
	rm -rf models
	rm -rf cleaned_data

.created-dirs:
	mkdir -p figures
	mkdir -p models

.created-data-dir:
	mkdir -p data

make_data:
	$(MAKE) data/plane_data.csv

# The following code takes 8+ hours to run if you do not have cached data- 
# I would suggest just using the dataset from data/
# I did not add the cached data folder to clean in order to avoid re-running for hours.
data/plane_data.csv: \
	data_cleaning/scrape_data.py \
	.created-data-dir \
	.created-dirs
		python3 data_cleaning/scrape_data.py

# This one takes about an hour because of lat/lon searches
cleaned_data/cleaned_data.csv: \
	data_cleaning/clean_data.R
		Rscript data_cleaning/clean_data.R

# Data is not included, as the data is already in the repo.
report.pdf: \
	report.Rmd \
	cleaned_data/cleaned_data.csv \
	.created-dirs 
		R -e "rmarkdown::render(\"report.Rmd\", output_format=\"pdf_document\")"

