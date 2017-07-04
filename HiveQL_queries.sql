CREATE TABLE GlobalLandTemperaturesByCity (dt DATE, AverageTemperature STRING, 
    AverageTemperatureUncertainty STRING, Country STRING, city STRING) ;

LOAD DATA INPATH ‘~/data/globallandtemperaturesbycity.csv’ INTO TABLE GlobalLandTemperaturesByCity;

ALTER TABLE GlobalLandTemperaturesByCity 
set serde 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES ('field.delim' = ‘,’);

# ***************************************************************************
# create a cleaned table as select from origin table
# removing missing value and create new columns of year, month…

CREATE TABLE temp_city_c AS
SELECT dt, 
	regexp_extract(dt, '^([0-9]+)-([0-9]+)-([0-9]+)', 1) as year, 
	regexp_extract(dt, '^([0-9]+)-([0-9]+)-([0-9]+)', 2) as month,
	averagetemperature as avgT, averagetemperatureuncertainty as t_uncertainty, 
city, Country, latitude, 
	regexp_extract(latitude, '^([0-9]+.[0-9]+)([N|S|E|W])', 1) as latitude_num, 
	regexp_extract(latitude, '^([0-9]+.[0-9]+)([N|S|E|W])', 2) as latitude_type,
	longitude,	
	regexp_extract(longitude, '^([0-9]+.[0-9]+)([N|S|E|W])', 1) as longitude_num, 
	regexp_extract(longitude, '^([0-9]+.[0-9]+)([N|S|E|W])', 2) as longitude_type
	
FROM globallandtemperaturesbycity
WHERE averagetemperature != "";

# ***************************************************************************
# — Average Temperature 
# table temp_avg is the average temperature of North Earth
# table atemp_avg is the global average temperature

# average temperature of North Earth
CREATE TABLE temp_avg AS
  SELECT year, month, AVG(avgt) as avg_t
  FROM temp_city_c
  WHERE latitude_type =="N"
  GROUP BY year, month;

# global monthly average temperature 
SELECT year, AVG(avgt) as avg_t, AVG(t_uncertainty) AS avg_un
FROM temp_city_c
GROUP BY year month;

# global annual average temperature 
SELECT year, MAX(avg_t) as max_t, MIN(avg_t) as min_t, AVG(avg_t) as mean_t
FROM atemp_avg
WHERE year > 1749
GROUP BY year;
# ————————————Figure 1
# Point plot in R
# yy_avg <- fread("/Users/xchen011/Downloads/global_avgt_annual.csv")
# yy_avg_s <- filter(yy_avg, yy_avg$year >= 1800 )
# ggplot(yy_avg_s, aes(x = yy_avg_s$year, y = yy_avg_s$avg_t)) + geom_point() + geom_smooth() + labs(title = "Global Average Temperature", x = "Year", y = "Average Temperature")
# —————————————

# — Maximum Minimum Mean temperature of each year
CREATE TABLE temp_year_min_max AS
  SELECT year, MAX(avg_t) as max_t, MIN(avg_t) as min_t, AVG(avg_t) as mean_t
  FROM temp_avg
  GROUP BY year;

# — Group 20 years as a time period, calculate min max and mean temperature of each category
SELECT year, max_t, min_t, mean_t, 
CASE 
when t.year BETWEEN 1800 AND 1820 then "1800-1820"
when t.year BETWEEN 1821 AND 1840 then "1821-1840"
when t.year BETWEEN 1841 AND 1860 then "1841-1860"
when t.year BETWEEN 1861 AND 1880 then "1861-1880"
when t.year BETWEEN 1881 AND 1900 then "1881-1900"
when t.year BETWEEN 1901 AND 1920 then "1901-1920"
when t.year BETWEEN 1921 AND 1940 then "1921-1940"
when t.year BETWEEN 1941 AND 1960 then "1941-1960" 
when t.year BETWEEN 1961 AND 1980 then "1961-1980"
when t.year BETWEEN 1981 AND 2000 then "1981-2000"
when t.year BETWEEN 2001 AND 2013 then "2001-2013"
else "before 1800”
END AS category
FROM temp_year_min_max t;

