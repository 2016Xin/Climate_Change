```{r}
library(tidyverse)
library(tidyquant)
library(modelr)
library(gridExtra)
library(grid)
library(prophet)
```
```{r}
# Read temperature trend data
temp <- read.csv("/Users/xchen011/Desktop/tsp_temp.csv") %>% select(ds, y) %>% mutate(ds=as.Date(ds))
# Divide input dataset into train and test dataset.
temp_eval <- temp %>% mutate(model = ifelse(ds <= "2011-12-31", "train", "test"))
# Create Train Dataset
train <- filter(temp_eval, model == "train") %>% select(ds, y)
# Create Test Dataset
test <- filter(temp_eval, model == "test") %>% select(ds, y)
```
```{r}
# Generate prediction model using Prophet function.
prophet_model_test <- prophet(train, 
                              growth = "linear", # growth curve trend
                              yearly.seasonality = TRUE
                              ) 
# Forecast using "Predict" function.
forecast_test <- predict(prophet_model_test, test)
```
```{r}
# Plot residuals
forecast_test %>%
  mutate(resid = y - yhat) %>%
  ggplot(aes(x = ds, y = resid)) +
    geom_hline(yintercept = 0, color = "red") +
    geom_point(alpha = 0.5, color = palette_light()[[1]]) +
    geom_smooth() +
    theme_tq()
sumresid <- sum(forecast_test$y - forecast_test$yhat)
```
