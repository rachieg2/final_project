.PHONY: clean
.PHONY: make_data
.PHONY: full_clean

full_clean:
	rm -rf data
	rm -rf page_cache
	rm -rf figures
	rm -rf cleaned_data
	rm -rf .created-dirs
	rm -rf .created-data-dir

clean:
	rm -rf figures
	rm -rf models
	rm -rf cleaned_data
	rm -rf .created-dirs

.created-dirs:
	mkdir -p figures
	mkdir -p cleaned_data
	touch .created-dirs

.created-data-dir:
	mkdir -p data
	touch .created-data-dir

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
	data_cleaning/clean_data.R \
	.created-dirs
		Rscript data_cleaning/clean_data.R

figures/num_crashes_by_year.png \
figures/heatmap_over_time.png: \
	.created-dirs \
	cleaned_data/cleaned_data.csv \
	conduct_analysis/number_crashes_year.R
		Rscript conduct_analysis/number_crashes_year.R

figures/operators_most_crashes.png: \
	.created-dirs \
	cleaned_data/cleaned_data.csv \
	conduct_analysis/operator_count.R
		Rscript conduct_analysis/operator_count.R

cleaned_data/plane_description_counts.csv: \
	.created-dirs \
	cleaned_data/cleaned_data.csv \
	conduct_analysis/transform_descriptions.py
		python3 conduct_analysis/transform_descriptions.py

figures/pca_decade.png: \
	.created-dirs \
	cleaned_data/plane_description_counts.csv \
	conduct_analysis/pca_descriptions.R
		Rscript conduct_analysis/pca_descriptions.R

figures/map_crashes.png: \
	.created-dirs \
	cleaned_data/cleaned_data.csv \
	conduct_analysis/crash_locations.R
		Rscript conduct_analysis/crash_locations.R

figures/perc_dead_plot.png \
figures/number_killed_ground_plot.png \
figures/perc_dead_plot.png: \
	.created-dirs \
	cleaned_data/cleaned_data.csv \
	conduct_analysis/number_dead.R
		Rscript conduct_analysis/number_dead.R

# Data is not included, as the data is already in the repo.
report.pdf: \
	report.Rmd \
	figures/heatmap_over_time.png \
	figures/num_crashes_by_year.png \
	figures/operators_most_crashes.png \
	figures/pca_decade.png \
	figures/map_crashes.png \
	figures/perc_dead_plot.png \
	figures/number_killed_ground_plot.png \
	figures/perc_dead_plot.png \
	.created-dirs 
		R -e "rmarkdown::render(\"report.Rmd\", output_format=\"pdf_document\")"

