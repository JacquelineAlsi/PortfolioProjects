-- Checking to see which column names are shared across tables 
SELECT column_name,COUNT(table_name) AS column_name_count 
FROM `portfolioprojects2023.bellabeat.INFORMATION_SCHEMA.COLUMNS`  
GROUP BY 1 
ORDER BY 2 DESC;  

 -- Id is a common column, let's make sure that it is in every table we have  
SELECT table_name,  
SUM(CASE  
WHEN column_name = "Id" THEN 1  
    ELSE  
    0  
    END  
    ) AS has_id_column  
FROM `portfolioprojects2023.bellabeat.INFORMATION_SCHEMA.COLUMNS`  
GROUP BY 1  
ORDER BY 1; 
--Yes, the id column is found in every table 

 
-- Checking how many participants are in each table 
SELECT COUNT(DISTINCT id) AS number_of_ids 
FROM `portfolioprojects2023.bellabeat.SleepDay`;  
 

SELECT COUNT(DISTINCT id) AS number_of_ids 
FROM `portfolioprojects2023.bellabeat.minuteSleep`; 
 

SELECT COUNT(DISTINCT id) AS number_of_ids 
FROM `portfolioprojects2023.bellabeat.DailyActivity`; 

 
SELECT COUNT(DISTINCT id) AS number_of_ids 
FROM `portfolioprojects2023.bellabeat.WeightLogInfo`;  
-- SleepDay AND minuteSleep have 24 each, DailyActivity has 33 and WeightLogInfo has 8. 
-- Conclusion, not all participants are represented in each table 
 

-- Checking to make sure that each table has a date or time related type column 
 SELECT table_name, 
 	SUM(CASE 
     	WHEN data_type IN ("TIMESTAMP", "DATETIME", "TIME", "DATE") THEN 1 
   	ELSE 0 
 	END 
) 
AS has_time_info 
FROM `portfolioprojects2023.bellabeat.INFORMATION_SCHEMA.COLUMNS` 
WHERE data_type IN ("TIMESTAMP","DATETIME", "DATE") 
GROUP BY 1; 

 
--Looking at the columns that are shared among the tables  
SELECT column_name, data_type,  
COUNT(table_name) AS table_count  
FROM `portfolioprojects2023.bellabeat.INFORMATION_SCHEMA.COLUMNS` 
GROUP BY 1, 2; 

 
--How long does it take participants to fall asleep each day? 
SELECT Id, (TotalTimeInBed - TotalMinutesAsleep) As minutes_to_fall_asleep 
FROM `portfolioprojects2023.bellabeat.SleepDay`  
ORDER BY 1; 

 
--How long does it take participants to fall asleep on average by day of the week? 
WITH time_to_sleep AS 
(SELECT Id, SleepDay, TotalTimeInBed, TotalMinutesAsleep, 
FORMAT_DATE('%A', DATE(SleepDay)) AS day_of_week 
FROM `portfolioprojects2023.bellabeat.SleepDay` 
) 
SELECT day_of_week, 
ROUND(AVG(TotalTimeInBed - TotalMinutesAsleep)) As min_to_sleep   
FROM time_to_sleep 
GROUP BY 1; 

 
--How many hours do participants sleep on average by day of the week?  
WITH sleep_length AS  
(SELECT Id, SleepDay, TotalTimeInBed, TotalMinutesAsleep,  
FORMAT_DATE('%A', DATE(SleepDay)) AS day_of_week  
FROM `portfolioprojects2023.bellabeat.SleepDay`  
)  
SELECT day_of_week,  
ROUND(AVG(TotalMinutesAsleep/60),1) As hours_asleep    
FROM sleep_length  
GROUP BY day_of_week; 

 
--Minimum and Maximum hours participants slept 
SELECT Id, ROUND(MIN(TotalMinutesAsleep/60)) As min_hours_asleep,  
ROUND(MAX(CAST(TotalMinutesAsleep as int64)/60)) AS max_hours_asleep 
FROM `portfolioprojects2023.bellabeat.SleepDay`    
GROUP BY 1 
ORDER BY 1; 
 

