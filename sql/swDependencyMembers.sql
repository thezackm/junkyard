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
SELECT DISTINCT d.name 'Dependency Name'
	,x.parentType 'Parent Object Type'
	,x.parentGroup 'Parent Group'
	,x.parentMember 'Parent Member'
	,x.childType 'Child Object Type'
	,x.childGroup 'Child Group'
	,x.ChildMember 'Child Member'
FROM dependencies d
JOIN (
	SELECT d.dependencyid
		,'Group' parentType
		,p.groupname parentGroup
		,p.groupmembername parentMember
		,'Group' childType
		,c.groupname childGroup
		,c.groupmembername childMember
	FROM dependencies d
	FULL OUTER JOIN containers_alertsandreportsdata p ON d.parentnetobjectid = p.groupid
	FULL OUTER JOIN containers_alertsandreportsdata c ON d.childnetobjectid = c.groupid
	WHERE d.parententitytype = 'Orion.Groups'
		OR d.childentitytype = 'Orion.Groups'
	
	UNION ALL
	
	SELECT d.dependencyid
		,'Node' parentType
		,'--N/A--' parentGroup
		,p.caption parentMember
		,'Node' childType
		,'--N/A--' childGroup
		,c.caption childMember
	FROM dependencies d
	FULL OUTER JOIN nodes p ON d.parentnetobjectid = p.nodeid
	FULL OUTER JOIN nodes c ON d.childnetobjectid = c.nodeid
	WHERE d.parententitytype = 'Orion.Nodes'
		OR d.childentitytype = 'Orion.Nodes'
	
	UNION ALL
	
	SELECT d.dependencyid
		,'Application' parentType
		,'--N/A--' parentGroup
		,p.name parentMember
		,'Application' childType
		,'--N/A--' childGroup
		,c.name childMember
	FROM dependencies d
	FULL OUTER JOIN apm_application p ON d.parentnetobjectid = p.id
	FULL OUTER JOIN apm_application c ON d.childnetobjectid = c.id
	WHERE d.parententitytype LIKE 'Orion.APM.%'
		OR d.childentitytype = 'Orion.APM.%'
	
	UNION ALL
	
	SELECT d.dependencyid
		,'Interface' parentType
		,'--N/A--' parentGroup
		,p.caption parentMember
		,'Interface' childType
		,'--N/A--' childGroup
		,c.caption childMember
	FROM dependencies d
	FULL OUTER JOIN interfaces p ON d.parentnetobjectid = p.interfaceid
	FULL OUTER JOIN interfaces c ON d.childnetobjectid = c.interfaceid
	WHERE d.parententitytype = 'Orion.NPM.Interfaces'
		OR d.childentitytype = 'Orion.NPM.Interfaces'
	
	UNION ALL
	
	SELECT d.dependencyid
		,'WPM Agent' parentType
		,'--N/A--' parentGroup
		,p.name parentMember
		,'WPM Agent' childType
		,'--N/A--' childGroup
		,c.name childMember
	FROM dependencies d
	FULL OUTER JOIN seum_agents p ON d.parentnetobjectid = p.agentid
	FULL OUTER JOIN seum_agents c ON d.childnetobjectid = c.agentid
	WHERE d.parententitytype = 'Orion.SEUM.Agents'
		OR d.childentitytype = 'Orion.SEUM.Agents'
	
	UNION ALL
	
	SELECT d.dependencyid
		,'WPM Transaction' parentType
		,'--N/A--' parentGroup
		,p.name parentMember
		,'WPM Transaction' childType
		,'--N/A--' childGroup
		,c.name childMember
	FROM dependencies d
	FULL OUTER JOIN seum_transactions p ON d.parentnetobjectid = p.transactionid
	FULL OUTER JOIN seum_transactions c ON d.childnetobjectid = c.transactionid
	WHERE d.parententitytype = 'Orion.SEUM.Transactions'
		OR d.childentitytype = 'Orion.SEUM.Transactions'
	
	UNION ALL
	
	SELECT d.dependencyid
		,'WPM Step' parentType
		,'--N/A--' parentGroup
		,p.name parentMember
		,'WPM Step' childType
		,'--N/A--' childGroup
		,c.name childMember
	FROM dependencies d
	FULL OUTER JOIN seum_transactionstepsalertsdata p ON d.parentnetobjectid = p.transactionstepid
	FULL OUTER JOIN seum_transactionstepsalertsdata c ON d.childnetobjectid = c.transactionstepid
	WHERE d.parententitytype = 'Orion.SEUM.TransactionSteps'
		OR d.childentitytype = 'Orion.SEUM.TransactionSteps'
	) x ON x.dependencyid = d.dependencyid
