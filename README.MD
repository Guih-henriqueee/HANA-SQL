# 📌 Repositório de Consultas SQL - SAP HANA Business One

Bem-vindo ao repositório de consultas SQL para o SAP HANA Business One! Aqui você encontrará uma coleção organizada de consultas para análise e extração de dados, tanto de tabelas nativas quanto customizadas.

## 📂 Estrutura do Repositório

📁 **Compras**  
📄 `C_Dev_NF_Entrada.SQL` - Notas fiscais de entrada (desenvolvimento)  
📄 `D_NF_Entrada.SQL` - Detalhamento de notas fiscais de entrada  

📁 **Contábil** *(Em construção)*  

📁 **Custom**  
📄 `C_Itens.SQL` - Consulta de itens customizados  
📄 `C_Validação.SQL` - Validação de dados customizados  
📄 `U_Gatilho_Operador.SQL` - Gatilho de operador customizado  
📄 `C_Transferencia_Matriz.SQL` - relatório de transferência de mercadorias  

   ### 📌 **Explicação Simplificada para Usuários || C_Transferencias_Matriz**  

   Esta consulta gera um **relatório de transferência de mercadorias** entre diferentes filiais, mostrando as notas fiscais de saída (NS) e suas respectivas notas de entrada (NE) e devoluções de saída (DS), quando houver.  

   ---

   ## **📊 O que este relatório mostra?**
   - O **número e a data** da Nota Fiscal de Saída (NS).
   - O **CNPJ da filial de origem** da mercadoria.
   - A **natureza da operação** (neste caso, transferências).
   - O **valor total da nota**.
   - O **número da Nota Fiscal** emitida.
   - Se houver, o **número da Nota Fiscal de Entrada (NE)** correspondente.
   - Se houver, o **número do Documento de Devolução de Saída (DS)**.
   - O **usuário responsável** pela emissão da NS.
   - O **vendedor vinculado** à transação.

   ---

   ## **📌 Como funciona?**
   1. **Filtra apenas transferências** feitas pela **Matriz (CLJ001)**.
   2. **Seleciona apenas filiais específicas** como origem da mercadoria.
   3. **Verifica se há uma Nota de Entrada (NE) correspondente**, exigindo que:
      - Para a filial **'17.642.282/0005-57'**, o fornecedor seja **'F001577'**.
      - Para outras filiais, sejam usados fornecedores específicos.
   4. **Verifica se há uma devolução de saída (DS)**, caso tenha ocorrido algum retorno de mercadoria.
   5. **Exibe as informações organizadas** e ordenadas do **maior para o menor valor total**.

   ---

   ## **📌 O que isso significa na prática?**
   Este relatório ajuda a **controlar a movimentação de mercadorias entre filiais**, garantindo que:  
   ✅ Cada **Nota de Saída tenha uma Nota de Entrada correspondente** quando necessário.  
   ✅ **A empresa matriz (CLJ001) esteja sempre envolvida nas transferências**.  
   ✅ As **regras de relacionamento entre CNPJs e fornecedores** sejam respeitadas.  

   ---

   📄 `D_Transverencias_Matriz.SQL` - Detalhamento de notas fiscais de entrada 
   ### 📌 **Explicação da Consulta SQL || C_Transferencias_Matriz**
   Esta consulta está extraindo informações de **documentos fiscais (Notas de Saída e Entrada)** no SAP Business One, garantindo que os relacionamentos entre as tabelas sejam feitos corretamente, com base em regras de negócio específicas.

   ---

   ## **1️⃣ Tabelas e Relacionamentos**
   A consulta busca informações das seguintes tabelas:

   | Tabela  | Descrição |
   |---------|----------|
   | `OINV`  | Nota Fiscal de Saída (NS) |
   | `INV12` | Informações de Utilização (Relacionada à NS) |
   | `OUSG`  | Natureza da Operação (Uso da Nota) |
   | `INV1`  | Itens da Nota Fiscal (Detalhes das linhas da NS) |
   | `OUSR`  | Usuários do sistema (Assinatura da NS) |
   | `OSLP`  | Vendedores (Relacionados às notas) |
   | `OPCH`  | Notas de Entrada (NE) |
   | `ORIN`  | Documentos de Devolução de Saída (DS) |

   ---

   ## **2️⃣ SELECT: Campos Selecionados**
   A consulta retorna os seguintes campos:

   | Coluna | Significado |
   |--------|------------|
   | `Nº Documento NS` | Número da Nota Fiscal de Saída |
   | `Data Documento NS` | Data da Nota Fiscal de Saída |
   | `CNPJ Origem` | CNPJ da filial que originou a nota |
   | `Natureza Operação` | Uso da nota (Ex: Transferência de mercadoria) |
   | `Total Linha` | Soma dos valores das linhas da nota |
   | `Nº NF` | Número do documento fiscal |
   | `Nº Documento NE` | Número da Nota de Entrada correspondente |
   | `Nº Documento DS` | Número do Documento de Devolução de Saída |
   | `Abertura` | Informação do campo de abertura (descrição) |
   | `Encerramento` | Informação do campo de encerramento (descrição) |
   | `Usuário` | Nome do usuário que criou a NS |
   | `Vendedor` | Nome do vendedor responsável pela NS |

   ---

   ## **3️⃣ INNER JOINS (Relacionamentos Obrigatórios)**
   Esses `JOINs` garantem que **apenas documentos válidos e existentes** sejam incluídos:

   ```sql
   INNER JOIN INV12 T1 ON T0."DocEntry" = T1."DocEntry"
   ```
   📌 Relaciona a Nota Fiscal (`OINV`) com sua **utilização fiscal** (`INV12`).

   ```sql
   INNER JOIN OUSG T2 ON T1."MainUsage" = T2."ID"
   ```
   📌 Obtém a **natureza da operação**.

   ```sql
   INNER JOIN INV1 T3 ON T0."DocEntry" = T3."DocEntry"
   ```
   📌 Relaciona a nota com **os itens da NF**.

   ```sql
   INNER JOIN OUSR Z0 ON T0."UserSign" = Z0."USERID"
   ```
   📌 Obtém o **usuário que criou a nota**.

   ```sql
   INNER JOIN OSLP D1 ON T0."SlpCode" = D1."SlpCode"
   ```
   📌 Obtém o **vendedor** associado à NF.

   ---

   ## **4️⃣ LEFT JOINS (Relacionamentos Opcionais)**
   Os `LEFT JOINs` incluem informações **se existirem**, sem eliminar registros caso não haja correspondência.

   ### **📌 Relacionamento com Documentos de Devolução (`ORIN`)**
   ```sql
   LEFT JOIN ORIN Z5 ON T0."Serial"  = Z5."Serial" AND (
         (T0."VATRegNum" = '17.642.282/0005-57' AND Z5."CardCode" = 'CLJ001') OR
         (T0."VATRegNum" = '17.642.282/0007-19' AND Z5."CardCode" = 'CLJ001') OR
         (T0."VATRegNum" = '17.642.282/0004-76' AND Z5."CardCode" = 'CLJ001') OR
         (T0."VATRegNum" = '17.642.282/0003-95' AND Z5."CardCode" = 'CLJ001') 
      )
   ```
   📌 **Relaciona Notas de Saída (`OINV`) com Devoluções de Saída (`ORIN`)**, considerando que o **CNPJ de origem seja de uma filial específica** e que o `CardCode` seja sempre `'CLJ001'` (Matriz).

   ---

   ### **📌 Relacionamento com Notas de Entrada (`OPCH`)**
   ```sql
   LEFT JOIN OPCH Z4 
      ON T0."Serial" = Z4."Serial"
      AND (
         (T0."VATRegNum" = '17.642.282/0005-57' AND Z4."CardCode" = 'F001577') OR
         (T0."VATRegNum" = '17.642.282/0007-19' AND Z4."CardCode" = 'F002550') OR
         (T0."VATRegNum" = '17.642.282/0004-76' AND Z4."CardCode" = 'F002085') OR
         (T0."VATRegNum" = '17.642.282/0003-95' AND Z4."CardCode" = 'F002550') 
      )
   ```
   📌 **Relaciona Notas de Saída (`OINV`) com Notas de Entrada (`OPCH`)** de acordo com regras específicas de **CNPJ vs. CardCode**.

   ---

   ## **5️⃣ WHERE: Filtros Aplicados**
   ```sql
   WHERE 
      T0."CardCode" = 'CLJ001' --- Cadastro da Matriz
   ```
   📌 Filtra **apenas documentos onde a Matriz (`CLJ001`) seja o fornecedor**.

   ```sql
      ---AND T0."CANCELED" = 'N'
   ```
   📌 Essa linha está comentada (`---`), mas caso seja ativada, **excluiria notas canceladas**.

   ```sql
      AND T2."ID" = 47 -- 47 = Utilização de Transferencia
   ```
   📌 Considera apenas **notas de transferência**.

   ```sql
      AND T0."VATRegNum" IN ('17.642.282/0005-57', '17.642.282/0007-19', '17.642.282/0004-76', '17.642.282/0003-95')  
   ```
   📌 Filtra apenas notas originadas **dessas filiais**.

   ---

   ## **6️⃣ GROUP BY e ORDER BY**
   ```sql
   GROUP BY 
      T0."DocNum", T0."DocDate", T0."VATRegNum", 
      T2."Usage", T0."Serial", Z4."DocNum",Z5."DocNum", 
      CAST(T0."Header" AS NVARCHAR(255)), CAST(T0."Footer" AS NVARCHAR(255)),
      Z0."U_NAME", D1."SlpName"
   ```
   📌 **Agrupa os dados** por número da nota, data, CNPJ, natureza da operação, usuário e vendedor.

   ```sql
   ORDER BY "Total Linha" DESC;
   ```
   📌 **Ordena os resultados** do maior para o menor valor total.

   ---

   ## **🔎 Resumo**
   - **Objetivo**: Trazer **notas fiscais de saída (NS)** com informações sobre **notas de entrada (NE) e devoluções de saída (DS)**.
   - **Regra Principal**: O **CNPJ da nota de saída deve corresponder a um CardCode específico na nota de entrada**.
   - **LEFT JOINs** garantem que a consulta retorne **todas as notas de saída**, mesmo que **não tenham notas de entrada ou devolução associadas**.
   - **Filtros** asseguram que **apenas transferências entre filiais** sejam exibidas.

   ---

   ## 🚀 **O que pode ser otimizado?**
   1. **Remover `CAST(T0."Header" AS NVARCHAR(255))` do `GROUP BY`** caso não seja necessário.
   2. **Adicionar índice** nas colunas `Serial`, `VATRegNum` e `CardCode` para melhorar performance.
   3. **Remover a cláusula `GROUP BY`** se a consulta não precisar de agregação (`SUM(T3."LineTotal")`).

   ---


