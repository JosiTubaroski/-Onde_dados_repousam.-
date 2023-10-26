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

# Menória da instância do SQL Server. A configuração ideal!

Vamos começar com a seguinte pergunta:

É mais rápido acessar os dados em memória ou em disco?

A sua resposta já diz por que o SQL Server deve ter memória suficiente para atender a carga de dados.

Menória.

 - Quanto mais, melhor. Memória será utilizada para carregar os dados que estão em disco para uma área no SQL Server conhecida como Buffer Pool.

 - Quanto mais dados o SQL Server conseguir manter em memória, melhor. Servidores com 16Gb, 32GB ou 64GB atende a maioria das demandas. Mas encontramos
   instalações que chegam a mais de 512Gb de memória.

   Apesar da recomendação mínima da Microsoft para memória do SQL Server é de 1Gb, eu recomendo iniciar com 4Gb, mas o correto deve ser a anãlise do
   ambiente para um melhor dimensionamento.

### SQL Server

Buffer Pool ou Buffer Cache.

Um buffer é uma área de 8Kbytes na mémoria onde o SQL Server armazena as páginas de dados lidas dos objetos de alocação que estão no disco
(papel do Gerenciador de Buffer).

O dado permanece no buffer até que o Gerenciador de Buffer precise de mais áreas para carregar novas páginas de dados. As áreas de buffer
mais antigas e com dados modificados são gravados em discos e liberados para as novas paginas.

Quando o SQL Server necessita de um dado e o mesmo está no buffer, ele faz uma leitura lógica desse dado. Se o dado não estiver no buffer, o SQL Server
faz uma leitura física do dado em disco para o buffer pool.

A área de memória onde fica o Buffer Pool é configurada no SQL Server como Min Server Memory e Max Server Memory.

Configurando a memória no SQL Server

  Quando instalamos o SQL Server, ele configura automáticamente a utilização da memória disponível no servidor. Ele tem as opções de "Max Server Memory"
  e "Min Server Memory" que voce pode consulta com o com o seguinte comando

  execute sp_configure 'show advanced options' , 1
go
reconfigure with override 

execute sp_configure 'min server memory (MB)'
execute sp_configure 'max server memory (MB)'
   
Na execução acima temos 1024Kb de memoria mínima e 2147483647KB(?) de memoria máxima.
2 Tb de memória máxima?

Min Server Memory

- Não significa memória mínima que o SQl Server utiliza.

- Quando inicializamos o serviço do SQL Server, ele aloca inicialmente 128Kb e espera as atividades de inclusão, alteração e exclusão de dados pela
  aplicação. No decorrer da execução das consultas, o SQL Server carrega os dados do disco e aloca na memoria que ele reservou. Essa memória inicial
  até atingir o valor de 'Min Server Memory' é do SQL SERVER e ele não entrega ao SO, se ele solicitar.

  Quando a alocação ultrapassa esse valor mínimo, o SQL Server continua a alocar mais memória. Mas se por algum motivo, o SO solicitar memória
  do SQL Server, o mesmo pode liberar a memória, mas até atingir o limite minimo.

Max Server Memory

 - Não significa memória máxima que o SQL SERVER utiliza.
 - Quando o SQL SERVER continua a realizar a alocação de dados do disco para a memória, ele somente realiza as até atingir o valor 'Max Server Memory'.
   Se o SQL Server precisar alocar novos dados em memoria, ele começa a gravar em disco os dados mais antigos em disco, liberar a area da memória e alocar
   os novos dados.

   Se o SO não tiver memória suficiente para trabalhar ou para outras aplicações alocarem seus dados, o SO solicita ao SQL Server memória. Se a memória do SQL
   Server reservado não estiver alocado, o SQL Server grava os dados em disco e libera a memoria para o SO.

   O SQL Server liberar memória até atingir o valor de 'Min Server Memory'

   ReF.: https://www.youtube.com/watch?v=OijdLj4lw5c

   👇Para saber mais.

   https://github.com/JosiTubaroski/-Onde_dados_repousam.-/edit/main/02%20-%20Arquitetura%20da%20Memoria.sql


   
  

  
    
