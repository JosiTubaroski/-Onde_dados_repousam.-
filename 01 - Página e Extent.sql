/*

Todos os dados enviados das aplica��es e sistemas para um banco de dados
s�o gravados em tabelas. 

Os dados s�o enviados para as instru��es INSERT e UPDATE para manuten��o ou
DELETE para excluir os dados.

As tabelas tem uma outra defini��o interna que s�o chamados de objetos
de aloca��o de dados. 

Esses objetos de aloca��o s�o gravados dentro dos arquivos de dados 
(localizados em discos) e associados a um banco de dados. 

Em cada arquivo de dados, temos �reas pr�-definidas onde os dados s�o gravados. Essas 
�reas s�o associadas aos objetos de aloca��o e onde os dados s�o gravados em formado de 
registro de dados. 

Essas �reas s�o conhecidas como P�GINAS DE DADOS.

- Uma p�gina de dados � a menor aloca��o de dados utilizada pelo SQL Server. 
  Ela � a unidade fundamental de armazenamento de dados. 

- Uma p�gina de dados tem um tamanho definido de 8Kbytes ou  8192 bytes que s�o
  dividos entre cabe�alho, �rea de dados e slot de controle (maiores detalhes 
  discutiremos na se��o Armazenamento de dados).

- Uma p�gina de dados � exclusiva para um objeto de aloca��o e um objeto de aloca��o
  pode ter diversas p�ginas de dados. 

- Em uma p�gina de dados somente ser�o armanzendos 8060 bytes de dados em cada linha. 
  
P�GINA DE DADOS - 8Kb ou 8192 bytes 

+-------+           +------------+
|       |           |            |      
|  8Kb  |    -->>   | 8060 bytes |
|       |           |            | 
+-------+           +------------+

Exemplos que demonstram a exist�ncia de p�ginas de dados

*/

use Master
go 

Drop Database if exists DBDemo
go

Create Database DBDemo
go

Use DBDemo 
go

--- O camando abaixo verifica o nome do banco de dados e seu ID

Select DB_name(), DB_id()

go
/*
Primeiro Teste 

Tabela Teste01

- Tr�s colunas de tamanho fixo com 4Kbytes em cada coluna.

*/

Create Table Teste01 
(
   cDescricao char(4096),
   cTitulo char(4096),
   cObservacao char(4096)
)

/*
Msg 1701, Level 16, State 1, Line 69
Creating or altering table 'Teste01' failed because the minimum row size would be 12295, 
including 7 bytes of internal overhead. 
This exceeds the maximum allowable table row size of 8060 bytes.

*/

go 

Create Table Teste01 
(
   cDescricao char(4000),
   cTitulo char(4000)
)
go

insert into Teste01 (cDescricao,cTitulo) values('Minha descricao', 'Meu titulo')
go

select * from Teste01

execute sp_spaceused 'Teste01' 

insert into Teste01 (cDescricao,cTitulo) values('Minha descricao', 'Meu titulo')
go

execute sp_spaceused 'Teste01' 



/*
sp_spaceused
Ref. https://docs.microsoft.com/pt-br/sql/relational-databases/system-stored-procedures/sp-spaceused-transact-sql
*/



/*
------------------------------------------------------
Extent ou Extens�o. 

- S�o agrupamentos l�gicos de p�ginas de dados.  

- Seu objetivo � gerenciar melhor o espa�o alocado do dados. 

- Um Extent tem exatamente 8 p�ginas de dados e um tamanho de 64 Kbytes. 

+------------------------------------------------------------------------------------------+
|                                           64 Kb                                          |
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  |
|  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |  | 
|  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  |  8Kb  |  | 
|  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |  | 
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  | 
+------------------------------------------------------------------------------------------+

- Extents podem ser
   - Misto (Mixed Extent), quando as p�ginas de dados s�o de objetos de aloc���es
     diferentes.

   - Uniforme (Uniform Extent), quando as p�ginas de dados s�o exclusiva de um �nico objeto
     de aloca��o 


Mixed Extent 
+------------------------------------------------------------------------------------------+
|                                           64 Kb                                          |
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  |
|  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |      
|  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  | 
|  |  A    |  |   B   |  |   B   |  |   A   |  |   A   |  |   B   |  |   B   |  |   C   |  | 
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  | 
+------------------------------------------------------------------------------------------+


Uniform Extent.
+------------------------------------------------------------------------------------------+
|                                           64 Kb                                          |
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  |
|  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |  |      
|  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  |Tabela |  | 
|  |  A    |  |   A   |  |   A   |  |   A   |  |   A   |  |   A   |  |   A   |  |   A   |  | 
|  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  +-------+  | 
+------------------------------------------------------------------------------------------+

- Uma nova tabela � alocada em um Mixed Extent utilizando um p�gina de dados. Se a tabela precisa 
  de uma nova p�gina e o Extent tem paginas n�o utilizadas, o SQL Server continua a alocar 
  os dados no Mixed Extent, junto com p�ginas de dados de outros objetos de aloca��o.

- Se a precisar de mais uma p�gina de dados e n�o tem mais p�ginas de dados no Mixed Extent, 
  ent�o o SQL SERVER come�a a alocar todas as novas p�ginas em Uniform Extent.




