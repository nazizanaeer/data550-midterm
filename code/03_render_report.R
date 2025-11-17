here::i_am("code/03_render_report.R")

library(rmarkdown)
library(here)

render(
  input  = here("midterm_report.Rmd"),
  output_file = "midterm_report.html",
  output_dir  = here()  
)