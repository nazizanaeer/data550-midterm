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

data <- data %>%
  mutate(
    death = case_when(
      final_status == 0 ~ 1,
      final_status == 1 ~ 0,
      TRUE ~ NA_real_
    )
  )

analysis_data <- data %>%
  filter(!is.na(death)) %>%
  filter(
    !is.na(arm_new),
    !is.na(weight_group),
    !is.na(diarrhoea_new),
    !is.na(oedema_new),
    !is.na(agemons),
    !is.na(sex_group),
    !is.na(hiv_new),
    !is.na(muac),
    !is.na(kwas_new)
  )

logit_model <- glm(
  death ~ arm_new + weight_group +
    diarrhoea_new + oedema_new +
    agemons + sex_group +
    hiv_new + muac +
    kwas_new,
  data   = analysis_data,
  family = binomial(link = "logit")
)

summary(logit_model)

tableregression <- tbl_regression(
  logit_model,
  exponentiate = TRUE
) %>% bold_labels()

tableregression

gtsave(
  as_gt(tableregression),
  filename = here::here("output", "regression_analysis.png")
)

saveRDS(
  tableregression,
  file = here::here("output", "regression_analysis.rds")
)

plot_data <- analysis_data %>%
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

logit_smooth_plot <- ggplot(
  analysis_data,
  aes(x = muac, y = death, colour = arm_new)
) +
  geom_jitter(height = 0.05, width = 0, alpha = 0.4) +
  geom_smooth(
    method = "glm",
    method.args = list(family = "binomial"),
    se = TRUE
  ) +
  scale_y_continuous(
    name = "Predicted Probability of Death",
    limits = c(0, 1)
  ) +
  labs(
    title = "Logistic Curve of Death vs MUAC by Treatment Arm",
    x = "MUAC (cm)",
    colour = "Treatment Arm"
  ) +
  theme_minimal()

logit_smooth_plot

ggsave(
  filename = here::here("output", "logistic_regression_smooth_curve.png"),
  plot = logit_smooth_plot,
  width = 6, height = 4
)