--Did participants become more or less active over time 
SELECT Id, ActivityDate, ROUND(AVG(SedentaryMinutes)) AS sedentary_minutes,    
ROUND(AVG(LightlyActiveMinutes)) AS lightly_active_minutes,     
ROUND(AVG(FairlyActiveMinutes)) AS fairly_active_minutes,     
ROUND(AVG(VeryActiveMinutes)) AS very_active_minutes,    
FROM `portfolioprojects2023.bellabeat.DailyActivity`     
GROUP BY 1,2  
ORDER BY 6; 

 
--How active were participants 
SELECT Id, ActivityDate, TotalSteps, 
SUM(SedentaryMinutes) AS sedentary_minutes,    
SUM(LightlyActiveMinutes) AS lightly_active_minutes,     
SUM(FairlyActiveMinutes) AS fairly_active_minutes,     
SUM(VeryActiveMinutes) AS very_active_minutes,  
SUM(SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes) 
AS total_minutes 
FROM `portfolioprojects2023.bellabeat.DailyActivity`     
GROUP BY 1,2,3; 


--Average activity level and sleep by day of week
SELECT activity.ActivityDate AS day_of_week,   
ROUND(AVG(SedentaryMinutes)) AS sedentary_minutes,    
ROUND(AVG(LightlyActiveMinutes)) AS lightly_active_minutes,     
ROUND(AVG(FairlyActiveMinutes)) AS fairly_active_minutes,     
ROUND(AVG(VeryActiveMinutes)) AS very_active_minutes,    
ROUND(AVG(TotalMinutesAsleep/60)) As hours_asleep       
FROM `portfolioprojects2023.bellabeat.DailyActivity` AS activity    
JOIN `portfolioprojects2023.bellabeat.SleepDay` AS sleep    
ON activity.ActivityDate = sleep.SleepDay   
GROUP BY 1  
ORDER BY 1;  

 
--Average steps by day of week  
WITH avg_steps_day AS  
(SELECT Id, ActivityDate, TotalSteps,  
FORMAT_DATE('%A', DATE(ActivityDate)) AS day_of_week  
FROM `portfolioprojects2023.bellabeat.DailyActivity`  
)  
SELECT day_of_week,  
ROUND(AVG(TotalSteps)) AS steps    
FROM avg_steps_day  
GROUP BY 1; 

 
 --How does activity level affect amount of sleep? 
SELECT activity.Id, ROUND(AVG(SedentaryMinutes)) AS sedentary_minutes,   
ROUND(AVG(LightlyActiveMinutes)) AS lightly_active_minutes,    
ROUND(AVG(FairlyActiveMinutes)) AS fairly_active_minutes,    
ROUND(AVG(VeryActiveMinutes)) AS very_active_minutes,   
ROUND(AVG(TotalMinutesAsleep/60)) As hours_asleep      
FROM `portfolioprojects2023.bellabeat.DailyActivity` AS activity   
JOIN `portfolioprojects2023.bellabeat.SleepDay` AS sleep   
ON activity.Id = sleep.Id  
AND activity.ActivityDate = sleep.SleepDay 
GROUP BY 1 
ORDER BY 6; 

 
--How does activity level affect how long it takes participants to fall asleep 
SELECT activity.Id, ROUND(AVG(SedentaryMinutes)) AS sedentary_minutes,    
ROUND(AVG(LightlyActiveMinutes)) AS lightly_active_minutes,     
ROUND(AVG(FairlyActiveMinutes)) AS fairly_active_minutes,     
ROUND(AVG(VeryActiveMinutes)) AS very_active_minutes,    
ROUND(AVG(TotalTimeInBed - TotalMinutesAsleep)) As min_to_sleep 
FROM `portfolioprojects2023.bellabeat.DailyActivity` AS activity    
JOIN `portfolioprojects2023.bellabeat.SleepDay` AS sleep    
ON activity.Id = sleep.Id   
AND activity.ActivityDate = sleep.SleepDay  
GROUP BY 1  
ORDER BY 6; 

 
--Which Active Distance type was the greatest and which the least on average? 
SELECT Id, ROUND(AVG(LightActiveDistance),2) AS light_active_dist, 
ROUND(AVG(ModeratelyActiveDistance),2) AS moderately_active_dist, 
ROUND(AVG(VeryActiveDistance),2) AS very_active_dist   
FROM `portfolioprojects2023.bellabeat.DailyActivity`  
GROUP BY 1 
ORDER BY 1; 
 

