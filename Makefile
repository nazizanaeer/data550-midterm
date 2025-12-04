WHICH_CONFIG ?= default
export WHICH_CONFIG

midterm_report_config_${WHICH_CONFIG}.html: \
    code/03_render_report.R \
    midterm_report.Rmd \
    output/table1.rds \
    regression_analysis
	Rscript code/03_render_report.R

output/logistic_regression_plot.png: code/02_regression_analysis.R output/f75_clean.rds
	Rscript code/02_regression_analysis.R

output/regression_table_config_${WHICH_CONFIG}.rds: code/02_regression_analysis.R output/f75_clean.rds
	Rscript code/02_regression_analysis.R

.PHONY: regression_analysis
regression_analysis: output/logistic_regression_plot.png output/regression_table_config_${WHICH_CONFIG}.rds

output/table1.rds: code/01_table_one.R output/f75_clean.rds
	Rscript code/01_table_one.R

output/f75_clean.rds: code/00_clean_data.R f75_dataset/f75_interim.csv
	Rscript code/00_clean_data.R

#Make Install Rule
.PHONY: install
install:
	Rscript -e "renv::restore()"
	
.PHONY: clean
clean:
	rm -f output/*.rds && rm -f output/*.png && rm -f *.html && rm -f *.pdf 