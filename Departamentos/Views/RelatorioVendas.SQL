-- SBO_INPOWER_PROD."VisaoRelatorioVendas" source

CREATE OR REPLACE VIEW SBO_INPOWER_PROD."VisaoRelatorioVendas" AS
SELECT
    COUNT(*) AS "Total de Documentos",
    CAST(T0."DocDate" AS DATE) AS "Data do Documento",
    TO_NVARCHAR(T0."DocDate", 'YYYY-MM') AS "Mês",
    T1."ItemCode" AS "Código do Item",
    T1."Dscription" AS "Descrição do Item",
    T9."FirmName" AS "Fabricante",
    T5."ItmsGrpNam" AS "Grupo de Itens",
    T0."U_OKS_TipoAnuncio" AS "Tipo de Anúncio",
    T0."U_OKS_PrCodeFull" AS "Código de Fullfilment",
    SUM(T1."Quantity") AS "Quantidade Total",
    SUM(T1."LineTotal") AS "Valor Total",
    AVG(T1."PriceBefDi") AS "Preço Médio Antes do Desconto",
    (SUM(T1."Quantity") * T7."Price") AS "Custo Total",
    AVG(T1."PriceBefDi") / CASE 
        WHEN T7."Price" > 0 THEN T7."Price" 
        ELSE 1.0 
    END AS "Markup",
    T2."SlpName" AS "Nome do Vendedor",
    T0."U_OKS_Mlb" AS "Código MLB",
    T2."U_Loja" AS "Loja",
    CASE 
        WHEN T0."DocStatus" = 'C' THEN 'Fechado' 
        ELSE 'Aberto' 
    END AS "Status do Documento",
    T13."SeqName" AS "Nome da Sequência",
    T1."WhsCode" AS "Depósito",
    NULL AS "Comprador"

FROM SBO_INPOWER_PROD."OINV" T0 
INNER JOIN SBO_INPOWER_PROD."INV1" T1 ON T0."DocEntry" = T1."DocEntry" 
INNER JOIN SBO_INPOWER_PROD."OSLP" T2 ON T0."SlpCode" = T2."SlpCode" 
INNER JOIN SBO_INPOWER_PROD."OITM" T4 ON T1."ItemCode" = T4."ItemCode" 
INNER JOIN SBO_INPOWER_PROD."OITB" T5 ON T4."ItmsGrpCod" = T5."ItmsGrpCod" 
INNER JOIN SBO_INPOWER_PROD."OCTG" T6 ON T0."GroupNum" = T6."GroupNum" 
INNER JOIN SBO_INPOWER_PROD."ITM1" T7 ON T4."ItemCode" = T7."ItemCode" AND T7."PriceList" = 5
INNER JOIN SBO_INPOWER_PROD."OPLN" T8 ON T7."PriceList" = T8."ListNum" 
INNER JOIN SBO_INPOWER_PROD."OMRC" T9 ON T4."FirmCode" = T9."FirmCode" 
INNER JOIN SBO_INPOWER_PROD."OCRD" T10 ON T0."CardCode" = T10."CardCode" 
INNER JOIN SBO_INPOWER_PROD."INV12" T12 ON T0."DocEntry" = T12."DocEntry" 
LEFT JOIN SBO_INPOWER_PROD."NFN1" T13 ON T13."SeqCode" = T0."SeqCode" 
WHERE T0."DocDate" BETWEEN ADD_MONTHS(CURRENT_DATE, -26) AND CURRENT_DATE
AND T1."FreeChrgBP" = 'N'
AND T0."U_NumPedCan" IS NULL 
AND T8."ListNum" = '5' 
AND T0."CANCELED" = 'N'
GROUP BY 
    T0."DocDate",
    TO_NVARCHAR(T0."DocDate", 'YYYY-MM'),
    T1."ItemCode",
    T1."Dscription",
    T9."FirmName",
    T5."ItmsGrpNam",
    T7."Price",
    T0."U_OKS_TipoAnuncio",
    T0."U_OKS_PrCodeFull",
    T2."SlpName",
    T0."U_OKS_Mlb",
    T2."U_Loja",
    T1."U_INP_CUSTOMANUAL",
    CASE 
        WHEN T0."DocStatus" = 'C' THEN 'Fechado' 
        ELSE 'Aberto' 
    END,
    T13."SeqName",
    T1."WhsCode"
    
    
    ----- ATUALIZAÇÃO 19-03-2025
    ----- Reversão informação de Preço de Custo 
    ----- Guilherme Martins
    
    ;