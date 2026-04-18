-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: shakeel_traders
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` int unsigned DEFAULT NULL,
  `old_value` json DEFAULT NULL,
  `new_value` json DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`,`created_at`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_action` (`action`),
  CONSTRAINT `fk_al_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (1,1,'CONVERT_ORDER_TO_BILL','orders',1,NULL,'{\"billId\": 1, \"billNumber\": \"OB-2026-04-00001\"}',NULL,'2026-04-04 22:17:05'),(2,1,'RECORD_DELIVERY_MAN_COLLECTION','delivery_man_collections',1,NULL,NULL,NULL,'2026-04-04 22:20:12'),(3,1,'ASSIGN_RECOVERY_BILLS','bill_recovery_assignments',NULL,NULL,'{\"billIds\": [\"1\"], \"bookerId\": \"2\"}',NULL,'2026-04-04 22:20:29'),(4,1,'VERIFY_RECOVERY','recovery_collections',1,NULL,NULL,NULL,'2026-04-04 22:41:22'),(5,1,'RECORD_SHOP_ADVANCE','shop_advances',7,NULL,'{\"amount\": 50000, \"shopId\": 2, \"advance_date\": \"2026-04-04\", \"payment_method\": \"cash\"}',NULL,'2026-04-04 22:56:14'),(6,1,'APPROVE_ISSUANCE','salesman_issuances',1,NULL,NULL,NULL,'2026-04-04 23:52:31'),(7,1,'MIDNIGHT_CRON_RETURN','bill_recovery_assignments',NULL,NULL,'{\"ran_at\": \"2026-04-04T19:00:00.138Z\", \"returned_count\": 1}',NULL,'2026-04-05 00:00:00'),(8,1,'APPROVE_RETURN','salesman_returns',3,NULL,'{\"final_sale_value\": 2064}',NULL,'2026-04-05 00:01:32'),(9,1,'RECORD_SALARY','salary_records',NULL,NULL,'{\"year\": \"2026\", \"month\": \"4\", \"amount\": \"45000\", \"staffId\": \"3\", \"staffType\": \"salesman\"}',NULL,'2026-04-05 00:02:59'),(10,1,'RECORD_SALARY_ADVANCE','salary_advances',1,NULL,NULL,NULL,'2026-04-05 00:03:09'),(11,1,'RECORD_SALARY_ADVANCE','salary_advances',2,NULL,NULL,NULL,'2026-04-05 00:03:20'),(12,1,'CREATE_DIRECT_SALE','bills',2,NULL,'{\"billNumber\": \"DS-2026-04-00001\"}',NULL,'2026-04-05 00:05:19'),(13,1,'RECORD_DELIVERY_MAN_COLLECTION','delivery_man_collections',2,NULL,NULL,NULL,'2026-04-05 00:15:47'),(14,1,'APPROVE_ISSUANCE','salesman_issuances',2,NULL,NULL,NULL,'2026-04-09 23:57:06'),(15,1,'APPROVE_RETURN','salesman_returns',4,NULL,'{\"final_sale_value\": 1272}',NULL,'2026-04-10 00:00:43'),(16,1,'APPROVE_ISSUANCE','salesman_issuances',3,NULL,NULL,NULL,'2026-04-10 00:34:11'),(17,1,'APPROVE_RETURN','salesman_returns',5,NULL,'{\"final_sale_value\": 3927}',NULL,'2026-04-10 00:35:42'),(18,1,'APPROVE_ISSUANCE','salesman_issuances',4,NULL,NULL,NULL,'2026-04-10 00:45:20'),(19,1,'APPROVE_RETURN','salesman_returns',6,NULL,'{\"final_sale_value\": 1272}',NULL,'2026-04-10 00:46:50'),(20,1,'APPROVE_ISSUANCE','salesman_issuances',5,NULL,NULL,NULL,'2026-04-10 01:16:07'),(21,1,'APPROVE_RETURN','salesman_returns',7,NULL,'{\"final_sale_value\": 1294}',NULL,'2026-04-10 01:17:14'),(22,1,'APPROVE_ISSUANCE','salesman_issuances',6,NULL,NULL,NULL,'2026-04-10 01:39:26'),(23,1,'APPROVE_RETURN','salesman_returns',8,NULL,'{\"final_sale_value\": 481}',NULL,'2026-04-10 01:40:36'),(24,1,'CONVERT_ORDER_TO_BILL','orders',2,NULL,'{\"billId\": 3, \"billNumber\": \"OB-2026-04-00002\"}',NULL,'2026-04-10 01:57:42'),(25,1,'CONVERT_ORDER_TO_BILL','orders',3,NULL,'{\"billId\": 4, \"billNumber\": \"OB-2026-04-00003\"}',NULL,'2026-04-10 01:57:57'),(26,1,'RECORD_DELIVERY_MAN_COLLECTION','delivery_man_collections',3,NULL,NULL,NULL,'2026-04-10 02:00:13'),(27,1,'RECORD_DELIVERY_MAN_COLLECTION','delivery_man_collections',4,NULL,NULL,NULL,'2026-04-10 02:01:02'),(28,1,'ASSIGN_RECOVERY_BILLS','bill_recovery_assignments',NULL,NULL,'{\"billIds\": [\"1\"], \"bookerId\": \"2\"}',NULL,'2026-04-10 02:01:49'),(29,1,'VERIFY_RECOVERY','recovery_collections',2,NULL,NULL,NULL,'2026-04-10 02:03:13'),(30,1,'ASSIGN_RECOVERY_BILLS','bill_recovery_assignments',NULL,NULL,'{\"billIds\": [\"3\"], \"bookerId\": \"7\"}',NULL,'2026-04-10 02:20:04'),(31,1,'VERIFY_RECOVERY','recovery_collections',3,NULL,NULL,NULL,'2026-04-10 02:23:06'),(32,1,'RECORD_SALARY','salary_records',NULL,NULL,'{\"year\": \"2026\", \"month\": \"4\", \"amount\": \"2000\", \"staffId\": \"3\", \"staffType\": \"salesman\"}',NULL,'2026-04-10 18:36:08'),(33,1,'CONVERT_ORDER_TO_BILL','orders',6,NULL,'{\"billId\": 5, \"billNumber\": \"OB-2026-04-00004\"}',NULL,'2026-04-10 18:53:09'),(34,1,'CONVERT_ORDER_TO_BILL','orders',5,NULL,'{\"billId\": 6, \"billNumber\": \"OB-2026-04-00005\"}',NULL,'2026-04-10 18:53:25'),(35,1,'CONVERT_ORDER_TO_BILL','orders',4,NULL,'{\"billId\": 7, \"billNumber\": \"OB-2026-04-00006\"}',NULL,'2026-04-10 18:53:29'),(36,1,'MIDNIGHT_CRON_RETURN','bill_recovery_assignments',NULL,NULL,'{\"ran_at\": \"2026-04-10T19:00:00.150Z\", \"returned_count\": 2}',NULL,'2026-04-11 00:00:00'),(37,1,'RECORD_SHOP_ADVANCE','shop_advances',8,NULL,'{\"amount\": 200, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:36:47'),(38,1,'RECORD_SHOP_ADVANCE','shop_advances',9,NULL,'{\"amount\": 200, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:36:52'),(39,1,'RECORD_SHOP_ADVANCE','shop_advances',10,NULL,'{\"amount\": 200, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:36:57'),(40,1,'RECORD_SHOP_ADVANCE','shop_advances',11,NULL,'{\"amount\": 200, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:37:01'),(41,1,'RECORD_SHOP_ADVANCE','shop_advances',12,NULL,'{\"amount\": 200, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:37:14'),(42,1,'RECORD_SHOP_ADVANCE','shop_advances',13,NULL,'{\"amount\": 200, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:37:18'),(43,1,'RECORD_SHOP_ADVANCE','shop_advances',14,NULL,'{\"amount\": 200, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:37:22'),(44,1,'RECORD_SHOP_ADVANCE','shop_advances',15,NULL,'{\"amount\": 300, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:37:25'),(45,1,'RECORD_SHOP_ADVANCE','shop_advances',16,NULL,'{\"amount\": 200, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:37:29'),(46,1,'RECORD_SHOP_ADVANCE','shop_advances',17,NULL,'{\"amount\": 2, \"shopId\": 1, \"advance_date\": \"2026-04-10\", \"payment_method\": \"cash\"}',NULL,'2026-04-11 00:37:34'),(47,1,'CREATE_DIRECT_SALE','bills',8,NULL,'{\"billNumber\": \"DS-2026-04-00002\"}',NULL,'2026-04-11 01:04:24'),(48,1,'CREATE_DIRECT_SALE','bills',9,NULL,'{\"billNumber\": \"DS-2026-04-00003\"}',NULL,'2026-04-11 01:09:01'),(49,1,'CREATE_DIRECT_SALE','bills',10,NULL,'{\"billNumber\": \"DS-2026-04-00004\"}',NULL,'2026-04-11 01:09:49'),(50,1,'RECORD_STOCK_RECEIPT','stock_receipts',1,NULL,'{\"companyId\": \"1\", \"totalValue\": 1215}',NULL,'2026-04-11 01:12:42'),(51,1,'RECORD_STOCK_RECEIPT','stock_receipts',2,NULL,'{\"companyId\": \"1\", \"totalValue\": 480}',NULL,'2026-04-11 01:16:29'),(52,1,'CREATE_DIRECT_SALE','bills',11,NULL,'{\"billNumber\": \"DS-2026-04-00005\"}',NULL,'2026-04-18 15:40:25');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bill_items`
--

DROP TABLE IF EXISTS `bill_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bill_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `cartons` int unsigned NOT NULL DEFAULT '0',
  `loose_units` int unsigned NOT NULL DEFAULT '0',
  `unit_price` decimal(10,2) NOT NULL,
  `line_total` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_bill` (`bill_id`),
  KEY `fk_bi_product` (`product_id`),
  CONSTRAINT `fk_bi_bill` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`),
  CONSTRAINT `fk_bi_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill_items`
