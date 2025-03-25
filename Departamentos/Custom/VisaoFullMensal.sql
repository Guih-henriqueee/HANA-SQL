-- Realizando um CTE com um unico case para otimização
WITH CanalMapping AS (
    SELECT 
        "U_ChaveAcesso",
        "U_Status",
        "U_Arquivo",
        (CASE 
            WHEN "U_ChaveAcesso" LIKE '%1764228200012355002%' THEN 'Mercado Livre SP'
            WHEN "U_ChaveAcesso" LIKE '%1764228200012355003%' THEN 'B2W'
            WHEN "U_ChaveAcesso" LIKE '%1764228200012355004%' THEN 'Amazon'
            WHEN "U_ChaveAcesso" LIKE '%1764228200012355005%' THEN 'Magalu'
            WHEN "U_ChaveAcesso" LIKE '%1764228200071955006%' THEN 'Mercado Livre MG'
            ELSE 'Outros'
        END) AS "Canal"
    FROM "@OKS_INP_XMLFUL"
)

-- Query principal
SELECT 
    C."Canal",
    COUNT(*) AS "Notas Fiscais API",
    COALESCE(T1."Notas Fiscais", 0) AS "Status Default (Antigo)",
    COALESCE(T3."Notas Fiscais", 0) AS "API PRECODE",
    C."U_Status" AS "Status API"
FROM CanalMapping C
LEFT JOIN (
    SELECT 
        "Canal",
        COUNT(*) AS "Notas Fiscais",
        "U_Status"
    FROM CanalMapping
    WHERE ("U_ChaveAcesso" LIKE '352412%' OR "U_ChaveAcesso" LIKE '312412%')
    AND "U_Arquivo" != 'API%'
    GROUP BY "Canal", "U_Status"
) T1 
ON C."Canal" = T1."Canal" AND C."U_Status" = T1."U_Status"
LEFT JOIN (SELECT 
        "Canal",
        COUNT(*) AS "Notas Fiscais",
        "U_Status"
    FROM CanalMapping
    WHERE ("U_ChaveAcesso" LIKE '352412%' OR "U_ChaveAcesso" LIKE '312412%')
    AND "U_Arquivo" = 'API-PRECODE'
    GROUP BY "Canal", "U_Status"
) T3 
ON C."Canal" = T3."Canal" AND C."U_Status" = T3."U_Status"
WHERE ("U_ChaveAcesso" LIKE '352412%' OR "U_ChaveAcesso" LIKE '312412%')
AND C."U_Arquivo" = 'API'
GROUP BY C."Canal", C."U_Status", T1."Notas Fiscais", T3."Notas Fiscais"

UNION ALL 

-- Query adicional com totais
SELECT 
    '-' AS "Canal",
    COUNT(*) AS "Notas Fiscais API",
    NULL AS "Status API",
    NULL AS "Status Default",
    NULL AS "API PRECODE"
FROM "@OKS_INP_XMLFUL"
WHERE ("U_ChaveAcesso" LIKE '352412%' OR "U_ChaveAcesso" LIKE '312412%')