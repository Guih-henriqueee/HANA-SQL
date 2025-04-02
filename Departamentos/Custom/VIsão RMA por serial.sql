SELECT 
     t0."LogEntry"									AS "Entrada Registro"
    ,t2."DistNumber"        						AS "Número de Série"
    ,t0."ItemCode"          						AS "Número do Item"
    ,t0."ItemName"          						AS "Descrição do Item"
    ,TO_DATE(t2."InDate")   						AS "Data de Admissão"
    ,t0."DocNum"            						AS "Documento"
    --,t0."DocLine"									AS "Linha do Documento"
    ,TO_DATE(t0."DocDate")  						AS "Data"
    ,t0."LocCode"           						AS "Depósito"
    ,t0."CardCode"          						AS "Cta.contáb/cód.PN"
    ,t0."CardName"          						AS "Cta.cont/Nome PN"
    ,t1."AllocQty"          						AS "Atribuído"
	,t3."LastPurPrc"								AS "Preço Unitário"
	,t4."FirmName" 									AS "Fabricante"
	,t5."CardName" 									AS "Fornecedor"
    ,CASE
        WHEN t1."Quantity" =  1 THEN 'Entrada'
        WHEN t1."Quantity" =  0 THEN 'Atribuição'
        WHEN t1."Quantity" = -1 THEN 'Saída'
     END                    						AS "Sentido"
    ,DAYS_BETWEEN(t0."DocDate", CURRENT_DATE) 		AS "Dias Estoque"
    ,CASE 
    	WHEN DAYS_BETWEEN(t0."DocDate", CURRENT_DATE) <= 30  THEN 'até 30 dias'
    	WHEN DAYS_BETWEEN(t0."DocDate", CURRENT_DATE) <= 60  THEN 'até 60 dias'
    	WHEN DAYS_BETWEEN(t0."DocDate", CURRENT_DATE) <= 90  THEN 'até 90 dias'
    	WHEN DAYS_BETWEEN(t0."DocDate", CURRENT_DATE) <= 120 THEN 'até 120 dias'
    	WHEN DAYS_BETWEEN(t0."DocDate", CURRENT_DATE) >  120 THEN '+ 120 dias'
    END												AS "Legenda Dias Estoque"
FROM SBO_INPOWER_PROD.OITL t0
INNER JOIN SBO_INPOWER_PROD.ITL1 t1 ON t0."LogEntry" = t1."LogEntry"
INNER JOIN SBO_INPOWER_PROD.OSRN t2 ON t1."MdAbsEntry"  = t2."AbsEntry"
INNER JOIN SBO_INPOWER_PROD.OITM t3 ON t0."ItemCode" = t3."ItemCode"
INNER JOIN SBO_INPOWER_PROD.OMRC t4 ON t3."FirmCode" = t4."FirmCode"
INNER JOIN SBO_INPOWER_PROD.OPCH t5 ON t0."DocEntry" = t5."DocEntry" 
INNER JOIN (
    SELECT 
        MAX(t0_inner."LogEntry") AS "LogEntry", 
        t2_inner."DistNumber"
    FROM SBO_INPOWER_PROD.OITL t0_inner
    INNER JOIN SBO_INPOWER_PROD.ITL1 t1_inner ON t0_inner."LogEntry" = t1_inner."LogEntry"
    INNER JOIN SBO_INPOWER_PROD.OSRN t2_inner ON t1_inner."MdAbsEntry" = t2_inner."AbsEntry"
    WHERE t0_inner."LocCode" IN ('LJ1-SALD','LJ01RMAF','LJ01SHOP')
      --AND t0_inner."ItemCode" = 'NAC006802' 
    GROUP BY t2_inner."DistNumber"
) max_entries ON t0."LogEntry" = max_entries."LogEntry" AND t2."DistNumber" = max_entries."DistNumber"
WHERE 
    t1."Quantity" = 1
AND t0."ItemCode" = 'NAC006802' 
--AND t2."DistNumber" = '23372400300.19'
--AND t2."DistNumber" = '[C1HB3T2000200'
ORDER BY 
    t2."DistNumber", t0."ItemCode", t0."LogEntry", t0."DocDate" ASC