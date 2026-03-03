SELECT current_database();


SELECT table_name 
FROM information_schema.tables
WHERE table_schema = 'public';







CREATE TABLE toyota_stock (
    date DATE,
    open FLOAT,
    high FLOAT,
    low FLOAT,
    close FLOAT,
    volume BIGINT
);








SELECT * FROM toyota_stock LIMIT 10;
---Check Total Rows
select count(*) from toyota_stock;


--------Check Column Types

SELECT *
FROM toyota_stock
WHERE "Open" IS NULL
   OR "High" IS NULL
   OR "Low" IS NULL
   OR "Close" IS NULL
   OR "Volume" IS NULL;



--------DESCRIPTIVE STATISTICS
---Date Range

SELECT MIN("Date") AS start_date,
       MAX("Date") AS end_date
FROM toyota_stock;





-- min. max, avg close price
SELECT 
    MIN("Close") AS min_price,
    MAX("Close") AS max_price,
    AVG("Close") AS avg_price
FROM toyota_stock;



----------- Daily price change

select "Date","Close" - "Open" AS price_change from toyota_stock order by "Date";





SELECT 
    "Date",
    "Close",
    LAG("Close") OVER (ORDER BY "Date") AS prev_close,
    ROUND(
        (("Close" - LAG("Close") OVER (ORDER BY "Date"))
        / LAG("Close") OVER (ORDER BY "Date")) * 100
    , 2) AS daily_return_percent
FROM toyota_stock;


----50-Day Moving Average

SELECT 
    "Date",
    "Close",
    AVG("Close") OVER (
        ORDER BY "Date"
        ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
    ) AS ma50
FROM toyota_stock;















-------------Monthly Average

SELECT 
    DATE_TRUNC('month', "Date") AS month,
    AVG("Close") AS avg_month_price
FROM toyota_stock
GROUP BY month
ORDER BY month;


SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'toyota_stock';


ALTER TABLE toyota_stock
ALTER COLUMN "Date" TYPE DATE
USING "Date"::DATE;


---Yearly Analysis

SELECT 
    DATE_PART('year', "Date") AS year,
    MIN("Close") AS yearly_low,
    MAX("Close") AS yearly_high,
    AVG("Close") AS yearly_avg
FROM toyota_stock
GROUP BY year
ORDER BY year;




----- highesrt Vollumen Day

SELECT "Date", "Volume"
FROM toyota_stock
ORDER BY "Volume" DESC
LIMIT 1;







CREATE VIEW toyota_stock_analysis AS
SELECT 
    "Date",
    "Open",
    "High",
    "Low",
    "Close",
    "Volume",
    "Close" - "Open" AS price_change,
    AVG("Close") OVER (
        ORDER BY "Date"
        ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
    ) AS ma50
FROM toyota_stock;


-------Cumulative Return
WITH returns AS (
    SELECT 
        "Date",
        ("Close" / LAG("Close") OVER (ORDER BY "Date")) - 1 AS daily_return
    FROM toyota_stock
)
SELECT 
    "Date",
    EXP(SUM(LN(1 + daily_return)) 
        OVER (ORDER BY "Date")) - 1 AS cumulative_return
FROM returns
WHERE daily_return IS NOT NULL;

  

-----Rolling Volatility -- 30 days's



---Top 5 Best Days

SELECT 
    "Date",
    ("Close" - "Open") AS gain
FROM toyota_stock
ORDER BY gain DESC
LIMIT 5;



----- Top 5 Worst Days

SELECT 
    "Date",
    ("Close" - "Open") AS loss
FROM toyota_stock
ORDER BY loss ASC
LIMIT 5;




-----Yearly Return %



WITH yearly AS (
    SELECT 
        DATE_PART('year', "Date") AS year,
        FIRST_VALUE("Close") OVER (
            PARTITION BY DATE_PART('year', "Date")
            ORDER BY "Date"
        ) AS first_price,
        LAST_VALUE("Close") OVER (
            PARTITION BY DATE_PART('year', "Date")
            ORDER BY "Date"
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_price
    FROM toyota_stock
)
SELECT DISTINCT
    year,
    ROUND(
        (((last_price - first_price) / first_price) * 100)::numeric
    , 2) AS yearly_return_percent
FROM yearly
ORDER BY year;



---Drawdown Analysis

WITH running_max AS (
    SELECT 
        "Date",
        "Close",
        MAX("Close") OVER (ORDER BY "Date") AS peak_price
    FROM toyota_stock
)
SELECT 
    "Date",
    "Close",
    peak_price,
    ROUND(
        ("Close" - peak_price) / peak_price * 100
    ,2) AS drawdown_percent
FROM running_max
ORDER BY drawdown_percent ASC
LIMIT 5;








CREATE VIEW toyota_performance_analysis AS
SELECT 
    "Date",
    "Open",
    "High",
    "Low",
    "Close",
    "Volume",
    "Close" - "Open" AS daily_gain,
    LAG("Close") OVER (ORDER BY "Date") AS prev_close,
    AVG("Close") OVER (
        ORDER BY "Date"
        ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
    ) AS ma50,
    AVG("Close") OVER (
        ORDER BY "Date"
        ROWS BETWEEN 199 PRECEDING AND CURRENT ROW
    ) AS ma200
FROM toyota_stock;




DROP VIEW toyota_stock_analysis;



ALTER TABLE toyota_stock
ALTER COLUMN "Close" TYPE numeric USING "Close"::numeric;

ALTER TABLE toyota_stock
ALTER COLUMN "Open" TYPE numeric USING "Open"::numeric;

ALTER TABLE toyota_stock
ALTER COLUMN "High" TYPE numeric USING "High"::numeric;

ALTER TABLE toyota_stock
ALTER COLUMN "Low" TYPE numeric USING "Low"::numeric;











CREATE VIEW toyota_stock_analysis AS
SELECT 
    "Date",
    "Open",
    "High",
    "Low",
    "Close",
    "Volume",
    "Close" - "Open" AS daily_gain,
    AVG("Close") OVER (
        ORDER BY "Date"
        ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
    ) AS ma50
FROM toyota_stock;











