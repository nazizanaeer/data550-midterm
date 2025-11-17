
midterm_report.html: code/03_render_report.R midterm_report.Rmd output/table1.rds
	Rscript code/03_render_report.R

output/table1.rds: code/01_table_one.R output/f75_clean.rds
	Rscript code/01_table_one.R

output/f75_clean.rds: code/00_clean_data.R f75_dataset/f75_interim.csv
	Rscript code/00_clean_data.R
	
.PHONY: clean
clean:
	rm -f output/*.rds && rm -f output/*.png && rm -f *.html && rm -f *.pdf 