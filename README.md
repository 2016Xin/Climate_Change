# Climate_Change
## The Earth Surface Temperature Dataset Analysis and Visualization

The dataset I analyzed is the Earth Surface Temperature Data sourced from Kaggle website.  There are five .csv files in the dataset, categorizing the global land temperature records by cities and countries. The file of “globallandtemperaturesbycity.csv” was used, containing 8235082 monthly temperatures covering 3448 cities from 159 countries. Dataset was uploaded into HIVE table temp_city_c, removing missing values and creating year, month, latitude_num, latitude_type, longitude_num, and longitude_type columns. The latitude_num and longitude_num were altered to negative value if the latitude_type and longitude_type are South and West, respectively. The code is listed in the link. The temperature records before 1800 are sparse with too many monthly temperature data unmeasured, therefore the data before 1800 were neglected. 

There are two main aims in this study. The first goal is to find out “Does global warming exist?” AVG () statement was used to get monthly and annually average temperatures. The global annually average temperature changing over years was calculated and displayed in Figure 1. We can see clearly that the average temperature has been increasing significantly since early 18th centry. The growth rate of temperature is getting higher in the latest decades, indicated by the lope of the curve. The maximum, minimum and average temperatures of each 20-year-interval were calculated using HiveQL queries (Figure 2).  The global maximum temperature of each time period didn’t show much change since 1800, while the global minimum temperature exhibits significant arising, especially in the time period of 1800 ~1920. The global average temperature arises about 4 degC since 1800. 

   ![figure1](https://user-images.githubusercontent.com/19471954/27813450-ffc4a482-6043-11e7-8d17-5681efcaa473.png)