📁 **Estoque**  
📄 `C_Itens_Saldo.SQL` - Consulta de saldo de itens  

📁 **Financeiro** *(Em construção)*  

📁 **Fiscal** *(Em construção)*  

📁 **Vendas**  
📄 `C_Ven_NF_Saidas.SQL` - Notas fiscais de saída  

---

## 🛠️ Convenções de Nomeação
🔹 `C_` - Consultas com possíveis campos de usuários (criadas por usuário, não sendo nativas)  
🔹 `D_` - Consultas em campos default  
🔹 `U_` - Consultas em tabelas de usuário  

---

## 🚀 Como Utilizar
1️⃣ Clone o repositório:  
   ```sh
   git clone https://github.com/guih-henriquee/HANA-SQL.git
   ```
2️⃣ Navegue até a pasta desejada e abra a consulta.
3️⃣ Execute no banco SAP HANA e ajuste conforme necessário.

---

## 🤝 Contribuição
Se quiser adicionar ou modificar consultas:
1. Faça um **fork** do repositório.
2. Crie uma nova **branch** com sua alteração.
3. Envie um **pull request** para revisão.

---

## 📬 Contato
Em caso de dúvidas ou sugestões, entre em contato com o mantenedor do repositório. 

🗂️ **Organize. Consulte. Otimize.** 🚀
