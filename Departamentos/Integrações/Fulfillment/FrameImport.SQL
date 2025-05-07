
SELECT oix."U_Status", oix."U_Fonte", d1."Total", COUNT(1) FROM "@OKS_INP_XMLFUL" oix 
LEFT JOIN (
SELECT "U_Status", "U_Fonte" , COUNT(1) AS "Total" FROM "@OKS_INP_XMLFUL" oix WHERE "U_DataReg" >  ADD_DAYS(CURRENT_DATE, -20)GROUP BY "U_Status", "U_Fonte" ) D1 ON oix."U_Status" = D1."U_Status" AND oix."U_Fonte" = D1."U_Fonte" 
WHERE oix."U_DataReg" BETWEEN ADD_DAYS(CURRENT_DATE, -40) AND  ADD_DAYS(CURRENT_DATE, -20)GROUP BY oix."U_Status", oix."U_Fonte", d1."Total"