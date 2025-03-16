SELECT DISTINCT
	'N'           		                as "*"
   ,t0."DocNum"  		                as "Nº Documento"
   ,t0."DocEntry"  		                as "Nº Documento SAP"
   ,t0."DocDate"     	                as "Data pedido"
   ,t0."CardCode"  		                as "Cliente"
   ,t0."CardName"  		                as "Nome do Cliente"
   ,t14."SlpName"                       as "Vendedor"
   ,t00."ItemCode"                      as "Cód. Item"
   ,t00."Quantity"                      as "Quantidade"
   ,t0."ObjType"                        as "TipoObjeto"
 ,(
SELECT
       IFNULL(T0."OnHand",0) AS "Disponivel"  
FROM
	 "OITW" AS T0
INNER JOIN "OITM" AS T1 on T0."ItemCode" = T1."ItemCode"
INNER JOIN "OWHS" AS T2 on T2."WhsCode" = T0."WhsCode"
WHERE
       T0."ItemCode" = T00."ItemCode"
       AND T2."Inactive" = 'N'
       AND IFNULL(T2."DropShip",'N') <> 'Y'
       AND T0."WhsCode"='LJ01RET' 
 
 
 ) AS "Estoque Local",(
SELECT
      
      
       IFNULL(T0."OnHand"+T0."OnOrder"-T0."IsCommited",0) AS "Disponivel"  
FROM
	 "OITW" AS T0
INNER JOIN "OITM" AS T1 on T0."ItemCode" = T1."ItemCode"
INNER JOIN "OWHS" AS T2 on T2."WhsCode" = T0."WhsCode"
WHERE
       T0."ItemCode" = T00."ItemCode"
       AND T2."Inactive" = 'N'
       AND IFNULL(T2."DropShip",'N') <> 'Y'
       AND T0."WhsCode"='LJ01-CON' 
 
 
 ) AS "Estoque Terceiro"
  ,T24."Code" as "CodeConexao"
FROM 
 	"ORDR" t0 
	 INNER JOIN "RDR12" t12 ON t0."DocEntry" = t12."DocEntry"
	 INNER JOIN "RDR1" t00 ON t0."DocEntry" = t00."DocEntry"
	 LEFT JOIN "CRD7" t13 ON t12."Carrier" = t13."CardCode" and t13."Address" = ''
     INNER JOIN "OSLP" as t14 ON t14."SlpCode" = t0."SlpCode" --AND t14."U_OKS_Operation" = '1'
     INNER JOIN "OWHS" as t15 ON t15."WhsCode" = t00."WhsCode"
LEFT JOIN "@OKS_PRCODE_PGTO" T20 ON T20."U_OrderID" = T0."NumAtCard"
LEFT JOIN "@OKS_CORE_PGTO" T21 ON T0."NumAtCard" = T21."U_Order"
LEFT JOIN "@OKS_INTMKP_PGTO" T22 ON T0."NumAtCard" = T22."U_OrderID"
LEFT JOIN "@OKS_B4_CONFFILIAL" T23 ON T23."U_Filial" = '5'
LEFT JOIN "@OKS_B4_CONFGERAL" T24 ON T24."Code" = T23."U_CodeConexao"
WHERE
	t0."Confirmed" = 'Y'
	AND t0."DocStatus" <> 'C'
    AND IFNULL(t0."U_OKS_B4_PedEnv",'N') = 'N' 
	AND t0."BPLId" = '5'
--  AND (IFNULL(t0."U_OKS_PrCodeNrPed",'') <> '' or IFNULL(t0."U_OKS_CoreNrPed",'') <> ''
--  or IFNULL(t0."U_NrPed",'') <> '')
--  AND t15."WhsCode" IN ('LJ01-CON','LJ01-BFA')
  AND COALESCE(t15."U_OKS_RelevanteB4",'N') = 'Y'
  
 --para testes - voltar em PRD
 -- AND (IFNULL(T20."Code",'') <> '' or IFNULL(T21."Code",'') <> ''
 -- or IFNULL(T22."Code",'') <> '')
  