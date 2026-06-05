-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: shakeel_traders
-- ------------------------------------------------------
-- Server version	8.0.46

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
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` int unsigned DEFAULT NULL,
  `old_value` json DEFAULT NULL,
  `new_value` json DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`,`created_at`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_action` (`action`),
  CONSTRAINT `fk_al_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (28,9,'MANUAL_STOCK_ADD','products',12,NULL,NULL,NULL,'2026-05-31 15:12:13'),(29,9,'RECORD_SUPPLIER_ADVANCE','supplier_advances',2,NULL,'{\"amount\": \"22143\", \"companyId\": \"2\"}',NULL,'2026-05-31 15:16:01'),(30,9,'RECORD_SUPPLIER_ADVANCE','supplier_advances',3,NULL,'{\"amount\": \"1175000\", \"companyId\": \"2\"}',NULL,'2026-06-02 08:47:54'),(31,9,'CREATE_DIRECT_SALE','bills',6,NULL,'{\"billNumber\": \"DS-2026-06-00001\"}',NULL,'2026-06-02 08:51:48'),(32,9,'RECORD_SALARY','salary_records',NULL,NULL,'{\"year\": \"2026\", \"month\": \"6\", \"amount\": \"35000\", \"staffId\": \"12\", \"staffType\": \"salesman\"}',NULL,'2026-06-02 08:58:49'),(33,9,'RECORD_SUPPLIER_ADVANCE','supplier_advances',4,NULL,'{\"amount\": \"180857\", \"companyId\": \"2\"}',NULL,'2026-06-02 09:10:10'),(34,9,'MANUAL_STOCK_ADD','products',16,NULL,NULL,NULL,'2026-06-02 12:32:34'),(35,9,'MANUAL_STOCK_ADD','products',21,NULL,NULL,NULL,'2026-06-02 12:34:07'),(36,9,'MANUAL_STOCK_ADD','products',10,NULL,NULL,NULL,'2026-06-02 12:34:50'),(37,9,'MANUAL_STOCK_ADD','products',30,NULL,NULL,NULL,'2026-06-02 12:36:05'),(38,9,'MANUAL_STOCK_ADD','products',15,NULL,NULL,NULL,'2026-06-02 12:36:29'),(39,9,'MANUAL_STOCK_ADD','products',29,NULL,NULL,NULL,'2026-06-02 12:37:26'),(40,9,'MANUAL_STOCK_ADD','products',14,NULL,NULL,NULL,'2026-06-02 12:38:03'),(41,9,'MANUAL_STOCK_ADD','products',22,NULL,NULL,NULL,'2026-06-02 12:39:21'),(42,9,'MANUAL_STOCK_ADD','products',33,NULL,NULL,NULL,'2026-06-02 12:45:59'),(43,9,'MANUAL_STOCK_ADD','products',32,NULL,NULL,NULL,'2026-06-02 12:46:57'),(44,9,'MANUAL_STOCK_ADD','products',8,NULL,NULL,NULL,'2026-06-02 12:47:15'),(45,9,'MANUAL_STOCK_ADD','products',7,NULL,NULL,NULL,'2026-06-02 12:47:59'),(46,9,'MANUAL_STOCK_ADD','products',20,NULL,NULL,NULL,'2026-06-02 12:53:44'),(47,9,'MANUAL_STOCK_ADD','products',9,NULL,NULL,NULL,'2026-06-02 12:54:09'),(48,9,'MANUAL_STOCK_ADD','products',18,NULL,NULL,NULL,'2026-06-02 12:56:09'),(49,9,'MANUAL_STOCK_ADD','products',34,NULL,NULL,NULL,'2026-06-02 13:05:14'),(50,9,'MANUAL_STOCK_ADD','products',13,NULL,NULL,NULL,'2026-06-02 13:05:36'),(51,9,'MANUAL_STOCK_ADD','products',35,NULL,NULL,NULL,'2026-06-02 13:08:17'),(52,9,'MANUAL_STOCK_ADD','products',23,NULL,NULL,NULL,'2026-06-02 13:11:33'),(53,9,'CREATE_DIRECT_SALE','bills',7,NULL,'{\"billNumber\": \"DS-2026-06-00002\"}',NULL,'2026-06-02 16:47:43'),(54,9,'ASSIGN_RECOVERY_BILLS','bill_recovery_assignments',NULL,NULL,'{\"billIds\": [\"6\"], \"bookerId\": \"22\"}',NULL,'2026-06-02 16:57:22'),(55,9,'RETURN_BILL_TO_POOL','bill_recovery_assignments',5,NULL,'{\"returned_by\": 9, \"assignment_id\": \"5\"}',NULL,'2026-06-02 16:57:33'),(56,9,'ASSIGN_RECOVERY_BILLS','bill_recovery_assignments',NULL,NULL,'{\"billIds\": [\"6\"], \"bookerId\": \"22\"}',NULL,'2026-06-02 16:57:54'),(57,9,'RECORD_DELIVERY_MAN_COLLECTION','delivery_man_collections',4,NULL,NULL,NULL,'2026-06-02 16:59:25'),(58,9,'CREATE_DIRECT_SALE','bills',8,NULL,'{\"billNumber\": \"DS-2026-06-00003\"}',NULL,'2026-06-02 17:04:25'),(59,9,'RECORD_STOCK_RECEIPT','stock_receipts',5,NULL,'{\"companyId\": \"2\", \"totalValue\": 0}',NULL,'2026-06-03 10:29:55'),(60,9,'RECORD_STOCK_RECEIPT','stock_receipts',6,NULL,'{\"companyId\": \"2\", \"totalValue\": 0}',NULL,'2026-06-03 10:30:51'),(61,9,'MANUAL_STOCK_ADD','products',36,NULL,NULL,NULL,'2026-06-03 10:36:18'),(62,9,'CONVERT_ORDER_TO_BILL','orders',7,NULL,'{\"billId\": 9, \"billNumber\": \"OB-2026-06-00001\"}',NULL,'2026-06-03 10:52:22'),(63,9,'CONVERT_ORDER_TO_BILL','orders',8,NULL,'{\"billId\": 10, \"billNumber\": \"OB-2026-06-00002\"}',NULL,'2026-06-03 10:55:13'),(64,9,'CONVERT_ORDER_TO_BILL','orders',9,NULL,'{\"billId\": 11, \"billNumber\": \"OB-2026-06-00003\"}',NULL,'2026-06-03 11:20:12'),(65,9,'CONVERT_ORDER_TO_BILL','orders',10,NULL,'{\"billId\": 12, \"billNumber\": \"OB-2026-06-00004\"}',NULL,'2026-06-03 11:26:58');
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
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill_items`
--

LOCK TABLES `bill_items` WRITE;
/*!40000 ALTER TABLE `bill_items` DISABLE KEYS */;
INSERT INTO `bill_items` VALUES (11,6,12,56,0,216.00,217728.00),(12,7,16,4,0,283.34,20400.48),(13,7,21,2,0,283.34,10200.24),(14,7,30,2,0,283.34,10200.24),(15,8,21,1,0,283.34,5100.12),(16,8,16,1,0,283.34,5100.12),(17,9,8,6,0,275.00,29700.00),(18,9,22,4,0,295.00,21240.00),(19,9,30,3,0,295.00,15930.00),(20,9,16,2,0,295.00,10620.00),(21,10,9,0,5,220.00,1100.00),(22,10,12,0,5,220.00,1100.00),(23,10,22,0,5,295.00,1475.00),(24,11,8,6,0,275.00,29700.00),(25,11,30,3,0,295.00,15930.00),(26,11,16,2,0,295.00,10620.00),(27,12,23,10,0,275.00,49500.00);
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
  `status` enum('assigned','partially_recovered','fully_recovered','returned_to_pool') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'assigned',
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill_recovery_assignments`
--

