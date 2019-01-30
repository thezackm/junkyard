/******************************
** File:   _NodeBaselines.txt
** Name:   Node Baseline Calculations
** Desc:   This report shows the recorded baselines that have been calculated by NPM for Nodes.
		   You can comment out any section/columns that are not desired in your end result.
** Auth:   Zach Mutchler
** Date:   May 20th, 2015
**************************
** Change History
**************************
** PR   Date	      Author         Description	
** --   -----------   -------        ------------------------------------
** 1    05/20/2015    Zach Mutchler  Initial development.
*******************************/
SELECT n.caption AS 'Device'
	,c.TIMESTAMP AS 'CPU/Memory Baseline Date'
	--CPU Baselines
	,c.avgloadmin AS 'Min CPU'
	,c.avgloadmax AS 'Max CPU'
	,c.avgloadmean AS 'Mean CPU'
	,c.avgloadstdev AS 'σ CPU'
	,CEILING(((c.avgloadstdev * 2) + c.avgloadmean)) AS 'CPU Warning'
	,CEILING(((c.avgloadstdev * 3) + c.avgloadmean)) AS 'CPU Critical'
	--Memory Baselines
	,c.avgpercentmemoryusedmin AS 'Min Memory'
	,c.avgpercentmemoryusedmax AS 'Max Memory'
	,c.avgpercentmemoryusedmean AS 'Mean Memory'
	,c.avgpercentmemoryusedstdev AS 'σ Memory'
	,CEILING(((c.avgpercentmemoryusedstdev * 2) + c.avgpercentmemoryusedmean)) AS 'Memory Warning'
	,CEILING(((c.avgpercentmemoryusedstdev * 3) + c.avgpercentmemoryusedmean)) AS 'Memory Critical'
	,r.TIMESTAMP AS 'Response Time/Packet Loss Baseline Date'
	--Response Time Baselines
	,r.avgresponsetimemin AS 'Min Response Time'
	,r.avgresponsetimemax AS 'Max Response Time'
	,r.avgresponsetimemean AS 'Mean Response Time'
	,r.avgresponsetimestdev AS 'σ Response Time'
	,CEILING(((r.avgresponsetimestdev * 2) + r.avgresponsetimemean)) AS 'Response Time Warning'
	,CEILING(((r.avgresponsetimestdev * 3) + r.avgresponsetimemean)) AS 'Response Time Critical'
	--Percent Loss Baselines
	,r.percentlossmin AS 'Min % Loss'
	,r.percentlossmax AS 'Max % Loss'
	,r.percentlossmean AS 'Mean % Loss'
	,r.percentlossstdev AS 'σ % Loss'
	,CEILING(((r.percentlossstdev * 2) + r.percentlossmean)) AS '% Loss Warning'
	,CEILING(((r.percentlossstdev * 3) + r.percentlossmean)) AS '% Loss Critical'
FROM cpuload_statistics c
JOIN nodes n ON n.nodeid = c.nodeid
JOIN responsetime_statistics r ON r.nodeid = n.nodeid
--Overall Averages = '1'
--Business Hours (8am - 6pm M-F) = '2'
--After Hours (6pm - 8am M-F and all day Sa-Su) = '3'
WHERE c.timeframeid = '2'
	AND r.timeframeid = '2'
ORDER BY n.caption
