/******************************
** File:   PeakUtilizationBlocks.txt
** Name:   Peak Utilization Rates - Yesterday
** Desc:   This query is used to create a table showing the hour block in which the peak utilization from yesterday was achieved.
** Auth:   Zach Mutchler
** Date:   August 10, 2015
**************************
** Change History
**************************
** PR   Date	      Author         Description	
** --   -----------   -------        ------------------------------------
** 1    08/10/2015    Zach Mutchler  Initial development.
*******************************/
SELECT n.market AS 'Market' --custom property
	,n.businessname AS 'Business Name' --custom property
	,n.caption AS 'Device'
	,i.caption AS 'Interface'
	--give our hour dateparts meaning...
	,CASE 
		WHEN x.hour = 0
			THEN '12:00am - 12:59am'
		WHEN x.hour = 1
			THEN '1:00am - 1:59am'
		WHEN x.hour = 2
			THEN '2:00am - 2:59am'
		WHEN x.hour = 3
			THEN '3:00am - 3:59am'
		WHEN x.hour = 4
			THEN '4:00am - 4:59am'
		WHEN x.hour = 5
			THEN '5:00am - 5:59am'
		WHEN x.hour = 6
			THEN '6:00am - 6:59am'
		WHEN x.hour = 7
			THEN '7:00am - 7:59am'
		WHEN x.hour = 8
			THEN '8:00am - 8:59am'
		WHEN x.hour = 9
			THEN '9:00am - 9:59am'
		WHEN x.hour = 10
			THEN '10:00am - 10:59am'
		WHEN x.hour = 11
			THEN '11:00am - 11:59am'
		WHEN x.hour = 12
			THEN '12:00pm - 12:59pm'
		WHEN x.hour = 13
			THEN '1:00pm - 1:59pm'
		WHEN x.hour = 14
			THEN '2:00pm - 2:59pm'
		WHEN x.hour = 15
			THEN '3:00pm - 3:59pm'
		WHEN x.hour = 16
			THEN '4:00pm - 4:59pm'
		WHEN x.hour = 17
			THEN '5:00pm - 5:59pm'
		WHEN x.hour = 18
			THEN '6:00pm - 6:59pm'
		WHEN x.hour = 19
			THEN '7:00pm - 7:59pm'
		WHEN x.hour = 20
			THEN '8:00pm - 8:59pm'
		WHEN x.hour = 21
			THEN '9:00pm - 9:59pm'
		WHEN x.hour = 22
			THEN '10:00pm - 10:59pm'
		WHEN x.hour = 23
			THEN '11:00pm - 11:59pm'
		END AS 'Hour Block'
	--calculate the % utilization based on max BPS and bandwidth (outbandwidth = XMT, inbandwidth = RCV)
	,cast(cast((x.peak / i.outbandwidth) * 100 AS DECIMAL(9, 2)) AS NVARCHAR(10)) + '%' AS 'Peak Transmit Utilization'
FROM interfaces i
JOIN nodes n ON n.nodeid = i.nodeid
JOIN
	--this is a derived table that breaks out our utilization metrics into the hour datepart and ranks them per interfaceid
	(
	SELECT interfaceid
		,datepart(hour, DATETIME) AS 'hour'
		--this is for XMT (RCV would be in_maxbps)
		,max(out_maxbps) AS 'peak'
		--rank out results per interfaceid by the out_maxbps value, descending (or in_maxbps for the RCV side)
		,rank() OVER (
			PARTITION BY interfaceid ORDER BY max(out_maxbps) DESC
			) AS 'ranking'
	FROM interfacetraffic
	--this subquery limits our results to interesting interfaces
	WHERE interfaceid IN (
			SELECT i.interfaceid
			FROM interfaces i
			JOIN nodes n ON n.nodeid = i.nodeid
			--This is where you add your limitations to the selected interfaces
			WHERE i.interfaceusage = 'mpls' --custom property 
				AND n.corpdivision = 'cmg' --custom property
				AND n.caption NOT LIKE '%csr%'
			)
		-- limit our results to the last 1 day
		AND DATETIME > (getdate() - 1)
	GROUP BY interfaceid
		,datepart(hour, DATETIME)
	) x ON x.interfaceid = i.interfaceid
--return the top ranked (peak) per interfaceid
WHERE x.ranking = 1
GROUP BY n.market
	,n.businessname
	,n.caption
	,i.caption
	,x.hour
	,x.peak
	,i.outbandwidth
--ignore all interfaces with 0% peak utilization
HAVING cast((x.peak / i.outbandwidth) * 100 AS DECIMAL(9, 2)) > 0
ORDER BY n.market
	,n.caption
	,i.caption
