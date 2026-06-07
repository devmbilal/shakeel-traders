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
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `staff_id` int unsigned NOT NULL,
  `staff_type` enum('admin','order_booker','salesman','delivery_man') COLLATE utf8mb4_unicode_ci NOT NULL,
  `attendance_date` date NOT NULL,
  `status` enum('present','absent','holiday','off') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'present',
  `marked_by` int unsigned DEFAULT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_staff_date` (`staff_id`,`staff_type`,`attendance_date`),
  KEY `idx_attendance_date` (`attendance_date`),
  KEY `idx_staff_type_date` (`staff_type`,`attendance_date`),
  KEY `idx_status` (`status`),
  KEY `fk_attendance_marked_by` (`marked_by`),
  CONSTRAINT `fk_attendance_marked_by` FOREIGN KEY (`marked_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Daily attendance records. Status: present, absent, holiday, off (Fridays default)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (1,12,'salesman','2026-06-03','absent',9,NULL,'2026-06-06 01:09:59','2026-06-06 01:13:59'),(3,14,'order_booker','2026-06-03','absent',9,NULL,'2026-06-06 01:13:59','2026-06-06 01:13:59'),(4,13,'salesman','2026-06-05','absent',9,NULL,'2026-06-06 15:22:24','2026-06-06 15:22:24'),(5,13,'salesman','2026-06-03','absent',9,NULL,'2026-06-06 15:23:24','2026-06-06 15:23:24');
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

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
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `last_backup_time` datetime DEFAULT NULL COMMENT 'Timestamp of last successful backup',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_profile`
--

LOCK TABLES `company_profile` WRITE;
/*!40000 ALTER TABLE `company_profile` DISABLE KEYS */;
INSERT INTO `company_profile` VALUES (1,'Shakeel Traders','Shakeel Ahmad','Ali Town Karrianwala Road , Khurrianwala Faisalabad','03049835773','03336624974','shakeeltraders346@gmail.com','3310406495513','3310406495513','33104-0649551-3',NULL,'23:00','2026-06-07 16:01:35',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `base_salary` decimal(10,2) DEFAULT NULL COMMENT 'Monthly base salary for payroll calculation',
  `enable_payroll` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Include in attendance and payroll (1=yes, 0=no)',
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_men`
--

LOCK TABLES `delivery_men` WRITE;
/*!40000 ALTER TABLE `delivery_men` DISABLE KEYS */;
INSERT INTO `delivery_men` VALUES (2,'Muhmmad Arslan',NULL,1,'2026-06-07 16:12:18',NULL,0),(3,'Muhammad Kamran',NULL,1,'2026-06-07 16:15:56',NULL,0);
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
-- Table structure for table `holidays`
--

DROP TABLE IF EXISTS `holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `holidays` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `holiday_date` date NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_holiday_date` (`holiday_date`),
  KEY `idx_holiday_date` (`holiday_date`),
  KEY `fk_holidays_created_by` (`created_by`),
  CONSTRAINT `fk_holidays_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System-wide holidays. Admin marks these dates as non-working days.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `holidays`
--

LOCK TABLES `holidays` WRITE;
/*!40000 ALTER TABLE `holidays` DISABLE KEYS */;
/*!40000 ALTER TABLE `holidays` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payroll_records`
--

