##### ------- Online Casino Product Analytics ------- #####


#1: Unique Users and Gadgets from July 2023 to December 2023
SELECT 
    EXTRACT(YEAR FROM event_timestamp) AS year,
    EXTRACT(YEAR FROM event_timestamp) AS month,
    COUNT(DISTINCT player_id) AS unique_players,
    COUNT(DISTINCT gadget_id) AS unique_gadgets
FROM
    event_log
WHERE
    event_timestamp >= '2023-07-01' AND event_timestamp < '2024-01-01'
GROUP BY year, month
ORDER BY year, month;


#2: Top 5 Countries by Registered Users in 2023
SELECT 
    country_code,
    COUNT(DISTINCT player_id) AS registered_users
FROM
    user_info
WHERE
    ToYear(record_created) = 2023
GROUP BY country_code
ORDER BY registered_users DESC
LIMIT 5;


#3: Top 5 Users by Total Payments in 2023 for Each of the Top 5 Country

-- Step 1: Aggregate Payments
WITH UsersPayments AS (
	SELECT 
		player_id,
		SUM(amount_RUB) as total_payments
	FROM payment_records
	WHERE payment_successfull = 1 AND toYear(payment_initiated) = 2023
	GROUP BY player_id
)
-- Step 2: Identify Top 5 Countries
, TopCountries AS (
	SELECT 
		country_code
	FROM user_info
	JOIN UserPayments ON user_info.player_id = UserPayments.player_id
	GROUP BY country_code
	ORDER BY SUM(total_payments) DESC
	LIMIT 5
)
-- Step 3: Rank Users Within Countries and Filter for Top 5
SELECT 
	user_info.country_code,
	UserPayments.player_id,
	UserPayments.total_payments
FROM UserPayments
JOIN user_info on UserPayments.player_id = user_info.player_id
WHERE user_info.country_code IN (SELECT country_code FROM TopCountries)
ORDER BY user_info.country_code, total_payments DESC
LIMIT 5 BY user_info.country_code;


#4: Average Session Length for the Whole Website in 2023
WITH SessionDurations AS (
	SELECT
        play_session_id,
        MIN(event_timestamp) AS session_start,
        MAX(event_timestamp) AS session_end
    FROM event_log
    WHERE toYear(event_timestamp) = 2023
    GROUP BY play_session_id
)
, AverageSessionLength AS (
	SELECT
		AVG(session_end - session_start) AS avg_session_length
	FROM SessionDurations
)
SELECT 
    avg_session_length
FROM AverageSessionLength;

    
#5: Daily Active Users (DAU) Who Have Confirmed Their Email Addresses by Month, from July 2023 to December 2023
SELECT 
    toYear(event_timestamp) AS year,
    toMonth(event_timestamp) AS month,
    COUNT(DISTINCT player_id) AS DAU
FROM
    event_log
        JOIN
    user_info ON event_log.player_id = user_info.player_id
WHERE
    (email_verified IS NOT NULL OR email_verified <> '1970-01-01')
        AND event_timestamp >= '2023-07-01'
        AND event_timestamp < '2024-01-01'
GROUP BY year, month
ORDER BY year, month;


#6: The Proportion of Successful Payment Amounts from Users with a Confirmed Email in December 2023
WITH TotalPayments AS (
	SELECT
		SUM(amount_RUB) AS total_amount
	FROM payment_records
    WHERE 
		(payment_successful IS NOT NULL OR payment_successful <> '1970-01-01')
        AND toYear(payment_initiated) = 2023
        AND toMonth(payment_initiated) = 12
)
, ConfirmedEmalPayments AS (
	SELECT
		SUM(amount_RUB) AS confirmed_email_amount
	FROM 
		payment_records
			JOIN 
        user_info ON payment_records.player_id = user_info.player_id
    WHERE
		(payment_successful IS NOT NULL OR payment_successful <> '1970-01-01')
        AND (email_verified IS NOT NULL OR email_verified <> '1970-01-01')
        AND toYear(payment_initiated) = 2023
        AND toMonth(payment_initiated) = 12
        -- Ensure email was verified at some point before or during the payment month
        AND email_verified <= toStartOfMonth(toDate(payment_successful)) + INTERVAL 1 MONTH - INTERVAL 1 SECOND
)
SELECT
	confirmed_email_amount / total_amount AS proportion_with_confirmed_email
FROM
	ConfirmedEmalPayments,
    TotalPayments;


#7: Mean, Lower Quartile, Median, and Upper Quartile of the Time between Successful Payments for Each User
WITH PaymentDifferences AS (
    SELECT 
        player_id,
        -- Calculate the difference in seconds between consecutive successful payments
        dateDiff('second', LAG(payment_successful) OVER (PARTITION BY player_id ORDER BY payment_successful), payment_successful) AS time_diff
    FROM 
        payment_records
    WHERE 
        (payment_successful IS NOT NULL OR payment_successful <> '1970-01-01')
)
, UserDifferences AS (
    SELECT 
        player_id,
        -- Collect all time differences into an array for each user
        groupArray(time_diff) AS time_diffs
    FROM 
        PaymentDifferences
    GROUP BY 
        player_id
)
SELECT 
    player_id,
    -- Calculate the mean of time differences
    avg(arrayJoin(time_diffs)) AS mean_diff,
    -- Calculate the lower quartile (25th percentile)
    arrayElement(arraySort(time_diffs), toUInt32(0.25 * length(time_diffs) + 0.5)) AS lower_quartile,
    -- Calculate the median (50th percentile)
    arrayElement(arraySort(time_diffs), toUInt32(0.5 * length(time_diffs) + 0.5)) AS median,
    -- Calculate the upper quartile (75th percentile)
    arrayElement(arraySort(time_diffs), toUInt32(0.75 * length(time_diffs) + 0.5)) AS upper_quartile
FROM 
    UserDifferences;

