-- =====================================================================
-- PROJETO DE BANCO DE DADOS: ACAI SELECT FROM PARADISE
-- Adaptacao da aula pratica de vendas para o nosso Minimundo
-- =====================================================================

-- Apaga o banco caso ele ja exista para poder criar novamente
DROP DATABASE IF EXISTS AcaiSelectDB;

-- Criando o banco de dados da loja de acai
CREATE DATABASE AcaiSelectDB;
USE AcaiSelectDB;

-- =====================================================================
-- 1. TABELA CLIENTE
-- Guarda os dados dos clientes, que fazem pedidos na loja
-- =====================================================================
CREATE TABLE Cliente (
    idCliente INT UNSIGNED NOT NULL PRIMARY KEY,
    nome VARCHAR(125) NOT NULL,
    telefone VARCHAR(15) NOT NULL
);

-- =====================================================================
-- 2. TABELA FUNCIONARIO
-- Identifica os funcionarios da loja, como gerente e atendente.
-- O atendente pode ser associado aos pedidos que registra
-- =====================================================================
CREATE TABLE Funcionario (
    idFuncionario INT UNSIGNED NOT NULL PRIMARY KEY,
    nome VARCHAR(125) NOT NULL,
    cargo VARCHAR(30) NOT NULL
);

-- =====================================================================
-- 3. TABELA PRODUTO
-- Guarda os acais e acompanhamentos disponiveis.
-- Tambem guarda o preco e a quantidade em estoque
-- Para os acompanhamentos, tamanho e sabor podem ficar vazios (NULL).
-- =====================================================================
CREATE TABLE Produto (
    idProduto INT UNSIGNED NOT NULL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    tamanho VARCHAR(20),
    sabor VARCHAR(50),
    preco DECIMAL(10,2) NOT NULL,
    quantidadeEstoque INT NOT NULL
);

-- =====================================================================
-- 4. TABELA PEDIDO
-- Um cliente pode realizar varios pedidos (relacao 1:N).
-- Cada pedido guarda a data o cliente, o atendente e o valor total.
-- idCliente e idFuncionario sao chaves estrangeiras (FK).
-- =====================================================================
CREATE TABLE Pedido (
    idPedido INT UNSIGNED NOT NULL PRIMARY KEY,
    dataPedido DATE NOT NULL,
    valorTotal DECIMAL(10,2) NOT NULL,
    idCliente INT UNSIGNED NOT NULL,
    idFuncionario INT UNSIGNED NOT NULL,

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),

    CONSTRAINT fk_pedido_funcionario
        FOREIGN KEY (idFuncionario) REFERENCES Funcionario(idFuncionario)
);

-- =====================================================================
-- 5. TABELA ITEM_PEDIDO (1a FORMA NORMAL - 1FN)
-- Um pedido pode conter mais de um produto ou acompanhamento.
-- Por isso, em vez de criar produto1, produto2, produto3 no Pedido,
-- usamos esta tabela para registrar cada produto e sua quantidade.
-- A chave primaria junta idPedido e idProduto
-- =====================================================================
CREATE TABLE ItemPedido (
    idPedido INT UNSIGNED NOT NULL,
    idProduto INT UNSIGNED NOT NULL,
    quantidade INT NOT NULL,

    PRIMARY KEY (idPedido, idProduto),

    CONSTRAINT fk_item_pedido
        FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido),

    CONSTRAINT fk_item_produto
        FOREIGN KEY (idProduto) REFERENCES Produto(idProduto)
);

-- =====================================================================
-- 6. CADASTRANDO OS DADOS (INSERT)
-- Primeiro cadastramos os clientes, funcionarios e produtos.
-- Depois os pedidos e os produtos de cada pedido.
-- =====================================================================

-- Cadastrando os clientes:
INSERT INTO Cliente (idCliente, nome, telefone) VALUES
(1, 'Carlos Eduardo Silva', '84999990001'),
(2, 'Maria Fernanda Oliveira', '84999990002'),
(3, 'Joao Pedro Santos', '84999990003');

-- Cadastrando o gerente e o atendente
INSERT INTO Funcionario (idFuncionario, nome, cargo) VALUES
(1, 'Ana Paula', 'Gerente'),
(2, 'Pedro Henrique', 'Atendente');

