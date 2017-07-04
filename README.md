# Climate_Change
## The Earth Surface Temperature Dataset Analysis and Visualization

The Earth Surface Temperature Data sourced from Kaggle website.There are five .csv files in the dataset, categorizing the global land temperature records by cities and countries. The file of “globallandtemperaturesbycity.csv” was used, containing 8235082 monthly temperatures covering 3448 cities from 159 countries. Dataset was uploaded into HIVE table temp_city_c, removing missing values and creating year, month, latitude_num, latitude_type, longitude_num, and longitude_type columns. The latitude_num and longitude_num were altered to negative value if the latitude_type and longitude_type are South and West, respectively. The code is listed in the link. The temperature records before 1800 are sparse with too many monthly temperature data unmeasured, therefore the data before 1800 were neglected. 

### 1. Does global warming exist?
The global annually average temperature changing over years was calculated and displayed in Figure 1. We can see clearly that the average temperature has been increasing significantly since early 18th centry. The growth rate of temperature is getting higher in the latest decades, indicated by the lope of the curve. The maximum, minimum and average temperatures of each 20-year-interval were calculated using HiveQL queries (Figure 2).  The global maximum temperature of each time period didn’t show much change since 1800, while the global minimum temperature exhibits significant arising, especially in the time period of 1800 ~1920. The global average temperature arises about 4 degC since 1800. 

   ![figure1](https://user-images.githubusercontent.com/19471954/27813450-ffc4a482-6043-11e7-8d17-5681efcaa473.png) 
  
  Figure 1. Global annually average temperature changes over years. Inserted plot is temperature uncertainty over years.
   ![figure2](https://user-images.githubusercontent.com/19471954/27813770-268f038a-6046-11e7-86c5-b3f92f0b7be1.png) 
  
  Figure 2. Global minimum, maximum, and average temperature in each 20-year-interval.

### 2. Temperature prediction using prophet time series forecasting package in R
The data contains monthly series of date column and the respective temperature for each date, which was split into train and test sets. The linear growth model was picked to generate prophet model, within which we can. The predictions exhibit perfect match with the real temperature data in test set with lower root mean square error of 0.32 on training dataset and 0.37 on testing dataset, indicating the model could be used to precisely predict future temperatures. The predicted temperatures of a future time series of 84 months to 2018-12-01 were shown as Figure 5. From the temperature trend in Figure 6, the temperature showed a slight drop in the first decade in 1900s, and then increases and reaches a flat phase during 1950 ~ 1970. The global temperature arises dramatically since 1975. It is reasonable to foresee that the global temperature will keep increasing with high growth rate in the next decade. The measures have to be taken immediately to prevent global warming, otherwise our human will be hoisted by our own petard.

   ![figure5](https://user-images.githubusercontent.com/19471954/27813903-15322c7e-6047-11e7-9cf3-c1dd3072554d.png)
   
   Figure 5. The plot of actual temperature (grey dots) vs forecasted data (blue line) and forecasted future temperature (red line) in next two years (2017~2018).




