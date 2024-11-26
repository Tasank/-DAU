WITH DailyActiveUsers AS (
    SELECT
        to_char(entry_at, 'YYYY-MM-DD') AS ymd,
        COUNT(DISTINCT user_id) AS cnt
    FROM
        UserEntry
    WHERE
        entry_at >= '2022-01-01' AND entry_at < '2023-01-01'
    GROUP BY
        to_char(entry_at, 'YYYY-MM-DD')
),
SlidingAverages AS (
    SELECT
        ymd,
        cnt,
        AVG(cnt) OVER (ORDER BY ymd ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sliding_average
    FROM
        DailyActiveUsers
),
SlidingMedians AS (
    SELECT
        ymd,
        cnt,
        sliding_average,
        (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cnt)
         FROM (SELECT cnt
               FROM SlidingAverages
               WHERE ymd <= sa.ymd) AS subquery) AS sliding_median
    FROM
        SlidingAverages sa
)
SELECT
    ymd,
    cnt,
    sliding_average,
    sliding_median
FROM
    SlidingMedians
ORDER BY
    ymd;