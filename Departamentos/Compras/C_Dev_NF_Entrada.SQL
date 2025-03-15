SELECT 
    T0."DocNum" AS "nº Documento",
    CAST(T0."DocDate" AS DATE) AS "Data do Documento",
    TO_NVARCHAR(T0."DocDate", 'YYYY-MM') AS "Mes",
    T0."CardCode" AS "Cód. do Cliente",
    MAX(T0."CardName") AS "Nome do Cliente",
    MAX(T12."StateS") AS "Estado Cliente",
    T1."ItemCode" AS "Cód. do Item",
    MAX(T1."Dscription") AS "Descrição",
    MAX(T9."FirmName") AS "Fabricante",
    MAX(T5."ItmsGrpNam") AS "Grupo de Itens",
    SUM(T1."Quantity") AS "Quantidade",
    SUM(T1."LineTotal") AS "Total Linha",
    AVG(T1."PriceBefDi") AS "Unitário",
    AVG(T7."Price") AS "Custo Manual",
    MAX(T2."SlpName") AS "Vendedor/Comprador",
    MAX(T2."U_Loja") AS "Origem",
    CASE WHEN MAX(T0."DocStatus") = 'C' THEN 'Fechado' ELSE 'Aberto' END AS "Status",
    MAX(T13."SeqName") AS "Sequencia Fiscal",
    MAX(Z4."Usage") AS "Utilização",
    CASE WHEN MAX(T1."FreeChrgBP") = 'Y' THEN 'Sim' 
         WHEN MAX(T1."FreeChrgBP") = 'N' THEN 'Não' 
         ELSE MAX(T1."FreeChrgBP") END AS "Gratuito",
    T1."WhsCode" AS "Deposito", 
    CASE 
        WHEN T1."BaseType" = -1 THEN 'Sem Referência'
        WHEN T1."BaseType" = 0 THEN 'Entrada Manual'
        WHEN T1."BaseType" = 18 THEN 'Fatura de Fornecedor'
        ELSE CAST (T1."BaseType" AS VARCHAR(50))
    END AS "Tipo de Documento Base",
    T1."BaseEntry" AS "Documento Base",
    MAX(T0."Serial") AS "Numero NF",
    MAX(Z5."Segment_0") AS "Conta Controle",
    MAX(Z5."AcctName") AS "Nome Conta Controle",
    T0."BPLId" AS "Filial do documento",
    MAX(T0."JrnlMemo") AS "Observação do diário",
    MAX(Z6."U_NAME") AS "Usuario",
 CASE 
    WHEN T10."QryGroup1" = 'Y' THEN 'Fornecedor'
    ELSE 'Outros' 
END AS "Fornecedor"
FROM "ORPC" T0 
LEFT JOIN "RPC1" T1 ON T0."DocEntry" = T1."DocEntry" 
LEFT JOIN "OSLP" T2 ON T0."SlpCode" = T2."SlpCode" 
LEFT JOIN "OITM" T4 ON T1."ItemCode" = T4."ItemCode" 
LEFT JOIN "OITB" T5 ON T4."ItmsGrpCod" = T5."ItmsGrpCod" 
LEFT JOIN "OCTG" T6 ON T0."GroupNum" = T6."GroupNum" 
LEFT JOIN "ITM1" T7 ON T4."ItemCode" = T7."ItemCode" 
LEFT JOIN "OPLN" T8 ON T7."PriceList" = T8."ListNum" 
LEFT JOIN "OMRC" T9 ON T4."FirmCode" = T9."FirmCode" 
LEFT JOIN "OCRD" T10 ON T0."CardCode" = T10."CardCode" 
LEFT JOIN "RPC12" T12 ON T0."DocEntry" = T12."DocEntry" 
LEFT JOIN "NFN1" T13 ON T13."SeqCode" = T0."SeqCode" 
LEFT JOIN "CRD7" Z1 ON T10."CardCode" = Z1."CardCode"
LEFT JOIN "OUSG" Z4 ON T1."Usage" = Z4."ID"
LEFT JOIN "OACT" Z5 ON T0."CtlAccount" = Z5."AcctCode"
LEFT JOIN "OUSR" Z6 ON T0."UserSign" = Z6."USERID"
WHERE T8."ListNum" = '5' 
AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocNum", 
    T0."DocDate", 
    T0."CardCode", 
    T1."ItemCode", 
    T1."WhsCode", 
    T1."BaseType", 
    T1."BaseEntry", 
    T0."BPLId", T10."QryGroup1"