LOCK TABLES `bill_recovery_assignments` WRITE;
/*!40000 ALTER TABLE `bill_recovery_assignments` DISABLE KEYS */;
INSERT INTO `bill_recovery_assignments` VALUES (5,6,22,'2026-06-02',9,'returned_to_pool','2026-06-02 16:57:21','2026-06-02 16:57:33'),(6,6,22,'2026-06-02',9,'assigned','2026-06-02 16:57:54',NULL);
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
  `bill_type` enum('order_booker','direct_shop','salesman') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `bill_date` date NOT NULL,
  `bill_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gross_amount` decimal(12,2) NOT NULL,
  `advance_deducted` decimal(12,2) NOT NULL DEFAULT '0.00',
  `net_amount` decimal(12,2) NOT NULL,
  `amount_paid` decimal(12,2) NOT NULL DEFAULT '0.00',
  `outstanding_amount` decimal(12,2) NOT NULL,
  `status` enum('open','partially_paid','cleared') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bills`
--

LOCK TABLES `bills` WRITE;
/*!40000 ALTER TABLE `bills` DISABLE KEYS */;
INSERT INTO `bills` VALUES (6,NULL,115,'direct_shop','2026-06-02','DS-2026-06-00001',217728.00,0.00,217728.00,217728.00,0.00,'cleared',9,'2026-06-02 08:51:47'),(7,NULL,173,'direct_shop','2026-06-02','DS-2026-06-00002',40800.96,0.00,40800.96,0.00,40800.96,'open',9,'2026-06-02 16:47:43'),(8,NULL,258,'direct_shop','2026-06-02','DS-2026-06-00003',10200.24,0.00,10200.24,0.00,10200.24,'open',9,'2026-06-02 17:04:25'),(9,7,120,'order_booker','2026-06-03','OB-2026-06-00001',77490.00,0.00,77490.00,0.00,77490.00,'open',9,'2026-06-03 10:52:22'),(10,8,282,'order_booker','2026-06-03','OB-2026-06-00002',3675.00,0.00,3675.00,0.00,3675.00,'open',9,'2026-06-03 10:55:13'),(11,9,120,'order_booker','2026-06-03','OB-2026-06-00003',56250.00,0.00,56250.00,0.00,56250.00,'open',9,'2026-06-03 11:20:12'),(12,10,52,'order_booker','2026-06-03','OB-2026-06-00004',49500.00,0.00,49500.00,0.00,49500.00,'open',9,'2026-06-03 11:26:58');
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
  `entry_type` enum('salesman_sale','recovery','delivery_man_collection') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` int unsigned DEFAULT NULL,
  `reference_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL,
  `cash_date` date NOT NULL,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_entry_type_date` (`entry_type`,`cash_date`),
  KEY `idx_cash_date` (`cash_date`),
  KEY `fk_cce_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_cce_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `centralized_cash_entries`
--

LOCK TABLES `centralized_cash_entries` WRITE;
/*!40000 ALTER TABLE `centralized_cash_entries` DISABLE KEYS */;
INSERT INTO `centralized_cash_entries` VALUES (6,'delivery_man_collection',4,'delivery_man_collections',217728.00,'2026-06-02',9,'2026-06-02 16:59:25');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `claim_value` decimal(12,2) NOT NULL,
  `status` enum('pending','cleared') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `cleared_at` datetime DEFAULT NULL,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_status` (`company_id`,`status`),
  KEY `fk_claim_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_claim_company` FOREIGN KEY (`company_id`) REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_claim_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `company_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `phone_1` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_2` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `gst_ntn` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sales_tax` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cnic` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `backup_time` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '23:00',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_profile`
--

LOCK TABLES `company_profile` WRITE;
/*!40000 ALTER TABLE `company_profile` DISABLE KEYS */;
INSERT INTO `company_profile` VALUES (1,'Shakeel Traders','Shakeel Ahmad','Ali Town , Karrianwala Road Khurrianwala , Faisalabad','03049835773','03336624974','shakeeltraders346@gmail.com','3310406495513',NULL,'33104-0649551-3',NULL,'23:00','2026-05-30 15:18:22');
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
INSERT INTO `delivery_man_collections` VALUES (4,6,2,217728.00,'2026-06-02',9,'2026-06-02 16:59:25');
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
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_men`
--

