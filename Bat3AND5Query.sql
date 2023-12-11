--1. Performance of 3 & 5 batsmen from innings 1

IF OBJECT_ID('tempdb..#InningsOne3AND5Patterns', 'U') IS NOT NULL
    DROP TABLE #InningsOne3AND5Patterns;

WITH ScorePatterns AS (
    SELECT
        First.GameID,
        First.Innings,
        CASE
            WHEN First.Runs > 20 AND Second.Runs > 20 THEN 'Both >20'
            WHEN First.Runs > 20 AND Second.Runs < 20 THEN 'Only BatNumber 3 >20'
            WHEN Second.Runs > 20 AND First.Runs < 20 THEN 'Only BatNumber 5 >20'
            ELSE 'None >20'
        END AS ScoringPattern
    FROM
        ProjectBBL..BattingStats AS First
    JOIN
        ProjectBBL..BattingStats AS Second
    ON
        First.GameID = Second.GameID
        AND First.Innings = Second.Innings
        AND First.GameID = Second.GameID
        AND First.Innings = 1
        AND First.BatNumber = 3
        AND Second.BatNumber = 5
)
-- Saving the results into a temporary table
SELECT 
    ScoringPattern,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS InningsOnePercentage
INTO #InningsOne3AND5Patterns
FROM ScorePatterns
GROUP BY ScoringPattern
ORDER BY InningsOnePercentage DESC;

Select *
From ProjectBBL..#InningsOne3AND5Patterns


--2. Performance of 3 & 5 batsmen from innings 2

IF OBJECT_ID('tempdb..#InningsTwo3AND5Patterns', 'U') IS NOT NULL
    DROP TABLE #InningsTwo3AND5Patterns;

WITH ScorePatterns AS (
    SELECT
        First.GameID,
        First.Innings,
       CASE
            WHEN First.Runs > 20 AND Second.Runs > 20 THEN 'Both >20'
            WHEN First.Runs > 20 AND Second.Runs < 20 THEN 'Only BatNumber 3 >20'
            WHEN Second.Runs > 20 AND First.Runs < 20 THEN 'Only BatNumber 5 >20'
            ELSE 'None >20'
        END AS ScoringPattern
    FROM
        ProjectBBL..BattingStats AS First
    JOIN
        ProjectBBL..BattingStats AS Second
    ON
        First.GameID = Second.GameID
        AND First.Innings = Second.Innings
        AND First.GameID = Second.GameID
        AND First.Innings = 2
        AND First.BatNumber = 3
        AND Second.BatNumber = 5
)
-- Saving the results into a temporary table
SELECT 
    ScoringPattern,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS InningsTwoPercentage
INTO #InningsTwo3AND5Patterns
FROM ScorePatterns
GROUP BY ScoringPattern
ORDER BY InningsTwoPercentage DESC;

Select *
From ProjectBBL..#InningsTwo3AND5Patterns

--3. Comparison of Performance of 3 & 5 batsmen from each innings

SELECT
    InningsOne.ScoringPattern AS ScoringPattern,
    InningsOne.InningsOnePercentage,
    InningsTwo.InningsTwoPercentage
FROM
    #InningsOne3AND5Patterns AS InningsOne
JOIN
    #InningsTwo3AND5Patterns AS InningsTwo ON InningsOne.ScoringPattern = InningsTwo.ScoringPattern;