--

LOCK TABLES `bill_items` WRITE;
/*!40000 ALTER TABLE `bill_items` DISABLE KEYS */;
INSERT INTO `bill_items` VALUES (1,1,1,12,0,15.00,4320.00),(2,1,2,15,0,10.00,7200.00),(3,1,3,2,0,12.00,864.00),(4,2,1,2,0,12.00,576.00),(5,2,3,3,0,12.00,1296.00),(6,3,1,1,2,15.00,390.00),(7,3,2,1,2,10.00,500.00),(8,3,3,1,2,12.00,456.00),(9,4,1,0,2,15.00,30.00),(10,4,2,0,2,10.00,20.00),(11,4,3,0,2,12.00,24.00),(12,5,1,1,11,15.00,525.00),(13,5,2,0,12,10.00,120.00),(14,5,3,0,12,12.00,144.00),(15,6,1,0,12,15.00,180.00),(16,6,2,0,2,10.00,20.00),(17,6,3,0,2,12.00,24.00),(18,7,1,0,2,15.00,30.00),(19,7,2,0,2,10.00,20.00),(20,7,3,0,2,12.00,24.00),(21,8,2,1,1,10.00,490.00),(22,8,3,0,2,12.00,24.00),(23,9,1,20,0,15.00,7200.00),(24,10,1,4,0,15.00,1440.00),(25,11,1,0,6,100.00,600.00);
/*!40000 ALTER TABLE `bill_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bill_recovery_assignments`
--

DROP TABLE IF EXISTS `bill_recovery_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bill_recovery_assignments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` int unsigned NOT NULL,
  `assigned_to_booker_id` int unsigned NOT NULL,
  `assigned_date` date NOT NULL,
  `assigned_by` int unsigned NOT NULL,
  `status` enum('assigned','partially_recovered','fully_recovered','returned_to_pool') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'assigned',
  `assigned_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `returned_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_bill` (`bill_id`),
  KEY `idx_booker_date` (`assigned_to_booker_id`,`assigned_date`),
  KEY `idx_status` (`status`),
  KEY `idx_assigned_date` (`assigned_date`),
  KEY `fk_bra_assigner` (`assigned_by`),
  CONSTRAINT `fk_bra_assigner` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_bra_bill` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`),
  CONSTRAINT `fk_bra_booker` FOREIGN KEY (`assigned_to_booker_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill_recovery_assignments`
--

LOCK TABLES `bill_recovery_assignments` WRITE;
/*!40000 ALTER TABLE `bill_recovery_assignments` DISABLE KEYS */;
INSERT INTO `bill_recovery_assignments` VALUES (1,1,2,'2026-04-04',1,'returned_to_pool','2026-04-04 22:20:29','2026-04-05 00:00:00'),(2,1,2,'2026-04-09',1,'returned_to_pool','2026-04-10 02:01:49','2026-04-11 00:00:00'),(3,3,7,'2026-04-09',1,'returned_to_pool','2026-04-10 02:20:04','2026-04-11 00:00:00');
/*!40000 ALTER TABLE `bill_recovery_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bills`
--

DROP TABLE IF EXISTS `bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bills` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned DEFAULT NULL,
  `shop_id` int unsigned NOT NULL,
  `bill_type` enum('order_booker','direct_shop','salesman') COLLATE utf8mb4_unicode_ci NOT NULL,
  `bill_date` date NOT NULL,
  `bill_number` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gross_amount` decimal(12,2) NOT NULL,
  `advance_deducted` decimal(12,2) NOT NULL DEFAULT '0.00',
  `net_amount` decimal(12,2) NOT NULL,
  `amount_paid` decimal(12,2) NOT NULL DEFAULT '0.00',
  `outstanding_amount` decimal(12,2) NOT NULL,
  `status` enum('open','partially_paid','cleared') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `created_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_bill_number` (`bill_number`),
  KEY `idx_shop_status` (`shop_id`,`status`),
  KEY `idx_bill_type` (`bill_type`),
  KEY `idx_bill_date` (`bill_date`),
  KEY `idx_status` (`status`),
  KEY `fk_bill_order` (`order_id`),
  KEY `fk_bill_created_by` (`created_by`),
  CONSTRAINT `fk_bill_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_bill_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_bill_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bills`
--

LOCK TABLES `bills` WRITE;
/*!40000 ALTER TABLE `bills` DISABLE KEYS */;
INSERT INTO `bills` VALUES (1,1,2,'order_booker','2026-04-04','OB-2026-04-00001',12384.00,0.00,12384.00,9299.00,3085.00,'partially_paid',1,'2026-04-04 22:17:05'),(2,NULL,1,'direct_shop','2026-04-04','DS-2026-04-00001',1872.00,0.00,1872.00,1872.00,0.00,'cleared',1,'2026-04-05 00:05:19'),(3,2,3,'order_booker','2026-04-09','OB-2026-04-00002',1346.00,0.00,1346.00,200.00,1146.00,'partially_paid',1,'2026-04-10 01:57:42'),(4,3,1,'order_booker','2026-04-09','OB-2026-04-00003',74.00,0.00,74.00,74.00,0.00,'cleared',1,'2026-04-10 01:57:57'),(5,6,1,'order_booker','2026-04-10','OB-2026-04-00004',789.00,0.00,789.00,0.00,789.00,'open',1,'2026-04-10 18:53:09'),(6,5,2,'order_booker','2026-04-10','OB-2026-04-00005',224.00,224.00,0.00,0.00,0.00,'open',1,'2026-04-10 18:53:25'),(7,4,3,'order_booker','2026-04-10','OB-2026-04-00006',74.00,0.00,74.00,0.00,74.00,'open',1,'2026-04-10 18:53:29'),(8,NULL,2,'direct_shop','2026-04-10','DS-2026-04-00002',514.00,514.00,0.00,0.00,0.00,'open',1,'2026-04-11 01:04:24'),(9,NULL,1,'direct_shop','2026-04-10','DS-2026-04-00003',7200.00,1902.00,5298.00,0.00,5298.00,'open',1,'2026-04-11 01:09:01'),(10,NULL,1,'direct_shop','2026-04-10','DS-2026-04-00004',1440.00,0.00,1440.00,0.00,1440.00,'open',1,'2026-04-11 01:09:49'),(11,NULL,4,'direct_shop','2026-04-18','DS-2026-04-00005',600.00,0.00,600.00,0.00,600.00,'open',1,'2026-04-18 15:40:25');
/*!40000 ALTER TABLE `bills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `centralized_cash_entries`
--

DROP TABLE IF EXISTS `centralized_cash_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `centralized_cash_entries` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entry_type` enum('salesman_sale','recovery','delivery_man_collection') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` int unsigned DEFAULT NULL,
  `reference_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `cash_date` date NOT NULL,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_entry_type_date` (`entry_type`,`cash_date`),
  KEY `idx_cash_date` (`cash_date`),
  KEY `fk_cce_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_cce_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `centralized_cash_entries`
--

LOCK TABLES `centralized_cash_entries` WRITE;
/*!40000 ALTER TABLE `centralized_cash_entries` DISABLE KEYS */;
INSERT INTO `centralized_cash_entries` VALUES (1,'delivery_man_collection',1,'delivery_man_collections',2000.00,'2026-04-04',1,'2026-04-04 22:20:12'),(2,'recovery',1,'recovery_collections',5000.00,'2026-04-04',1,'2026-04-04 22:41:22'),(3,'salesman_sale',3,'salesman_returns',2064.00,'2026-04-05',1,'2026-04-05 00:01:32'),(4,'delivery_man_collection',2,'delivery_man_collections',1872.00,'2026-04-05',1,'2026-04-05 00:15:47'),(5,'salesman_sale',4,'salesman_returns',1272.00,'2026-04-10',1,'2026-04-10 00:00:43'),(6,'salesman_sale',5,'salesman_returns',3927.00,'2026-04-10',1,'2026-04-10 00:35:42'),(7,'salesman_sale',6,'salesman_returns',1272.00,'2026-04-10',1,'2026-04-10 00:46:50'),(8,'salesman_sale',7,'salesman_returns',1294.00,'2026-04-10',1,'2026-04-10 01:17:14'),(9,'salesman_sale',8,'salesman_returns',481.00,'2026-04-10',1,'2026-04-10 01:40:36'),(10,'delivery_man_collection',3,'delivery_man_collections',299.00,'2026-04-10',1,'2026-04-10 02:00:13'),(11,'delivery_man_collection',4,'delivery_man_collections',74.00,'2026-04-10',1,'2026-04-10 02:01:02'),(12,'recovery',2,'recovery_collections',2000.00,'2026-04-10',1,'2026-04-10 02:03:13'),(13,'recovery',3,'recovery_collections',200.00,'2026-04-10',1,'2026-04-10 02:23:06');
/*!40000 ALTER TABLE `centralized_cash_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `claim_items`
--

DROP TABLE IF EXISTS `claim_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claim_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `claim_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `cartons` int unsigned NOT NULL DEFAULT '0',
  `loose_units` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_ci_claim` (`claim_id`),
  KEY `fk_ci_product` (`product_id`),
  CONSTRAINT `fk_ci_claim` FOREIGN KEY (`claim_id`) REFERENCES `claims` (`id`),
  CONSTRAINT `fk_ci_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `claim_items`
--

LOCK TABLES `claim_items` WRITE;
/*!40000 ALTER TABLE `claim_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `claim_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `claims`
--

DROP TABLE IF EXISTS `claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claims` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `claim_date` date NOT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `claim_value` decimal(12,2) NOT NULL,
  `status` enum('pending','cleared') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `cleared_at` datetime DEFAULT NULL,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_status` (`company_id`,`status`),
  KEY `fk_claim_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_claim_company` FOREIGN KEY (`company_id`) REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_claim_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `claims`
--

LOCK TABLES `claims` WRITE;
/*!40000 ALTER TABLE `claims` DISABLE KEYS */;
/*!40000 ALTER TABLE `claims` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_profile`
--

DROP TABLE IF EXISTS `company_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_profile` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `phone_1` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_2` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gst_ntn` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sales_tax` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cnic` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_profile`
--

LOCK TABLES `company_profile` WRITE;
/*!40000 ALTER TABLE `company_profile` DISABLE KEYS */;
INSERT INTO `company_profile` VALUES (1,'Shakeel Traders','Shakeel Ahmad','Karrianwala Road Khurrianwala','04235000000',NULL,NULL,'NTN-1234567','ST-5643-786','33104-5026301-3','/uploads/logos/company-logo.png','2026-04-18 15:52:34');
/*!40000 ALTER TABLE `company_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_man_collections`
--

DROP TABLE IF EXISTS `delivery_man_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_man_collections` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` int unsigned NOT NULL,
  `delivery_man_id` int unsigned NOT NULL,
  `amount_collected` decimal(12,2) NOT NULL,
  `collection_date` date NOT NULL,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_bill` (`bill_id`),
  KEY `idx_delivery_man` (`delivery_man_id`),
  KEY `idx_date` (`collection_date`),
  KEY `fk_dmc_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_dmc_bill` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`),
  CONSTRAINT `fk_dmc_delivery_man` FOREIGN KEY (`delivery_man_id`) REFERENCES `delivery_men` (`id`),
  CONSTRAINT `fk_dmc_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_man_collections`
--

LOCK TABLES `delivery_man_collections` WRITE;
/*!40000 ALTER TABLE `delivery_man_collections` DISABLE KEYS */;
INSERT INTO `delivery_man_collections` VALUES (1,1,1,2000.00,'2026-04-04',1,'2026-04-04 22:20:12'),(2,2,1,1872.00,'2026-04-05',1,'2026-04-05 00:15:47'),(3,1,1,299.00,'2026-04-10',1,'2026-04-10 02:00:13'),(4,4,1,74.00,'2026-04-10',1,'2026-04-10 02:01:02');
/*!40000 ALTER TABLE `delivery_man_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_men`
--

DROP TABLE IF EXISTS `delivery_men`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_men` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_men`
--

LOCK TABLES `delivery_men` WRITE;
/*!40000 ALTER TABLE `delivery_men` DISABLE KEYS */;
INSERT INTO `delivery_men` VALUES (1,'Usman Ali','03111234567',1,'2026-04-03 18:09:04');
/*!40000 ALTER TABLE `delivery_men` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expenses`
--

DROP TABLE IF EXISTS `expenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expenses` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `expense_type` enum('fuel','daily_allowance','vehicle_maintenance','office','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `expense_date` date NOT NULL,
  `related_user_id` int unsigned DEFAULT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_type_date` (`expense_type`,`expense_date`),
  KEY `idx_date` (`expense_date`),
  KEY `fk_exp_related_user` (`related_user_id`),
  KEY `fk_exp_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_exp_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_exp_related_user` FOREIGN KEY (`related_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expenses`
--

LOCK TABLES `expenses` WRITE;
/*!40000 ALTER TABLE `expenses` DISABLE KEYS */;
/*!40000 ALTER TABLE `expenses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `issuance_items`
--

DROP TABLE IF EXISTS `issuance_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `issuance_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `issuance_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `cartons` int unsigned NOT NULL DEFAULT '0',
  `loose_units` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_ii_issuance` (`issuance_id`),
  KEY `fk_ii_product` (`product_id`),
  CONSTRAINT `fk_ii_issuance` FOREIGN KEY (`issuance_id`) REFERENCES `salesman_issuances` (`id`),
  CONSTRAINT `fk_ii_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issuance_items`
--

LOCK TABLES `issuance_items` WRITE;
/*!40000 ALTER TABLE `issuance_items` DISABLE KEYS */;
INSERT INTO `issuance_items` VALUES (1,1,1,3,0),(2,1,2,2,0),(3,1,3,3,0),(4,2,1,1,0),(5,2,2,1,0),(6,2,3,1,0),(7,3,1,5,5),(8,3,2,5,5),(9,3,3,5,5),(10,4,1,2,1),(11,4,2,2,1),(12,4,3,2,1),(13,5,1,1,1),(14,5,2,1,1),(15,5,3,1,1),(16,6,1,1,1),(17,6,2,1,1),(18,6,3,2,2);
/*!40000 ALTER TABLE `issuance_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `ordered_cartons` int unsigned NOT NULL DEFAULT '0',
  `ordered_loose` int unsigned NOT NULL DEFAULT '0',
  `final_cartons` int unsigned NOT NULL DEFAULT '0',
  `final_loose` int unsigned NOT NULL DEFAULT '0',
  `unit_price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`),
  KEY `fk_oi_product` (`product_id`),
  CONSTRAINT `fk_oi_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_oi_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,1,12,2,12,0,15.00),(2,1,2,15,85,15,0,10.00),(3,1,3,2,3,2,0,12.00),(4,2,1,1,2,1,2,15.00),(5,2,2,1,2,1,2,10.00),(6,2,3,1,2,1,2,12.00),(7,3,1,0,2,0,2,15.00),(8,3,2,0,2,0,2,10.00),(9,3,3,0,2,0,2,12.00),(10,4,1,0,2,0,2,15.00),(11,4,2,0,2,0,2,10.00),(12,4,3,0,2,0,2,12.00),(13,5,1,0,12,0,12,15.00),(14,5,2,0,2,0,2,10.00),(15,5,3,0,2,0,2,12.00),(16,6,1,1,11,1,11,15.00),(17,6,2,0,12,0,12,10.00),(18,6,3,0,12,0,12,12.00);
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `order_booker_id` int unsigned NOT NULL,
  `shop_id` int unsigned NOT NULL,
  `route_id` int unsigned NOT NULL,
  `created_at_device` datetime NOT NULL,
  `synced_at` datetime DEFAULT NULL,
  `status` enum('pending','stock_adjusted','converted','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `stock_check_note` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_booker_date` (`order_booker_id`,`created_at_device`),
  KEY `idx_shop` (`shop_id`),
  KEY `idx_status` (`status`),
  KEY `idx_route` (`route_id`),
  CONSTRAINT `fk_order_booker` FOREIGN KEY (`order_booker_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_order_route` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`),
  CONSTRAINT `fk_order_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,2,2,1,'2026-04-04 22:15:52',NULL,'converted',NULL,'2026-04-04 22:15:52'),(2,2,3,1,'2026-04-10 01:55:26',NULL,'converted',NULL,'2026-04-10 01:55:26'),(3,2,1,1,'2026-04-10 01:55:26',NULL,'converted',NULL,'2026-04-10 01:55:26'),(4,9,3,6,'2026-04-10 18:45:59',NULL,'converted',NULL,'2026-04-10 18:45:59'),(5,9,2,6,'2026-04-10 18:45:59',NULL,'converted',NULL,'2026-04-10 18:45:59'),(6,9,1,6,'2026-04-10 18:45:59',NULL,'converted',NULL,'2026-04-10 18:45:59');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `sku_code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `brand` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `units_per_carton` int unsigned NOT NULL,
  `retail_price` decimal(10,2) NOT NULL,
  `wholesale_price` decimal(10,2) NOT NULL,
  `current_stock_cartons` int unsigned NOT NULL DEFAULT '0',
  `current_stock_loose` int unsigned NOT NULL DEFAULT '0',
  `low_stock_threshold` int unsigned DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sku` (`sku_code`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `chk_stock_non_negative` CHECK (((`current_stock_cartons` >= 0) and (`current_stock_loose` >= 0)))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'CBL-001','CBL Biscuit 100g','CBL',24,100.00,13.50,10,12,5,1,'2026-04-03 18:09:04','2026-04-18 15:40:25'),(2,'CBL-002','CBL Cake 50g','CBL',48,10.00,9.00,26,22,5,1,'2026-04-03 18:09:04','2026-04-11 01:16:29'),(3,'CBL-003','CBL Wafer 75g','CBL',36,12.00,10.50,34,8,5,1,'2026-04-03 18:09:04','2026-04-11 01:04:24');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recovery_collections`
--

DROP TABLE IF EXISTS `recovery_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recovery_collections` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `assignment_id` int unsigned NOT NULL,
  `bill_id` int unsigned NOT NULL,
  `collected_by_booker_id` int unsigned NOT NULL,
  `amount_collected` decimal(12,2) NOT NULL,
  `payment_method` enum('cash','bank_transfer') COLLATE utf8mb4_unicode_ci NOT NULL,
  `collected_at_device` datetime NOT NULL,
  `synced_at` datetime DEFAULT NULL,
  `verified_by_admin_id` int unsigned DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_assignment` (`assignment_id`),
  KEY `idx_bill` (`bill_id`),
  KEY `idx_verified` (`verified_by_admin_id`),
  KEY `fk_rc_booker` (`collected_by_booker_id`),
  CONSTRAINT `fk_rc_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `bill_recovery_assignments` (`id`),
  CONSTRAINT `fk_rc_bill` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`),
  CONSTRAINT `fk_rc_booker` FOREIGN KEY (`collected_by_booker_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rc_verifier` FOREIGN KEY (`verified_by_admin_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recovery_collections`
--

LOCK TABLES `recovery_collections` WRITE;
/*!40000 ALTER TABLE `recovery_collections` DISABLE KEYS */;
INSERT INTO `recovery_collections` VALUES (1,1,1,2,5000.00,'cash','2026-04-04 22:40:11',NULL,1,'2026-04-04 22:41:22','2026-04-04 22:40:11'),(2,2,1,2,2000.00,'cash','2026-04-10 02:02:40',NULL,1,'2026-04-10 02:03:13','2026-04-10 02:02:40'),(3,3,3,7,200.00,'cash','2026-04-10 02:22:47',NULL,1,'2026-04-10 02:23:06','2026-04-10 02:22:47');
/*!40000 ALTER TABLE `recovery_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `return_items`
--

DROP TABLE IF EXISTS `return_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `return_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `return_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `returned_cartons` int unsigned NOT NULL DEFAULT '0',
  `returned_loose` int unsigned NOT NULL DEFAULT '0',
  `sold_cartons` int unsigned NOT NULL DEFAULT '0',
  `sold_loose` int unsigned NOT NULL DEFAULT '0',
  `retail_price` decimal(10,2) NOT NULL,
  `line_sale_value` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `fk_ri_return` (`return_id`),
  KEY `fk_ri_product` (`product_id`),
  CONSTRAINT `fk_ri_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_ri_return` FOREIGN KEY (`return_id`) REFERENCES `salesman_returns` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `return_items`
--

LOCK TABLES `return_items` WRITE;
/*!40000 ALTER TABLE `return_items` DISABLE KEYS */;
INSERT INTO `return_items` VALUES (1,3,1,1,0,2,0,15.00,720.00),(2,3,2,1,0,1,0,10.00,480.00),(3,3,3,1,0,2,0,12.00,864.00),(4,4,1,0,0,1,0,15.00,360.00),(5,4,2,0,0,1,0,10.00,480.00),(6,4,3,0,0,1,0,12.00,432.00),(7,5,1,2,2,3,3,15.00,1125.00),(8,5,2,2,2,3,3,10.00,1470.00),(9,5,3,2,2,3,3,12.00,1332.00),(10,6,1,1,1,1,0,15.00,360.00),(11,6,2,1,1,1,0,10.00,480.00),(12,6,3,1,1,1,0,12.00,432.00),(13,7,1,0,1,1,0,15.00,360.00),(14,7,2,0,0,1,1,10.00,490.00),(15,7,3,0,0,1,1,12.00,444.00),(16,8,1,1,0,0,1,15.00,15.00),(17,8,2,1,0,0,1,10.00,10.00),(18,8,3,1,0,1,2,12.00,456.00);
/*!40000 ALTER TABLE `return_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `route_assignments`
--

DROP TABLE IF EXISTS `route_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `route_assignments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `route_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `assignment_date` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_route_date` (`route_id`,`assignment_date`),
  KEY `idx_user_date` (`user_id`,`assignment_date`),
  KEY `idx_assignment_date` (`assignment_date`),
  CONSTRAINT `fk_ra_route` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`),
  CONSTRAINT `fk_ra_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route_assignments`
--

LOCK TABLES `route_assignments` WRITE;
/*!40000 ALTER TABLE `route_assignments` DISABLE KEYS */;
INSERT INTO `route_assignments` VALUES (1,3,2,'2026-04-03','2026-04-03 20:10:07'),(2,2,2,'2026-04-04','2026-04-04 13:04:01'),(3,1,2,'2026-04-04','2026-04-04 22:09:19'),(4,3,7,'2026-04-09','2026-04-10 01:44:36'),(5,1,2,'2026-04-10','2026-04-10 01:49:27'),(6,1,2,'2026-04-09','2026-04-10 01:49:50'),(8,2,2,'2026-04-09','2026-04-10 01:56:31'),(10,4,7,'2026-04-09','2026-04-10 02:12:21'),(12,6,9,'2026-04-10','2026-04-10 18:44:35');
/*!40000 ALTER TABLE `route_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `routes`
--

DROP TABLE IF EXISTS `routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `routes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_route_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES (1,'Route A - North',1,'2026-04-03 18:09:04'),(2,'Route B - South',1,'2026-04-03 18:09:04'),(3,'Main Bazar',1,'2026-04-03 20:08:19'),(4,'mlsa',1,'2026-04-10 02:11:59'),(5,'bazar',1,'2026-04-10 18:26:19'),(6,'adnan',1,'2026-04-10 18:44:11');
/*!40000 ALTER TABLE `routes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_advances`
--

DROP TABLE IF EXISTS `salary_advances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_advances` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `staff_id` int unsigned NOT NULL,
  `staff_type` enum('salesman','order_booker','delivery_man') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `advance_date` date NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_staff_date` (`staff_id`,`staff_type`,`advance_date`),
  KEY `fk_sadv2_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_sadv2_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_advances`
--

LOCK TABLES `salary_advances` WRITE;
/*!40000 ALTER TABLE `salary_advances` DISABLE KEYS */;
INSERT INTO `salary_advances` VALUES (1,3,'salesman',12000.00,'2026-04-04',NULL,1,'2026-04-05 00:03:09'),(2,3,'salesman',2000.00,'2026-04-04',NULL,1,'2026-04-05 00:03:20');
/*!40000 ALTER TABLE `salary_advances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salary_records`
--

DROP TABLE IF EXISTS `salary_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salary_records` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `staff_id` int unsigned NOT NULL,
  `staff_type` enum('salesman','order_booker','delivery_man') COLLATE utf8mb4_unicode_ci NOT NULL,
  `month` tinyint unsigned NOT NULL,
  `year` year NOT NULL,
  `basic_salary` decimal(10,2) NOT NULL,
  `total_advances_paid` decimal(10,2) NOT NULL DEFAULT '0.00',
  `cleared_at` datetime DEFAULT NULL,
  `cleared_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_staff_month_year` (`staff_id`,`staff_type`,`month`,`year`),
  KEY `idx_staff_type` (`staff_type`),
  KEY `fk_sr_cleared_by` (`cleared_by`),
  CONSTRAINT `fk_sr_cleared_by` FOREIGN KEY (`cleared_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_records`
--

LOCK TABLES `salary_records` WRITE;
/*!40000 ALTER TABLE `salary_records` DISABLE KEYS */;
INSERT INTO `salary_records` VALUES (1,3,'salesman',4,2026,2000.00,14000.00,NULL,NULL,'2026-04-05 00:02:59');
/*!40000 ALTER TABLE `salary_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salesman_issuances`
--

DROP TABLE IF EXISTS `salesman_issuances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salesman_issuances` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `salesman_id` int unsigned NOT NULL,
  `issuance_date` date NOT NULL,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` int unsigned DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_salesman_date` (`salesman_id`,`issuance_date`),
  KEY `idx_status` (`status`),
  KEY `fk_si_approved_by` (`approved_by`),
  CONSTRAINT `fk_si_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_si_salesman` FOREIGN KEY (`salesman_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salesman_issuances`
--

LOCK TABLES `salesman_issuances` WRITE;
/*!40000 ALTER TABLE `salesman_issuances` DISABLE KEYS */;
INSERT INTO `salesman_issuances` VALUES (1,3,'2026-04-04','approved',1,'2026-04-04 23:52:31','2026-04-04 23:52:03'),(2,3,'2026-04-09','approved',1,'2026-04-09 23:57:06','2026-04-09 23:56:46'),(3,4,'2026-04-09','approved',1,'2026-04-10 00:34:11','2026-04-10 00:33:47'),(4,5,'2026-04-09','approved',1,'2026-04-10 00:45:20','2026-04-10 00:45:04'),(5,6,'2026-04-09','approved',1,'2026-04-10 01:16:07','2026-04-10 01:15:53'),(6,8,'2026-04-09','approved',1,'2026-04-10 01:39:26','2026-04-10 01:39:03');
/*!40000 ALTER TABLE `salesman_issuances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `salesman_returns`
--

DROP TABLE IF EXISTS `salesman_returns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `salesman_returns` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `issuance_id` int unsigned NOT NULL,
  `salesman_id` int unsigned NOT NULL,
  `return_date` date NOT NULL,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `system_sale_value` decimal(12,2) DEFAULT NULL,
  `admin_edited_sale_value` decimal(12,2) DEFAULT NULL,
  `final_sale_value` decimal(12,2) DEFAULT NULL,
  `cash_collected` decimal(12,2) NOT NULL DEFAULT '0.00',
  `approved_by` int unsigned DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_issuance_return` (`issuance_id`),
  KEY `idx_status` (`status`),
  KEY `fk_ret_salesman` (`salesman_id`),
  KEY `fk_ret_approved_by` (`approved_by`),
  CONSTRAINT `fk_ret_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_ret_issuance` FOREIGN KEY (`issuance_id`) REFERENCES `salesman_issuances` (`id`),
  CONSTRAINT `fk_ret_salesman` FOREIGN KEY (`salesman_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salesman_returns`
--

LOCK TABLES `salesman_returns` WRITE;
/*!40000 ALTER TABLE `salesman_returns` DISABLE KEYS */;
INSERT INTO `salesman_returns` VALUES (3,1,3,'2026-04-04','approved',2064.00,2064.00,2064.00,0.00,1,'2026-04-05 00:01:32','2026-04-04 23:59:53'),(4,2,3,'2026-04-09','approved',1272.00,NULL,1272.00,12000.00,1,'2026-04-10 00:00:43','2026-04-09 23:59:59'),(5,3,4,'2026-04-09','approved',3927.00,NULL,3927.00,12000.00,1,'2026-04-10 00:35:42','2026-04-10 00:35:04'),(6,4,5,'2026-04-09','approved',1272.00,NULL,1272.00,1200.00,1,'2026-04-10 00:46:50','2026-04-10 00:46:32'),(7,5,6,'2026-04-09','approved',1294.00,NULL,1294.00,0.00,1,'2026-04-10 01:17:14','2026-04-10 01:16:55'),(8,6,8,'2026-04-09','approved',481.00,NULL,481.00,0.00,1,'2026-04-10 01:40:36','2026-04-10 01:40:23');
/*!40000 ALTER TABLE `salesman_returns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int unsigned NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  PRIMARY KEY (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('5DfBG1WtR6yvk09PuY2g6GZXu_p0K_TF',1776597460,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-04-19T11:00:31.397Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{},\"user\":{\"id\":1,\"full_name\":\"Administrator\",\"username\":\"devmbilal\",\"role\":\"admin\"}}'),('OSrdfeA8nyIdYy2v-QA2KGH0mW3WPSDQ',1776622922,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-04-19T18:22:01.948Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('elPNnO66wJHfnLgmJJeqJELf204F5Ier',1776596129,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-04-19T10:55:28.795Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{\"error\":[\"Please log in to access this page.\"]}}'),('kAtjsGDYzqSfvVH_aEFaQL-5XUNNEaPX',1776628502,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-04-19T19:42:50.259Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{},\"user\":{\"id\":1,\"full_name\":\"Administrator\",\"username\":\"devmbilal\",\"role\":\"admin\"}}'),('muEYWE_KRKgFLS3vbXyfgOecdAfkhgnj',1776622912,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-04-19T18:21:52.319Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('ryVlSDwRhl8avuWHabwQKjh-DW0twEB1',1776623879,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-04-19T18:37:59.256Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('ugym0XSZUst1PutUPPGuUMH8AZdYTrQa',1776615416,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-04-19T16:09:43.815Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{},\"user\":{\"id\":1,\"full_name\":\"Administrator\",\"username\":\"devmbilal\",\"role\":\"admin\"}}');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shop_advances`
--

DROP TABLE IF EXISTS `shop_advances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shop_advances` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `shop_id` int unsigned NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `remaining_balance` decimal(12,2) NOT NULL,
  `advance_date` date NOT NULL,
  `payment_method` enum('cash','bank_transfer','cheque','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop` (`shop_id`),
  KEY `fk_sadv_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_sadv_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_sadv_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_advances`
--

LOCK TABLES `shop_advances` WRITE;
/*!40000 ALTER TABLE `shop_advances` DISABLE KEYS */;
INSERT INTO `shop_advances` VALUES (7,2,50000.00,49262.00,'2026-04-04','cash','yyy',1,'2026-04-04 22:56:14'),(8,1,200.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:36:47'),(9,1,200.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:36:52'),(10,1,200.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:36:57'),(11,1,200.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:37:01'),(12,1,200.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:37:14'),(13,1,200.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:37:18'),(14,1,200.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:37:22'),(15,1,300.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:37:25'),(16,1,200.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:37:29'),(17,1,2.00,0.00,'2026-04-10','cash',NULL,1,'2026-04-11 00:37:34');
/*!40000 ALTER TABLE `shop_advances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shop_last_prices`
--

DROP TABLE IF EXISTS `shop_last_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shop_last_prices` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `shop_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `last_price` decimal(10,2) NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_shop_product` (`shop_id`,`product_id`),
  KEY `fk_slp_product` (`product_id`),
  CONSTRAINT `fk_slp_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_slp_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_last_prices`
--

LOCK TABLES `shop_last_prices` WRITE;
/*!40000 ALTER TABLE `shop_last_prices` DISABLE KEYS */;
INSERT INTO `shop_last_prices` VALUES (1,2,1,15.00,'2026-04-10 18:53:25'),(2,2,2,10.00,'2026-04-11 01:04:24'),(3,2,3,12.00,'2026-04-11 01:04:24'),(4,1,1,15.00,'2026-04-11 01:09:49'),(5,1,3,12.00,'2026-04-10 18:53:09'),(6,3,1,15.00,'2026-04-10 18:53:29'),(7,3,2,10.00,'2026-04-10 18:53:29'),(8,3,3,12.00,'2026-04-10 18:53:29'),(10,1,2,10.00,'2026-04-10 18:53:09'),(25,4,1,100.00,'2026-04-18 15:40:25');
/*!40000 ALTER TABLE `shop_last_prices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shop_ledger_entries`
--

DROP TABLE IF EXISTS `shop_ledger_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shop_ledger_entries` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `shop_id` int unsigned NOT NULL,
  `entry_type` enum('bill','payment_delivery_man','recovery','advance_payment','advance_adjustment','claim_credit') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` int unsigned DEFAULT NULL,
  `reference_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `debit` decimal(12,2) NOT NULL DEFAULT '0.00',
  `credit` decimal(12,2) NOT NULL DEFAULT '0.00',
  `balance_after` decimal(12,2) NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `entry_date` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_date` (`shop_id`,`entry_date`),
  KEY `idx_entry_type` (`entry_type`),
  CONSTRAINT `fk_sle_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_ledger_entries`
--

LOCK TABLES `shop_ledger_entries` WRITE;
/*!40000 ALTER TABLE `shop_ledger_entries` DISABLE KEYS */;
INSERT INTO `shop_ledger_entries` VALUES (1,2,'bill',1,'bills',12384.00,0.00,12384.00,'Bill OB-2026-04-00001','2026-04-04','2026-04-04 22:17:05'),(2,2,'payment_delivery_man',1,'delivery_man_collections',0.00,2000.00,10384.00,'Delivery man payment for OB-2026-04-00001','2026-04-04','2026-04-04 22:20:12'),(3,2,'recovery',1,'recovery_collections',0.00,5000.00,5384.00,'Recovery for bill OB-2026-04-00001','2026-04-04','2026-04-04 22:41:22'),(4,2,'advance_payment',7,'shop_advances',0.00,50000.00,-44616.00,'yyy','2026-04-04','2026-04-04 22:56:14'),(5,1,'bill',2,'bills',1872.00,0.00,1872.00,'Bill DS-2026-04-00001','2026-04-04','2026-04-05 00:05:19'),(6,1,'payment_delivery_man',2,'delivery_man_collections',0.00,1872.00,0.00,'Delivery man payment for DS-2026-04-00001','2026-04-05','2026-04-05 00:15:47'),(7,3,'bill',3,'bills',1346.00,0.00,1346.00,'Bill OB-2026-04-00002','2026-04-09','2026-04-10 01:57:42'),(8,1,'bill',4,'bills',74.00,0.00,74.00,'Bill OB-2026-04-00003','2026-04-09','2026-04-10 01:57:57'),(9,2,'payment_delivery_man',3,'delivery_man_collections',0.00,299.00,-44915.00,'Delivery man payment for OB-2026-04-00001','2026-04-10','2026-04-10 02:00:13'),(10,1,'payment_delivery_man',4,'delivery_man_collections',0.00,74.00,0.00,'Delivery man payment for OB-2026-04-00003','2026-04-10','2026-04-10 02:01:02'),(11,2,'recovery',2,'recovery_collections',0.00,2000.00,-46915.00,'Recovery for bill OB-2026-04-00001','2026-04-10','2026-04-10 02:03:13'),(12,3,'recovery',3,'recovery_collections',0.00,200.00,1146.00,'Recovery for bill OB-2026-04-00002','2026-04-10','2026-04-10 02:23:06'),(13,1,'bill',5,'bills',789.00,0.00,789.00,'Bill OB-2026-04-00004','2026-04-10','2026-04-10 18:53:09'),(14,2,'bill',6,'bills',0.00,224.00,-47139.00,'Bill OB-2026-04-00005','2026-04-10','2026-04-10 18:53:25'),(15,3,'bill',7,'bills',74.00,0.00,1220.00,'Bill OB-2026-04-00006','2026-04-10','2026-04-10 18:53:29'),(16,1,'advance_payment',8,'shop_advances',0.00,200.00,589.00,NULL,'2026-04-10','2026-04-11 00:36:47'),(17,1,'advance_payment',9,'shop_advances',0.00,200.00,389.00,NULL,'2026-04-10','2026-04-11 00:36:52'),(18,1,'advance_payment',10,'shop_advances',0.00,200.00,189.00,NULL,'2026-04-10','2026-04-11 00:36:57'),(19,1,'advance_payment',11,'shop_advances',0.00,200.00,-11.00,NULL,'2026-04-10','2026-04-11 00:37:01'),(20,1,'advance_payment',12,'shop_advances',0.00,200.00,-211.00,NULL,'2026-04-10','2026-04-11 00:37:14'),(21,1,'advance_payment',13,'shop_advances',0.00,200.00,-411.00,NULL,'2026-04-10','2026-04-11 00:37:18'),(22,1,'advance_payment',14,'shop_advances',0.00,200.00,-611.00,NULL,'2026-04-10','2026-04-11 00:37:22'),(23,1,'advance_payment',15,'shop_advances',0.00,300.00,-911.00,NULL,'2026-04-10','2026-04-11 00:37:25'),(24,1,'advance_payment',16,'shop_advances',0.00,200.00,-1111.00,NULL,'2026-04-10','2026-04-11 00:37:29'),(25,1,'advance_payment',17,'shop_advances',0.00,2.00,-1113.00,NULL,'2026-04-10','2026-04-11 00:37:34'),(26,2,'bill',8,'bills',0.00,514.00,-47653.00,'Bill DS-2026-04-00002','2026-04-10','2026-04-11 01:04:24'),(27,1,'bill',9,'bills',5298.00,1902.00,2283.00,'Bill DS-2026-04-00003','2026-04-10','2026-04-11 01:09:01'),(28,1,'bill',10,'bills',1440.00,0.00,3723.00,'Bill DS-2026-04-00004','2026-04-10','2026-04-11 01:09:49'),(29,4,'bill',11,'bills',600.00,0.00,600.00,'Bill DS-2026-04-00005','2026-04-18','2026-04-18 15:40:25');
/*!40000 ALTER TABLE `shop_ledger_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shops`
--

DROP TABLE IF EXISTS `shops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shops` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `route_id` int unsigned NOT NULL,
  `shop_type` enum('retail','wholesale') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'retail',
  `price_edit_allowed` tinyint(1) NOT NULL DEFAULT '0',
  `price_min_pct` decimal(5,2) DEFAULT NULL,
  `price_max_pct` decimal(5,2) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_route` (`route_id`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_shop_route` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shops`
--

LOCK TABLES `shops` WRITE;
/*!40000 ALTER TABLE `shops` DISABLE KEYS */;
INSERT INTO `shops` VALUES (1,'Al-Noor General Store','Noor Ahmed','03211111111',NULL,6,'retail',1,2.00,3.00,1,'2026-04-03 18:09:04'),(2,'City Wholesale','Tariq Mehmood','03222222222',NULL,6,'wholesale',0,NULL,NULL,1,'2026-04-03 18:09:04'),(3,'Pak Kiryana','Imran Shah','03233333333',NULL,6,'retail',0,NULL,NULL,1,'2026-04-03 18:09:04'),(4,'ddd','ccccccccccc',NULL,'v',6,'retail',0,NULL,NULL,1,'2026-04-18 15:32:57');
/*!40000 ALTER TABLE `shops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_movements`
--

DROP TABLE IF EXISTS `stock_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_movements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int unsigned NOT NULL,
  `movement_type` enum('receipt_supplier','manual_add','bill_deduction','issuance_salesman','return_salesman','direct_sale_deduction') COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` int unsigned DEFAULT NULL,
  `reference_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cartons_in` int unsigned NOT NULL DEFAULT '0',
  `loose_in` int unsigned NOT NULL DEFAULT '0',
  `cartons_out` int unsigned NOT NULL DEFAULT '0',
  `loose_out` int unsigned NOT NULL DEFAULT '0',
  `stock_after_cartons` int unsigned NOT NULL,
  `stock_after_loose` int unsigned NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_date` (`product_id`,`created_at`),
  KEY `idx_movement_type` (`movement_type`),
  KEY `fk_sm_created_by` (`created_by`),
  CONSTRAINT `fk_sm_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_sm_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_movements`
--

LOCK TABLES `stock_movements` WRITE;
/*!40000 ALTER TABLE `stock_movements` DISABLE KEYS */;
INSERT INTO `stock_movements` VALUES (1,1,'bill_deduction',1,'orders',0,0,12,0,38,0,NULL,1,'2026-04-04 22:17:05'),(2,2,'bill_deduction',1,'orders',0,0,15,0,35,0,NULL,1,'2026-04-04 22:17:05'),(3,3,'bill_deduction',1,'orders',0,0,2,0,48,0,NULL,1,'2026-04-04 22:17:05'),(4,1,'issuance_salesman',1,'salesman_issuances',0,0,3,0,35,0,NULL,1,'2026-04-04 23:52:31'),(5,2,'issuance_salesman',1,'salesman_issuances',0,0,2,0,33,0,NULL,1,'2026-04-04 23:52:31'),(6,3,'issuance_salesman',1,'salesman_issuances',0,0,3,0,45,0,NULL,1,'2026-04-04 23:52:31'),(7,1,'return_salesman',3,'salesman_returns',1,0,0,0,36,0,NULL,1,'2026-04-05 00:01:32'),(8,2,'return_salesman',3,'salesman_returns',1,0,0,0,34,0,NULL,1,'2026-04-05 00:01:32'),(9,3,'return_salesman',3,'salesman_returns',1,0,0,0,46,0,NULL,1,'2026-04-05 00:01:32'),(10,1,'direct_sale_deduction',NULL,NULL,0,0,2,0,34,0,NULL,1,'2026-04-05 00:05:19'),(11,3,'direct_sale_deduction',NULL,NULL,0,0,3,0,43,0,NULL,1,'2026-04-05 00:05:19'),(12,1,'issuance_salesman',2,'salesman_issuances',0,0,1,0,33,0,NULL,1,'2026-04-09 23:57:06'),(13,2,'issuance_salesman',2,'salesman_issuances',0,0,1,0,33,0,NULL,1,'2026-04-09 23:57:06'),(14,3,'issuance_salesman',2,'salesman_issuances',0,0,1,0,42,0,NULL,1,'2026-04-09 23:57:06'),(15,1,'return_salesman',4,'salesman_returns',0,0,0,0,33,0,NULL,1,'2026-04-10 00:00:43'),(16,2,'return_salesman',4,'salesman_returns',0,0,0,0,33,0,NULL,1,'2026-04-10 00:00:43'),(17,3,'return_salesman',4,'salesman_returns',0,0,0,0,42,0,NULL,1,'2026-04-10 00:00:43'),(18,1,'issuance_salesman',3,'salesman_issuances',0,0,5,5,27,19,NULL,1,'2026-04-10 00:34:11'),(19,2,'issuance_salesman',3,'salesman_issuances',0,0,5,5,27,43,NULL,1,'2026-04-10 00:34:11'),(20,3,'issuance_salesman',3,'salesman_issuances',0,0,5,5,36,31,NULL,1,'2026-04-10 00:34:11'),(21,1,'return_salesman',5,'salesman_returns',2,2,0,0,29,21,NULL,1,'2026-04-10 00:35:42'),(22,2,'return_salesman',5,'salesman_returns',2,2,0,0,29,45,NULL,1,'2026-04-10 00:35:42'),(23,3,'return_salesman',5,'salesman_returns',2,2,0,0,38,33,NULL,1,'2026-04-10 00:35:42'),(24,1,'issuance_salesman',4,'salesman_issuances',0,0,2,1,27,20,NULL,1,'2026-04-10 00:45:20'),(25,2,'issuance_salesman',4,'salesman_issuances',0,0,2,1,27,44,NULL,1,'2026-04-10 00:45:20'),(26,3,'issuance_salesman',4,'salesman_issuances',0,0,2,1,36,32,NULL,1,'2026-04-10 00:45:20'),(27,1,'return_salesman',6,'salesman_returns',1,1,0,0,28,21,NULL,1,'2026-04-10 00:46:50'),(28,2,'return_salesman',6,'salesman_returns',1,1,0,0,28,45,NULL,1,'2026-04-10 00:46:50'),(29,3,'return_salesman',6,'salesman_returns',1,1,0,0,37,33,NULL,1,'2026-04-10 00:46:50'),(30,1,'issuance_salesman',5,'salesman_issuances',0,0,1,1,27,20,NULL,1,'2026-04-10 01:16:07'),(31,2,'issuance_salesman',5,'salesman_issuances',0,0,1,1,27,44,NULL,1,'2026-04-10 01:16:07'),(32,3,'issuance_salesman',5,'salesman_issuances',0,0,1,1,36,32,NULL,1,'2026-04-10 01:16:07'),(33,1,'return_salesman',7,'salesman_returns',0,1,0,0,27,21,NULL,1,'2026-04-10 01:17:14'),(34,2,'return_salesman',7,'salesman_returns',0,0,0,0,27,44,NULL,1,'2026-04-10 01:17:14'),(35,3,'return_salesman',7,'salesman_returns',0,0,0,0,36,32,NULL,1,'2026-04-10 01:17:14'),(36,1,'issuance_salesman',6,'salesman_issuances',0,0,1,1,26,20,NULL,1,'2026-04-10 01:39:26'),(37,2,'issuance_salesman',6,'salesman_issuances',0,0,1,1,26,43,NULL,1,'2026-04-10 01:39:26'),(38,3,'issuance_salesman',6,'salesman_issuances',0,0,2,2,34,30,NULL,1,'2026-04-10 01:39:26'),(39,1,'return_salesman',8,'salesman_returns',1,0,0,0,27,20,NULL,1,'2026-04-10 01:40:36'),(40,2,'return_salesman',8,'salesman_returns',1,0,0,0,27,43,NULL,1,'2026-04-10 01:40:36'),(41,3,'return_salesman',8,'salesman_returns',1,0,0,0,35,30,NULL,1,'2026-04-10 01:40:36'),(42,1,'bill_deduction',2,'orders',0,0,1,2,26,18,NULL,1,'2026-04-10 01:57:42'),(43,2,'bill_deduction',2,'orders',0,0,1,2,26,41,NULL,1,'2026-04-10 01:57:42'),(44,3,'bill_deduction',2,'orders',0,0,1,2,34,28,NULL,1,'2026-04-10 01:57:42'),(45,1,'bill_deduction',3,'orders',0,0,0,2,26,16,NULL,1,'2026-04-10 01:57:57'),(46,2,'bill_deduction',3,'orders',0,0,0,2,26,39,NULL,1,'2026-04-10 01:57:57'),(47,3,'bill_deduction',3,'orders',0,0,0,2,34,26,NULL,1,'2026-04-10 01:57:57'),(48,1,'bill_deduction',6,'orders',0,0,1,11,25,5,NULL,1,'2026-04-10 18:53:09'),(49,2,'bill_deduction',6,'orders',0,0,0,12,26,27,NULL,1,'2026-04-10 18:53:09'),(50,3,'bill_deduction',6,'orders',0,0,0,12,34,14,NULL,1,'2026-04-10 18:53:09'),(51,1,'bill_deduction',5,'orders',0,0,0,12,24,17,NULL,1,'2026-04-10 18:53:25'),(52,2,'bill_deduction',5,'orders',0,0,0,2,26,25,NULL,1,'2026-04-10 18:53:25'),(53,3,'bill_deduction',5,'orders',0,0,0,2,34,12,NULL,1,'2026-04-10 18:53:25'),(54,1,'bill_deduction',4,'orders',0,0,0,2,24,15,NULL,1,'2026-04-10 18:53:29'),(55,2,'bill_deduction',4,'orders',0,0,0,2,26,23,NULL,1,'2026-04-10 18:53:29'),(56,3,'bill_deduction',4,'orders',0,0,0,2,34,10,NULL,1,'2026-04-10 18:53:29'),(57,2,'direct_sale_deduction',NULL,NULL,0,0,1,1,25,22,NULL,1,'2026-04-11 01:04:24'),(58,3,'direct_sale_deduction',NULL,NULL,0,0,0,2,34,8,NULL,1,'2026-04-11 01:04:24'),(59,1,'direct_sale_deduction',NULL,NULL,0,0,20,0,4,15,NULL,1,'2026-04-11 01:09:01'),(60,1,'direct_sale_deduction',NULL,NULL,0,0,4,0,0,15,NULL,1,'2026-04-11 01:09:49'),(61,1,'receipt_supplier',1,'stock_receipts',10,3,0,0,10,18,NULL,1,'2026-04-11 01:12:42'),(62,2,'receipt_supplier',2,'stock_receipts',1,0,0,0,26,22,NULL,1,'2026-04-11 01:16:29'),(63,1,'direct_sale_deduction',NULL,NULL,0,0,0,6,10,12,NULL,1,'2026-04-18 15:40:25');
/*!40000 ALTER TABLE `stock_movements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_receipt_items`
--

DROP TABLE IF EXISTS `stock_receipt_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_receipt_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `receipt_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `cartons` int unsigned NOT NULL DEFAULT '0',
  `loose_units` int unsigned NOT NULL DEFAULT '0',
  `unit_price` decimal(10,2) NOT NULL,
  `line_value` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_sri_receipt` (`receipt_id`),
  KEY `fk_sri_product` (`product_id`),
  CONSTRAINT `fk_sri_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_sri_receipt` FOREIGN KEY (`receipt_id`) REFERENCES `stock_receipts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_receipt_items`
--

LOCK TABLES `stock_receipt_items` WRITE;
/*!40000 ALTER TABLE `stock_receipt_items` DISABLE KEYS */;
INSERT INTO `stock_receipt_items` VALUES (1,1,1,10,3,5.00,1215.00),(2,2,2,1,0,10.00,480.00);
/*!40000 ALTER TABLE `stock_receipt_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_receipts`
--

DROP TABLE IF EXISTS `stock_receipts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_receipts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `receipt_date` date NOT NULL,
  `total_value` decimal(12,2) NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_date` (`company_id`,`receipt_date`),
  KEY `fk_sr_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_sr_company` FOREIGN KEY (`company_id`) REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_sr_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_receipts`
--

LOCK TABLES `stock_receipts` WRITE;
/*!40000 ALTER TABLE `stock_receipts` DISABLE KEYS */;
INSERT INTO `stock_receipts` VALUES (1,1,'2026-04-10',1215.00,NULL,1,'2026-04-11 01:12:42'),(2,1,'2026-04-10',480.00,NULL,1,'2026-04-11 01:16:29');
/*!40000 ALTER TABLE `stock_receipts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_advances`
--

DROP TABLE IF EXISTS `supplier_advances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplier_advances` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `payment_date` date NOT NULL,
  `payment_method` enum('cash','bank_transfer','cheque','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_date` (`company_id`,`payment_date`),
  KEY `fk_sa_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_sa_company` FOREIGN KEY (`company_id`) REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_sa_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_advances`
--

LOCK TABLES `supplier_advances` WRITE;
/*!40000 ALTER TABLE `supplier_advances` DISABLE KEYS */;
/*!40000 ALTER TABLE `supplier_advances` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supplier_companies`
--

DROP TABLE IF EXISTS `supplier_companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplier_companies` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_person` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_advance_balance` decimal(12,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_supplier_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_companies`
--

LOCK TABLES `supplier_companies` WRITE;
/*!40000 ALTER TABLE `supplier_companies` DISABLE KEYS */;
INSERT INTO `supplier_companies` VALUES (1,'CBL','CBL Sales Rep','04212345678',48305.00,1,'2026-04-03 18:09:04');
/*!40000 ALTER TABLE `supplier_companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','order_booker','salesman') COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Administrator','devmbilal','$2a$10$/YhbyLtZ7UDiwGhfSYnR4O9umsQ7NRlJHWunBE2Qmc.WuSiUJz3Ku','admin',NULL,1,'2026-04-03 18:09:03','2026-04-18 14:02:15'),(2,'Ahmed Khan','ahmed','$2a$10$8dkAhnxBIn9gPxhzaeFvpeP15OhBRW.0aDhoUKPEgys9Dtxn09yc.','order_booker','03001234567',0,'2026-04-03 18:09:04','2026-04-18 01:16:30'),(3,'Bilal Raza','bilal','$2a$12$6v/K5Axv8.r7967jqkmYROvgzl72dHQhUIvKyG8o6q.xdfy4GzOn2','salesman','03009876543',1,'2026-04-03 18:09:04','2026-04-03 18:09:04'),(4,'KAMRAN','kamran','$2a$10$/eoUsZvCzryNUb2.I7KNp.ZcPJvkR4JnVzioSUBNO3wPhLolnIImy','salesman',NULL,0,'2026-04-10 00:30:00','2026-04-11 00:57:28'),(5,'farhan','farhan','$2a$10$cmzqidFApgtygxt2OnWfmexDMV4svbsLXmUGDyr652naK.DTA9/ya','salesman',NULL,1,'2026-04-10 00:43:37','2026-04-10 00:43:37'),(6,'zulfi','zulfi','$2a$10$IC9XqvaTJ0BQW7n5/RB18u7DXJTViBcZGvL.DY8al43iwHmZ8qVWG','salesman',NULL,0,'2026-04-10 01:14:44','2026-04-11 00:57:21'),(7,'mlsa','mlsa','$2a$10$6F9mHa233d/RSMwMBT403Oc8vVuayP/FmBS8ihYs8VZygOTLjhLEe','order_booker',NULL,0,'2026-04-10 01:25:16','2026-04-18 01:16:28'),(8,'usman','usman','$2a$10$SED6E.bgD8RLF4o3sUkEYuXWr.jsuhKZSa97RgdgKNrO3BhHC3sS2','salesman',NULL,0,'2026-04-10 01:25:39','2026-04-11 00:57:25'),(9,'adnan','adnan','$2a$10$AQVVAJTyP.0EBKjM9fNEvOMIMb23C/LuqMX2yT0PvFLFY2Qls4VWO','order_booker',NULL,1,'2026-04-10 18:43:27','2026-04-10 18:43:27');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-19  0:55:06
