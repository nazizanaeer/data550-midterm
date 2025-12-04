here::i_am("code/03_render_report.R")

WHICH_CONFIG <- Sys.getenv("WHICH_CONFIG")
config_list <- config::get(
  config = WHICH_CONFIG
)

library(rmarkdown)
library(here)

#render(
#  input  = here("midterm_report.Rmd"),
#  output_file = "midterm_report.html",
#  output_dir  = here()  
#)

report_filename <- paste0(
  "midterm_report_config_",
  WHICH_CONFIG,
  "html"
)