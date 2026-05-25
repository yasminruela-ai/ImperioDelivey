-- MySQL dump 10.13  Distrib 8.0.44, for Linux (x86_64)
--
-- Host: mysql-1d9027ca-joaotoledo-bd.e.aivencloud.com    Database: hamburgueria
-- ------------------------------------------------------
-- Server version	8.0.35

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '51ac82df-b369-11f0-80c8-862ccfb03d59:1-1140';

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `idCategorias` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(45) NOT NULL,
  `ativo` tinyint NOT NULL,
  PRIMARY KEY (`idCategorias`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (2,'Lanches',0),(3,'Lanches',1),(4,'Bebidas',1),(5,'Acompanhamentos',1),(6,'Sobremesas',1),(7,'Adicional',1),(8,'Nova',0),(12,'novo3',0),(13,'nova4',0),(14,'novovovoodokaojsoaklÃ§salÃ§sj.laks',0),(15,'shdjhdlkshklsdj',0),(16,'FuncionaPeloAmordeDeus',0),(17,'teste',0),(18,'Test',0);
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estoque`
--

DROP TABLE IF EXISTS `estoque`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estoque` (
  `idEstoque` int NOT NULL AUTO_INCREMENT,
  `qtdAtual` float NOT NULL,
  `qtdMinima` float NOT NULL,
  `ingredientes_idIngredientes` int NOT NULL,
  PRIMARY KEY (`idEstoque`),
  KEY `fk_estoque_ingredientes1_idx` (`ingredientes_idIngredientes`),
  CONSTRAINT `fk_estoque_ingredientes1` FOREIGN KEY (`ingredientes_idIngredientes`) REFERENCES `ingredientes` (`idIngredientes`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estoque`
--

LOCK TABLES `estoque` WRITE;
/*!40000 ALTER TABLE `estoque` DISABLE KEYS */;
INSERT INTO `estoque` VALUES (1,50,10,1),(2,3000,500,2),(3,1500,300,3),(4,800,1000,4),(5,10550,2000,5);
/*!40000 ALTER TABLE `estoque` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ingredientes`
--

DROP TABLE IF EXISTS `ingredientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredientes` (
  `idIngredientes` int NOT NULL AUTO_INCREMENT,
  `ingredientescol` varchar(45) NOT NULL,
  `medida` varchar(2) NOT NULL,
  `ativo` tinyint NOT NULL,
  PRIMARY KEY (`idIngredientes`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredientes`
--

LOCK TABLES `ingredientes` WRITE;
/*!40000 ALTER TABLE `ingredientes` DISABLE KEYS */;
INSERT INTO `ingredientes` VALUES (1,'PÃ£o de HambÃºrguer','un',1),(2,'Carne Bovina','g',1),(3,'Queijo Cheddar','g',1),(4,'Batata Frita','g',1),(5,'Refrigerante Lata','ml',1);
/*!40000 ALTER TABLE `ingredientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `itensVendas`
--

DROP TABLE IF EXISTS `itensVendas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `itensVendas` (
  `idItensVendas` int NOT NULL AUTO_INCREMENT,
  `quantidade` float NOT NULL,
  `precoUnitario` decimal(10,2) NOT NULL,
  `vendas_idVendas` int NOT NULL,
  `produtos_idProdutos` int NOT NULL,
  PRIMARY KEY (`idItensVendas`),
  KEY `fk_itensVendas_vendas1_idx` (`vendas_idVendas`),
  KEY `fk_itensVendas_produtos1_idx` (`produtos_idProdutos`),
  CONSTRAINT `fk_itensVendas_produtos1` FOREIGN KEY (`produtos_idProdutos`) REFERENCES `produtos` (`idProdutos`),
  CONSTRAINT `fk_itensVendas_vendas1` FOREIGN KEY (`vendas_idVendas`) REFERENCES `vendas` (`idVendas`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `itensVendas`
--

LOCK TABLES `itensVendas` WRITE;
/*!40000 ALTER TABLE `itensVendas` DISABLE KEYS */;
INSERT INTO `itensVendas` VALUES (8,3,12.45,4,10),(9,2,6.00,4,11),(12,1,12.45,6,10),(13,1,12.45,7,10),(15,1,12.45,9,10),(16,19,6.00,10,11),(17,2,12.45,11,10),(37,1,12.45,31,10),(38,1,30.99,32,14),(39,1,6.00,32,11),(40,1,15.00,32,12);
/*!40000 ALTER TABLE `itensVendas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `logs` (
  `idLog` int NOT NULL AUTO_INCREMENT,
  `tabela` varchar(100) DEFAULT NULL,
  `operacao` varchar(10) DEFAULT NULL,
  `registroId` int DEFAULT NULL,
  `valoresAntigos` text,
  `valoresNovos` text,
  `usuarioSistema` varchar(100) DEFAULT NULL,
  `dataOperacao` datetime DEFAULT NULL,
  PRIMARY KEY (`idLog`)
) ENGINE=InnoDB AUTO_INCREMENT=484 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs`
--

LOCK TABLES `logs` WRITE;
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissoes`
--

DROP TABLE IF EXISTS `permissoes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissoes` (
  `idPermissoes` int NOT NULL AUTO_INCREMENT,
  `tabela` varchar(45) NOT NULL,
  PRIMARY KEY (`idPermissoes`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissoes`
--

LOCK TABLES `permissoes` WRITE;
/*!40000 ALTER TABLE `permissoes` DISABLE KEYS */;
INSERT INTO `permissoes` VALUES (1,'Pedidos'),(2,'Funcionarios'),(3,'Vendas'),(4,'Produtos'),(5,'Historico');
/*!40000 ALTER TABLE `permissoes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produtos`
--

DROP TABLE IF EXISTS `produtos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `produtos` (
  `idProdutos` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(45) NOT NULL,
  `preco` decimal(10,2) NOT NULL,
  `ativo` tinyint NOT NULL,
  `categorias_idCategorias` int NOT NULL,
  PRIMARY KEY (`idProdutos`),
  KEY `fk_produtos_categorias1_idx` (`categorias_idCategorias`),
  CONSTRAINT `fk_produtos_categorias1` FOREIGN KEY (`categorias_idCategorias`) REFERENCES `categorias` (`idCategorias`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produtos`
--

LOCK TABLES `produtos` WRITE;
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
INSERT INTO `produtos` VALUES (2,'X-Tudo',15.90,0,2),(8,'X-Burguer',18.90,0,2),(9,'X-Salada',20.90,0,2),(10,'Batata Frita Grande',12.45,1,5),(11,'Refrigerante Lata',6.00,1,4),(12,'Milkshake Chocolate',15.00,1,6),(13,'X-Bacon',27.00,1,3),(14,'X-Infarto',30.99,1,3),(15,'X-nivaldo',30.99,1,3);
/*!40000 ALTER TABLE `produtos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produtosIngredientes`
--

DROP TABLE IF EXISTS `produtosIngredientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `produtosIngredientes` (
  `produtos_idProdutos` int NOT NULL,
  `ingredientes_idIngredientes` int NOT NULL,
  `quantidade` float NOT NULL,
  PRIMARY KEY (`produtos_idProdutos`,`ingredientes_idIngredientes`),
  KEY `fk_produtos_has_ingredientes_ingredientes1_idx` (`ingredientes_idIngredientes`),
  KEY `fk_produtos_has_ingredientes_produtos1_idx` (`produtos_idProdutos`),
  CONSTRAINT `fk_produtos_has_ingredientes_ingredientes1` FOREIGN KEY (`ingredientes_idIngredientes`) REFERENCES `ingredientes` (`idIngredientes`),
  CONSTRAINT `fk_produtos_has_ingredientes_produtos1` FOREIGN KEY (`produtos_idProdutos`) REFERENCES `produtos` (`idProdutos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produtosIngredientes`
--

LOCK TABLES `produtosIngredientes` WRITE;
/*!40000 ALTER TABLE `produtosIngredientes` DISABLE KEYS */;
INSERT INTO `produtosIngredientes` VALUES (2,1,1),(2,2,150),(2,3,50),(2,4,50),(2,5,30),(8,1,1),(8,2,150),(8,3,50),(9,1,1),(9,2,150),(9,3,50),(10,4,200),(11,5,350),(12,3,50);
/*!40000 ALTER TABLE `produtosIngredientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `idUsuarios` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(45) NOT NULL,
  `login` varchar(45) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `ativo` tinyint NOT NULL,
  PRIMARY KEY (`idUsuarios`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'JoÃ£o','joao','123',1),(3,'teste','testeteste','$2b$10$svEDKc19.1J4BfSOIMhGa.noiyrkWYqm6HHSE/hx8.jQVkwgb4eTS',1),(10,'teste5','teste5','$2b$10$0RrVjaJO51oPWDlCiaK80eZRdkzpoebL.m./0e54xHOXQTMOkTKdq',1),(11,'teste6','teste6','$2b$10$W0niqeBD82WTDxmEVw/qJuJR.luSri7k5DJWVqtuCdfrTzyLoFnhi',1),(12,'teste10','teste10','$2b$10$MQhuyiFN82H89qXF0k.P0e0/5JODjJiGiZFlCBMaRRSXjTYF5J.oy',1),(13,'Pedro de Freitas da Silva','PedroFreitas','$2b$10$3jva.2.xp6JQ0l9xAmih9eIN1tf9OL1RhrfSVOL.g7JsALVgBq2BW',1);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuariosPermissoes`
--

DROP TABLE IF EXISTS `usuariosPermissoes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuariosPermissoes` (
  `usuarios_idUsuarios` int NOT NULL,
  `permissoes_idPermissoes` int NOT NULL,
  `permisaoSelect` tinyint NOT NULL,
  `permisaoInsert` tinyint NOT NULL,
  `permisaoUpdate` tinyint NOT NULL,
  `permisaoDelete` tinyint NOT NULL,
  PRIMARY KEY (`usuarios_idUsuarios`,`permissoes_idPermissoes`),
  KEY `fk_usuarios_has_permissoes_permissoes1_idx` (`permissoes_idPermissoes`),
  KEY `fk_usuarios_has_permissoes_usuarios_idx` (`usuarios_idUsuarios`),
  CONSTRAINT `fk_usuarios_has_permissoes_permissoes1` FOREIGN KEY (`permissoes_idPermissoes`) REFERENCES `permissoes` (`idPermissoes`),
  CONSTRAINT `fk_usuarios_has_permissoes_usuarios` FOREIGN KEY (`usuarios_idUsuarios`) REFERENCES `usuarios` (`idUsuarios`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuariosPermissoes`
--

LOCK TABLES `usuariosPermissoes` WRITE;
/*!40000 ALTER TABLE `usuariosPermissoes` DISABLE KEYS */;
INSERT INTO `usuariosPermissoes` VALUES (1,1,1,1,1,1),(1,2,1,1,1,1),(1,3,1,1,1,1),(1,4,1,1,1,1),(1,5,1,1,1,1),(10,1,1,0,0,0),(10,2,0,0,0,0),(10,3,1,0,0,0),(10,4,1,1,1,1),(10,5,1,0,0,0),(11,1,0,0,0,0),(11,2,0,0,0,0),(11,3,0,0,0,0),(11,4,0,0,0,0),(11,5,0,0,0,0),(12,1,0,0,0,0),(12,2,0,0,0,0),(12,3,0,0,0,0),(12,4,0,0,0,0),(12,5,0,0,0,0),(13,1,1,1,1,1),(13,2,1,1,1,1),(13,3,1,1,1,1),(13,4,1,1,1,1),(13,5,1,0,0,0);
/*!40000 ALTER TABLE `usuariosPermissoes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendas`
--

DROP TABLE IF EXISTS `vendas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendas` (
  `idVendas` int NOT NULL AUTO_INCREMENT,
  `dataVenda` datetime NOT NULL,
  `status` varchar(45) NOT NULL,
  `usuarios_idUsuarios` int NOT NULL,
  `nome` varchar(45) NOT NULL,
  PRIMARY KEY (`idVendas`),
  KEY `fk_vendas_usuarios1_idx` (`usuarios_idUsuarios`),
  CONSTRAINT `fk_vendas_usuarios1` FOREIGN KEY (`usuarios_idUsuarios`) REFERENCES `usuarios` (`idUsuarios`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendas`
--

LOCK TABLES `vendas` WRITE;
/*!40000 ALTER TABLE `vendas` DISABLE KEYS */;
INSERT INTO `vendas` VALUES (4,'2025-11-16 19:51:43','pago',1,'joao'),(6,'2025-11-18 23:50:40','pago',10,'Rui'),(7,'2025-11-19 00:59:53','cancelado',10,'a'),(9,'2025-11-19 03:15:01','pendente',10,'sfddds'),(10,'2025-11-19 18:04:13','pendente',1,'yasmin'),(11,'2025-11-19 18:04:56','pendente',1,'Pedro'),(31,'2025-11-19 19:24:50','pago',1,'Pedro'),(32,'2025-11-19 23:11:22','pago',13,'Gustavo');
/*!40000 ALTER TABLE `vendas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vwCategoriaVenda`
--

DROP TABLE IF EXISTS `vwCategoriaVenda`;
/*!50001 DROP VIEW IF EXISTS `vwCategoriaVenda`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vwCategoriaVenda` AS SELECT 
 1 AS `mesAno`,
 1 AS `idCategoria`,
 1 AS `categoria`,
 1 AS `quantidadeVendida`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwQuantidadeVenda`
--

DROP TABLE IF EXISTS `vwQuantidadeVenda`;
/*!50001 DROP VIEW IF EXISTS `vwQuantidadeVenda`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vwQuantidadeVenda` AS SELECT 
 1 AS `dataVenda`,
 1 AS `quantidadeVendida`,
 1 AS `valorTotalDia`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwVendaMes`
--

DROP TABLE IF EXISTS `vwVendaMes`;
/*!50001 DROP VIEW IF EXISTS `vwVendaMes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vwVendaMes` AS SELECT 
 1 AS `mesAno`,
 1 AS `totalVendas`,
 1 AS `quantidadeTotalVendida`,
 1 AS `valorTotalVendido`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwVendaUsuario`
--

DROP TABLE IF EXISTS `vwVendaUsuario`;
/*!50001 DROP VIEW IF EXISTS `vwVendaUsuario`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vwVendaUsuario` AS SELECT 
 1 AS `mesAno`,
 1 AS `idUsuarios`,
 1 AS `usuario`,
 1 AS `quantidadeVendida`,
 1 AS `valorTotalVendido`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vwCategoriaVenda`
--

/*!50001 DROP VIEW IF EXISTS `vwCategoriaVenda`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `vwCategoriaVenda` AS select date_format(`v`.`dataVenda`,'%Y-%m') AS `mesAno`,`c`.`idCategorias` AS `idCategoria`,`c`.`nome` AS `categoria`,sum(`iv`.`quantidade`) AS `quantidadeVendida` from (((`vendas` `v` join `itensVendas` `iv` on((`v`.`idVendas` = `iv`.`vendas_idVendas`))) join `produtos` `p` on((`iv`.`produtos_idProdutos` = `p`.`idProdutos`))) join `categorias` `c` on((`p`.`categorias_idCategorias` = `c`.`idCategorias`))) group by date_format(`v`.`dataVenda`,'%Y-%m'),`c`.`idCategorias`,`c`.`nome` order by `mesAno`,`categoria` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwQuantidadeVenda`
--

/*!50001 DROP VIEW IF EXISTS `vwQuantidadeVenda`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `vwQuantidadeVenda` AS select cast(`v`.`dataVenda` as date) AS `dataVenda`,sum(`iv`.`quantidade`) AS `quantidadeVendida`,round(sum((`iv`.`quantidade` * `iv`.`precoUnitario`)),2) AS `valorTotalDia` from (`vendas` `v` join `itensVendas` `iv` on((`v`.`idVendas` = `iv`.`vendas_idVendas`))) group by cast(`v`.`dataVenda` as date) order by `dataVenda` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwVendaMes`
--

/*!50001 DROP VIEW IF EXISTS `vwVendaMes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `vwVendaMes` AS select date_format(`v`.`dataVenda`,'%Y-%m') AS `mesAno`,count(distinct `v`.`idVendas`) AS `totalVendas`,sum(`iv`.`quantidade`) AS `quantidadeTotalVendida`,round(sum((`iv`.`quantidade` * `iv`.`precoUnitario`)),2) AS `valorTotalVendido` from (`vendas` `v` join `itensVendas` `iv` on((`v`.`idVendas` = `iv`.`vendas_idVendas`))) group by date_format(`v`.`dataVenda`,'%Y-%m') order by `mesAno` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwVendaUsuario`
--

/*!50001 DROP VIEW IF EXISTS `vwVendaUsuario`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=CURRENT_USER SQL SECURITY DEFINER */
/*!50001 VIEW `vwVendaUsuario` AS select date_format(`v`.`dataVenda`,'%Y-%m') AS `mesAno`,`u`.`idUsuarios` AS `idUsuarios`,`u`.`nome` AS `usuario`,sum(`iv`.`quantidade`) AS `quantidadeVendida`,round(sum((`iv`.`quantidade` * `iv`.`precoUnitario`)),2) AS `valorTotalVendido` from ((`vendas` `v` join `itensVendas` `iv` on((`v`.`idVendas` = `iv`.`vendas_idVendas`))) join `usuarios` `u` on((`v`.`usuarios_idUsuarios` = `u`.`idUsuarios`))) group by date_format(`v`.`dataVenda`,'%Y-%m'),`u`.`idUsuarios` order by `mesAno`,`usuario` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-22 21:48:08
