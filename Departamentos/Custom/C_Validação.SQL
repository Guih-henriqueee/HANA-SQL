--Query para achar a cidade
SELECT TOP 1
	T2."AbsId" 
FROM 
	OCRY T0
	INNER JOIN OCST T1 ON T0."Code"=T1."Country" 
						  AND T1."Country"='BR' 
						  AND T1."Code"='SP'
	INNER JOIN OCNT T2 ON T1."Country"=T2."Country" 
						  AND T1."Code"=T2."State" 
						  AND (UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
						      REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
						      REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
							  T2."Name"
							  ,'''','')
							  ,'-','' )
							  ,' ','' )
							  ,'Ã¡','a')
							  ,'Ã ','a')
							  ,'Ã¢','a')
							  ,'Ã£','a')
							  ,'Ã¤','a')
							  ,'Ã©','e')
							  ,'Ã¨','e')
							  ,'Ãª','e')
							  ,'Ã«','e')
							  ,'Ã­','i')
							  ,'Ã¬','i')
							  ,'Ã®','i')
							  ,'Ã¯','i')
							  ,'Ã³','o')
							  ,'Ã²','o')
							  ,'Ã´','o')
							  ,'Ãµ','o')
							  ,'Ã¶','o')
							  ,'Ãº','u')
							  ,'Ã¹','u')
							  ,'Ã»','u')
							  ,'Ã¼','u')
							  ,'Ã½','y')
							  ,'Ã§','c')
							  ,'Ã±','n')) =UPPER('BonfimPaulista'))
