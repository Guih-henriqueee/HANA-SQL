Select
	t1."CreateDate" as "Data de Criação",
	t0."Data Lançamento",
	t0."Data Documento", 
	TO_NVARCHAR(TO_DATE(t0."Data Documento"),'YYYY.MM') as "Mês",
	t1."DocDueDate" AS "Data de Vencimento",
	t1."CANCELED" AS "Cancelado (Y/N)",
	t0."BPLId",
	t0."Filial",
	t0."Número SAP",
	t0."DocEntry",
	t0."Número Referência PN",
	t0."Número Pedido Cliente",
	t0."Tipo DOC",
	t0."Status Docto",
	CASE 
		WHEN LENGTH(t4."TaxId0") > 3 Then 'Pessoa Jurídica' 
		WHEN LENGTH(t4."TaxId4") > 3 Then 'Pessoa Física'
	ELSE
		'Não Identificado'
	END AS "Classificação PN",
	t0."Código PN",
	t0."Nome Abreviado",
	t0."Nome PN",
	t0."Grupo PN",
	t0."Nome Grupo PN",
	t0."Código Município",
	t0."Nome Município",
	t0."UF",
	t0."Região",
	t0."Código Vendedor",
	t0."Nome Vendedor",	
	t3."U_Loja" as "Classificação do Vendedor",
	t0."Serial" as "Número da Nota",
	T1."SeriesStr" AS "Serial da Nota",
	t0."SeqName" as "Sequencia",
	t0."Model" as "Modelo",
	t0."Transportadora",
	t5."CardName" as "Nome Transportadora",
	t0."Código Utilização",
	t0."Nome Utilização",
	t0."Código Imposto",
	t0."CFOP",
	t0."Gratuito",
	t0."Terceiros",
	t0."Código Item",
	--t6."SWW" as "SKU PreCode",
	t0."Descrição Item",
	t0."Descrição Item Doc",
	t7."FirmName" AS "Fabricante",
	t0."Grupo",
	t0."Nome Grupo",
	t6."U_OKS_IPW_DSHierarquia" as "Hierarquia",
	t0."Depósito",
	t0."Quantidade",
	t0."CMV",
	t2."Price" as "Custo Manual",
	t2."Price" * t0."Quantidade" as "Custo Manual Total",
	t0."Unitário R$",
	t0."Total Mercadoria R$",
	t0."DA Frete",
	t0."DA Seguro",
	t0."DA Outros",
	t0."IMPOSTOS-I",
	t0."IMPOSTOS-NI",
	t0."Faturamento Bruto",
	t0."Faturamento Líquido",
	CASE 
		WHEN (IFNULL(t2."Price",0.00) = 0.00 
		OR t0."Faturamento Bruto" = 0.00 
		OR t0."Quantidade" = 0.00)	THEN 0 
		ELSE (t0."Faturamento Bruto"-(t2."Price"*t0."Quantidade"))/t0."Faturamento Bruto"
		END AS "Margem Bruta",
	CASE
		WHEN (IFNULL(t2."Price",0.00) = 0.00
		OR t0."Faturamento Bruto" = 0.00 
		OR t0."Quantidade" = 0.00) THEN 0 
		ELSE (t0."Faturamento Líquido"-(t2."Price"*t0."Quantidade"))/t0."Faturamento Líquido" 
		END AS "Margem Líquida",
	t0."COFINS-I",
	t0."PIS-I",
	t0."ICMS-I",
	t0."ICMSDest-I",
	t0."ICMSRemet-I",
	t0."FCP-I",
	t0."FCP-ST-I",
	t0."ICMS-ST-I",
	t0."IPI-I",
	t0."ISS-I",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
	t0."OUTROS IMP-I",
	t0."COFINS-NI",
	t0."PIS-NI",
	t0."ICMS-NI",
	t0."ICMSDest-NI",
	t0."ICMSRemet-NI",
	t0."FCP-NI",
	t0."FCP-ST-NI",
	t0."ICMS-ST-NI",
	t0."IPI-NI",
	t0."ISS-NI",
	t0."CSLL-NI",
	t0."IRPJ-NI",
	t0."II-NI",
	t0."OUTROS IMP-NI"
FROM SBO_INPOWER_PROD."OKS_NFS" as t0
	INNER JOIN SBO_INPOWER_PROD."OINV" AS t1 ON t0."DocEntry" = t1."DocEntry"
	LEFT JOIN SBO_INPOWER_PROD."ITM1" t2 ON t0."Código Item" = t2."ItemCode" and t2."PriceList" = '5'
	LEFT JOIN SBO_INPOWER_PROD."OSLP" AS t3 ON t0."Código Vendedor" = t3."SlpCode"
	INNER JOIN SBO_INPOWER_PROD."INV12" AS t4 ON t0."DocEntry" = t4."DocEntry"
	LEFT JOIN SBO_INPOWER_PROD."OCRD" AS t5 ON t0."Transportadora" = t5."CardCode"
	LEFT JOIN SBO_INPOWER_PROD."OITM" t6 ON t0."Código Item" = t6."ItemCode"
	INNER JOIN SBO_INPOWER_PROD."OMRC" T7 ON T6."FirmCode" = T7."FirmCode"
WHERE
	T0."Nome Utilização" NOT IN ('RETORNO CONSERTO', 'REMESSA CONSERTO', 'REM.P/DEP.TEMPORARIO', 'REMESSA VEND À ORDEM', 'RETORNO DE COMODATO', 'REM ENTREGA FUTURA', 'TRANSFERÊNCIA')
	AND T0."Model" NOT IN ('NFC-e', 'NFS-e', 'Nota de Débito')
	AND T1."CANCELED" = 'N' 
	AND T0."Data Documento" BETWEEN '20240101' AND '20241231'