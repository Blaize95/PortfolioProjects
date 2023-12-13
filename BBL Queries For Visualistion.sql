/*
BBL Australia - Batting Statistics
This set of SQL queries delves into batting statistics for the 2021/22 and 2022/23 BBL seasons.
The goal was to determine scoring patterns and gain insight into how runs are scored by each batting position and innings.
*/

-- 1. Average Runs Per Batting Position
SELECT BatNumber, AVG(Runs) AS AverageRuns
FROM BattingStats
GROUP BY BatNumber
ORDER BY BatNumber;

-- 2. Average Runs Per Batting Position - Innings Comparison

SELECT
    BatNumber,
    AVG(CASE WHEN Innings = 1 THEN Runs END) AS AverageRunsInning1,
    AVG(CASE WHEN Innings = 2 THEN Runs END) AS AverageRunsInning2
FROM BattingStats
GROUP BY BatNumber
ORDER BY BatNumber;


-- 3. Ranking Bat Numbers by Average Runs
-- Although the list can be simply ordered by AverageRuns to achieve a similar result, I find it useful to assign a ranking. 

WITH BattingAverages AS (
    SELECT BatNumber, AVG(Runs) AS AverageRuns
    FROM BattingStats
    GROUP BY BatNumber
)
SELECT BatNumber, AverageRuns,
       RANK() OVER (ORDER BY AverageRuns DESC) AS Rank
FROM BattingAverages;

-- 4. Comparison of Average Runs Per Batting Position to the Overall Average

SELECT BatNumber, AverageRuns,
       CASE WHEN AverageRuns > OverallAverage THEN 'Above Average'
            ELSE 'Below Average'
       END AS PerformanceCategory
FROM (
    SELECT BatNumber, AVG(Runs) AS AverageRuns,
           AVG(AVG(Runs)) OVER () AS OverallAverage
    FROM BattingStats
    GROUP BY BatNumber
) AS BattingAverages
ORDER BY BatNumber;

-- 5. Retrieving the Top 5 Batters Based On Average Runs - 1st Innings

SELECT TOP 5 BatNumber, AverageRuns
FROM (
    SELECT BatNumber, Innings, AVG(Runs) AS AverageRuns
    FROM BattingStats
    WHERE Innings = 1
    GROUP BY BatNumber, Innings
) AS BattingAverages
ORDER BY AverageRuns DESC;

-- 6. Retrieving the Top 5 Batters Based On Average Runs - 2nd Innings

SELECT TOP 5 BatNumber, AverageRuns
FROM (
    SELECT BatNumber, Innings, AVG(Runs) AS AverageRuns
    FROM BattingStats
    WHERE Innings = 2
    GROUP BY BatNumber, Innings
) AS BattingAverages
ORDER BY AverageRuns DESC;

-- 7. Time Series of Running Average Over Two Seasons. Variable can be changed per batting position and innings. 
-- VISUALISE IN TABLEAU

WITH BattingAverages AS (
    SELECT
        GameID,
        BatNumber,
        AVG(Runs) OVER (PARTITION BY BatNumber ORDER BY GameID) AS RunningAverage
    FROM
        BattingStats
)
SELECT
    DISTINCT GameID,
    BatNumber,
    FIRST_VALUE(RunningAverage) OVER (PARTITION BY GameID, BatNumber ORDER BY GameID) AS RunningAverage
FROM BattingAverages
WHERE BatNumber BETWEEN 1 AND 5
ORDER BY GameID, BatNumber;


-- 8. Average Runs Per Bat Number (1-4), using venue as the variable. Innings can also be used as variable in the 'WHERE Innings' statement. 
-- The query counts the number of venues that have been played at more than 5 times. It achieves this by counting venue based on distinct GameID. 
-- A value of more than 5 for the venue count allows for more accurate representation of averages. 
-- VISUALISE IN TABLEAU


SELECT
    Venue,
    AVG(CASE WHEN BatNumber = 1 THEN Runs END) AS AverageRuns_Bat1,
    AVG(CASE WHEN BatNumber = 2 THEN Runs END) AS AverageRuns_Bat2,
    AVG(CASE WHEN BatNumber = 3 THEN Runs END) AS AverageRuns_Bat3,
    AVG(CASE WHEN BatNumber = 4 THEN Runs END) AS AverageRuns_Bat4
FROM BattingStats
WHERE Innings = 2
GROUP BY Venue
HAVING COUNT(DISTINCT GameID) > 5;












