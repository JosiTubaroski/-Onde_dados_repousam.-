# Onde os dados repousam!

Onde os dados repousam. Uma introdução a página de dados

Vamos verificar alguns conceitos que precisamos entender para começar a trabalhar com preformance.

Todos os dados enviados das aplicações e sistemas para um banco de dados são gravados em tabelas.

Os dados são enviados por instruções de INSERT e UPDATE para manutenção ou DELETE para excluir os dados.

As tabelas tem outra definição interna que são chamados de objeto de alocação de dados.

Em cada arquivo de dados, temos áreas pré-definidas onde os dados são gravados. Essas áreas são associadas aos objetos de alocação e onde os dados
são gravados em formato de registro de dados.

Essas áreas são conhecidas como PÁGINAS DE DADOS.

- Uma página de dados é a menor alocação utilizada pelo SQL Server.
  Ela é a unidade fundamental de armazenamento de dados.

- Uma página de dados tem um tamanho definido de 8Kbytes ou 8192 bytes que são divididos entre cabeçalho, área de dados e slot de controle.
- Uma página de dados é exclusiva para um objeto de alocação e um objeto de alocação pode ter diversar páginas de dados.
- Em uma página de dados somente serão armazenados 8060 bytes de dados em cada linha.

  PÁGINA DE DADOS - 8Kb ou 8192 bytes 

Verificar exemplo: 

execute sp_spaceused 'Nome da Tabela' 


👇 Para Saber mais:

sp_spaceused
Ref. https://docs.microsoft.com/pt-br/sql/relational-databases/system-stored-procedures/sp-spaceused-transact-sql

## Extend ou Extensão.

- São agrupamentos lógicos de páginas de dados.
- Seu objetivo é gerenciar melhor o espaço alocado dos dados.
- Um Extent tem exatamente 8 páginas de dados e um tamanho de 64 Kbytes.

- Extents podem ser
   - Misto (Mixed Extent), quando as páginas de dados são de objetos de alocações diferentes.
   - Uniforme (Uniform Extent), quando as páginas de dados são exclusiva de um único objeto de alocação.
 
Uma nova tabela é alocada em um Mixed Extend utilizando uma página de dados. Se a tabela precisar de uma nova
página e o Extent tem paginas não utilizadas, o SQL Server continua a alocar os dados no Mixed Extent, junto com
páginas de dados de outros objetos de alocação.

Se precisar de mais uma página de dados e não tem mais páginas de dados no Mixed Extent, então o SQL SERVER começa a 
alocar todas as novas páginas em Uniform Extent. 

👇 Saiba Mais:

https://github.com/JosiTubaroski/-Onde_dados_repousam.-/blob/main/01%20-%20P%C3%A1gina%20e%20Extent.sql

  
    
