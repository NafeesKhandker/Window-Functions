DROP TABLE IF EXISTS Stock_Prices;

-- Create an empty table that has columns name, date and close.
CREATE TABLE stock_prices (
    name VARCHAR(10),
    date DATE,
    close NUMERIC
);

-- Copy the csv data to the table
COPY stock_prices
FROM 'C:\\Program Files\\PostgreSQL\\18\\data\\Data_TSLA_AAPL_AMZN_MSFT.csv'
DELIMITER ','
CSV HEADER
NULL 'NA';

-- Check the data
SELECT * FROM stock_prices ORDER BY name, date;

DROP TABLE IF EXISTS moving_avg_6d;
-- Create a new table moving_avg_6d
-- Create a column ytd_avg that shows the year to date average
-- Create another column moving_avg_6d that shows the 6-day moving average.

CREATE TABLE moving_avg_6d AS
SELECT
    name,
    date,
    close,
    -- Year-to-date average
    AVG(close) OVER (
        PARTITION BY name, EXTRACT(YEAR FROM date) -- Break data into groups so that each stock and each year is separate
        ORDER BY date -- Within each partition, sort by date (very important step)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- Define the window
    ) AS ytd_avg,
    -- 6-day moving average
    AVG(close) OVER (
        PARTITION BY name
        ORDER BY date
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW -- Define window for 6-day
    ) AS moving_avg_6d
FROM stock_prices
ORDER BY name, date; -- Final output is sorted: all AAPL rows, then AMZN, then MSFT, then TSLA, each sorted by date

-- Check the output for each stock
SELECT * FROM moving_avg_6d;

SELECT * FROM moving_avg_6d WHERE name = 'TSLA';
SELECT * FROM moving_avg_6d WHERE name = 'AMZN';
SELECT * FROM moving_avg_6d WHERE name = 'MSFT';

