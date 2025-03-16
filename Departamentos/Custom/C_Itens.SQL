SELECT
    T0."ItemCode" AS product_code,                      -- Código do Produto (T0 refere-se à tabela OITM)
    T0."ItemName" AS product_name,                     -- Nome do Produto (T0 refere-se à tabela OITM)
    T0."ItmsGrpCod" AS category_code,                  -- Código da Categoria (referente ao código do grupo de itens na tabela OITM)
    T1."ItmsGrpNam" AS category,                       -- Nome da Categoria (T1 refere-se à tabela OITB, nome do grupo de itens)
    T0."U_OKS_GRD_Categ" AS category2_code,            -- Código de uma segunda categoria personalizada (campo da tabela OITM)
    MC."Name" AS category2,                            -- Nome da segunda categoria (campo da tabela @OKS_GRD_CATEG, uma tabela de categorias personalizadas)
    T0."U_OKS_IPW_IDHierarquia" AS category3_code,     -- Código da terceira categoria hierárquica (campo da tabela OITM)
    T0."U_OKS_IPW_DSHierarquia" AS category3,          -- Nome da terceira categoria hierárquica (campo da tabela OITM)
    
    CASE 
        WHEN T0."validFor" = 'Y' THEN 'true'           -- Verificação do estado ativo do produto: 'true' se ativo
        ELSE 'false'                                   -- 'false' caso contrário
    END AS active_state,                             -- Estado Ativo/Inativo do produto
    
    T0."CodeBars" AS code_alt_ean,                     -- Código de Barras (EAN) do produto (campo da tabela OITM)
    T0."NumInBuy" AS factor_purchase,                  -- Fator de Compra (campo da tabela OITM)
    'Não aplicável' AS shelf_life,                     -- Vida útil do produto (valor fixo: 'Não aplicável')
    AVG(VLM."LineTotal") AS sale_price,                -- Preço de Venda (média do valor da linha de venda da view "View_Relatorio_Marcos_90")
    T0."LastPurPrc" AS purchase_cost,                  -- Custo de Compra (campo da tabela OITM)
    T0."SWeight1" AS weight,                            -- Peso Bruto do Produto (campo da tabela OITM)
    T0."SWidth1" AS width,                              -- Largura do Produto (campo da tabela OITM)
    T0."SHeight1" AS height,                            -- Altura do Produto (campo da tabela OITM)
    T0."SLength1" AS length,                            -- Comprimento do Produto (campo da tabela OITM)
    'Não aplicável' AS master_product,                 -- Produto Principal (SKU Mestre) (valor fixo: 'Não aplicável')
    'LJ01-CON' AS default_warehouse,                   -- Armazém Padrão do Produto (valor fixo: 'LJ01-CON')
    'SEM INFORMAÇÃO NO ERP' AS abc_classification,     -- Classificação ABC (valor fixo: 'SEM INFORMAÇÃO NO ERP')
    1 AS multiple,                                     -- Múltiplos de Venda (valor fixo: '1')
    'Não aplicável' AS phase_out_product_code,         -- Código de Produto Substituto (valor fixo: 'Não aplicável')
    'Não aplicável' AS phase_out_date                  -- Data de Descontinuação do Produto (valor fixo: 'Não aplicável')
FROM
    "OITM" T0                                         -- Tabela de Itens (referência T0 para OITM)
LEFT JOIN
    "OITB" T1 ON T0."ItmsGrpCod" = T1."ItmsGrpCod"         -- Junção com a Tabela de Grupos de Itens (OITB) para obter o nome do grupo
LEFT JOIN
    "View_Relatorio_Marcos_90" VLM ON T0."ItemCode" = VLM."ItemCode"   -- Junção com a View do CMV ("View_Relatorio_Marcos_90") para pegar a média do preço de venda
LEFT JOIN 
    "@OKS_GRD_CATEG" MC ON T0."U_OKS_GRD_Categ" = MC."Code"  -- Junção com a tabela personalizada "@OKS_GRD_CATEG" para obter o nome da segunda categoria
WHERE
    T0."ItemType" = 'I'                               -- Filtrando apenas os itens de estoque (ItemType = 'I')
    AND T0."ItemCode" LIKE 'NAC%'                     -- Filtrando os itens cujo código começa com 'NAC%'
GROUP BY
    T0."ItemCode", 
    T0."ItemName",
    T0."ItmsGrpCod",
    T1."ItmsGrpNam",
    T0."U_OKS_GRD_Categ",
    MC."Name",
    T0."U_OKS_IPW_IDHierarquia",
    T0."U_OKS_IPW_DSHierarquia",
    T0."validFor",
    T0."CodeBars",
    T0."NumInBuy",
    T0."LastPurPrc",
    T0."SWeight1",
    T0."SWidth1",
    T0."SHeight1",
    T0."SLength1",
    T0."CardCode"
-- Agrupando por todas as colunas não agregadas
ORDER BY
    T0."ItemCode";                                    -- Ordenando o resultado pelo código do produto (ItemCode)