DROP TABLE IF EXISTS `payroll_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_records` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `staff_id` int unsigned NOT NULL,
  `staff_type` enum('admin','order_booker','salesman','delivery_man') COLLATE utf8mb4_unicode_ci NOT NULL,
  `month` tinyint unsigned NOT NULL COMMENT '1-12',
  `year` year NOT NULL,
  `base_salary` decimal(10,2) NOT NULL,
  `working_days` tinyint unsigned NOT NULL COMMENT 'Total working days in month (excluding Fridays and holidays)',
  `present_days` tinyint unsigned NOT NULL COMMENT 'Days marked present',
  `absent_days` tinyint unsigned NOT NULL COMMENT 'Days marked absent',
  `holiday_days` tinyint unsigned NOT NULL COMMENT 'Public holidays in month',
  `off_days` tinyint unsigned NOT NULL COMMENT 'Weekly offs (Fridays)',
  `per_day_salary` decimal(10,2) NOT NULL COMMENT 'base_salary / working_days',
  `absence_deduction` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'absent_days * per_day_salary',
  `net_salary` decimal(10,2) NOT NULL COMMENT 'base_salary - absence_deduction',
  `advances_paid` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Total advances during month',
  `final_payable` decimal(10,2) NOT NULL COMMENT 'net_salary - advances_paid',
  `payment_status` enum('pending','paid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `paid_at` datetime DEFAULT NULL,
  `paid_by` int unsigned DEFAULT NULL,
  `payment_method` enum('cash','bank_transfer') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_note` text COLLATE utf8mb4_unicode_ci,
  `generated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `generated_by` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_staff_month_year` (`staff_id`,`staff_type`,`month`,`year`),
  KEY `idx_month_year` (`month`,`year`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `fk_payroll_generated_by` (`generated_by`),
  KEY `fk_payroll_paid_by` (`paid_by`),
  CONSTRAINT `fk_payroll_generated_by` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_payroll_paid_by` FOREIGN KEY (`paid_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Monthly payroll with attendance-based deductions. Generated at month end.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payroll_records`
--

LOCK TABLES `payroll_records` WRITE;
/*!40000 ALTER TABLE `payroll_records` DISABLE KEYS */;
INSERT INTO `payroll_records` VALUES (1,13,'salesman',6,2026,30000.00,26,28,1,0,4,1153.85,1153.85,28846.15,10000.00,18846.15,'paid','2026-06-07 16:18:32',9,'cash',NULL,'2026-06-06 15:23:39',9),(2,11,'salesman',6,2026,30000.00,26,30,0,0,4,1153.85,0.00,30000.00,0.00,30000.00,'pending',NULL,NULL,NULL,NULL,'2026-06-07 16:17:24',9),(3,12,'salesman',6,2026,30000.00,26,29,1,0,4,1153.85,1153.85,28846.15,0.00,28846.15,'pending',NULL,NULL,NULL,NULL,'2026-06-07 16:17:24',9);
/*!40000 ALTER TABLE `payroll_records` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_route_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `routes`
--

LOCK TABLES `routes` WRITE;
/*!40000 ALTER TABLE `routes` DISABLE KEYS */;
INSERT INTO `routes` VALUES (5,'Main Bazar Jhumra Road',1,'2026-05-30 14:49:08'),(6,'Bara Latianwala FSD Road',1,'2026-05-30 14:49:28'),(7,'Adda Khurrianwala',1,'2026-05-30 14:49:42'),(8,'Karrian Wala Road',1,'2026-05-30 14:56:19'),(9,'Jarranwala Road',1,'2026-05-30 14:57:40'),(10,'Jandwali Road',1,'2026-05-30 14:58:01'),(11,'Johal Adda',1,'2026-05-30 14:58:21'),(12,'Madina Town Lahore Road',1,'2026-05-30 14:58:37'),(13,'Nazeer Town Lahore Road',1,'2026-05-30 14:58:51'),(14,'Purani Abbadi',1,'2026-05-30 14:59:07'),(15,'Main Bazar 5 Marla Schem Rehman Colony',1,'2026-05-30 14:59:36'),(17,'Chak NO 189 RB Rasoolpura',1,'2026-06-07 15:58:28');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `salary_records`
--

LOCK TABLES `salary_records` WRITE;
/*!40000 ALTER TABLE `salary_records` DISABLE KEYS */;
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
INSERT INTO `sessions` VALUES ('xpWvSyilPUC1xDn-yB0pBgRPR8xjoTMb',1780922150,'{\"cookie\":{\"originalMaxAge\":86399998,\"expires\":\"2026-06-08T11:18:32.180Z\",\"httpOnly\":true,\"path\":\"/\",\"sameSite\":\"lax\"},\"flash\":{},\"user\":{\"id\":9,\"full_name\":\"Administrator\",\"username\":\"shakeeltraders\",\"role\":\"admin\"}}');
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=826 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shops`
--

LOCK TABLES `shops` WRITE;
/*!40000 ALTER TABLE `shops` DISABLE KEYS */;
INSERT INTO `shops` VALUES (563,'786 KS','Waqas','3049311396','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(564,'786 KS','Jasam','3000687903','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(565,'786 Photo Copy','Sarfaraz','3087108761','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(566,'Abbas kiryan stor','M Abbas','3247387524','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(567,'Abdul Qadeer KS','Abdul qadrer','3049637148','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(568,'Abdul Raziq K S','Abdul Raziq','3377518527','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(569,'ABID TEA STALL','M Wajad','3235277546','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(570,'Abubakar K S','M Abubakar','3017452385','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(571,'Adnan Pan Shop','M Adnan','3027176434','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(572,'Adnan Pan Shop','M Adnan','3027176434','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:33'),(573,'Ahmad BD','Arshad','3336564005','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(574,'Ahmad KS','Nawazesh','3457853162','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(575,'Ahmad KS','Tahir','3046358018','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(576,'Ahsan k stor','Ahsan','3007216420','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(577,'Ahtasham Ks','Ihtesham','3413814506','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(578,'Ahtsham sweets','Ahtsham','3056407409','Adda khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(579,'Al barkat sweet and bakers 1','Saeed gujjar','3061055045','Adda khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(580,'Al Fahad KS','Fahid','3000220325','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(581,'AL Haram K/S',NULL,NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(582,'Al Haram KS','Fayaiz','3357125940','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(583,'Al Haram KS','Waqas','3016079365','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(584,'Al Madina GS','zafar','3004048266','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(585,'Al Madina Pan Shop','M Fiasal','3017043182','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(586,'AL MAKKAH G S M S','Umer Razak','3006962200','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(587,'Al Makkah KS','Abid','3427864889','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(588,'Al Minhaj KS','Zeshan','3022497877','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(589,'Al Rahmat Mobiles','M Rahmat','3202592001','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(590,'Al Rehman KS','Mohammad Akram','3008698272','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(591,'Al rehmat k stor','sajjad','3046683866','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(592,'Al Sayed KS','Ali','3068740833','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(593,'Al shareef super store','M yaseen','3226362709','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(594,'Al Shirah medical and stor','M. Naveed','3338982493','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(595,'Alfahid k/S','Allah Dettah','3028435860','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(596,'Alharam general store','Naveed','3066769141','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(597,'Ali g stor','M. Amer','3006617200','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(598,'Ali Hajwary KS','Malik Salman','3007285636','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(599,'Ali K S','M Ali','3006617200','Bara Latianwala FSD Road',6,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(600,'Allah Dita KS','Allah Dita','3217761077','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(601,'Allah Hoo KS','Sultan','3007216420','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(602,'Allah Tawaqal Karyana Store','Nadiam Nawaz','3069512524','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(603,'Allah Towakal KS','Arshad','3007662774','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(604,'Ansari KS','Shahfaqat','3007287552','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(605,'Arham KS','Rana irfan','3009443683','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(606,'Arham Mobile & TS','M. Adnan','3007623249','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(607,'Arshad KS','irshad','3029234154','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(608,'Arshad PS','Awais','3061712597','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(609,'Asif kiryana store sweets bakers','Fahran Javad','3009497170','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(610,'Aslam KS','Aslam','0','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(611,'Assad KS','Asid','3001275266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(612,'Atari kiryana Jenral stor','Athir Also','3007940173','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(613,'Ateeq k stor','Strew sarwar','3007260833','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(614,'Awais Karni PS','Latief','3007105300','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(615,'Awais Qarni','Mohammad zee Shan Atari','3037105300','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(616,'Awan k stor','Tariq nazeer','3033932755','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(617,'Awan KS','Asad','3006900068','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(618,'Awan Sweet G/S','Sarwar Awan','3001466266','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(619,'Azeem Mart','faheem','3339799127','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(620,'Baba Akram','Baba Akram','3008656985','Jarranwala road',9,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(621,'Babar Traders','Babar Ali','3007266689','CHAK 189 RB RASULPUR',17,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(622,'Bahia Cold Corner','Ilyas','3000872640','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(623,'Bhai Naveed KS','Naveed','3067044334','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(624,'Bhai PS','Ilyas','3000872640','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(625,'Bhehlwan Sweets','M sadeeq','3016036018','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(626,'Bhola Butt KS','Mohammad jameel','3467721456','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(627,'Bhola PS','Imran','3007605761','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(628,'Bilal kiryana store','M Shahid','3367613557','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(629,'Bilal KS','Akram','3027134457','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(630,'Bismillah K/S','Jasim','3000687903','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(631,'Bismillah kariyana Store 1',NULL,NULL,'Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(632,'Butt Chaki Wala','Amer','3017187714','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(633,'Danish kiryana store','Shahzad','3045572019','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(634,'Dar ul Ahsan Sweets','saeed','3061055045','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(635,'Data Ali Hajwari KS','Asif','3017061363','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(636,'E Mart K S','Nazaqat Ali','3012393285','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(637,'EHSAAN K S','M Sultan','3007216420','Bara Latianwala FSD Road',6,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(638,'ERHAM MOBILE T S','Adnan','3007723249','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(639,'Faheem Dogar KS','Liaqat','3015063116','Jarranwala Road',9,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(640,'Faheem K S','M Ameen','3442870281','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(641,'Faisal Shah GS','Faisal','3317279376','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(642,'Farooq KS','Farooq','3067080655','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(643,'Foji kariana store','sanaulaha','3063992266','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(644,'Fuji Ishfaq KS','Javed','3015857642','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(645,'Geo Supper KS','Ghulam hussain','3027149590','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(646,'Gholdra Sharif KS','Khalid','3007679130','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(647,'Ghousia Kiryana store','M Tariq','3245005033','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(648,'Grace Gift Center','Waheed','3457027447','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(649,'Grand Mart sweets Bakers Fast Food','M Bineemeen','3006693359','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(650,'Gulam Rasool De Hatti','Irfan','3017124622','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(651,'Hafiz Imran general store','Hafiz m imran','3003501266','Jandwali Road',10,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(652,'Hafiz kariyana Store','Aftab Akber','3007981150','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(653,'Hafiz kiryana store','Mushtaq ahmad','3216972473','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(654,'Hafiz Mart','Main Saeed','3326800545','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(655,'Hafiz Mudassar K/S',NULL,NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(656,'Hafiz pan Shop','Hafiz Shahzad','3005673100','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(657,'Hafiz PS','Shahzad','3005673100','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(658,'Hafiz PS','Asif','3022232266','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(659,'Hafiz PS','Hafiz irslan','3096956373','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(660,'Hafiz Qayom TS','Qamer','0','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(661,'Haider kiryana store','Muhammad Haider',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(662,'Haidri Pan Shop','Zaighum Abbas','3217050166','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(663,'Haji M Rafique kiryana store','Saeed Ahmad','3075282707','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(664,'Haji Nisar Sweets','Nasar','0','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(665,'Hamza K S','M Hamza','3343533033','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(666,'Haq Bahoo','Abdul Manaf','3048942683','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(667,'Haroon Karyana Store','M Haroon','3458666371','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(668,'Hassan Kiryana store','Abdul Rasheed','3237619968','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(669,'Ideal Sweets','Azeem','3029821100','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(670,'Ideal Sweets','imant','3067691277','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(671,'Ilyas KS','Ilyas','3046574233','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(672,'Imran KS','Usman','3126658042','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(673,'Iqbal Sweets & Bakers','Waqas','3006535817','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(674,'Irfan K S','M Arif','3247055889','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(675,'Irfan Khalid PS','Irfan','3023448740','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(676,'Irfan KS','Irfan','3061211266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(677,'Irshad Ali K S','M Irshad','3366566062','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(678,'J Mart','Jawad ul hussan','3457939299','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(679,'Jani PS','kamran Shahzad','3004711266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(680,'javaad K S','M Javaad','3047582642','Bara Latianwala FSD Road',6,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(681,'Javeed ijaz k stor','Javeed','3013658266','Jarranwala road',9,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(682,'Jawaad Karyana Store','M Jawaad','3015253984','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(683,'Jutt Karyana Store','Sher Muhammad','3048562745','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(684,'Jutt KS','Asghar','3067162235','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(685,'Jutt ks','yasar jutt','3035161290','Adda khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(686,'Jutt Tanveer Ilyas KS','Tanveer','3037799013','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(687,'Kamran KS','Kamran','3016948869','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(688,'Kaqam And Son Karyana Store','M Qasam','3067009733','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(689,'Kashmir GS','Shabeer','3013656553','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(690,'khoshi ks','shahbaz','3037171772','Adda khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(691,'Khuba Karyana Store','Aslam','3448247713','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(692,'Khurram kiryana store','M.Khurram',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(693,'Lahorei sweet','Basharat Ali','3006687862','Jarranwala road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(694,'Lala Freed PS','Faryaad','3467770586','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(695,'Liaqat Drink corner','Niamat','3072697350','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(696,'Lohari Sweets','Basharat','3006687862','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(697,'M Asif Ali KS','M. Asif','3479018103','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(698,'M Jameel PS','Jameel','3339920866','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(699,'Madina general kiryana store','Majid','3423578521','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(700,'Madina K S','M IDREES','3081148237','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(701,'Madina Kiryana General Store','Qasim','3407852918','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(702,'Madina Mobile Shop','M Azar hussain','3026022143','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(703,'Madni KS','Farhan','3129084111','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(704,'Madnia Sweets','Razaq','3016009872','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(705,'Mahar Karyana Store','Main Awias','3000732597','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(706,'Main Mobile and Genral Store',NULL,'3007271292','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(707,'Main Shahid K S','M Shahzad','3007254676','Bara Latianwala FSD Road',6,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(708,'Main Teeq K S','Mian Teeq','3017265243','Bara Latianwala FSD Road',6,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(709,'Maki Madni k/S','Shahid','3035797179','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(710,'Makkha K/S','Abid','3427864889','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(711,'Malik Abdul Haq KS','Aftab','3007964220','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(712,'Malik Akbar Sweets','Malik Akbar Sweet','3064824372','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(713,'Malik Akram KS','Akram','3339929985','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(714,'Malik Amir GS','Amir','3006013490','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(715,'Malik Asif K S','M Asif','3247660370','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(716,'Malik G Karyana Store','Malik Shahad','3067221880','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(717,'Malik Imran KS','Malik Imran','3006629043','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(718,'Malik kiryana store','M Shabbir','3086730710','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(719,'Malik KS','Imtaiyaz','3425804350','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(720,'Malik Riaz KS','Raiz','0','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(721,'Malik Sadique KS','Sadeeq','3063726266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(722,'Malik Shahbaz KS','Nazeer','0','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(723,'Malik Yaseen KS','Yaseen','3009781751','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(724,'Marhaba Mart','tahir','3212631003','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(725,'Marhabah KS','Awais','3143912105','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(726,'Master Shareef KS','Rahman','3054565784','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(727,'Mehar Gift Center G S','Murad','3237285666','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(728,'Mehmood KS','Waqas','3037717773','Adda Khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(729,'Methu PS','Farooq','3404076606','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(730,'Mian Affaq TS','waqas','3045465608','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(731,'Mian Asif Kiryana Store','Mian Asif',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(732,'Mian KS','mean ishtiaq','3007247498','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(733,'Mian Mudassir G S','Mudassir Abbas','3057207330','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(734,'Mian Muzzamil KS','Basheer','3346402710','Karrian Wala road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(735,'Mian PS','Azkar','3054779630','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(736,'Millit Traders','Shahid','3017039470','Jandwali Road',10,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(737,'Mohammad Jameel P/S','Mohammad Naveed','3339920866','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(738,'MS KS','Anayat','3424508203','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(739,'Mudasir Hussain KS','Mudesdar','3156026535','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(740,'Mudasir KS','Mudessar','3007684425','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(741,'Mursleen KS','Yaseen','3046890760','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(742,'Mushtaq TS','Mustaq','3082214169','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(743,'muzammal k/s','Muzammal','3346402710','Karrian Wala road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(744,'Nadeem GS','Ashraf','3006609958','Jarranwala Road',9,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(745,'Nadeem p /shop 2','Saleem','3054247077','Jarranwala road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(746,'Nadeem PS','Saleem','3226266805','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(747,'Naeem KS','Naeem','3017069282','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(748,'Nasar Bajwa k/s','Nasar','3006664659','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(749,'Naseer KS','Naseer',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(750,'Nasir pan shop','Nasir','3007980085','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(751,'Nasir PS','Nasir','3007980085','Adda Khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(752,'Nazeer KS','Saleem','3077296830','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(753,'New Nasir GS','Asif','3067981050','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(754,'New Niaz KS','Ali Ahmed','3006625838','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(755,'Niaz KS','Niyaz ali','3007665309','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(756,'Niazi KS','Niazi','0','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:34'),(757,'Niazi KS','Sajid','3427054986','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(758,'Noman KS','Noman',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(759,'Noorani KS','Murtaza','3004812686','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(760,'Noshahi KS','Shahbeer','3017025266','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(761,'Palkia KS','Sakhawat','3006644630','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(762,'Panno Traders','Shair afgan','3006642206','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(763,'pappo g pan shop','M Saeed','3007664490','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(764,'Paradise Store','M Basit','3245066430','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(765,'Pasha PCO','Musan Seed','3096527200','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(766,'pehalwan Sweet','Abdul Gafoor','3007677631','Jarranwala road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(767,'Qadri KS','Ashaq','3046200497','Adda Khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(768,'Qadri KS','Umair','3067074252','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(769,'Qamar KS','Qamer','3009514959','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(770,'Raiz Gujar K/S','Raiz',NULL,'Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(771,'Raju PS','Adnan','3056355266','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(772,'Rana Ahsan KS','Raiz','3007203256','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(773,'Rana Azeem KS','Usman','3057434982','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(774,'Rana Ijaz KS','Rana Ejaz','3061773547','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(775,'Rana Imtiaz KS','Rana imtiaz','3067057552','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(776,'Rana Liaqat KS','liaqat','3017165739','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(777,'Rashid KS','Rashad','3017147724','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(778,'Rizvi Kiryana Store','M.Amjad','3036497121','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(779,'Saad Telecom','waqas','3008602539','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(780,'Sabi ul Hassan k stor','Sabi ul hussan','3343533033','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(781,'Safi Traders','Safi','30973270340','CHAK 189 RB RASULPUR',17,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(782,'Sajid KS','Sajid','3074732118','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(783,'Sajjad KS','sajjad','3076717368','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(784,'Sardar Plaza KS','Shahzad','3007989903','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(785,'Sartaj KS','Mohammad saleem','3017177397','Johal Adda',11,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(786,'Sath g ks','Sath asim','3403652095','Adda khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(787,'Shafiq Traders','Shahfeeq','3082070736','Jandwali Road',10,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(788,'Shah Gee KS','Muzammil','3007233995','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(789,'Shah Gee Traders','Mudaser','3007911392','Adda khurrianwala',7,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(790,'Shah Jee K/S','Syed Muzammal Hussain','3007233995','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(791,'Shaheen Book Dipo','M Shaheen','3007297725','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(792,'Shahid Gujjar KS','shahid','3007600331','Johal Adda',11,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(793,'Shahid Kiryana store','M umar','3059146605','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(794,'Shahid kiryana store','Shahid','3063957523','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(795,'Shahid Makki Madni KS','Shahid','3007655834','Karrian Wala Road',8,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(796,'Shahzaib kiryana store Drink Corner','M Shahzaib','3424578631','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(797,'Shana Behlwan KS','Usman','3030359115','Main Bazar 5 Marla Schem Rehman Colony',15,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(798,'Sheikahan De Hatti','Nasir','3067091715','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(799,'Sheikh Gee KS','Mohammad Usman','3000201488','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(800,'Spiece Home KS','Misn liaqat','3044373737','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(801,'Subhan KS','Aslam','3444632597','Nazeer Town Lahore Road',13,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(802,'Sufi Sweets','Zeshan','3000676148','Adda Khurrianwala',7,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(803,'Sufyan KS','Ahsan','3415200266','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(804,'Suleman KS','Shahfeeq','3038010214','Jandwali Road',10,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(805,'Suleman Madina TS','Zawaar','3084876395','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(806,'Tahir K S','M Tahir','3000935200','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(807,'Talha Ayub','Ayub','3073009889','Karrian Wala Road',8,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(808,'Tayyab Karyana Store','M Tayyab','3087781442','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(809,'Umer Karyana Store','M Umer','3054258652','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(810,'Usman K S','Usman','3025263189','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(811,'Uzaifa KS','Saleem','3046091732','Purani Abbadi',14,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(812,'Waqas K S','Yasir','3437612838','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(813,'Yaseen Butt KS','Yaseen','3052507688','Main Bazar Jhumra Road',5,'wholesale',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(814,'Yasir kiryana store','Babar ali','3006648349','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(815,'ZA Bakers','Altaaf','3009715601','Jarranwala Road',9,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(816,'Zafar K S','M Zafar','3007602543','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(817,'Zahor GS','Kaseem','3004523532','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(818,'Zain KS','Javed','3075373147','Madina Town Lahore Road',12,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(819,'zapped Ali g/s','zahoor','3004523532','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(820,'Zeeshan KS','Zeeshan','3029310561','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(821,'Ziaqa Sweets & Bakers','Mohammad Shahzad','3017014364','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(822,'Ziqria g stor','younes','3027044292','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(823,'Zoq-E-Shereen','Talha','3206533365','Main Bazar Jhumra Road',5,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(824,'Zulfiqar kiryana store','Zulfiqar','3217614189','CHAK 189 RB RASULPUR',17,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35'),(825,'Zunair K S','M Zunair','3004182296','Bara Latianwala FSD Road',6,'retail',0,0.00,NULL,NULL,1,'2026-06-07 15:59:35');
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_date` (`company_id`,`receipt_date`),
  KEY `fk_sr_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_sr_company` FOREIGN KEY (`company_id`) REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_sr_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `payment_method` enum('cash','bank_transfer','cheque','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `recorded_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_date` (`company_id`,`payment_date`),
  KEY `fk_sa_recorded_by` (`recorded_by`),
  CONSTRAINT `fk_sa_company` FOREIGN KEY (`company_id`) REFERENCES `supplier_companies` (`id`),
  CONSTRAINT `fk_sa_recorded_by` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_person` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `base_salary` decimal(10,2) DEFAULT NULL COMMENT 'Monthly base salary for payroll calculation',
  `enable_payroll` tinyint(1) NOT NULL DEFAULT '1' COMMENT '1=Include in attendance/payroll, 0=Exclude (e.g., admin/system users)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (9,'Administrator','shakeeltraders','$2a$10$icifiMffOX4kbELlh.JQWeFx73WXN3JLIfOb/eQssylh9fo80QPmG','admin',NULL,1,'2026-05-02 16:30:24','2026-06-07 16:05:40',NULL,0),(10,'Muhammad Abdullah','abdullah','$2a$10$VlZu2kW32qToRr1.zJnGaeyDs8OfaCEe0appeUM2et5kO7G0X79qe','order_booker',NULL,1,'2026-06-07 16:06:57','2026-06-07 16:06:57',NULL,0),(11,'Muhammad Kamran','kamransalesman','$2a$10$g4OfP3rT.MFxw..BpA8ZOeRL/DoWOs3zkCXYcAb6x67UiSDqFA4RK','salesman',NULL,1,'2026-06-07 16:07:59','2026-06-07 16:17:09',30000.00,1),(12,'Muhmmad Arslan','arslansalesman','$2a$10$aTXYc5tBRz8lF29tpfmbhe3ZjG9tcSAutskEzvGU/m0/qCLtOJqSC','salesman',NULL,1,'2026-06-07 16:08:41','2026-06-07 16:17:16',30000.00,1);
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

-- Dump completed on 2026-06-07 13:35:58
