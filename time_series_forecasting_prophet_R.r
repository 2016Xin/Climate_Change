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
```{r}
# Plot Actual Test data vs Forecasted data
forecast_test %>%
  gather(x, y, y, yhat) %>%
  ggplot(aes(x = ds, y = y, color = x)) +
    geom_point(alpha = 0.5) +
    geom_line(alpha = 0.5) +
    scale_color_manual(values = palette_light()) +
    theme_tq()
```
```{r}
# Create a future dataframe for prediction.
future <- make_future_dataframe(prophet_model_test, periods = 204, freq = 'm')
# Forecast using "predict" function in PROPHET package.
forecast <- predict(prophet_model_test, future)
# Plot Train data + Forecasted data
plot(prophet_model_test, forecast) + theme_tq()
```
```{r}
# Function: Calculate RMSE value
rmse <- function(actual, predicted)
{
    sqrt(mean((actual-predicted)^2))
}
 
# Calculate RMSE value
forecasted_data <- left_join(test, forecast, by="ds") %>% select(ds, y, yhat) %>% filter(year(ds)==2012)
rmse_cal <- rmse(forecasted_data$y, forecasted_data$yhat) 
# Print Forecasted values
print(forecasted_data)
# Display RMSE
print(rmse_cal)
```

```{r}
prophet_plot_components(prophet_model_test, forecast, uncertainty = TRUE)
```
```{r}
forecast_col <- forecast%>%mutate(colorc = ifelse(ds <= "2013-09-01", "royalblue1", "tomato1"))
plot(prophet_model_test, forecast_col, col = forecast_col$colorc) + theme_tq()
```
```{r}
ggplot() + geom_point(data = temp, aes(x = temp$ds, y = temp$y), color = "grey40") +
  geom_line(data = forecast_col, aes(x = forecast_col$ds, y = forecast_col$yhat), color = forecast_col$colorc) + 
  labs(x = "ds", y = "Temperature")
```
