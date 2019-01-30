--EASTERN = (CAST(DateTime as TIME) BETWEEN '06:00' and '18:00')
--CENTRAL = (CAST(DateTime as TIME) BETWEEN '07:00' and '19:00')
--MOUNTAIN = (CAST(DateTime as TIME) BETWEEN '08:00' and '20:00')
--PACIFIC = (CAST(DateTime as TIME) BETWEEN '09:00' and '21:00')
--ALASKA = (CAST(DateTime as TIME) BETWEEN '10:00' and '22:00')
--HAWAII = (CAST(DateTime as TIME) BETWEEN '12:00' and '23:59')

--Last Week (not last 7 days)
declare @lastsunday datetime
set @lastsunday = dateadd(wk, datediff(wk, 0, getdate()) - 1, 0)
declare @lastsaturday datetime
set @lastsaturday = dateadd(wk, datediff(wk, 0, getdate()) -1, 7)

select
	x.device
	,x.interface
	,x.jobsite
	,x.usercount
	,x.avgrcv
	,x.avgxmt
	,x.totalavg
	,case when x.usercount = '0' then '0'
		else cast((x.TotalAvg/x.UserCount) as decimal (9,2))
	end as perUser
from
(select
    n.caption as 'Device',
    i.caption as 'Interface',
	n.jobsite,
	n.usercount,
    case
        when i.inbandwidth = 0 then 0
        else cast((tr.avg_in/i.inbandwidth)*100 as decimal(9,2))
    end as 'AvgRCV',
    case
        when i.outbandwidth = 0 then 0
        else cast((tr.avg_out/i.outbandwidth)*100 as decimal(9,2))
    end as 'AvgXMT',
	((tr.avg_in + tr.avg_out)/(i.inbandwidth + i.outbandwidth))*100 as 'TotalAvg'
from interfaces i
join nodes n on n.nodeid=i.nodeid
join    
(
select 
    interfaceid,
    avg(in_averagebps) as avg_in,
    avg(out_averagebps) as avg_out
from interfacetraffic_detail
where (in_averagebps is not null and out_averagebps is not null)
and
(
    (datetime >= @lastsunday and datetime < @lastsaturday) --last week
     and  
    (
        (datepart(weekday, datetime) <> 1) and -- 1 represents sunday
        (datepart(weekday, datetime) <> 7) and -- 7 represents saturday
         --This is your time zone offset from EST
        (CAST(DateTime as TIME) BETWEEN '06:00' and '18:00') 
    )
)
group by interfaceid) as tr on tr.interfaceid=i.interfaceid
where i.outsideinterface = 1
and (i.InBandwidth <> '0' and i.OutBandwidth <> '0')
and n.region = 'AMER'
and n.TimeZone = 'EASTERN') x