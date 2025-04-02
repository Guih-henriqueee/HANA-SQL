CREATE OR REPLACE VIEW SBO_INPOWER_PROD."VisaoRebates" AS((
SELECT T0."DocEntry" as "Documento",
--T0."Serial" as "NF",
--'NFS',
T0."DocNum" as "Primário", 
T0."CustOffice" as "Setor Responsável",
CASE when T0."DocStatus" = 'O' Then  'Aberto'
        Else   'Fechado' end as "Status ND",
T0."CardCode" as "PN", 
T0."CardName" AS "Fornecedor", 
T0."ShipPlace" as "Origem ND",
T0."DocTotal" + T0."DpmAmnt" as "Total NF" ,
--IFNULL(( SELECT SUM(S."LineTotal") FROM INV1 S WHERE S."DocEntry" = T0."DocEntry" AND S."ItemCode" = 'I000075'),0) as "Impostos",
--IFNULL(( SELECT SUM(S."LineTotal") FROM INV1 S WHERE S."DocEntry" = T0."DocEntry" AND S."ItemCode" = 'I000076'),0) as "Comissão",
--IFNULL(( SELECT SUM(S."LineTotal") FROM INV1 S WHERE S."DocEntry" = T0."DocEntry" AND S."ItemCode" = 'I000074'),0) as "Rebate Líquido",
--T1."SlpName" as "Pessoa Responsável",
TO_NVARCHAR(T0."DocDate", 'YYYY-MM') AS "Dt_Mes",
CAST (T0."DocDate" AS DATE)as "Dt_Lançamento",
CAST (T0."TaxDate" AS DATE)as "Dt_Documento",
CAST (T0."DocDueDate"AS DATE) as "Dt_Vencimento", 
CASE WHEN  T0."DocStatus" = 'C' THEN 'PAGO' WHEN T0."DocDueDate" <= CURRENT_DATE THEN 'VENCIDO' ELSE 'NO PRAZO' END AS "STATUS COBRANCA",
CASE WHEN D3."ReconDate" IS NULL THEN 
	CASE WHEN PG."CreateDate" <= '20241231' THEN  PG."DocDate"
	ELSE NULL END
ELSE D3."ReconDate" END as "Dt_Crédito",
T0."PaidSum" as "Recebimento",
T0."DocTotal" + T0."DpmAmnt" - T0."PaidSum" as "Saldo",
T10."PymntGroup" as "Negociação Comercial",
T0."U_SKILL_NR_MEMO" as "ND Comercial",
--T0."SlpCode", 
--T4."Usage",
--T5."NfmName",
--T11."BPLName",
T0."Comments",
T15."Notes" as "Cobrança Rebate"
FROM SBO_INPOWER_PROD.OINV T0  
LEFT JOIN SBO_INPOWER_PROD.ORCT PG ON T0."ReceiptNum" = PG."DocEntry" 
INNER JOIN SBO_INPOWER_PROD.OSLP T1 ON T0."SlpCode" = T1."SlpCode" 
INNER JOIN SBO_INPOWER_PROD.OCRD T15 ON T0."CardCode" = T15."CardCode"
INNER JOIN SBO_INPOWER_PROD.OCTG T10 ON T0."GroupNum" = T10."GroupNum"
INNER JOIN SBO_INPOWER_PROD.INV12 T3 ON T0."DocEntry" = T3."DocEntry"
INNER JOIN SBO_INPOWER_PROD.OBPL T11 ON T0."BPLId" = T11."BPLId"
INNER JOIN SBO_INPOWER_PROD.OUSG T4 ON T3."MainUsage" = T4."ID"
INNER JOIN SBO_INPOWER_PROD.ONFM T5 ON T0."Model" = T5."AbsEntry"
LEFT JOIN  SBO_INPOWER_PROD.ITR1 D2 ON T0."TransId" = D2."TransId"
LEFT JOIN  SBO_INPOWER_PROD.OITR D3 ON D2."ReconNum" = D3."ReconNum"
LEFT JOIN SBO_INPOWER_PROD."@SKL25NFE" T6 ON T0."DocEntry" = T6."U_DocEntry"
WHERE T0."DocDueDate" between '2000-01-01' and '2030-12-31' and
T0."CANCELED" = 'N' and (T4."ID" in (72,73,74,75))) UNION (SELECT Distinct
T0."DocEntry" as "Documento",
--T0."Serial" as "NF",
--'NFS',
T0."DocNum" as "Primário", 
'BONIFICAÇÃO' as "Setor Responsável",
CASE when T0."DocStatus" = 'O' Then  'Aberto'
        Else   'Fechado' end as "Status ND",
T0."CardCode" as "PN", 
T0."CardName" AS "Fornecedor", 
'BONIFICAÇÃO' as "Origem ND",
T0."NfeValue" as "Total NF" ,
--IFNULL(( SELECT SUM(S."LineTotal") FROM INV1 S WHERE S."DocEntry" = T0."DocEntry" AND S."ItemCode" = 'I000075'),0) as "Impostos",
--IFNULL(( SELECT SUM(S."LineTotal") FROM INV1 S WHERE S."DocEntry" = T0."DocEntry" AND S."ItemCode" = 'I000076'),0) as "Comissão",
--IFNULL(( SELECT SUM(S."LineTotal") FROM INV1 S WHERE S."DocEntry" = T0."DocEntry" AND S."ItemCode" = 'I000074'),0) as "Rebate Líquido",
--T1."SlpName" as "Pessoa Responsável",
TO_NVARCHAR(T0."DocDate", 'YYYY-MM') AS "Dt_Mes",
CAST (T0."DocDate" AS DATE)as "Dt_Lançamento",
CAST (T0."TaxDate" AS DATE)as "Dt_Documento",
CAST (T0."DocDueDate"AS DATE) as "Dt_Vencimento", 
'PAGO',
CAST (T0."DocDate" AS DATE)as "Dt_Crédito",
T0."NfeValue" as "Recebimento",
T0."DocTotal" + T0."DpmAmnt" - T0."PaidSum" as "Saldo",
'BONIFICAÇÃO' as "Negociação Comercial",
'BONIFICAÇÃO' as "ND Comercial",
--T0."SlpCode", 
--T4."Usage",
--T5."NfmName",
--T11."BPLName",
T0."Comments",
'' as "Cobrança Rebate"
FROM SBO_INPOWER_PROD.OPCH T0 
INNER JOIN SBO_INPOWER_PROD.PCH12 T3 ON T0."DocEntry" = T3."DocEntry" 
WHERE T0."DocDueDate" between '2000-01-01' and '2030-12-31' 
AND T0."CANCELED" = 'N' 
AND T3."MainUsage" = 55))