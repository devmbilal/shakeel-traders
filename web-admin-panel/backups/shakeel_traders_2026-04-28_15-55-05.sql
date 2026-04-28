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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (1,1,'RECORD_SALARY','salary_records',NULL,NULL,'{\"year\": \"2026\", \"month\": \"4\", \"amount\": \"30000\", \"staffId\": \"1\", \"staffType\": \"delivery_man\"}',NULL,'2026-04-28 20:44:52'),(2,1,'RECORD_SALARY','salary_records',NULL,NULL,'{\"year\": \"2026\", \"month\": \"4\", \"amount\": \"20000\", \"staffId\": \"4\", \"staffType\": \"salesman\"}',NULL,'2026-04-28 20:45:22'),(3,1,'RECORD_SALARY_ADVANCE','salary_advances',1,NULL,NULL,NULL,'2026-04-28 20:45:44'),(4,1,'RECORD_SALARY','salary_records',NULL,NULL,'{\"year\": \"2026\", \"month\": \"4\", \"amount\": \"16000\", \"staffId\": \"4\", \"staffType\": \"salesman\"}',NULL,'2026-04-28 20:47:36'),(5,1,'RECORD_SALARY','salary_records',NULL,NULL,'{\"year\": \"2026\", \"month\": \"4\", \"amount\": \"20000\", \"staffId\": \"4\", \"staffType\": \"salesman\"}',NULL,'2026-04-28 20:47:59'),(6,1,'RECORD_SALARY_ADVANCE','salary_advances',2,NULL,NULL,NULL,'2026-04-28 20:48:16');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill_items`
--

LOCK TABLES `bill_items` WRITE;
/*!40000 ALTER TABLE `bill_items` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill_recovery_assignments`
--

LOCK TABLES `bill_recovery_assignments` WRITE;
/*!40000 ALTER TABLE `bill_recovery_assignments` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bills`
--

LOCK TABLES `bills` WRITE;
/*!40000 ALTER TABLE `bills` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `centralized_cash_entries`
--

LOCK TABLES `centralized_cash_entries` WRITE;
/*!40000 ALTER TABLE `centralized_cash_entries` DISABLE KEYS */;
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
INSERT INTO `company_profile` VALUES (1,'Shakeel Traders','Muhammad Shakeel','Main Market, Lahore','04235000000',NULL,NULL,'NTN-1234567','234577899665','3310406495513','/uploads/logos/company-logo.png','2026-04-28 20:49:42');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_man_collections`
--

LOCK TABLES `delivery_man_collections` WRITE;
/*!40000 ALTER TABLE `delivery_man_collections` DISABLE KEYS */;
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
INSERT INTO `delivery_men` VALUES (1,'Usman Ali','03111234567',1,'2026-04-28 20:38:11');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
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
INSERT INTO `products` VALUES (1,'CBL-001','CBL Biscuit 100g','CBL',24,15.00,13.50,50,0,5,1,'2026-04-28 20:38:11','2026-04-28 20:38:11'),(2,'CBL-002','CBL Cake 50g','CBL',48,10.00,9.00,50,0,5,1,'2026-04-28 20:38:11','2026-04-28 20:38:11'),(3,'CBL-003','CBL Wafer 75g','CBL',36,12.00,10.50,50,0,5,1,'2026-04-28 20:38:11','2026-04-28 20:38:11');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `route_assignments`
--

LOCK TABLES `route_assignments` WRITE;
/*!40000 ALTER TABLE `route_assignments` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES (1,'Route A - North',1,'2026-04-28 20:38:11'),(2,'Route B - South',1,'2026-04-28 20:38:11');
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
INSERT INTO `salary_advances` VALUES (1,4,'salesman',5000.00,'2026-04-28','biscuits',1,'2026-04-28 20:45:44'),(2,4,'salesman',16000.00,'2026-04-28',NULL,1,'2026-04-28 20:48:16');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_records`
--