# — Add category columns in table of atemp_avg  (LEFT JOIN)
SELECT t1.year, t1.month,t1.avg_t, t1.avg_un, t2.category
FROM atemp_avg t1
LEFT JOIN atemp_min_max_ann_cat t2
ON t1.year = t2.year;

# ———————————————Figure 2
# box plot in R
# cat_avgt <- fread("/Users/xchen011/Downloads/temp_avg_cat.csv")
# cat_avgt_s <- filter(cat_avgt, cat_avgt$t1.year >= 1800)
# boxplot(cat_avgt_s$t1.avg_t~cat_avgt_s$t2.category) 
# ————————————————————

# summarise:
SELECT category, MAX(max_t) as maxt, MIN(min_t) as mint, AVG(mean_t) as meant
FROM category_year_avgt
GROUP BY category;


# ==========================================

SELECT country, city, AVG(avgt) as avgt, stddev_pop(avgt) as stdt,  
CASE 
WHEN latitude_type = "N" then latitude_num
else -latitude_num
end as latitude_num, latitude_type, 
CASE
when longitude_type = "E" then longitude_num
else -longitude_num
end as longitude_num, longitude_type
FROM temp_city_c
WHERE month = "07" AND (year BETWEEN 1800 and 1816)
GROUP BY city, country, latitude_num, latitude_type, longitude_num, longitude_type
ORDER BY country;

CREATE TABLE atemp_1816_07 AS
SELECT t1.country, t1.city, t1.latitude_num, t1.longitude_num, t1.avgt, (t2.avgt - t1.avgt) as tdiff, t2.stdt
FROM atemp_city_c t1
LEFT JOIN atemp_avg_std_before1816 t2
ON t1.country = t2.country AND t1.city = t2.city
WHERE t1.year = 1816 AND t1.month = 07
ORDER BY tdiff DESC;

SELECT country, city, latitude_num, longitude_num, avgt, tdiff, stdt
FROM atemp_1816_07
WHERE tdiff > stdt AND tdiff IS NOT NULL;


# select the cities and countries with lower temperature than the years before 1816
SELECT country, city, latitude_num, longitude_num, avgt, tdiff, stdt, 
CASE 
when t.tdiff BETWEEN 6 AND 8 then "000d33"
when t.tdiff BETWEEN 5 AND 5.99999 then "00134d"
when t.tdiff BETWEEN 4 AND 4.99999 then "001a66"
when t.tdiff BETWEEN 3 AND 3.99999 then "002db3"
when t.tdiff BETWEEN 2 AND 2.99999 then "0040ff"
when t.tdiff BETWEEN 1 AND 1.99999 then "4d79ff"
when t.tdiff BETWEEN 0.5 AND 0.99999 then "668cff" 
else "99b3ff"
END AS color
FROM atemp_1816_07 t;


# ============================================================= TS table
CREATE TABLE ts_temp_c AS 
SELECT dt, year, month, 
CASE 
WHEN avgt = "" THEN 0
ELSE avgt
end as avgt,
CASE
WHEN t_uncertainty= "" THEN 0
else t_uncertainty
end as t_uncertainty, 
city, country, latitude,
CASE 
WHEN latitude_type = "N" then latitude_num
else -latitude_num
end as latitude_num, 
CASE
when longitude_type = "E" then longitude_num
else -longitude_num
end as longitude_num
FROM ts_temp;

# =============================== format datetime as DATE=========
## the format of date in 90s  is dd/mm/yy
SELECT cast(dt as date) AS dt, AVG(averagetemperature) as avgt
FROM globallandtemperaturesbycity
GROUP BY dt
ORDER BY dt;
