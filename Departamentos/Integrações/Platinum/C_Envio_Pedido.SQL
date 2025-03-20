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

FROM 
 	"ORDR" t0 
	 INNER JOIN "RDR12" t12 ON t0."DocEntry" = t12."DocEntry"
	 INNER JOIN "RDR1" t00 ON t0."DocEntry" = t00."DocEntry"
	 LEFT JOIN "CRD7" t13 ON t12."Carrier" = t13."CardCode" and t13."Address" = ''
     INNER JOIN "OSLP" as t14 ON t14."SlpCode" = t0."SlpCode" AND t14."U_OKS_Operation" = '1'
     INNER JOIN "OWHS" as t15 ON t15."WhsCode" = t00."WhsCode"
WHERE
	t0."Confirmed" = 'Y'
	AND t0."DocStatus" <> 'C'
    AND IFNULL(t0."U_OKS_PL_PedEnv",'N') = 'N' 
	AND t0."BPLId" = '7'
  AND (IFNULL(t0."U_OKS_PrCodeNrPed",'') <> '' or IFNULL(t0."U_OKS_CoreNrPed",'') <> ''
  or IFNULL(t0."U_NrPed",'') <> '')
  AND t15."WhsCode" IN ('MG-GERAL')
  AND (T00."Usage" = '' OR '' = '')