LOCK TABLES `salary_records` WRITE;
/*!40000 ALTER TABLE `salary_records` DISABLE KEYS */;
INSERT INTO `salary_records` VALUES (1,1,'delivery_man',4,2026,30000.00,0.00,NULL,NULL,'2026-04-28 20:44:52'),(2,4,'salesman',4,2026,20000.00,21000.00,NULL,NULL,'2026-04-28 20:45:22');
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
INSERT INTO `sessions` VALUES ('l7ClnIt6J5xtDv8XFsU1vCLW8FF5MR6_',1777476298,'{\"cookie\":{\"originalMaxAge\":86400000,\"expires\":\"2026-04-29T15:24:57.580Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{\"error\":[\"Please log in to access this page.\"]}}'),('uXhv4NUYxQp9hBYkYBCkshloVEKb1buh',1777478101,'{\"cookie\":{\"originalMaxAge\":86399998,\"expires\":\"2026-04-29T15:52:54.789Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{},\"user\":{\"id\":1,\"full_name\":\"Administrator\",\"username\":\"admin\",\"role\":\"admin\"}}');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_last_prices`
--

LOCK TABLES `shop_last_prices` WRITE;
/*!40000 ALTER TABLE `shop_last_prices` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_ledger_entries`
--

LOCK TABLES `shop_ledger_entries` WRITE;
/*!40000 ALTER TABLE `shop_ledger_entries` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shops`
--

LOCK TABLES `shops` WRITE;
/*!40000 ALTER TABLE `shops` DISABLE KEYS */;
INSERT INTO `shops` VALUES (1,'Al-Noor General Store','Noor Ahmed','03211111111',NULL,1,'retail',0,NULL,NULL,1,'2026-04-28 20:38:11'),(2,'City Wholesale','Tariq Mehmood','03222222222',NULL,1,'wholesale',0,NULL,NULL,1,'2026-04-28 20:38:11'),(3,'Pak Kiryana','Imran Shah','03233333333',NULL,2,'retail',0,NULL,NULL,1,'2026-04-28 20:38:11');
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_movements`
--

LOCK TABLES `stock_movements` WRITE;
/*!40000 ALTER TABLE `stock_movements` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_receipt_items`
--

LOCK TABLES `stock_receipt_items` WRITE;
/*!40000 ALTER TABLE `stock_receipt_items` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_receipts`
--

LOCK TABLES `stock_receipts` WRITE;
/*!40000 ALTER TABLE `stock_receipts` DISABLE KEYS */;
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
INSERT INTO `supplier_companies` VALUES (1,'CBL','CBL Sales Rep','04212345678',50000.00,1,'2026-04-28 20:38:11');
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Administrator','admin','$2a$12$bvvBDve4tiHB5DQ96R67v.iFYxzQ/aZcl09uRIESCr.3wWCpAKqSO','admin',NULL,1,'2026-04-28 20:29:33','2026-04-28 20:29:33'),(3,'Ahmed Khan','ahmed','$2a$12$3yfPIgSG.IhllucLmqCYTOd/Hf4XKrWUD.3VS8Sf7oDxFRR2H.qam','order_booker','03001234567',1,'2026-04-28 20:38:10','2026-04-28 20:38:10'),(4,'Bilal Raza','bilal','$2a$12$ehppymR3sp.JPUga/CWPNuD4vmM27Xgb9BGz.4Y1IFQWchprCi1aa','salesman','03009876543',1,'2026-04-28 20:38:11','2026-04-28 20:38:11'),(6,'ahsan','ahsan','$2a$10$BrbDio696NfSVbLkNDgwI.8NprEMc1LUaU2LWd1U4CfhsYX5UsTjW','order_booker',NULL,1,'2026-04-28 20:40:18','2026-04-28 20:40:18'),(7,'salman','salman','$2a$10$8GjgxQQmbASJDuEpITvCl.HpIkmqJcKJjSrAPzwikyqp2pLuBHZuy','salesman',NULL,1,'2026-04-28 20:41:05','2026-04-28 20:41:05');
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

-- Dump completed on 2026-04-28 16:55:06