-- Cadastrando os acais e acompanhamentos:
INSERT INTO Produto
(idProduto, nome, tipo, tamanho, sabor, preco, quantidadeEstoque) VALUES
(1, 'Acai Tradicional', 'Acai', '300ml', 'Tradicional', 12.00, 40),
(2, 'Acai Tradicional', 'Acai', '500ml', 'Tradicional', 18.00, 30),
(3, 'Acai com Cupuacu', 'Acai', '300ml', 'Cupuacu', 14.00, 25),
(4, 'Granola', 'Acompanhamento', NULL, NULL, 3.00, 20),
(5, 'Leite em po', 'Acompanhamento', NULL, NULL, 2.50, 15),
(6, 'Chocolate', 'Acompanhamento', NULL, NULL, 3.50, 8);

-- Cadastrando os pedidos (registrados pelo atendente de ID 2):
INSERT INTO Pedido
(idPedido, dataPedido, valorTotal, idCliente, idFuncionario) VALUES
(101, '2026-03-01', 27.00, 1, 2),
(102, '2026-03-02', 20.50, 1, 2),
(103, '2026-03-05', 17.50, 2, 2);

-- Produtos escolhidos em cada pedido:
-- Pedido 101: 2 acais de 300ml e 1 granola = R$ 27,00.
-- Pedido 102: 1 acai de 500ml e 1 leite em po = R$ 20,50.
-- Pedido 103: 1 acai com cupuacu e 1 chocolate = R$ 17,50.
INSERT INTO ItemPedido (idPedido, idProduto, quantidade) VALUES
(101, 1, 2),
(101, 4, 1),
(102, 2, 1),
(102, 5, 1),
(103, 3, 1),
(103, 6, 1);

-- O cliente Joao Pedro esta cadastrado mas ainda nao fez pedidos
-- Isso ajuda a mostrar a diferenca entre INNER JOIN e LEFT JOIN

-- =====================================================================
-- 7. TESTE DE CHAVE ESTRANGEIRA (EXEMPLO)
-- Este INSERT esta comentado porque o cliente 99 nao existe.
-- Se tentarmos executar o banco vai impedir o cadastro do pedido.
-- =====================================================================
-- INSERT INTO Pedido
-- (idPedido, dataPedido, valorTotal, idCliente, idFuncionario)
-- VALUES (104, '2026-03-10', 12.00, 99, 2);

-- =====================================================================
-- 8. CONSULTANDO OS DADOS (SELECT E JOIN)
-- =====================================================================

-- CONSULTA 1: Mostrar todos os clientes cadastrados.
SELECT * FROM Cliente;

-- Mostrar somente o codigo e o nome dos clientes
SELECT idCliente, nome FROM Cliente;

-- Mostrar com nomes mais faceis de ler.
SELECT idCliente AS 'Codigo do Cliente', nome AS 'Nome' FROM Cliente;

-- CONSULTA 2: Mostrar todos os pedidos cadastrados.
SELECT * FROM Pedido;

-- CONSULTA 3: Mostrar os produtos da loja, seus precos e estoque.
SELECT nome, tipo, tamanho, sabor, preco, quantidadeEstoque FROM Produto;

-- CONSULTA 4: INNER JOIN
-- Mostra os pedidos e os nomes dos clientes que os fizeram.
SELECT
    p.idPedido AS 'Codigo do Pedido',
    p.dataPedido AS 'Data da Compra',
    c.nome AS 'Nome do Cliente',
    p.valorTotal AS 'Valor Total'
FROM Pedido p
INNER JOIN Cliente c ON p.idCliente = c.idCliente;

-- CONSULTA 5: LEFT JOIN
-- Mostra todos os clientes ate os que ainda nao fizeram pedidos.
SELECT
    c.idCliente AS 'ID Cliente',
    c.nome AS 'Nome do Cliente',
    p.idPedido AS 'Codigo do Pedido',
    p.dataPedido AS 'Data'
FROM Cliente c
LEFT JOIN Pedido p ON c.idCliente = p.idCliente;

-- CONSULTA 6: Mostrar os produtos escolhidos em cada pedido.
SELECT
    i.idPedido AS 'Pedido',
    pr.nome AS 'Produto',
    pr.tamanho AS 'Tamanho',
    i.quantidade AS 'Quantidade'
FROM ItemPedido i
INNER JOIN Produto pr ON i.idProduto = pr.idProduto;

-- CONSULTA 7: Mostrar produtos com pouco estoque (10 ou menos).
-- Assim a loja consegue identificar o que precisa ser reposto
SELECT nome, quantidadeEstoque
FROM Produto
WHERE quantidadeEstoque <= 10;

