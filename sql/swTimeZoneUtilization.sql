--EASTERN = (CAST(DateTime as TIME) BETWEEN '06:00' and '18:00')
--CENTRAL = (CAST(DateTime as TIME) BETWEEN '07:00' and '19:00')
--MOUNTAIN = (CAST(DateTime as TIME) BETWEEN '08:00' and '20:00')
--PACIFIC = (CAST(DateTime as TIME) BETWEEN '09:00' and '21:00')
--ALASKA = (CAST(DateTime as TIME) BETWEEN '10:00' and '22:00')
--HAWAII = (CAST(DateTime as TIME) BETWEEN '12:00' and '23:59')
--Last Week (not last 7 days)
DECLARE @lastsunday DATETIME

SET @lastsunday = dateadd(wk, datediff(wk, 0, getdate()) - 1, 0)

DECLARE @lastsaturday DATETIME

SET @lastsaturday = dateadd(wk, datediff(wk, 0, getdate()) - 1, 7)

SELECT x.device
	,x.interface
	,x.jobsite
	,x.usercount
	,x.avgrcv
	,x.avgxmt
	,x.totalavg
	,CASE 
		WHEN x.usercount = '0'
			THEN '0'
		ELSE cast((x.TotalAvg / x.UserCount) AS DECIMAL(9, 2))
		END AS perUser
FROM (
	SELECT n.caption AS 'Device'
		,i.caption AS 'Interface'
		,n.jobsite
		,n.usercount
		,CASE 
			WHEN i.inbandwidth = 0
				THEN 0
			ELSE cast((tr.avg_in / i.inbandwidth) * 100 AS DECIMAL(9, 2))
			END AS 'AvgRCV'
		,CASE 
			WHEN i.outbandwidth = 0
				THEN 0
			ELSE cast((tr.avg_out / i.outbandwidth) * 100 AS DECIMAL(9, 2))
			END AS 'AvgXMT'
		,((tr.avg_in + tr.avg_out) / (i.inbandwidth + i.outbandwidth)) * 100 AS 'TotalAvg'
	FROM interfaces i
	JOIN nodes n ON n.nodeid = i.nodeid
	JOIN (
		SELECT interfaceid
			,avg(in_averagebps) AS avg_in
			,avg(out_averagebps) AS avg_out
		FROM interfacetraffic_detail
		WHERE (
				in_averagebps IS NOT NULL
				AND out_averagebps IS NOT NULL
				)
			AND (
				(
					DATETIME >= @lastsunday
					AND DATETIME < @lastsaturday
					) --last week
				AND (
					(datepart(weekday, DATETIME) <> 1)
					AND -- 1 represents sunday
					(datepart(weekday, DATETIME) <> 7)
					AND -- 7 represents saturday
					--This is your time zone offset from EST
					(
						CAST(DATETIME AS TIME) BETWEEN '06:00'
							AND '18:00'
						)
					)
				)
		GROUP BY interfaceid
		) AS tr ON tr.interfaceid = i.interfaceid
	WHERE i.outsideinterface = 1
		AND (
			i.InBandwidth <> '0'
			AND i.OutBandwidth <> '0'
			)
		AND n.region = 'AMER'
		AND n.TimeZone = 'EASTERN'
	) x