LOCK TABLES `delivery_men` WRITE;
/*!40000 ALTER TABLE `delivery_men` DISABLE KEYS */;
INSERT INTO `delivery_men` VALUES (2,'Arslan Deliveryman','03278551485',1,'2026-05-30 15:24:03'),(3,'Kamran Deliveryman',NULL,1,'2026-05-30 15:24:30');
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
  `expense_type` enum('fuel','daily_allowance','vehicle_maintenance','office','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `expense_date` date NOT NULL,
  `related_user_id` int unsigned DEFAULT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `issuance_items`
--

LOCK TABLES `issuance_items` WRITE;
/*!40000 ALTER TABLE `issuance_items` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (11,6,21,3,0,3,0,283.34),(12,6,16,4,0,4,0,283.34),(13,6,22,1,0,1,0,283.34),(14,7,8,6,0,6,0,266.67),(15,7,22,4,0,4,0,283.34),(16,7,30,3,0,3,0,283.34),(17,7,16,2,0,2,0,283.34),(18,8,9,0,5,0,5,289.00),(19,8,12,0,5,0,5,291.00),(20,8,22,0,5,0,5,285.00),(21,9,8,6,0,6,0,266.67),(22,9,30,3,0,3,0,283.34),(23,9,16,2,0,2,0,283.34),(24,10,23,10,0,10,0,266.67);
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
  `status` enum('pending','stock_adjusted','converted','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `stock_check_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_booker_date` (`order_booker_id`,`created_at_device`),
  KEY `idx_shop` (`shop_id`),
  KEY `idx_status` (`status`),
  KEY `idx_route` (`route_id`),
  CONSTRAINT `fk_order_booker` FOREIGN KEY (`order_booker_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_order_route` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`),
  CONSTRAINT `fk_order_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (6,22,75,9,'2026-06-03 10:51:32',NULL,'pending',NULL,'2026-06-03 10:51:32'),(7,22,120,7,'2026-06-03 10:51:32',NULL,'converted',NULL,'2026-06-03 10:51:32'),(8,22,282,14,'2026-06-03 10:51:32',NULL,'converted',NULL,'2026-06-03 10:51:32'),(9,22,120,7,'2026-06-03 11:19:07',NULL,'converted',NULL,'2026-06-03 11:19:07'),(10,22,52,7,'2026-06-03 11:26:39',NULL,'converted',NULL,'2026-06-03 11:26:39');
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
  `sku_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `brand` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (4,'SKU01633','BP Prince Mini Star 18.0g 12x18 Rs.20','CBL',18,220.00,215.00,0,0,36,0,'2026-05-30 16:33:34','2026-05-31 15:26:33'),(5,'SKU01873','BP OREO CHOCOLATE 19.0g 16x18 Rs20','CBL',18,220.00,215.00,0,0,36,0,'2026-05-30 16:33:34','2026-05-31 15:26:14'),(6,'SKU01898','SP Bakeri Butter 33g 6x24 Rs.50','CBL',24,275.00,269.00,0,0,36,1,'2026-05-30 16:33:34','2026-06-01 14:59:30'),(7,'SKU01924','SP Wheatable SF 38.0g 6x18 Rs.50','CBL',18,275.00,270.00,1,7,36,1,'2026-05-30 16:33:34','2026-06-02 12:47:59'),(8,'SKU01963','BP Tiger 18.0g 30x18 Rs 10','CBL',18,275.00,269.44,11,3,36,1,'2026-05-30 16:33:34','2026-06-03 11:20:12'),(9,'SKU02244','BP Mini Oreo Original 10.0g 24x18 Rs.10','CBL',18,220.00,213.00,17,6,36,1,'2026-05-30 16:33:34','2026-06-03 10:55:13'),(10,'SKU02276','SP Prince Chocolate 57g 6x24 Rs50','CBL',24,275.00,268.76,28,2,36,1,'2026-05-30 16:33:35','2026-06-03 10:29:55'),(11,'SKU02368','BP Oreo Original 19g 16x18 Rs20','CBL',18,295.00,286.11,0,0,36,0,'2026-05-30 16:33:35','2026-05-31 15:26:24'),(12,'SKU02506','BP Zeera Plus 32.4g 12x18 Rs.20','CBL',18,220.00,216.67,4,10,36,1,'2026-05-30 16:33:35','2026-06-03 10:55:13'),(13,'SKU02581','SP TUC 44.16g 8x18 Rs40 (12biscuits)','CBL',18,295.00,286.11,0,2,36,1,'2026-05-30 16:33:35','2026-06-02 13:05:36'),(14,'SKU02583','BP TUC 22.08g 15x18 Rs.20 (6biscuits)','CBL',18,295.00,286.11,4,3,36,1,'2026-05-30 16:33:35','2026-06-02 12:38:03'),(15,'SKU02584','TP TUC 11.04g 30x18 Rs.10 (3 biscuits)','CBL',18,275.00,269.00,2,2,36,1,'2026-05-30 16:33:35','2026-06-02 12:36:29'),(16,'SKU02625','SP Zeera Plus 59.4g 8x18 Rs 40 (11 Bics)','CBL',18,295.00,286.11,80,6,36,1,'2026-05-30 16:33:35','2026-06-03 11:20:12'),(17,'SKU02635','SP Milco LU Double Milk 48.6g 6x18 Rs40','CBL',18,295.00,286.11,0,0,36,1,'2026-05-30 16:33:35','2026-05-30 16:33:35'),(18,'SKU02680','BP Cadbury Centered Filled 25.0g (8x18) Rs.40','CBL',18,295.00,286.11,15,3,36,1,'2026-05-30 16:33:35','2026-06-02 12:56:09'),(19,'SKU02770','BP Gala Egg 20.0g 1x74 1 Rs10 4BP 1BP','CBL',18,295.00,286.11,0,0,36,0,'2026-05-30 16:33:35','2026-05-31 15:24:31'),(20,'SKU02775','VP Bakeri Khaas 56.04g 6x18 Rs.40 12bis','CBL',18,295.00,286.11,10,14,36,1,'2026-05-30 16:33:35','2026-06-03 10:29:55'),(21,'SKU02831','SP Candi Orig. 62.7g 8x18 Rs.40 (11Bisc)','CBL',18,295.00,286.11,8,13,36,1,'2026-05-30 16:33:35','2026-06-02 17:04:25'),(22,'SKU02893','VP Gala Egg 56.4g 8x18 Rs.40 (12 Bisc)','CBL',18,295.00,286.11,0,2,2,1,'2026-05-30 16:33:35','2026-06-03 10:55:13'),(23,'SKU02894','SP Gala Egg 42.3g 10x18 Rs.30 (9 Bisc)','CBL',18,275.00,269.00,0,8,36,1,'2026-05-30 16:33:35','2026-06-03 11:26:58'),(24,'SKU02914','TP Candi Orig 17.1g 30x18 Rs.10 (3 bisc)','CBL',18,275.00,269.00,0,0,36,1,'2026-05-30 16:33:36','2026-06-01 15:00:50'),(25,'SKU02919','SP Milco LU DM 32.4g 8x18 Rs40 (1BPCP)','CBL',18,295.00,286.11,0,0,36,1,'2026-05-30 16:33:36','2026-05-30 16:33:36'),(26,'SKU02950','SP Oreo Org 36.8g 8x18 (+1BP CP) Rs 40','CBL',18,295.00,286.11,0,0,36,1,'2026-05-30 16:33:36','2026-05-30 16:33:36'),(27,'SKU02989','SP Bakeri Bistiks 40g 8x18 Rs.40','CBL',18,295.00,286.11,0,0,36,1,'2026-05-30 16:33:36','2026-05-30 16:33:36'),(28,'SKU02994','VP Oreo Orig 55.2g 6x18 Rs 50 +1 VPCP','CBL',18,280.00,275.00,0,0,36,1,'2026-05-30 16:33:36','2026-06-01 15:08:19'),(29,'SKU03002','VP Oreo Orig 54g 6x18 Rs 50 (6 bisc)','CBL',18,275.00,270.00,6,15,36,1,'2026-05-30 16:33:36','2026-06-02 12:37:26'),(30,'SKU03003','SP Oreo Org 36g 8x18 Rs 40','CBL',18,295.00,286.11,5,7,36,1,'2026-05-30 16:33:36','2026-06-03 11:20:12'),(31,'SKU03059','BP Gala Egg 14.1g 70 5 Rs10 70BP 5BP','CBL',18,295.00,286.11,0,0,36,0,'2026-05-30 16:33:36','2026-05-31 15:24:26'),(32,'SKU02019','BP Tiger 18.0g 30x18 Rs 10 [CP+2BP]','CBL',18,280.00,270.00,2,12,25,1,'2026-06-01 14:56:36','2026-06-02 12:46:57'),(33,'[SKU02891]','	VP Gala Egg 56.4g 8x18 Rs.40 (1 HRCP) ','CBL',18,296.00,288.00,5,12,2,1,'2026-06-02 12:45:13','2026-06-02 12:45:59'),(34,'[SKU03064]','BP Cadbury Cookies 25.0g 8x18 1CP BP Rs.40','CBL',18,295.00,287.00,4,17,2,1,'2026-06-02 13:02:02','2026-06-02 13:05:14'),(35,'[SKU02257]','SP Bakeri NanKhatai 44.8g 8x18Rs40','CBL',18,295.00,286.00,0,7,2,1,'2026-06-02 13:07:36','2026-06-02 13:08:17'),(36,' [ SKU01899 ]','	SP Bakeri Coconut 33g 6x18 Rs.50 ','CBL',18,295.00,286.00,2,14,2,1,'2026-06-03 09:54:17','2026-06-03 10:36:18'),(37,'[SKU02893]','VP Gala Egg 56.4g 8x18 Rs.40 (12 Bisc)','CBL',18,295.00,286.00,0,0,2,1,'2026-06-03 10:35:04','2026-06-03 10:35:04');
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
  `payment_method` enum('cash','bank_transfer') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recovery_collections`
--

LOCK TABLES `recovery_collections` WRITE;
/*!40000 ALTER TABLE `recovery_collections` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `return_items`
--

LOCK TABLES `return_items` WRITE;
/*!40000 ALTER TABLE `return_items` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route_assignments`
--

LOCK TABLES `route_assignments` WRITE;
/*!40000 ALTER TABLE `route_assignments` DISABLE KEYS */;
INSERT INTO `route_assignments` VALUES (10,6,10,'2026-06-02','2026-06-02 08:43:14'),(11,7,22,'2026-06-03','2026-06-03 10:37:51'),(12,9,22,'2026-06-03','2026-06-03 10:37:51'),(13,8,22,'2026-06-03','2026-06-03 10:37:51');
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
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_route_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES (5,'Main Bazar Jhumra Road',1,'2026-05-30 14:49:08'),(6,'Bara Latianwala FSD Road',1,'2026-05-30 14:49:28'),(7,'Adda Khurrianwala',1,'2026-05-30 14:49:42'),(8,'Karrian Wala Road',1,'2026-05-30 14:56:19'),(9,'Jarranwala Road',1,'2026-05-30 14:57:40'),(10,'Jandwali Road',1,'2026-05-30 14:58:01'),(11,'Johal Adda',1,'2026-05-30 14:58:21'),(12,'Madina Town Lahore Road',1,'2026-05-30 14:58:37'),(13,'Nazeer Town Lahore Road',1,'2026-05-30 14:58:51'),(14,'Purani Abbadi',1,'2026-05-30 14:59:07'),(15,'Main Bazar 5 Marla Schem Rehman Colony',1,'2026-05-30 14:59:36');
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
  `staff_type` enum('salesman','order_booker','delivery_man') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `advance_date` date NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
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
  `staff_type` enum('salesman','order_booker','delivery_man') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_records`
--

LOCK TABLES `salary_records` WRITE;
/*!40000 ALTER TABLE `salary_records` DISABLE KEYS */;
INSERT INTO `salary_records` VALUES (7,12,'salesman',6,2026,35000.00,0.00,NULL,NULL,'2026-06-02 08:58:49');
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
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` int unsigned DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_salesman_date` (`salesman_id`,`issuance_date`),
  KEY `idx_status` (`status`),
  KEY `fk_si_approved_by` (`approved_by`),
  CONSTRAINT `fk_si_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_si_salesman` FOREIGN KEY (`salesman_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salesman_issuances`
--

LOCK TABLES `salesman_issuances` WRITE;
/*!40000 ALTER TABLE `salesman_issuances` DISABLE KEYS */;
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
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salesman_returns`
--

LOCK TABLES `salesman_returns` WRITE;
/*!40000 ALTER TABLE `salesman_returns` DISABLE KEYS */;
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
INSERT INTO `sessions` VALUES ('1xZcxgSeeKcmi55JhQh0S9k5zJUi8UZE',1780551595,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T05:39:55.351Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('2R97ZbWJhtT_Fns9YNuasyHvg6MJvEAN',1780554586,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T06:29:46.223Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('5aBDwIozOK_ePgCe5_T10OrIYpfFPdfH',1780551521,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T05:38:40.570Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('Eh-KbMhRlVo4LFk1AO66tHPQJPP1F4ij',1780554400,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T06:26:39.534Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('IY0gopoypprgYDjpaXptsVTI8F3tYL_o',1780551598,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T05:39:58.443Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('QggVcL4xMrCvqQvDijziT159IG7-LsdI',1780551517,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T05:38:36.786Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('SAzXgyfeukk8-_Q1dhMBcztcagYm0Ml_',1780553629,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T06:13:48.747Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('WVE8l666hzxK3jIWdeAa4MGWzVWXgfAE',1780551942,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T05:45:42.390Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('ZAkugDe5TUnoHQHEIAhcU7jSaYCUdcnr',1780553948,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T06:19:07.648Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('fc5VfO_99u0wQtxPCWqbd50L7r9XcUQm',1780554776,'{\"cookie\":{\"originalMaxAge\":86399998,\"expires\":\"2026-06-04T06:28:58.423Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{},\"user\":{\"id\":9,\"full_name\":\"Administrator\",\"username\":\"admin\",\"role\":\"admin\"}}'),('mlr7IfeRd_e2Y9DiNAUHm200xF4nx569',1780552133,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T05:48:52.827Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('sNTKeWUuEzDdESVnqA8IQwq_gyUdXcEH',1780551505,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T05:38:24.748Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}'),('u34RSDGwnvP2rMOPgY9OOlFUACUMLSN7',1780552293,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-06-04T05:51:32.765Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{}}');
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
  `payment_method` enum('cash','bank_transfer','cheque','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop` (`shop_id`),
  KEY `fk_sadv_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_sadv_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_sadv_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_advances`
--

LOCK TABLES `shop_advances` WRITE;
/*!40000 ALTER TABLE `shop_advances` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_last_prices`
--

LOCK TABLES `shop_last_prices` WRITE;
/*!40000 ALTER TABLE `shop_last_prices` DISABLE KEYS */;
INSERT INTO `shop_last_prices` VALUES (11,115,12,216.00,'2026-06-02 08:51:47'),(12,173,16,283.34,'2026-06-02 16:47:43'),(13,173,21,283.34,'2026-06-02 16:47:43'),(14,173,30,283.34,'2026-06-02 16:47:43'),(15,258,21,283.34,'2026-06-02 17:04:25'),(16,258,16,283.34,'2026-06-02 17:04:25'),(17,120,8,275.00,'2026-06-03 11:20:12'),(18,120,22,295.00,'2026-06-03 10:52:22'),(19,120,30,295.00,'2026-06-03 11:20:12'),(20,120,16,295.00,'2026-06-03 11:20:12'),(21,282,9,220.00,'2026-06-03 10:55:13'),(22,282,12,220.00,'2026-06-03 10:55:13'),(23,282,22,295.00,'2026-06-03 10:55:13'),(27,52,23,275.00,'2026-06-03 11:26:58');
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
  `entry_type` enum('bill','payment_delivery_man','recovery','advance_payment','advance_adjustment','claim_credit') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` int unsigned DEFAULT NULL,
  `reference_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `debit` decimal(12,2) NOT NULL DEFAULT '0.00',
  `credit` decimal(12,2) NOT NULL DEFAULT '0.00',
  `balance_after` decimal(12,2) NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `entry_date` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shop_date` (`shop_id`,`entry_date`),
  KEY `idx_entry_type` (`entry_type`),
  CONSTRAINT `fk_sle_shop` FOREIGN KEY (`shop_id`) REFERENCES `shops` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_ledger_entries`
--

LOCK TABLES `shop_ledger_entries` WRITE;
/*!40000 ALTER TABLE `shop_ledger_entries` DISABLE KEYS */;
INSERT INTO `shop_ledger_entries` VALUES (11,115,'bill',6,'bills',217728.00,0.00,217728.00,'Bill DS-2026-06-00001','2026-06-02','2026-06-02 08:51:48'),(12,173,'bill',7,'bills',40800.96,0.00,40800.96,'Bill DS-2026-06-00002','2026-06-02','2026-06-02 16:47:43'),(13,115,'payment_delivery_man',4,'delivery_man_collections',0.00,217728.00,0.00,'Delivery man payment for DS-2026-06-00001','2026-06-02','2026-06-02 16:59:25'),(14,258,'bill',8,'bills',10200.24,0.00,10200.24,'Bill DS-2026-06-00003','2026-06-02','2026-06-02 17:04:25'),(15,120,'bill',9,'bills',77490.00,0.00,77490.00,'Bill OB-2026-06-00001','2026-06-03','2026-06-03 10:52:22'),(16,282,'bill',10,'bills',3675.00,0.00,3675.00,'Bill OB-2026-06-00002','2026-06-03','2026-06-03 10:55:13'),(17,120,'bill',11,'bills',56250.00,0.00,133740.00,'Bill OB-2026-06-00003','2026-06-03','2026-06-03 11:20:12'),(18,52,'bill',12,'bills',49500.00,0.00,49500.00,'Bill OB-2026-06-00004','2026-06-03','2026-06-03 11:26:58');
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
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `route_id` int unsigned DEFAULT NULL,
  `shop_type` enum('retail','wholesale') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'retail',
  `price_edit_allowed` tinyint(1) NOT NULL DEFAULT '0',
  `price_max_discount_pct` decimal(5,2) DEFAULT '0.00',
  `price_min_pct` decimal(5,2) DEFAULT NULL,
  `price_max_pct` decimal(5,2) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_route` (`route_id`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `fk_shop_route` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=312 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shops`
--

LOCK TABLES `shops` WRITE;
/*!40000 ALTER TABLE `shops` DISABLE KEYS */;
INSERT INTO `shops` VALUES (1,'Grand Mart sweets Bakers Fast Food','M Bineemeen','3006693359','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:17'),(2,'Bilal kiryana store','M Shahid','3367613557','CHAK 189 RB RASULPUR',6,'retail',1,2.00,NULL,NULL,1,'2026-05-30 15:45:17'),(3,'Madina general kiryana store','Majid','3423578521','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:17'),(4,'Grace Gift Center','Waheed','3457027447','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:17'),(5,'Madina Kiryana General Store','Qasim','3407852918','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:17'),(6,'Abdul Raziq K S','Abdul Raziq','3377518527','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:17'),(7,'Asif kiryana store sweets bakers','Fahran Javad','3009497170','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:17'),(8,'Shahid Kiryana store','M umar','3059146605','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(9,'Safi Traders','Safi','030973270340','CHAK 189 RB RASULPUR',6,'wholesale',1,5.00,NULL,NULL,1,'2026-05-30 15:45:18'),(10,'Waqas K S','Yasir','3437612838','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(11,'Haq Bahoo','Abdul Manaf','3048942683','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(12,'Atari kiryana Jenral stor','Athir Also','3007940173','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(13,'Shahzaib kiryana store Drink Corner','M Shahzaib','3424578631','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(14,'Ghousia Kiryana store','M Tariq','3245005033','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(15,'Sultan Pan Shop',NULL,'03030604204',NULL,6,'retail',1,3.00,NULL,NULL,1,'2026-05-30 15:45:18'),(16,'Zulfiqar kiryana store','Zulfiqar','3217614189','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(17,'Danish kiryana store','Shahzad','3045572019','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(18,'Al shareef super store','M yaseen','3226362709','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(19,'Faheem K S','M Ameen','3442870281','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(20,'Mehar Gift Center G S','Murad','3237285666','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(21,'E Mart K S','Nazaqat Ali','3012393285','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(22,'Malik kiryana store','M Shabbir','3086730710','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:18'),(23,'Irfan K S','M Arif','3247055889','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(24,'Usman K S','Usman','3025263189','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(25,'pappo g pan shop','M Saeed','3007664490','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(26,'Momin kariyana Store',NULL,'03077485366',NULL,6,'retail',1,3.00,NULL,NULL,1,'2026-05-30 15:45:19'),(27,'Hassan Kiryana store','Abdul Rasheed','3237619968','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(28,'Abbas kiryan stor','M Abbas','3247387524','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(29,'Mian Mudassir G S','Mudassir Abbas','3057207330','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(30,'Alharam general store','Naveed','3066769141','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(31,'Butt K S','Manzoor Hussain','3007294919','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(32,'Shahid kiryana store','Shahid','3063957523','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(33,'Haji M Rafique kiryana store','Saeed Ahmad','3075282707','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(34,'Babar Traders','Babar Ali','3007266689','CHAK 189 RB RASULPUR',NULL,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(35,'Bismillah kariyana Store 2',NULL,NULL,'CHAK 189 RB RASULPUR',6,'retail',1,2.00,NULL,NULL,1,'2026-05-30 15:45:19'),(36,'Rizvi Kiryana Store','M.Amjad','3036497121','CHAK 189 RB RASULPUR',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:19'),(37,'Zafar K S','M Zafar','3007602543','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(38,'ERHAM MOBILE T S','Adnan','3007723249','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(39,'Adnan Pan Shop','M Adnan','3027176434','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(40,'javaad K S','M Javaad','3047582642','Bara Latianwala FSD Road',NULL,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(41,'Hafiz PS','Shahzad','3005673100','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(42,'M Jameel PS','Jameel','3339920866','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(43,'Awais Karni PS','Latief','3007105300','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(44,'Bhai PS','Ilyas','3000872640','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(45,'Hafiz PS','Asif','3022232266','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(46,'Mehmood KS','Waqas','3037717773','Adda Khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(47,'Nasir PS','Nasir','3007980085','Adda Khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(48,'Lohari Sweets','Basharat','3006687862','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(49,'Irfan Khalid PS','Irfan','3023448740','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(50,'Saad Telecom','waqas','3008602539','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(51,'Hafiz PS','Hafiz irslan','3096956373','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(52,'Qadri KS','Ashaq','3046200497','Adda Khurrianwala',7,'wholesale',1,3.00,NULL,NULL,1,'2026-05-30 15:45:20'),(53,'Malik Yaseen KS','Yaseen','3009781751','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(54,'Sufi Sweets','Zeshan','3000676148','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:20'),(55,'muzammal k/s','Muzammal','3346402710','Karrian Wala road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(56,'Basra K/S','Mursaleen','3046890760','Karrian Wala road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(57,'Nasir pan shop','Nasir','3007980085','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(58,'Maki Madni k/S','Shahid','3035797179','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(59,'Talha Ayub','Ayub','3073009889','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(60,'Nasar Bajwa k/s','Nasar','3006664659','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(61,'Sheean Sweet','sher Afgan','3006642206','Karrian Wala Road',NULL,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(62,'Alfahid k/S','Allah Dettah','3028435860','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(63,'Shah Jee K/S','Syed Muzammal Hussain','3007233995','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(64,'Bismillah K/S','Jasim','3000687903','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(65,'Liaqat Drink corner','Niamat','3072697350','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(66,'Bahia Cold Corner','Ilyas','3000872640','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(67,'Awais Qarni','Mohammad zee Shan Atari','3037105300','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(68,'Mohammad Jameel P/S','Mohammad Naveed','3339920866','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(69,'Awan Sweet G/S','Sarwar Awan','3001466266','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(70,'Hafiz pan Shop','Hafiz Shahzad','3005673100','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(71,'Makkha K/S','Abid','3427864889','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:21'),(72,'Nadeem P/S','Nadeem','3007260294','Jarranwala road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(73,'pehalwan Sweet','Abdul Gafoor','3007677631','Jarranwala road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(74,'Nadeem p /shop 2','Saleem','3054247077','Jarranwala road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(75,'Baba Akram','Baba Akram','3008656985','Jarranwala road',9,'wholesale',1,3.00,NULL,NULL,1,'2026-05-30 15:45:22'),(76,'Javeed ijaz k stor','Javeed','3013658266','Jarranwala road',9,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(77,'Lahorei sweet','Basharat Ali','3006687862','Jarranwala road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(78,'Hafiz Imran general store','Hafiz m imran','3003501266','Jandwali Road',10,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(79,'Foji kariana store','sanaulaha','3063992266','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(80,'Awan KS','Asad','3006900068','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(81,'Azeem Mart','faheem','3339799127','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(82,'Marhabah KS','Awais','3143912105','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(83,'Arshad KS','irshad','3029234154','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(84,'Rashid KS','Rashad','3017147724','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(85,'Sajjad KS','sajjad','3076717368','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(86,'Shahid Gujjar KS','shahid','3007600331','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(87,'Rana Liaqat KS','liaqat','3017165739','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(88,'Madnia Sweets','Razaq','3016009872','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(89,'Ideal Sweets','Azeem','3029821100','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(90,'Sartaj KS','Mohammad saleem','3017177397','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:22'),(91,'Fuji Ishfaq KS','Javed','3015857642','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(92,'Al Makkah KS','Abid','3427864889','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(93,'Dar ul Ahsan Sweets','saeed','3061055045','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(94,'Shafiq Traders','Shahfeeq','3082070736','Jandwali Road',10,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(95,'Arham KS','Rana irfan','3009443683','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(96,'J Mart','Jawad ul hussan','3457939299','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(97,'Suleman KS','Shahfeeq','3038010214','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(98,'Noorani KS','Murtaza','3004812686','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(99,'MS KS','Anayat','3424508203','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(100,'Millit Traders','Shahid','3017039470','Jandwali Road',10,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(101,'Al Haram KS','Waqas','3016079365','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(102,'Shahid Makki Madni KS','Shahid','3007655834','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(103,'Mursleen KS','Yaseen','3046890760','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(104,'Allah Towakal KS','Arshad','3007662774','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(105,'Jutt KS','Asghar','3067162235','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(106,'Bilal KS','Akram','3027134457','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(107,'Malik KS','Sarfaraz','3486860306','Karrian Wala Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(108,'Tllah Ayyob KS','Ayoub','3073009889','Karrian Wala Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(109,'Panno Traders','Shair afgan','3006642206','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:23'),(110,'Al Fahad KS','Fahid','3000220325','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(111,'Malik Akram KS','Akram','3339929985','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(112,'Shah Gee KS','Muzammil','3007233995','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(113,'Shah Gee Traders','Mudaser','3007911392','Adda khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(114,'Al Rehman KS','Mohammad Akram','3008698272','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(115,'786 KS','Jasam','3000687903','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(116,'Liaqat CC','Niyamet','3072697350','Karrian Wala Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(117,'Mirza pan shop','Mirza khuram','3003392993','Karrian Wala Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(118,'Al barkat sweet and bakers 1','Saeed gujjar','3061055045','Adda khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(119,'khoshi ks','shahbaz','3037171772','Adda khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(120,'Ahtsham sweets','Ahtsham','3056407409','Adda khurrianwala',7,'wholesale',1,4.00,NULL,NULL,1,'2026-05-30 15:45:24'),(121,'Sath g ks','Sath asim','3403652095','Adda khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(122,'Jutt ks','yasar jutt','3035161290','Adda khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(123,'Mian PS','Azkar','3054779630','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(124,'Mian Affaq TS','waqas','3045465608','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(125,'Arham Mobile & TS','M. Adnan','3007623249','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(126,'Aslam KS','Aslam','0','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(127,'Qamar KS','Qamer','3009514959','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(128,'Zahor GS','Kaseem','3004523532','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(129,'Allah Hoo KS','Sultan','3007216420','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:24'),(130,'M Asif Ali KS','M. Asif','3479018103','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(131,'Sajid KS','Sajid','3074732118','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(132,'Kashmir GS','Shabeer','3013656553','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(133,'Kamran KS','Kamran','3016948869','Bara Latianwala FSD Road',6,'retail',1,3.00,NULL,NULL,1,'2026-05-30 15:45:25'),(134,'Ahmad BD','Arshad','3336564005','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(135,'Iqbal Sweets & Bakers','Waqas','3006535817','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(136,'Suleman Madina TS','Zawaar','3084876395','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(137,'Arshad PS','Awais','3061712597','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(138,'Main Mobile and Genral Store',NULL,'03007271292','Bara Latianwala FSD Road',6,'retail',1,2.00,NULL,NULL,1,'2026-05-30 15:45:25'),(139,'Al rehmat k stor','sajjad','3046683866','Bara Latianwala FSD Road',6,'retail',1,2.00,NULL,NULL,1,'2026-05-30 15:45:25'),(140,'Awan k stor','Tariq nazeer','3033932755','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(141,'Ali g stor','M. Amer','3006617200','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(142,'Ahsan k stor','Ahsan','3007216420','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(143,'Ziqria g stor','younes','3027044292','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(144,'Al Shirah medical and stor','M. Naveed','3338982493','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(145,'Ateeq k stor','Strew sarwar','3007260833','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(146,'Sabi ul Hassan k stor','Sabi ul hussan','3343533033','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(147,'zapped Ali g/s','zahoor','3004523532','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:25'),(148,'Kaqam And Son Karyana Store','M Qasam','3067009733','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(149,'Tahir K S','M Tahir','3000935200','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(150,'Hamza K S','M Hamza','3343533033','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(151,'Malik Asif K S','M Asif','3247660370','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(152,'Paradise Store','M Basit','3245066430','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(153,'Madina K S','M IDREES','3081148237','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(154,'Bismillah kariyana Store 1',NULL,NULL,'Bara Latianwala FSD Road',6,'retail',1,2.00,NULL,NULL,1,'2026-05-30 15:45:26'),(155,'Haroon Karyana Store','M Haroon','3458666371','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(156,'Allah Tawaqal Karyana Store','Nadiam Nawaz','3069512524','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(157,'Jawaad Karyana Store','M Jawaad','3015253984','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(158,'Irshad Ali K S','M Irshad','3366566062','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(159,'Malik G Karyana Store','Malik Shahad','3067221880','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(160,'Madina Mobile Shop','M Azar hussain','3026022143','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(161,'Jutt Karyana Store','Sher Muhammad','3048562745','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:26'),(162,'Zunair K S','M Zunair','3004182296','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(163,'Khuba Karyana Store','Aslam','3448247713','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(164,'Umer Karyana Store','M Umer','3054258652','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(165,'Al Madina Pan Shop','M Fiasal','3017043182','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(166,'AL MAKKAH G S M S','Umer Razak','3006962200','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(167,'Shaheen Book Dipo','M Shaheen','3007297725','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(168,'Abubakar K S','M Abubakar','3017452385','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(169,'Tayyab Karyana Store','M Tayyab','3087781442','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(170,'Pasha PCO','Musan Seed','3096527200','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(171,'Mahar Karyana Store','Main Awias','3000732597','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:27'),(172,'ABID TEA STALL','M Wajad','3235277546','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(173,'Adnan Pan Shop','M Adnan','3027176434','Bara Latianwala FSD Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(174,'Main Teeq K S','Mian Teeq','3017265243','Bara Latianwala FSD Road',NULL,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(175,'Main Shahid K S','M Shahzad','3007254676','Bara Latianwala FSD Road',6,'wholesale',1,4.00,NULL,NULL,1,'2026-05-30 15:45:28'),(176,'Al Rahmat Mobiles','M Rahmat','03202592001','Bara Latianwala FSD Road',6,'retail',1,3.00,NULL,NULL,1,'2026-05-30 15:45:28'),(177,'EHSAAN K S','M Sultan','3007216420','Bara Latianwala FSD Road',NULL,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(178,'Ali K S','M Ali','3006617200','Bara Latianwala FSD Road',NULL,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(179,'Hafiz kariyana Store','Aftab Akber','3007981150','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(180,'Javeed Ijaz KS','javed','3013656266','Jarranwala Road',NULL,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(181,'Bhola PS','Imran','3007605761','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(182,'Baba Akram KS','Ghulam sabar','3008656985','Jarranwala Road',NULL,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(183,'Nadeem PS','Saleem','3226266805','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(184,'Bhehlwan Sweets','M sadeeq','3016036018','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(185,'Nadeem GS','Ashraf','3006609958','Jarranwala Road',9,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(186,'Palkia KS','Sakhawat','3006644630','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(187,'Mudasir KS','Mudessar','3007684425','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(188,'Al Minhaj KS','Zeshan','3022497877','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(189,'Geo Supper KS','Ghulam hussain','3027149590','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(190,'Pak School Joniar KS','Asim','3000226266','Jarranwala Road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:28'),(191,'Faheem Dogar KS','Liaqat','3015063116','Jarranwala Road',9,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(192,'Gholdra Sharif KS','Khalid','3007679130','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(193,'Sardar Plaza KS','Shahzad','3007989903','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(194,'New Niaz KS','Ali Ahmed','3006625838','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(195,'Niaz KS','Niyaz ali','3007665309','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(196,'Malik KS','Imtaiyaz','3425804350','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(197,'Ahmad KS','Nawazesh','3457853162','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(198,'Naeem KS','Naeem','3017069282','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(199,'786 Photo Copy','Sarfaraz','3087108761','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(200,'Lala Freed PS','Faryaad','3467770586','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(201,'ZA Bakers','Altaaf','3009715601','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(202,'Malik Riaz KS','Raiz','0','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(203,'Zain KS','Javed','3075373147','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(204,'Qadri KS','Umair','3067074252','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(205,'Niazi KS','Niazi','0','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(206,'Hafiz Qayom TS','Qamer','0','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(207,'Subhan KS','Aslam','3444632597','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(208,'Malik Amir GS','Amir','3006013490','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(209,'Nazeer KS','Saleem','3077296830','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:29'),(210,'Master Shareef KS','Rahman','3054565784','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(211,'Mushtaq TS','Mustaq','3082214169','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(212,'Malik Abdul Haq KS','Aftab','3007964220','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(213,'Mian KS','mean ishtiaq','3007247498','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(214,'Sheikahan De Hatti','Nasir','3067091715','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(215,'Ali Hajwary KS','Malik Salman','3007285636','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(216,'Spiece Home KS','Misn liaqat','3044373737','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(217,'Malik Akbar Sweets','Malik Akbar Sweet','3064824372','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(218,'Nasir Bajwa Ks','nasir','3006664659','Karrian Wala road',NULL,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(219,'Haji Nisar Sweets','Nasar','0','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(220,'Sheikh Gee KS','Mohammad Usman','3000201488','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(221,'Malik Imran KS','Malik Imran','3006629043','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(222,'New Nasir GS','Asif','3067981050','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(223,'Malik Sadique KS','Sadeeq','3063726266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(224,'Ziaqa Sweets & Bakers','Mohammad Shahzad','3017014364','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(225,'Hafiz Mart','Main Saeed','3326800545','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(226,'Jani PS','kamran Shahzad','3004711266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:30'),(227,'Raju PS','Adnan','3056355266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(228,'Yaseen Butt KS','Yaseen','3052507688','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(229,'Malik Shahbaz KS','Nazeer','0','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(230,'Ideal Sweets','imant','3067691277','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(231,'Madni KS','Farhan','3129084111','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(232,'Assad KS','Asid','3001275266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(233,'Methu PS','Farooq','3404076606','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(234,'Bhola Butt KS','Mohammad jameel','3467721456','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(235,'Rana Imtiaz KS','Rana imtiaz','3067057552','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(236,'Zeeshan KS','Zeeshan','3029310561','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(237,'Irfan KS','Irfan','3061211266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(238,'Rana Ijaz KS','Rana Ejaz','3061773547','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(239,'Faisal Shah GS','Faisal','3317279376','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(240,'Al Sayed KS','Ali','3068740833','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(241,'Imran KS','Usman','3126658042','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(242,'Rana Azeem KS','Usman','3057434982','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:31'),(243,'Zoq-E-Shereen','Talha','3206533365','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(244,'Marhaba Mart','tahir','3212631003','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(245,'Haidri Pan Shop','Zaighum Abbas','3217050166','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(246,'Yasir kiryana store','Babar ali','3006648349','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(247,'Mian Muzzamil KS','Basheer','3346402710','Karrian Wala road',8,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(248,'Ilyas KS','Ilyas','3046574233','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(249,'Data Ali Hajwari KS','Asif','3017061363','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(250,'Noshahi KS','Shahbeer','3017025266','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(251,'Ahtasham Ks','Ihtesham','3413814506','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(252,'Farooq KS','Farooq','3067080655','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(253,'Mudasir Hussain KS','Mudesdar','3156026535','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(254,'Shana Behlwan KS','Usman','3030359115','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(255,'Niazi KS','Sajid','3427054986','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(256,'Al Haram KS','Fayaiz','3357125940','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(257,'786 KS','Waqas','3049311396','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(258,'Al Madina GS','zafar','3004048266','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:32'),(259,'Gulam Rasool De Hatti','Irfan','3017124622','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(260,'Butt Chaki Wala','Amer','3017187714','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(261,'Ansari KS','Shahfaqat','3007287552','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(262,'Jutt Tanveer Ilyas KS','Tanveer','3037799013','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(263,'Ahmad KS','Tahir','3046358018','Purani Abbadi',14,'retail',1,3.00,NULL,NULL,1,'2026-05-30 15:45:33'),(264,'Sufyan KS','Ahsan','3415200266','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(265,'Abdul Qadeer KS','Abdul qadrer','3049637148','Purani Abbadi',14,'retail',1,3.00,NULL,NULL,1,'2026-05-30 15:45:33'),(266,'Noman KS','Noman',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(267,'Raiz Gujar K/S','Raiz ',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(268,'Bhai Naveed KS','Naveed','3067044334','Purani Abbadi',14,'retail',1,3.00,NULL,NULL,1,'2026-05-30 15:45:33'),(269,'Uzaifa KS','Saleem','3046091732','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(270,'Allah Dita KS','Allah Dita','3217761077','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(271,'Naseer KS','Naseer',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(272,'Hafiz Mudassar K/S',NULL,NULL,'Purani Abbadi',14,'retail',1,5.00,NULL,NULL,1,'2026-05-30 15:45:33'),(273,'Rana Ahsan KS','Raiz','3007203256','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(274,'Khurram kiryana store','M.Khurram',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(275,'Hafiz kiryana store','Mushtaq ahmad','3216972473','Purani Abbadi',14,'retail',1,6.00,NULL,NULL,1,'2026-05-30 15:45:33'),(276,'AL Haram K/S',NULL,NULL,'Purani Abbadi',14,'retail',1,4.00,NULL,NULL,1,'2026-05-30 15:45:33'),(277,'Mian Asif Kiryana Store','Mian Asif',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:33'),(278,'Haider kiryana store','Muhammad Haider',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-05-30 15:45:34'),(279,'Bismillah K/S',NULL,NULL,NULL,14,'retail',1,4.00,NULL,NULL,1,'2026-06-01 12:16:39'),(280,'Baby Paradise Garments',NULL,NULL,NULL,14,'retail',1,4.00,NULL,NULL,1,'2026-06-01 12:28:04'),(281,'yasir K/S',NULL,NULL,NULL,14,'retail',1,3.00,NULL,NULL,1,'2026-06-01 13:03:33'),(282,'Padhyar K/S',NULL,NULL,NULL,14,'retail',1,5.00,NULL,NULL,1,'2026-06-01 13:06:26'),(283,'Padhyar K/S',NULL,NULL,NULL,NULL,'retail',1,5.00,NULL,NULL,1,'2026-06-01 13:07:40'),(284,'Abad Super Store',NULL,NULL,NULL,14,'retail',1,3.00,NULL,NULL,1,'2026-06-01 13:10:35'),(285,'Shareef and Sami K/S','M Shareef',NULL,NULL,14,'retail',1,3.00,NULL,NULL,1,'2026-06-01 13:12:37'),(286,'Al Madina K/S',NULL,NULL,NULL,14,'retail',1,3.00,NULL,NULL,1,'2026-06-01 13:13:48'),(287,'Bissmillah Ayta Chaki ',NULL,NULL,NULL,14,'retail',1,2.00,NULL,NULL,1,'2026-06-01 13:16:44'),(288,'AL Madina  Mobiles',NULL,NULL,NULL,14,'retail',0,0.00,NULL,NULL,1,'2026-06-01 13:17:55'),(289,'Bilal K/S',NULL,NULL,NULL,14,'retail',1,3.00,NULL,NULL,1,'2026-06-01 13:24:45'),(290,'Urban Foods','Kashif','0325365880',NULL,6,'wholesale',1,5.00,NULL,NULL,1,'2026-06-01 14:08:36'),(291,'Bismillah Traders',NULL,'03008829204',NULL,6,'wholesale',1,3.00,NULL,NULL,1,'2026-06-01 14:14:53'),(292,'Kamal Sweets',NULL,'030271148447',NULL,6,'retail',1,1.00,NULL,NULL,1,'2026-06-01 14:17:21'),(293,'Abina Aqeel kariyana Store',NULL,NULL,NULL,6,'retail',1,3.00,NULL,NULL,1,'2026-06-01 14:21:35'),(294,'Marhaba Mart',NULL,'03004744983',NULL,6,'retail',1,3.50,NULL,NULL,1,'2026-06-01 14:23:08'),(295,'Al Madina Pan Shop',NULL,'03090436182',NULL,6,'retail',1,0.00,NULL,NULL,1,'2026-06-01 14:25:57'),(296,'Tahir and Shahid kariyana Store',NULL,'03000935200',NULL,6,'retail',1,5.00,NULL,NULL,1,'2026-06-01 14:27:25'),(297,'Saad Traders','Saad','03055601542',NULL,6,'wholesale',1,4.00,NULL,NULL,1,'2026-06-01 14:33:45'),(298,'Dani Pan Shop','Dani',NULL,NULL,6,'retail',1,2.00,NULL,NULL,1,'2026-06-01 14:40:58'),(299,'Shahbaz kariyana Store','Shahbaz',NULL,NULL,6,'retail',0,0.00,NULL,NULL,1,'2026-06-01 14:41:59'),(300,'Tayab Subhan kariyana Store','Tayab',NULL,NULL,6,'retail',1,2.00,NULL,NULL,1,'2026-06-01 14:42:54'),(301,'Irfan kariyana Store','Irfan',NULL,NULL,6,'retail',0,0.00,NULL,NULL,1,'2026-06-01 14:43:37'),(302,'Al Shifa Medical Store',NULL,NULL,NULL,6,'retail',1,2.00,NULL,NULL,1,'2026-06-01 14:44:35'),(303,'Hafiz Fresh Fruit',NULL,NULL,NULL,6,'retail',1,2.00,NULL,NULL,1,'2026-06-01 14:45:19'),(304,'Wali Mart',NULL,NULL,NULL,6,'retail',1,3.00,NULL,NULL,1,'2026-06-01 14:46:04'),(305,'Ali kariyana Store',NULL,NULL,NULL,6,'retail',1,3.00,NULL,NULL,1,'2026-06-01 14:48:08'),(306,'Sheel Pump',NULL,NULL,NULL,6,'retail',1,3.00,NULL,NULL,1,'2026-06-01 14:49:53'),(307,'Asif Stationery and kariyana Store','M Asif',NULL,NULL,6,'retail',1,3.00,NULL,NULL,1,'2026-06-01 14:50:46'),(308,'Haris Pan Shop','M Haris',NULL,NULL,6,'retail',1,2.00,NULL,NULL,1,'2026-06-01 15:12:30'),(309,'Family Mart',NULL,NULL,NULL,6,'retail',1,5.00,NULL,NULL,1,'2026-06-01 15:15:55'),(310,'Maher Sweets',NULL,'03269512598',NULL,10,'retail',1,2.00,NULL,NULL,1,'2026-06-01 16:40:58'),(311,'Moshin Chawal Store','Moshin ',NULL,NULL,9,'wholesale',1,4.00,NULL,NULL,1,'2026-06-02 16:29:33');
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
  `movement_type` enum('receipt_supplier','manual_add','bill_deduction','issuance_salesman','return_salesman','direct_sale_deduction') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` int unsigned DEFAULT NULL,
  `reference_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cartons_in` int unsigned NOT NULL DEFAULT '0',
  `loose_in` int unsigned NOT NULL DEFAULT '0',
  `cartons_out` int unsigned NOT NULL DEFAULT '0',
  `loose_out` int unsigned NOT NULL DEFAULT '0',
  `stock_after_cartons` int unsigned NOT NULL,
  `stock_after_loose` int unsigned NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_date` (`product_id`,`created_at`),
  KEY `idx_movement_type` (`movement_type`),
  KEY `fk_sm_created_by` (`created_by`),
  CONSTRAINT `fk_sm_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_sm_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_movements`
--

LOCK TABLES `stock_movements` WRITE;
/*!40000 ALTER TABLE `stock_movements` DISABLE KEYS */;
INSERT INTO `stock_movements` VALUES (17,12,'manual_add',NULL,NULL,56,0,0,0,56,0,NULL,9,'2026-05-31 15:12:13'),(18,12,'direct_sale_deduction',NULL,NULL,0,0,56,0,0,0,NULL,9,'2026-06-02 08:51:47'),(19,16,'manual_add',NULL,NULL,54,6,0,0,54,6,NULL,9,'2026-06-02 12:32:34'),(20,21,'manual_add',NULL,NULL,11,13,0,0,11,13,NULL,9,'2026-06-02 12:34:07'),(21,10,'manual_add',NULL,NULL,8,2,0,0,8,2,NULL,9,'2026-06-02 12:34:50'),(22,30,'manual_add',NULL,NULL,3,7,0,0,3,7,NULL,9,'2026-06-02 12:36:05'),(23,15,'manual_add',NULL,NULL,2,2,0,0,2,2,NULL,9,'2026-06-02 12:36:29'),(24,29,'manual_add',NULL,NULL,6,15,0,0,6,15,NULL,9,'2026-06-02 12:37:26'),(25,14,'manual_add',NULL,NULL,4,3,0,0,4,3,NULL,9,'2026-06-02 12:38:03'),(26,22,'manual_add',NULL,NULL,4,7,0,0,4,7,NULL,9,'2026-06-02 12:39:21'),(27,33,'manual_add',NULL,NULL,5,12,0,0,5,12,NULL,9,'2026-06-02 12:45:59'),(28,32,'manual_add',NULL,NULL,2,12,0,0,2,12,NULL,9,'2026-06-02 12:46:57'),(29,8,'manual_add',NULL,NULL,0,3,0,0,0,3,NULL,9,'2026-06-02 12:47:15'),(30,7,'manual_add',NULL,NULL,1,7,0,0,1,7,NULL,9,'2026-06-02 12:47:59'),(31,20,'manual_add',NULL,NULL,0,14,0,0,0,14,NULL,9,'2026-06-02 12:53:44'),(32,9,'manual_add',NULL,NULL,1,11,0,0,1,11,NULL,9,'2026-06-02 12:54:09'),(33,18,'manual_add',NULL,NULL,15,3,0,0,15,3,NULL,9,'2026-06-02 12:56:09'),(34,34,'manual_add',NULL,NULL,4,17,0,0,4,17,NULL,9,'2026-06-02 13:05:14'),(35,13,'manual_add',NULL,NULL,0,2,0,0,0,2,NULL,9,'2026-06-02 13:05:36'),(36,35,'manual_add',NULL,NULL,0,7,0,0,0,7,NULL,9,'2026-06-02 13:08:17'),(37,23,'manual_add',NULL,NULL,0,8,0,0,0,8,NULL,9,'2026-06-02 13:11:33'),(38,16,'direct_sale_deduction',NULL,NULL,0,0,4,0,50,6,NULL,9,'2026-06-02 16:47:43'),(39,21,'direct_sale_deduction',NULL,NULL,0,0,2,0,9,13,NULL,9,'2026-06-02 16:47:43'),(40,30,'direct_sale_deduction',NULL,NULL,0,0,2,0,1,7,NULL,9,'2026-06-02 16:47:43'),(41,21,'direct_sale_deduction',NULL,NULL,0,0,1,0,8,13,NULL,9,'2026-06-02 17:04:25'),(42,16,'direct_sale_deduction',NULL,NULL,0,0,1,0,49,6,NULL,9,'2026-06-02 17:04:25'),(43,36,'receipt_supplier',5,'stock_receipts',2,0,0,0,2,0,NULL,9,'2026-06-03 10:29:55'),(44,23,'receipt_supplier',5,'stock_receipts',10,0,0,0,10,8,NULL,9,'2026-06-03 10:29:55'),(45,10,'receipt_supplier',5,'stock_receipts',20,0,0,0,28,2,NULL,9,'2026-06-03 10:29:55'),(46,30,'receipt_supplier',5,'stock_receipts',10,0,0,0,11,7,NULL,9,'2026-06-03 10:29:55'),(47,12,'receipt_supplier',5,'stock_receipts',4,15,0,0,4,15,NULL,9,'2026-06-03 10:29:55'),(48,8,'receipt_supplier',5,'stock_receipts',23,0,0,0,23,3,NULL,9,'2026-06-03 10:29:55'),(49,9,'receipt_supplier',5,'stock_receipts',16,0,0,0,17,11,NULL,9,'2026-06-03 10:29:55'),(50,20,'receipt_supplier',5,'stock_receipts',10,0,0,0,10,14,NULL,9,'2026-06-03 10:29:55'),(51,16,'receipt_supplier',6,'stock_receipts',35,0,0,0,84,6,NULL,9,'2026-06-03 10:30:51'),(52,36,'manual_add',NULL,NULL,0,14,0,0,2,14,NULL,9,'2026-06-03 10:36:18'),(53,8,'bill_deduction',7,'orders',0,0,6,0,17,3,NULL,9,'2026-06-03 10:52:22'),(54,22,'bill_deduction',7,'orders',0,0,4,0,0,7,NULL,9,'2026-06-03 10:52:22'),(55,30,'bill_deduction',7,'orders',0,0,3,0,8,7,NULL,9,'2026-06-03 10:52:22'),(56,16,'bill_deduction',7,'orders',0,0,2,0,82,6,NULL,9,'2026-06-03 10:52:22'),(65,9,'bill_deduction',8,'orders',0,0,0,5,17,6,NULL,9,'2026-06-03 10:55:13'),(66,12,'bill_deduction',8,'orders',0,0,0,5,4,10,NULL,9,'2026-06-03 10:55:13'),(67,22,'bill_deduction',8,'orders',0,0,0,5,0,2,NULL,9,'2026-06-03 10:55:13'),(74,8,'bill_deduction',9,'orders',0,0,6,0,11,3,NULL,9,'2026-06-03 11:20:12'),(75,30,'bill_deduction',9,'orders',0,0,3,0,5,7,NULL,9,'2026-06-03 11:20:12'),(76,16,'bill_deduction',9,'orders',0,0,2,0,80,6,NULL,9,'2026-06-03 11:20:12'),(81,23,'bill_deduction',10,'orders',0,0,10,0,0,8,NULL,9,'2026-06-03 11:26:58');
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_receipt_items`
--

LOCK TABLES `stock_receipt_items` WRITE;
/*!40000 ALTER TABLE `stock_receipt_items` DISABLE KEYS */;
INSERT INTO `stock_receipt_items` VALUES (5,5,36,2,0,0.00,0.00),(6,5,23,10,0,0.00,0.00),(7,5,10,20,0,0.00,0.00),(8,5,30,10,0,0.00,0.00),(9,5,12,4,15,0.00,0.00),(10,5,8,23,0,0.00,0.00),(11,5,9,16,0,0.00,0.00),(12,5,20,10,0,0.00,0.00),(13,6,16,35,0,0.00,0.00);
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
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_date` (`company_id`,`receipt_date`),
  KEY `fk_sr_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_sr_company` FOREIGN KEY (`company_id`) REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_sr_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_receipts`
--

LOCK TABLES `stock_receipts` WRITE;
/*!40000 ALTER TABLE `stock_receipts` DISABLE KEYS */;
INSERT INTO `stock_receipts` VALUES (5,2,'2026-06-03',0.00,'80747907',9,'2026-06-03 10:29:55'),(6,2,'2026-06-03',0.00,'80747909',9,'2026-06-03 10:30:51');
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
  `payment_method` enum('cash','bank_transfer','cheque','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_date` (`company_id`,`payment_date`),
  KEY `fk_sa_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_sa_company` FOREIGN KEY (`company_id`) REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_sa_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_advances`
--

LOCK TABLES `supplier_advances` WRITE;
/*!40000 ALTER TABLE `supplier_advances` DISABLE KEYS */;
INSERT INTO `supplier_advances` VALUES (2,2,22143.00,'2026-05-29','bank_transfer',NULL,9,'2026-05-31 15:16:01'),(3,2,1175000.00,'2026-06-01','bank_transfer',NULL,9,'2026-06-02 08:47:54'),(4,2,180857.00,'2026-06-01','bank_transfer',NULL,9,'2026-06-02 09:10:10');
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
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_person` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `current_advance_balance` decimal(12,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_supplier_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier_companies`
--

LOCK TABLES `supplier_companies` WRITE;
/*!40000 ALTER TABLE `supplier_companies` DISABLE KEYS */;
INSERT INTO `supplier_companies` VALUES (2,'CBL','Hassan Raza','0301-4452722',1378000.00,1,'2026-05-30 15:22:46');
/*!40000 ALTER TABLE `supplier_companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test_table`
--

DROP TABLE IF EXISTS `test_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_table` (
  `id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test_table`
--

LOCK TABLES `test_table` WRITE;
/*!40000 ALTER TABLE `test_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `test_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','order_booker','salesman') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (9,'Administrator','admin','$2a$12$DBD/VNDYDg7pIXRuai9yhObv6Fa8bVmsrM58Tnu6T8RBG5TPxeTMG','admin',NULL,1,'2026-05-02 16:30:24','2026-05-02 16:30:24'),(10,'Muhammad Abdullah 2','abdullah2','$2a$10$A4iWDVQw.V5pOx0VUZ4B8e5IdbD1ahk6V3nNk.QEUC5.qjpC9yzAK','order_booker','03278551485',0,'2026-05-30 15:10:58','2026-06-02 10:02:16'),(11,'Muhammad Arslan','arslan','$2a$10$r0Fb6.CgWk3oXkpO5fMtt.grB..ScLF9Jr1A2NGfHCUcRYo7E34sa','order_booker','03278551485',0,'2026-05-30 15:11:22','2026-06-02 09:41:27'),(12,'Muhammad Arslan','arslansalesman','$2a$10$iiPja0fWZt0pwH7qGEo1yeO6FEV4klmOlSJ2pN87D9yCp1KVuYZwm','salesman','03406692141',0,'2026-05-30 15:12:13','2026-06-02 09:01:23'),(13,'Muhammad kamran','kamransalesman','$2a$10$6hobwDefPUyb195WNz2Wm.bqdxGR/Il73eiC76/VrjgXcz4yD1rcq','salesman','03221590926',1,'2026-05-30 15:12:49','2026-06-02 09:31:58'),(14,'Muhammad Arslan','arslansaleman','$2a$10$oPHAO1RyB8ynCFkwUDoPguF2jeYjcfMVZ7LW/v8E18qewprakhxOG','order_booker','03406692141',1,'2026-06-02 09:02:59','2026-06-02 09:02:59'),(15,'Muhammad Arslan','arslansalemane','$2a$10$s27XM6wzG7wTqFdFySrOQuJUPwdc2H0YUZDL9jDvnFFYoVQrDdSBu','salesman','03406692141',1,'2026-06-02 09:03:55','2026-06-02 09:03:55'),(22,'Muhammad Abdullah','abdullah','$2a$10$mywFU6im5zpPR4/9iKi/4Obi1xPuLxmcmjeVfXqxB2quRhdcH.vI6','order_booker','03278551485',1,'2026-06-02 10:03:09','2026-06-02 10:03:09');
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

-- Dump completed on 2026-06-03  7:32:58
