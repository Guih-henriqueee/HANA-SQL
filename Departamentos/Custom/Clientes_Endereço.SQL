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
NULL                                                         AS "LIMITE SUGERIDO"

FROM
    SBO_INPOWER_PROD.OCRD BASE
    INNER JOIN 
        SBO_INPOWER_PROD.CRD7 D0 						ON BASE."CardCode" 				= D0."CardCode"
    INNER JOIN 
    	COBRANCA D1 									ON BASE."CardCode"				= D1."CardCode"
    INNER JOIN 
    	ENTREGA D2 									    ON BASE."CardCode"				= D2."CardCode"    	
    INNER JOIN 
    	CNPJ AD 										ON BASE."CardCode" 				= AD."CardCode"
WHERE 
    LENGTH(
        REPLACE(
            REPLACE(
                D0."TaxId0", '.',''
                ), '/',''
            )
        ) > 11
    
    
)

SELECT DISTINCT * FROM PARNTERS
     