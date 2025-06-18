WITH CNPJ AS (
	SELECT DISTINCT 
    "CardCode", 
    SUBSTRING(
        REPLACE(
            REPLACE(
                REPLACE(
                    "TaxId0", '.',''
                    ),'-',''
                ),'/',''
            ),1,2
        ) || '.' ||  
            
    SUBSTRING(
        REPLACE(
            REPLACE(
                REPLACE(
                    "TaxId0", '.',''),'-',''
                    ),'/',''
                ),4,3
            ) || '.' ||  
    SUBSTRING (
        REPLACE(
            REPLACE(
                REPLACE(
                    "TaxId0", '.',''
                    ),'-',''
                ),'/',''
            ),7,3
        ) || '/' ||
    SUBSTRING (
        REPLACE(
            REPLACE(
                REPLACE(
                    "TaxId0", '.',''
                    ),'-',''
                ),'/',''
            ),9,4
        )  || '-' || 
    SUBSTRING (
        REPLACE(
            REPLACE(
                REPLACE(
                    "TaxId0", '.',''
                    ),'-',''
                ),'/',''
            ),13,2
        )
	AS "TaxId0" FROM SBO_INPOWER_PROD.CRD7
	
    WHERE LENGTH(
                REPLACE(
                    REPLACE(
                        "TaxId0", '.',''
                        ), '/',''
                    )
                ) > 11 
),
COBRANCA AS (
	SELECT 
        "CardCode",
        "Street",
        "Block", 
        REPLACE(
            "ZipCode", '-',''
            )                                               AS "ZipCode",
        "City",
        "Country", 
        "State", 
        "Building", 
        "StreetNo"
	
    FROM SBO_INPOWER_PROD.CRD1
	WHERE LOWER(
                "Address"
                ) LIKE '%cobran%' 
),
ENTREGA AS (
	SELECT 
        "CardCode",
        "Street",
        "Block",
        REPLACE(
            "ZipCode", '-',''
            )                                               AS "ZipCode",
        "City",
        "Country",
        "State",
        "Building",
        "StreetNo"
	
    FROM SBO_INPOWER_PROD.CRD1
	WHERE LOWER(
                "Address"
                ) LIKE '%entre%' 
), 

FATURAMENTO AS (
SELECT DISTINCT
    SUBSTRING (REPLACE(REPLACE(REPLACE(CNPJ, '.',''),'-',''),'/',''),1,2) || '.' ||  SUBSTRING (REPLACE(REPLACE(REPLACE(CNPJ, '.',''),'-',''),'/',''),4,3) || '.' ||  SUBSTRING (REPLACE(REPLACE(REPLACE(CNPJ, '.',''),'-',''),'/',''),7,3) || '/' ||  SUBSTRING (REPLACE(REPLACE(REPLACE(CNPJ, '.',''),'-',''),'/',''),9,4)  || '-' ||  SUBSTRING (REPLACE(REPLACE(REPLACE(CNPJ, '.',''),'-',''),'/',''),13,2)
	AS CNPJ,
    MES,
    TOTAL,
    ROW_NUMBER() OVER (
        PARTITION BY CNPJ
        ORDER BY MES
    ) AS RANKING
FROM (
    SELECT
        REPLACE(REPLACE(D1."TaxId0", '.', ''), '/', '') AS CNPJ,
        TO_NVARCHAR(D0."DocDate", 'MMYYYY') AS MES,
        SUM(D0."DocTotal") AS TOTAL
    FROM
        SBO_INPOWER_PROD.OINV D0
        INNER JOIN SBO_INPOWER_PROD.INV12 D1 ON D0."DocEntry" = D1."DocEntry"
    WHERE
        LENGTH(REPLACE(REPLACE(D1."TaxId0", '.', ''), '/', '')) > 11
        AND D0."DocDate" > ADD_MONTHS(CURRENT_DATE, -13)
    GROUP BY
        REPLACE(REPLACE(D1."TaxId0", '.', ''), '/', ''),
        TO_NVARCHAR(D0."DocDate", 'MMYYYY')
) AS Base
ORDER BY
    CNPJ,
    MES

),

