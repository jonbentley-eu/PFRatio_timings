/*
===============================================================================
Title:		PFratio_datediff.sql
Author:		JBentley
Date:		2024-07-16
-------------------------------------------------------------------------------
Specification: 
Extract a list of intubated patients with a P/F ratio on an ABG under 23.3kPa 
on 2 separate occasions, at least 6 hours apart.
				
-------------------------------------------------------------------------------
Revision History: 
Author		Date		Change
------------------------------------------------
JBentley	2024-07-16	Initial Version				
===============================================================================
*/


SELECT 
	a.encounterId, 
	patientLifetimeNumber, 
	utcChartTime, 
	interventionShortLabel, 
	CONVERT(DECIMAL(10,2),valueNumber) AS Ratio,
	DATEDIFF(minute, LAG(utcChartTime) OVER (PARTITION BY [patientLifetimeNumber] ORDER BY utcChartTime), utcChartTime) AS diff_in_minutes
FROM
	DAR.PatientAssessment AS a
	JOIN DAR.D_Encounter AS e
		a.encounterId = e.encounterId
WHERE
	a.utcChartTime >'2024/01/01' 
	AND a.utcChartTime < '2024/03/31'
	AND a.clinicalUnitId IN ('53', '54')
	AND a.attributePropName = ('PO2FIO2_RatioMsmnt')
	AND a.valueNumber < '23.2'
	AND LAG(utcChartTime) OVER (ORDER BY utcChartTime) > '360'
ORDER BY a.encounterId, utcChartTime
