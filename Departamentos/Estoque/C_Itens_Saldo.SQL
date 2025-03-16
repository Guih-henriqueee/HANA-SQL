
SELECT
    T0."WhsCode" AS location_code,       -- Código do armazém
    T1."ItemCode" AS product_code,      -- Código do produto
    NOW() AS date,                -- Data atual
    T0."OnHand" AS quantity             -- Quantidade em estoque
FROM
    "SBO_INPOWER_PROD"."OITW" T0                           -- Tabela de Estoque por Armazém
INNER JOIN
    "SBO_INPOWER_PROD"."OITM" T1 ON T0."ItemCode" = T1."ItemCode" -- Join com a tabela de Itens
WHERE
    T0."OnHand" > 0                     -- Estoque maior que zero
ORDER BY
    T0."WhsCode", T1."ItemCode";





