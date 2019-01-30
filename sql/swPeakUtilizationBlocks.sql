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

select
n.market as 'Market' --custom property
,n.businessname as 'Business Name' --custom property
,n.caption as 'Device'
,i.caption as 'Interface'
--give our hour dateparts meaning...
,case
	when x.hour = 0 then '12:00am - 12:59am'
	when x.hour = 1 then '1:00am - 1:59am'
	when x.hour = 2 then '2:00am - 2:59am'
	when x.hour = 3 then '3:00am - 3:59am'
	when x.hour = 4 then '4:00am - 4:59am'
	when x.hour = 5 then '5:00am - 5:59am'
	when x.hour = 6 then '6:00am - 6:59am'
	when x.hour = 7 then '7:00am - 7:59am'
	when x.hour = 8 then '8:00am - 8:59am'
	when x.hour = 9 then '9:00am - 9:59am'
	when x.hour = 10 then '10:00am - 10:59am'
	when x.hour = 11 then '11:00am - 11:59am'
	when x.hour = 12 then '12:00pm - 12:59pm'
	when x.hour = 13 then '1:00pm - 1:59pm'
	when x.hour = 14 then '2:00pm - 2:59pm'
	when x.hour = 15 then '3:00pm - 3:59pm'
	when x.hour = 16 then '4:00pm - 4:59pm'
	when x.hour = 17 then '5:00pm - 5:59pm'
	when x.hour = 18 then '6:00pm - 6:59pm'
	when x.hour = 19 then '7:00pm - 7:59pm'
	when x.hour = 20 then '8:00pm - 8:59pm'
	when x.hour = 21 then '9:00pm - 9:59pm'
	when x.hour = 22 then '10:00pm - 10:59pm'
	when x.hour = 23 then '11:00pm - 11:59pm'
end as 'Hour Block'
--calculate the % utilization based on max BPS and bandwidth (outbandwidth = XMT, inbandwidth = RCV)
,cast(cast((x.peak/i.outbandwidth)*100 as decimal (9,2)) as nvarchar(10)) + '%' as 'Peak Transmit Utilization'
from interfaces i
join nodes n on n.nodeid = i.nodeid
join
--this is a derived table that breaks out our utilization metrics into the hour datepart and ranks them per interfaceid
	(select 
		interfaceid
		,datepart(hour, datetime) as 'hour'
		--this is for XMT (RCV would be in_maxbps)
		,max(out_maxbps) as 'peak'
		--rank out results per interfaceid by the out_maxbps value, descending (or in_maxbps for the RCV side)
		,rank() over(partition by interfaceid order by max(out_maxbps) desc) as 'ranking'
	from interfacetraffic
	--this subquery limits our results to interesting interfaces
	where interfaceid in 
		(select i.interfaceid 
		from interfaces i 
		join nodes n on n.nodeid = i.nodeid 
		--This is where you add your limitations to the selected interfaces
		where i.interfaceusage = 'mpls' --custom property 
		and n.corpdivision = 'cmg' --custom property
		and n.caption not like '%csr%')
	-- limit our results to the last 1 day
	and datetime > (getdate()-1)
	group by interfaceid, datepart(hour, datetime)
	) x on x.interfaceid = i.interfaceid
--return the top ranked (peak) per interfaceid
where x.ranking = 1
group by n.market, n.businessname, n.caption, i.caption, x.hour, x.peak, i.outbandwidth
--ignore all interfaces with 0% peak utilization
having cast((x.peak/i.outbandwidth)*100 as decimal (9,2)) > 0
order by n.market, n.caption, i.caption