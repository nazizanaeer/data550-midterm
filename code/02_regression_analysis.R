here::i_am("code/02_regression_analysis.R")


data <- readRDS(
  file=here::here("output/f75_clean.rds")
)

library(here)
library(dplyr)
library(gtsummary)
library(gt)
library(ggplot2)

data <- data %>%
  mutate(
    arm_new = factor(arm_new, levels = c(0, 1),
                     labels = c("Standard F75", "Modified F75")),
    sex_group = factor(sex_group, levels = c(0, 1),
                       labels = c("Male", "Female")),
    weight_group = factor(weight_group, labels = c("< Median", "≥ Median")),
    oedema_new = factor(oedema_new, labels = c("0", "1", "2", "3")),
    diarrhoea_new = factor(diarrhoea_new, labels = c("No", "Yes")),
    kwas_new = factor(kwas_new, labels = c("No", "Yes")),
    hiv_new = factor(hiv_new, labels = c("Negative", "Positive"))
  )

WHICH_CONFIG <- Sys.getenv("WHICH_CONFIG", unset = "default")
config_list <- config::get(
  config = WHICH_CONFIG
)

## logistic regression

if (config_list$sex != "all") {
  # filter by Male or Female
  data <- data %>% filter(sex_group == config_list$sex)
}

logit_model <- glm(
  final_status ~ arm_new + weight_group +
    diarrhoea_new + oedema_new +
    agemons + hiv_new + 
    muac + kwas_new,
  data   = data,
  family = binomial(link = "logit")
)

tableregression <- tbl_regression(
  logit_model,
  exponentiate = TRUE
) %>% bold_labels()

model_filename <- paste0("logit_model_config_", WHICH_CONFIG, ".rds")
regression_table_filename <- paste0("regression_table_config_", WHICH_CONFIG, ".rds")

saveRDS(logit_model, here("output", model_filename))
saveRDS(tableregression, here("output", regression_table_filename))

## graph

plot_data <- data %>%
  mutate(pred = predict(logit_model, type = "response"))

logit_plot <- ggplot(plot_data, aes(x = arm_new, y = pred, fill = arm_new)) +
  stat_summary(fun = mean, geom = "bar", alpha = 0.7) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  labs(
    title = "Predicted Probability of Death Before Stabilization",
    x = "Treatment Arm",
    y = "Predicted Probability"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

logit_plot

ggsave(
  filename = here::here("output", "logistic_regression_plot.png"),
  plot = logit_plot,
  width = 6, height = 4
)

