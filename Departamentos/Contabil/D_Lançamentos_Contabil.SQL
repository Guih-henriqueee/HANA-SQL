SELECT DISTINCT 
    CAST(BASE."RefDate" AS DATE) AS "Data Lançamento", 
    BASE."TransId" || '_' || BASE."Line_ID" AS "Nº da Transação",
    BASE."BatchNum" AS "Pré-Lançamento Contábil",

    CASE 
        WHEN BASE."TransType" = 13 THEN 'NS (A/R Invoice)'
        WHEN BASE."TransType" = 14 THEN 'AT (A/R Credit Memo)'
        WHEN BASE."TransType" = 18 THEN 'NE (A/P Invoice)'
        WHEN BASE."TransType" = 19 THEN 'AT (A/P Credit Memo)'
        WHEN BASE."TransType" = 30 THEN 'LC (Journal Entry)'
        WHEN BASE."TransType" = 24 THEN 'Recebimento de Cliente (Incoming Payment)'
        WHEN BASE."TransType" = 46 THEN 'Pagamento de Fornecedor (Vendor Payment)'
        WHEN BASE."TransType" = 15 THEN 'Entrega (Delivery)'
        WHEN BASE."TransType" = 16 THEN 'Devolução (Returns)'
        WHEN BASE."TransType" = 20 THEN 'Entrada de Mercadorias (Goods Receipt PO)'
        WHEN BASE."TransType" = 21 THEN 'Devolução de Mercadorias (Goods Return)'
        WHEN BASE."TransType" = 67 THEN 'Transferência de Estoque'
        WHEN BASE."TransType" = 202 THEN 'Ordem de Produção'
        ELSE 'Outros Tipos'
    END AS "Origem",
    CASE 
    	WHEN BASE."TransType" = 13 THEN ARINVOICE."Serial"
    	WHEN BASE."TransType" = 18 THEN APINVOICE."Serial"
    	ELSE NULL
    END AS "Nº NF",
    CASE
    	WHEN BASE."TransType" = 13 THEN CAST(ARINVOICEP."InstlmntID" AS NVARCHAR(10)) || ' de ' || ARINVOICE."Installmnt" 
	    WHEN BASE."TransType" = 18 THEN CAST(APINVOICEP."InstlmntID" AS NVARCHAR(10)) || ' de ' || APINVOICE."Installmnt" 
    	ELSE NULL
    END AS "Parcela",
    
    BASE."BaseRef" AS "Nº Origem",
    BASE."Ref1" AS "Ref. 1",
    BASE."Ref2" AS "Ref. 2",
    BASE."Ref3Line" AS "Ref. 3",
    

    CASE 
        WHEN LEFT(BASE."ContraAct", 1) = '_' THEN ACCOUNTPLAN."AcctName"
        ELSE BASE."ContraAct"
    END AS "Contra de Contrapartida",
	CASE 
	    WHEN LEFT(BASE."ContraAct", 1) = '_' THEN ACCOUNTPLAN."Segment_0"
	    
	    ELSE BASE."ContraAct"
	END AS "ID Contrapartida",

    BASE."LineMemo" AS "Detalhes", 

    CASE 
        WHEN BASE."Debit" != 0 THEN BASE."Debit"
        ELSE BASE."Credit"
    END AS "C/D (ML)",

    CASE 
        WHEN BASE."SYSDeb" != 0 THEN BASE."SYSDeb"
        ELSE BASE."SYSCred"
    END AS "C/D (ME)",

    BASE."FCDebit" AS "Débito (MC)",
    BASE."FCCredit" AS "Crédito (MC)", 
    BASE."BPLName" AS "Filial"

FROM JDT1 AS BASE 
	LEFT JOIN OACT AS ACCOUNTPLAN ON BASE."ContraAct" = ACCOUNTPLAN."AcctCode"
	LEFT JOIN OINV AS ARINVOICE ON BASE."TransId" = ARINVOICE."DocEntry" 
 	LEFT JOIN OPCH AS APINVOICE ON BASE."TransId" = APINVOICE."DocEntry" 
 	LEFT JOIN INV6 AS ARINVOICEP ON ARINVOICE."DocEntry" = ARINVOICEP."DocEntry" AND ARINVOICEP."InstlmntID" = BASE."Line_ID"+1 	
 	LEFT JOIN PCH6 AS APINVOICEP ON APINVOICE."DocEntry" = ARINVOICEP."DocEntry" AND APINVOICEP."InstlmntID" = BASE."Line_ID"+1 	
 	
WHERE "RefDate" BETWEEN  '20240501' AND '20240530'
