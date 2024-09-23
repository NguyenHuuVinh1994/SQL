--DROP DATABASE IF EXISTS Challenge
--CREATE DATABASE Challenge
--USE Challenge
drop table if exists SalesData
CREATE TABLE SalesData (
    userID INT,
    sale_session INT,
    channel VARCHAR(50),
    revenue DECIMAL(10, 2)
);

INSERT INTO SalesData VALUES
(6652, 7, 'EMAIL', 52.00),
(6832, 3, 'DIRECT', 64.32),
(7890, 3, 'PAID SEARCH', 75.00);

drop table if exists UserSessions
CREATE TABLE UserSessions (
    userID INT,
    sessions INT,
    channel VARCHAR(50)
);
INSERT INTO UserSessions VALUES
(6652, 1, 'Paid Search'),
(6652, 2, 'Organic Search NB'),
(6652, 3, 'Organic Search NB'),
(6652, 4, 'Display RT'),
(6652, 5, 'SEA Search Brand'),
(6652, 6, 'EMAIL'),
(6652, 7, 'EMAIL'),
(6652, 8, 'DIRECT'),
(6832, 1, 'Paid Search'),
(6832, 2, 'Organic Search NB'),
(6832, 3, 'DIRECT'),
(7890, 1, 'Paid Search'),
(7890, 2, 'Organic Search NB'),
(7890, 3, 'Display RT'),
(7890, 4, 'SEA Search Brand'),
(7890, 5, 'PAID SEARCH');

--> Tạo bảng CTE tính toán các số liệu cần thiết
WITH RevenueCTE AS (
	SELECT 
		us.userID,
		us.channel,
		sd.revenue,
		ROW_NUMBER() OVER (PARTITION BY us.userID ORDER BY us.sessions) AS rn,
		COUNT(*) OVER (PARTITION BY us.userID) AS total_sessions
	FROM UserSessions us
	JOIN SalesData sd ON us.userID = sd.userID
	WHERE us.sessions <= sd.sale_session
),
-->Tạo bảng dựa trên điều kiện
	--1chanel = 100%; 2chanel =/2; nếu nhiều hơn chia tỷ lệ 40% cho chanel đầu, 40% cho chanel bán hàng còn lại 20%
RevenueDistribution as (
SELECT 
	userID,
	channel,
	CASE 
		WHEN total_sessions = 1 THEN revenue
		WHEN total_sessions = 2 THEN revenue / 2
		WHEN rn = 1 THEN revenue * 0.4
		WHEN rn = total_sessions THEN revenue * 0.4
		ELSE revenue * 0.2 / (total_sessions - 2)
	END AS allocated_revenue
FROM RevenueCTE
)

SELECT 
    channel,
    CAST(SUM(allocated_revenue) AS FLOAT) AS total_revenue
FROM RevenueDistribution
GROUP BY channel
order by SUM(allocated_revenue)  desc

