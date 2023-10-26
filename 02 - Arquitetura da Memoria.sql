/*
Vamos come�ar essa aula com a seguinte pergunta:

� mais r�pido acessar os dados em mem�ria ou em disco ?

A sua resposta j� diz por que o SQL Server deve ter mem�ria suficiente
para atender a carga de dados. 


Mem�ria.

   - Quanto mais, melhor. Mem�ria ser� utilizada para carregar os dados que est�o em 
     disco para um �rea no SQL Server conhecida como Buffer Pool.

   - Quando mais dados o SQL Server conseguir manter em mem�ria, melhor. Servidores com 
     16Gb, 32GB ou 64Gb atende a maioria das demandas. Mas encontramos instala��es que 
     chegam a mais de 512Gb de mem�ria. 

     Apesar da recomenda��o m�nima da Microsoft para mem�ria do SQL Server � de 1Gb, 
     eu recomendo inicial com 4Gb, mas o correto deve ser a an�lise do ambiente para 
     um melhor dimensionamento.
*/

/*

SQL Server 
----------

Buffer Pool ou Buffer Cache.

Um buffer � uma �rea de 8Kbytes na mem�ria onde o SQL Server armazena as p�ginas  de dados 
lidas dos objetos de aloca��o que est�o no disco ( papel do Gerenciador de Buffer). 

O dado permanece no buffer at� que o Gerenciador de Buffer precise de mais �reas para carregar
novas p�ginas de dados. As �reas de buffer mais antigas e com dados modificados s�o gravos em discos
e liberadas para os novas p�ginas. 

Quando o SQL Server necessita de um dado � o mesmo est� no buffer, 
ele faz uma leitura l�gica desse dado. Se o dado n�o estiver no buffer, o SQL Server faz uma
leitura f�sica do dado em disco para o buffer pool.

A �rea de mem�ria onde fica o Buffer Pool � configurada no SQL Server como 
Min Server Memory e Max Server Memory.


Configurando a mem�ria no SQL SERVER.

   Quando instalamos o SQL SERVER, ele configura autom�ticamente a utiliza��o da mem�ria dispon�vel
   no servidor. Ele tem as op��es de "Max Server Memory" e "Min Server Memory"  que voce pode consultar
   com o seguinte comando:
*/

execute sp_configure 'show advanced options' , 1
go
reconfigure with override 

execute sp_configure 'min server memory (MB)'
execute sp_configure 'max server memory (MB)'

/*
   Na execu��o acima temos 1024Kb de memoria m�nima e  2147483647KB(?) de memoria m�xima.
   2 Tb de mem�ria m�xima? 

   Min Server Memory
   
   - N�o significa mem�ria m�nima que o SQL SERVER utiliza.
   
   - Quando inicializamos o servi�o do SQL Server, ele aloca inicialmente 128Kb e espera as atividades
     de inclus�o, altera��o e exclus�o de dados pela aplica��o. No decorrer da execu��o das consultas, 
     o SQL SERVER carrega os dados do disco e aloca na mem�ria que ele reservou. Essa mem�ria inicial 
     at� atingir o valor de 'Min Server Memory' � do SQL SERVER e ele n�o entrega ao SO, se ele solicitar. 

     Quando a aloca��o ultrapassa esse valor m�nimo, O SQL Server continua a alocar mais mem�ria. Mas se 
     por algum motivo, o SO solicitar mem�ria do SQL Server, o mesmo pode liberar a mem�ria, mas at� 
     atingir o limite m�nimo.

   Max Server Memory
   
   - N�o significa mem�ria m�xima que o SQL SERVER utiliza. 

   - Quando o SQL SERVER continua a realizar a aloca��o de dados do disco para a mem�ria, ele somente 
     realiza as aloca��es at� atingir o valor de 'Max Server Memory'. Se o SQL Server precisar alocar 
     novos dados em memoria, ele come�a grava em discos os dados mais antigos em discos, liberar a area 
     da mem�ria e aloca os novos dados. 

     Se o SO n�o tiver mem�ria suficiente para trabalhar ou para outras aplica��es alocarem seus dados,
     o SO solicita ao SQL Server mem�ria. Se a mem�ria do SQL SERVER reservado n�o estivar alocada com 
     dados, ele libera��o essa mem�ria para o SO. Se esse mem�ria estiver aloca��o, o SQL Server grava
     os dados em disco e libera a memoria para o SO. 

     O SQL Server liberar mem�ria at� atingir o valor de 'Min Server Memory'

     ReF.: https://www.youtube.com/watch?v=OijdLj4lw5c

*/

-- Visualizando memoria total do servidor 

select total_physical_memory_kb / 1024.0     as MemoriaTotal ,
       available_physical_memory_kb / 1024.0 as MemoriaDisponivel 
from sys.dm_os_sys_memory

/*
MemoriaTotal	MemoriaDisponivel
------------   -----------------
 2047.421875	       403.734375
*/


execute sp_configure 'min server memory (MB)' , 512
go
reconfigure with override 
go
execute sp_configure 'max server memory (MB)' , 1536
go
reconfigure with override 

/*
Consultando a quantidade de p�ginas no Buffer Pool ocupada por cada
banco de dados.

Ref.: https://docs.microsoft.com/PT-BR/sql/relational-databases/system-dynamic-management-views/sys-dm-os-buffer-descriptors-transact-sql

*/

select * from sys.dm_os_buffer_descriptors


select db_name(database_id) as BancoDeDados, 
       (count(1) * 8192 ) / 1024 /1024 as nTamanhoPaginas 
  from sys.dm_os_buffer_descriptors
group by db_name(database_id)  
go

use eCommerce
go

select * from tCliente 










/*
3. Lock Page in Memory.

   O Windows Server "ainda" trabalha com o conceito de mem�ria virtual em disco 
   (arquivo de pagina��o) que ele utiliza para paginar dados entre a mem�ria fisica e a virutal.

   O conceito � transferir para o arquivo de pagina��o, dados que est�o em mem�ria mas n�o 
   est�o em utiliza��o pelas aplica��es. Ent�o o Windows transfere esses dados da mem�ria
   f�sica para a mem�ria virtual. Se o dados for acessado pela aplica��o, o Windows ent�o
   carrega os dados da mem�ria virtual e transfere para a mem�ria f�sica, fazendo uma troca 
   com os dados mais antigos em mem�ria. 

   No caso do SQL Server, al�m de armazenar os dados em mem�ria, ele tamb�m armezana informa��es
   sobre as tabelas, planos de execu��o entre outros que podem ser raramente acessados. Com isso,
   eles podem ser enviados para o arquivo de pagina��o.

   Para enviar isso, o Windows tem um mecanismo que impede essa troca de dados. Esse mecanismo
   � uma permiss�o que � concedida a conta do usu�rio que executa o servi�o do SQL SERVER 
   chamado de "Lock Pages in Memory" 

   Demonstra��o:

   - Identificando a conta que executa o servi�o do SQL Server.
   - Conceder a permiss�o.
*/
