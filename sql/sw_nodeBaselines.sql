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

select
	n.caption as 'Device'
	,c.timestamp as 'CPU/Memory Baseline Date'
	--CPU Baselines
		,c.avgloadmin as 'Min CPU'
		,c.avgloadmax as 'Max CPU'
		,c.avgloadmean as 'Mean CPU'
		,c.avgloadstdev as 'σ CPU' 
		,CEILING(((c.avgloadstdev * 2) + c.avgloadmean)) as 'CPU Warning'
		,CEILING(((c.avgloadstdev * 3) + c.avgloadmean)) as 'CPU Critical'
	--Memory Baselines
		,c.avgpercentmemoryusedmin as 'Min Memory'
		,c.avgpercentmemoryusedmax as 'Max Memory'
		,c.avgpercentmemoryusedmean as 'Mean Memory'
		,c.avgpercentmemoryusedstdev as 'σ Memory'
		,CEILING(((c.avgpercentmemoryusedstdev * 2) + c.avgpercentmemoryusedmean)) as 'Memory Warning'
		,CEILING(((c.avgpercentmemoryusedstdev * 3) + c.avgpercentmemoryusedmean)) as 'Memory Critical'
	,r.timestamp as 'Response Time/Packet Loss Baseline Date'
	--Response Time Baselines
		,r.avgresponsetimemin as 'Min Response Time'
		,r.avgresponsetimemax as 'Max Response Time'
		,r.avgresponsetimemean as 'Mean Response Time'
		,r.avgresponsetimestdev as 'σ Response Time'
		,CEILING(((r.avgresponsetimestdev * 2) + r.avgresponsetimemean)) as 'Response Time Warning'
		,CEILING(((r.avgresponsetimestdev * 3) + r.avgresponsetimemean)) as 'Response Time Critical'
	--Percent Loss Baselines
		,r.percentlossmin as 'Min % Loss'
		,r.percentlossmax as 'Max % Loss'
		,r.percentlossmean as 'Mean % Loss'
		,r.percentlossstdev as 'σ % Loss'
		,CEILING(((r.percentlossstdev * 2) + r.percentlossmean)) as '% Loss Warning'
		,CEILING(((r.percentlossstdev * 3) + r.percentlossmean)) as '% Loss Critical'
from cpuload_statistics c
join nodes n on n.nodeid = c.nodeid
join responsetime_statistics r on r.nodeid = n.nodeid
	--Overall Averages = '1'
	--Business Hours (8am - 6pm M-F) = '2'
	--After Hours (6pm - 8am M-F and all day Sa-Su) = '3'
		where c.timeframeid = '2' and r.timeframeid = '2'
order by n.caption