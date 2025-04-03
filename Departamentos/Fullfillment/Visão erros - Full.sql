SELECT 
COUNT (1),
CAST (CASE WHEN "U_Mensagem" LIKE '%CFOP%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%encontrar número de série disponível%' THEN 'Logistica/Estoque'
	 WHEN "U_Mensagem" LIKE '%Warehouse is not assigned%' THEN 'Okser'
	 WHEN "U_Mensagem" LIKE '%Não foi possível encontrar a nota de saída%' THEN 'Integração/Fiscal'
	 WHEN "U_Mensagem" LIKE '%localizar o item no SAP para o Cód. XML%' THEN 'Cadastro'
	 WHEN "U_Mensagem" LIKE '%Select business partner assigned to specified branch%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%enter a unique business partner code%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%Quantity falls into negative inventory%' THEN 'Logistica/Estoque'
	 WHEN "U_Mensagem" LIKE '%open the window again%' THEN 'TI'
	 WHEN "U_Mensagem" LIKE '%not specified as sales item%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%Sequence was dropped during calling nextval%' THEN 'TI'
	 WHEN "U_Mensagem" LIKE '%Cannot add row without complete selection of batch%' THEN 'Logistica/Estoque'
	 WHEN "U_Mensagem" LIKE '%Update the exchange rate   USD%' THEN 'Okser'
	 WHEN "U_Mensagem" LIKE '%does not exist in warehouse%' THEN 'Logistica/Estoque' 
	 ELSE 'Não Definido' END AS VARCHAR(250)) AS "Responsável"
	 

FROM "@OKS_INP_XMLFUL" WHERE "U_Status" = 'Erro'

GROUP BY CAST (CASE WHEN "U_Mensagem" LIKE '%CFOP%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%encontrar número de série disponível%' THEN 'Logistica/Estoque'
	 WHEN "U_Mensagem" LIKE '%Warehouse is not assigned%' THEN 'Okser'
	 WHEN "U_Mensagem" LIKE '%Não foi possível encontrar a nota de saída%' THEN 'Integração/Fiscal'
	 WHEN "U_Mensagem" LIKE '%localizar o item no SAP para o Cód. XML%' THEN 'Cadastro'
	 WHEN "U_Mensagem" LIKE '%Select business partner assigned to specified branch%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%enter a unique business partner code%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%Quantity falls into negative inventory%' THEN 'Logistica/Estoque'
	 WHEN "U_Mensagem" LIKE '%open the window again%' THEN 'TI'
	 WHEN "U_Mensagem" LIKE '%not specified as sales item%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%Sequence was dropped during calling nextval%' THEN 'TI'
	 WHEN "U_Mensagem" LIKE '%Cannot add row without complete selection of batch%' THEN 'Logistica/Estoque'
	 WHEN "U_Mensagem" LIKE '%Update the exchange rate   USD%' THEN 'Okser'
	 WHEN "U_Mensagem" LIKE '%does not exist in warehouse%' THEN 'Logistica/Estoque' 
	 ELSE 'Não Definido' END AS VARCHAR (250))
	 
SELECT "U_ChaveAcesso", "U_Mensagem",
CASE WHEN "U_Mensagem" LIKE '%CFOP%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%encontrar número de série disponível%' THEN 'Logistica/Estoque'
	 WHEN "U_Mensagem" LIKE '%Warehouse is not assigned%' THEN 'Okser'
	 WHEN "U_Mensagem" LIKE '%Não foi possível encontrar a nota de saída%' THEN 'Integração/Fiscal'
	 WHEN "U_Mensagem" LIKE '%localizar o item no SAP para o Cód. XML%' THEN 'Cadastro'
	 WHEN "U_Mensagem" LIKE '%Select business partner assigned to specified branch%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%enter a unique business partner code%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%Quantity falls into negative inventory%' THEN 'Logistica/Estoque'
	 WHEN "U_Mensagem" LIKE '%open the window again%' THEN 'TI'
	 WHEN "U_Mensagem" LIKE '%not specified as sales item%' THEN 'Fiscal'
	 WHEN "U_Mensagem" LIKE '%Sequence was dropped during calling nextval%' THEN 'TI'
	 WHEN "U_Mensagem" LIKE '%Cannot add row without complete selection of batch%' THEN 'Logistica/Estoque'
	 WHEN "U_Mensagem" LIKE '%Update the exchange rate   USD%' THEN 'Okser'
	 WHEN "U_Mensagem" LIKE '%does not exist in warehouse%' THEN 'Logistica/Estoque' 
	 ELSE 'Não Definido' END AS "Responsável"

FROM "@OKS_INP_XMLFUL" WHERE "U_Status" = 'Erro'

