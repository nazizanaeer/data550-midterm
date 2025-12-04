here::i_am("code/03_render_report.R")

WHICH_CONFIG <- Sys.getenv("WHICH_CONFIG", unset = "default")
config_list <- config::get(
  config = WHICH_CONFIG
)

library(rmarkdown)
library(here)

report_filename <- paste0(
  "midterm_report_config_",
  WHICH_CONFIG
)
rmarkdown::render(
  input       = here::here("midterm_report.Rmd"),
  output_file = report_filename
)