--How active were the participants on average per day of week? 
WITH activity_per_day AS  
(SELECT Id, ActivityDate, SedentaryMinutes,LightlyActiveMinutes, 
FairlyActiveMinutes,VeryActiveMinutes, 
FORMAT_DATE('%A', DATE(ActivityDate)) AS day_of_week  
FROM `portfolioprojects2023.bellabeat.DailyActivity`  
)  
SELECT day_of_week,  
ROUND(AVG(SedentaryMinutes)) AS sedentary_minutes,  
ROUND(AVG(LightlyActiveMinutes)) AS lightly_active_minutes,   
ROUND(AVG(FairlyActiveMinutes)) AS fairly_active_minutes,   
ROUND(AVG(VeryActiveMinutes)) AS very_active_minutes     
FROM activity_per_day  
GROUP BY day_of_week; 

 

--How many steps were taken on average?   
SELECT Id, ROUND(AVG(TotalSteps)) AS avg_steps   
FROM `portfolioprojects2023.bellabeat.DailyActivity`  
GROUP BY 1 
ORDER BY 1; 
 

--What's the relationship between steps taken in a day and activity 
SELECT Id,   
ROUND(AVG(TotalSteps)) As total_steps, 
ROUND(AVG(SedentaryMinutes)) AS sedentary_minutes,   
ROUND(AVG(LightlyActiveMinutes)) AS lightly_active_minutes,    
ROUND(AVG(FairlyActiveMinutes)) AS fairly_active_minutes,    
ROUND(AVG(VeryActiveMinutes)) AS very_active_minutes 
FROM `portfolioprojects2023.bellabeat.DailyActivity`   
GROUP BY 1 
ORDER BY 2 DESC; 

 
--How many calories did they burn on average? 
SELECT Id, ROUND(AVG(Calories)) AS calories    
FROM `portfolioprojects2023.bellabeat.DailyActivity`   
GROUP BY 1 
ORDER BY 1;  

 
--How do calories relate to activity time?  
SELECT Id,  
ROUND(AVG(SedentaryMinutes)) AS sedentary_minutes,  
ROUND(AVG(LightlyActiveMinutes)) AS lightly_active_minutes,   
ROUND(AVG(FairlyActiveMinutes)) AS fairly_active_minutes,   
ROUND(AVG(VeryActiveMinutes)) AS very_active_minutes,  
ROUND(AVG(Calories)) As calories     
FROM `portfolioprojects2023.bellabeat.DailyActivity`  
GROUP BY 1 
ORDER BY 6; 

 
--What was their minimum and maximum weight? 
SELECT Id, ROUND(MIN(WeightPounds),1) AS min_weight,  
ROUND(MAX(WeightPounds),1) AS max_weight 
FROM `portfolioprojects2023.bellabeat.WeightLogInfo`  
GROUP BY 1 
ORDER BY 1; 

 
SELECT  Id,AVG(TotalSteps) AS avg_total_steps 
FROM `portfolioprojects2023.bellabeat.DailyActivity` 
WHERE TotalSteps <>0 
GROUP BY Id, TotalSteps;