PARNTERS AS(

SELECT
'INPOWER'                                                    AS "Código do Grupo Econônimo",
NULL                                                         AS "Código do Cliente no Convênio ou CNPJ",
UPPER(BASE."CardName")                                       AS "RAZÃO SOCIAL",
BASE."OrdersBal"                                             AS "FATURAMENTO",
UPPER(AD."TaxId0")                                           AS "COBRANÇA CNPJ",
UPPER(D1."Street")		                                     AS "COBRANÇA LOGRADOURO",
UPPER(D1."StreetNo")                                         AS "COBRANÇA NUMERO",
UPPER(D1."Building")                                         AS "COBRANÇA COMPLEMENTO",
UPPER(D1."ZipCode")                                          AS "COBRANÇA CEP",
UPPER(D1."Block")                                            AS "COBRANÇA BAIRRO",
UPPER(D1."City")                                             AS "COBRANÇA MUNICIPIO",
UPPER(D1."State")                                            AS "COBRANÇA UF",
NULL                                                         AS "COBRANÇA CONTATO",
UPPER(BASE."Phone1")                                         AS "COBRANÇA TELEFONE 1",
UPPER(BASE."Cellular")                                       AS "COBRANÇA TELEFONE 2",
UPPER(BASE."E_Mail")                                         AS "COBRANÇA EMAIL 1",
NULL                                                         AS "COBRANÇA EMAIL 2",
UPPER(D2."Street")		                                     AS "ENTREGA LOGRADOURO",
UPPER(D2."StreetNo")                                         AS "ENTREGA NUMERO",
UPPER(D2."Building")                                         AS "ENTREGA COMPLEMENTO",
UPPER(D2."ZipCode")                                          AS "ENTREGA CEP",
UPPER(D2."Block")                                            AS "ENTREGA BAIRRO",
UPPER(D2."City")                                             AS "ENTREGA MUNICIPIO",
UPPER(D2."State")                                            AS "ENTREGA UF",
NULL                                                         AS "SEGMENTO",
COALESCE(F1."TOTAL",0)										 AS "MES 01",
COALESCE(F2."TOTAL",0)										 AS "MES 02",
COALESCE(F3."TOTAL",0)										 AS "MES 03",
COALESCE(F4."TOTAL",0)										 AS "MES 04",
COALESCE(F5."TOTAL",0)										 AS "MES 05",
COALESCE(F6."TOTAL",0)										 AS "MES 06",
COALESCE(F7."TOTAL",0)										 AS "MES 07",
COALESCE(F8."TOTAL",0)										 AS "MES 08",
COALESCE(F9."TOTAL",0)										 AS "MES 09",
COALESCE(F10."TOTAL",0)										 AS "MES 10",
COALESCE(F11."TOTAL",0)										 AS "MES 11",
COALESCE(F12."TOTAL",0)										 AS "MES 12"

FROM
    SBO_INPOWER_PROD.OCRD BASE
    LEFT JOIN 
        SBO_INPOWER_PROD.CRD7 D0 						ON BASE."CardCode" 				= D0."CardCode"
    LEFT JOIN 
    	COBRANCA D1 									ON BASE."CardCode"				= D1."CardCode"
    LEFT JOIN 
    	ENTREGA D2 									    ON BASE."CardCode"				= D2."CardCode"    	
    LEFT JOIN 
    	CNPJ AD 										ON BASE."CardCode" 				= AD."CardCode"
    LEFT JOIN
        FATURAMENTO F1                                  ON AD."TaxId0"                    = F1."CNPJ"         AND F1."RANKING" = 1
    LEFT JOIN
        FATURAMENTO F2                                  ON AD."TaxId0"                    = F2."CNPJ"         AND F2."RANKING" = 2
    LEFT JOIN
        FATURAMENTO F3                                  ON AD."TaxId0"                    = F3."CNPJ"         AND F3."RANKING" = 3
    LEFT JOIN
        FATURAMENTO F4                                  ON AD."TaxId0"                    = F4."CNPJ"         AND F4."RANKING" = 4
    LEFT JOIN
        FATURAMENTO F5                                  ON AD."TaxId0"                    = F5."CNPJ"         AND F5."RANKING" = 5
    LEFT JOIN
        FATURAMENTO F6                                  ON AD."TaxId0"                    = F6."CNPJ"         AND F6."RANKING" = 6
    LEFT JOIN
        FATURAMENTO F7                                  ON AD."TaxId0"                    = F7."CNPJ"         AND F7."RANKING" = 7
    LEFT JOIN
        FATURAMENTO F8                                  ON AD."TaxId0"                    = F8."CNPJ"         AND F8."RANKING" = 8
    LEFT JOIN
        FATURAMENTO F9                                  ON AD."TaxId0"                    = F9."CNPJ"         AND F9."RANKING" = 9
    LEFT JOIN
        FATURAMENTO F10                                  ON AD."TaxId0"                    = F10."CNPJ"         AND F10."RANKING" = 10
    LEFT JOIN
        FATURAMENTO F11                                  ON AD."TaxId0"                    = F11."CNPJ"         AND F11."RANKING" = 11
    LEFT JOIN
        FATURAMENTO F12                                  ON AD."TaxId0"                    = F12."CNPJ"         AND F12."RANKING" = 12
    
WHERE 
    LENGTH (REPLACE(REPLACE(D0."TaxId0", '.',''), '/','')) > 11
    
    
)

SELECT DISTINCT * FROM PARNTERS
     