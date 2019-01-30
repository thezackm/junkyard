/******************************
** File:   DependencyMembers.txt
** Name:   Dependency Members
** Desc:   This query is used to create a table showing all mapped dependency parent and child objects (with members for groups).
** Auth:   Zach Mutchler
** Date:   October 22, 2015
**************************
** Change History
**************************
** PR   Date	      Author         Description	
** --   -----------   -------        ------------------------------------
** 1    10/22/2015    Zach Mutchler  Initial development.
*******************************/

select distinct
	d.name 'Dependency Name'
	,x.parentType 'Parent Object Type'
	,x.parentGroup 'Parent Group'
	,x.parentMember 'Parent Member'
	,x.childType 'Child Object Type'
	,x.childGroup 'Child Group'
	,x.ChildMember 'Child Member'
from dependencies d
join
	(
		select
			d.dependencyid
			,'Group' parentType
			,p.groupname parentGroup
			,p.groupmembername parentMember
			,'Group' childType
			,c.groupname childGroup
			,c.groupmembername childMember
		from dependencies d
		full outer join containers_alertsandreportsdata p on d.parentnetobjectid = p.groupid
		full outer join containers_alertsandreportsdata c on d.childnetobjectid = c.groupid
		where d.parententitytype = 'Orion.Groups' or d.childentitytype = 'Orion.Groups'

		union all 

		select
			d.dependencyid
			,'Node' parentType
			,'--N/A--' parentGroup
			,p.caption parentMember
			,'Node' childType
			,'--N/A--' childGroup
			,c.caption childMember
		from dependencies d
		full outer join nodes p on d.parentnetobjectid = p.nodeid
		full outer join nodes c on d.childnetobjectid = c.nodeid
		where d.parententitytype = 'Orion.Nodes' or d.childentitytype = 'Orion.Nodes'

		union all 

		select
			d.dependencyid
			,'Application' parentType
			,'--N/A--' parentGroup
			,p.name parentMember
			,'Application' childType
			,'--N/A--' childGroup
			,c.name childMember
		from dependencies d
		full outer join apm_application p on d.parentnetobjectid = p.id
		full outer join apm_application c on d.childnetobjectid = c.id
		where d.parententitytype like 'Orion.APM.%' or d.childentitytype = 'Orion.APM.%'

		union all 

		select
			d.dependencyid
			,'Interface' parentType
			,'--N/A--' parentGroup
			,p.caption parentMember
			,'Interface' childType
			,'--N/A--' childGroup
			,c.caption childMember
		from dependencies d
		full outer join interfaces p on d.parentnetobjectid = p.interfaceid
		full outer join interfaces c on d.childnetobjectid = c.interfaceid
		where d.parententitytype = 'Orion.NPM.Interfaces' or d.childentitytype = 'Orion.NPM.Interfaces'

		union all 

		select
			d.dependencyid
			,'WPM Agent' parentType
			,'--N/A--' parentGroup
			,p.name parentMember
			,'WPM Agent' childType
			,'--N/A--' childGroup
			,c.name childMember
		from dependencies d
		full outer join seum_agents p on d.parentnetobjectid = p.agentid
		full outer join seum_agents c on d.childnetobjectid = c.agentid
		where d.parententitytype = 'Orion.SEUM.Agents' or d.childentitytype = 'Orion.SEUM.Agents'

		union all 

		select
			d.dependencyid
			,'WPM Transaction' parentType
			,'--N/A--' parentGroup
			,p.name parentMember
			,'WPM Transaction' childType
			,'--N/A--' childGroup
			,c.name childMember
		from dependencies d
		full outer join seum_transactions p on d.parentnetobjectid = p.transactionid
		full outer join seum_transactions c on d.childnetobjectid = c.transactionid
		where d.parententitytype = 'Orion.SEUM.Transactions' or d.childentitytype = 'Orion.SEUM.Transactions'

		union all 

		select
			d.dependencyid
			,'WPM Step' parentType
			,'--N/A--' parentGroup
			,p.name parentMember
			,'WPM Step' childType
			,'--N/A--' childGroup
			,c.name childMember
		from dependencies d
		full outer join seum_transactionstepsalertsdata p on d.parentnetobjectid = p.transactionstepid
		full outer join seum_transactionstepsalertsdata c on d.childnetobjectid = c.transactionstepid
		where d.parententitytype = 'Orion.SEUM.TransactionSteps' or d.childentitytype = 'Orion.SEUM.TransactionSteps'
	) x on x.dependencyid = d.dependencyid