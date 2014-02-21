-- MySQL dump 10.11
--
-- Host: web-dev2.fonality.com    Database: fcs
-- ------------------------------------------------------
-- Server version	5.0.77

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `billing_schedule`
--

DROP TABLE IF EXISTS `billing_schedule`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `billing_schedule` (
  `billing_schedule_id` int(10) unsigned NOT NULL auto_increment,
  `customer_id` int(10) unsigned NOT NULL,
  `order_id` int(10) unsigned NOT NULL,
  `credit_card_id` int(10) unsigned default NULL,
  `payment_method_id` int(10) unsigned NOT NULL,
  `type` enum('SERVICE','SYSTEM','ALL') NOT NULL default 'SERVICE',
  `start_date` timestamp NOT NULL default '1970-01-01 08:00:00',
  `end_date` timestamp NOT NULL default '1970-01-01 08:00:00',
  `status` enum('NOT_PROCESSED','PROCESSED_MRC_AND_TAX','PROCESSED_ALL') NOT NULL default 'NOT_PROCESSED',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`billing_schedule_id`),
  KEY `credit_card_id` (`credit_card_id`),
  KEY `order_id` (`order_id`),
  KEY `payment_method_id` (`payment_method_id`),
  CONSTRAINT `billing_schedule_ibfk_4` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_method` (`payment_method_id`) ON UPDATE CASCADE,
  CONSTRAINT `billing_schedule_ibfk_2` FOREIGN KEY (`credit_card_id`) REFERENCES `entity_credit_card` (`entity_credit_card_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `billing_schedule_ibfk_3` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1522 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bundle`
--

DROP TABLE IF EXISTS `bundle`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `bundle` (
  `bundle_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `display_name` varchar(255) NOT NULL,
  `description` mediumtext NOT NULL,
  `manufacturer` varchar(255) NOT NULL default '',
  `model` varchar(255) NOT NULL default '',
  `is_inventory` tinyint(1) unsigned NOT NULL default '1',
  `category_id` int(10) unsigned NOT NULL,
  `cost_price` decimal(10,2) NOT NULL default '0.00',
  `base_price` decimal(10,2) NOT NULL default '0.00',
  `mrc_price` decimal(10,2) NOT NULL default '0.00',
  `netsuite_order_id` bigint(20) unsigned default NULL,
  `netsuite_one_time_id` bigint(20) unsigned default NULL,
  `netsuite_mrc_id` bigint(20) unsigned default NULL,
  `is_active` tinyint(1) unsigned NOT NULL default '1',
  `display_priority` tinyint(3) unsigned NOT NULL default '0',
  `order_label_id` int(10) unsigned default NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`bundle_id`),
  UNIQUE KEY `name` (`name`),
  KEY `order_label_id` (`order_label_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `bundle_ibfk_1` FOREIGN KEY (`order_label_id`) REFERENCES `order_label` (`label_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `bundle_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `bundle_category` (`bundle_category_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=195 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bundle_category`
--

DROP TABLE IF EXISTS `bundle_category`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `bundle_category` (
  `bundle_category_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `discount_category_id` int(10) unsigned NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`bundle_category_id`),
  UNIQUE KEY `name` (`name`),
  KEY `discount_category_id` (`discount_category_id`),
  CONSTRAINT `bundle_category_ibfk_1` FOREIGN KEY (`discount_category_id`) REFERENCES `discount_category` (`discount_category_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bundle_discount`
--

DROP TABLE IF EXISTS `bundle_discount`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `bundle_discount` (
  `bundle_discount_id` int(10) unsigned NOT NULL auto_increment,
  `bundle_id` int(10) unsigned NOT NULL,
  `discount_id` int(10) unsigned NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`bundle_discount_id`),
  UNIQUE KEY `bundle_id` (`bundle_id`,`discount_id`),
  KEY `bundle_discount_ibfk_2` (`discount_id`),
  CONSTRAINT `bundle_discount_ibfk_1` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bundle_discount_ibfk_2` FOREIGN KEY (`discount_id`) REFERENCES `discount` (`discount_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=153 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bundle_feature`
--

DROP TABLE IF EXISTS `bundle_feature`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `bundle_feature` (
  `bundle_feature_id` int(10) unsigned NOT NULL auto_increment,
  `bundle_id` int(10) unsigned NOT NULL,
  `feature_id` int(10) unsigned NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`bundle_feature_id`),
  UNIQUE KEY `bundle_id` (`bundle_id`,`feature_id`),
  KEY `feature_id` (`feature_id`),
  CONSTRAINT `bundle_feature_ibfk_1` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bundle_feature_ibfk_2` FOREIGN KEY (`feature_id`) REFERENCES `feature` (`feature_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=806 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bundle_license`
--

DROP TABLE IF EXISTS `bundle_license`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `bundle_license` (
  `bundle_license_id` int(10) unsigned NOT NULL auto_increment,
  `bundle_id` int(10) unsigned NOT NULL,
  `license_type_id` int(10) unsigned NOT NULL,
  `is_basic` tinyint(1) unsigned NOT NULL default '0',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`bundle_license_id`),
  UNIQUE KEY `bundle_id` (`bundle_id`,`license_type_id`),
  KEY `bundle_license_ibfk_2` (`license_type_id`),
  CONSTRAINT `bundle_license_ibfk_1` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bundle_license_ibfk_2` FOREIGN KEY (`license_type_id`) REFERENCES `license_type` (`license_type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bundle_packing`
--

DROP TABLE IF EXISTS `bundle_packing`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `bundle_packing` (
  `bundle_packing_id` int(10) unsigned NOT NULL auto_increment,
  `bundle_id` int(10) unsigned NOT NULL,
  `ounces` decimal(6,2) NOT NULL,
  `l` decimal(6,2) NOT NULL,
  `w` decimal(6,2) NOT NULL,
  `h` decimal(6,2) NOT NULL,
  `packing` enum('FILLER','IS_BOXED','NEEDS_BOX') NOT NULL default 'NEEDS_BOX',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`bundle_packing_id`),
  UNIQUE KEY `bundle_id` (`bundle_id`),
  UNIQUE KEY `bundle_id_2` (`bundle_id`),
  CONSTRAINT `bundle_packing_ibfk_1` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bundle_price_model`
--

DROP TABLE IF EXISTS `bundle_price_model`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `bundle_price_model` (
  `bundle_price_model_id` int(10) unsigned NOT NULL auto_increment,
  `bundle_id` int(10) unsigned NOT NULL,
  `price_model_id` int(10) unsigned NOT NULL,
  `tax_mapping_id` int(10) unsigned NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`bundle_price_model_id`),
  UNIQUE KEY `bundle_id` (`bundle_id`,`price_model_id`),
  KEY `price_model_id` (`price_model_id`),
  KEY `tax_mapping_id` (`tax_mapping_id`),
  CONSTRAINT `bundle_price_model_ibfk_1` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bundle_price_model_ibfk_2` FOREIGN KEY (`price_model_id`) REFERENCES `price_model` (`price_model_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bundle_price_model_ibfk_3` FOREIGN KEY (`tax_mapping_id`) REFERENCES `tax_mapping` (`tax_mapping_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=239 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `bundle_relationship`
--

DROP TABLE IF EXISTS `bundle_relationship`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `bundle_relationship` (
  `bundle_relationship_id` int(10) unsigned NOT NULL auto_increment,
  `bundle_id` int(10) unsigned NOT NULL,
  `product_id` int(10) unsigned default NULL,
  `provides_bundle_id` int(10) unsigned default NULL,
  `provides_bundle_id_multiplier` decimal(3,2) NOT NULL default '0.00',
  `disables_bundle_id` int(10) unsigned default NULL,
  `disables_bundle_id_message` varchar(255) NOT NULL default '',
  `enables_bundle_id` int(10) unsigned default NULL,
  `sets_max_bundle_id` int(10) unsigned default NULL,
  `sets_max_bundle_id_multiplier` decimal(3,2) NOT NULL default '0.00',
  `sets_min_bundle_id` int(10) unsigned default NULL,
  `sets_min_bundle_id_multiplier` decimal(3,2) NOT NULL default '0.00',
  `requires_bundle_id` int(10) unsigned default NULL,
  `requires_bundle_id_multiplier` decimal(3,2) NOT NULL default '0.00',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`bundle_relationship_id`),
  KEY `bundle_id` (`bundle_id`),
  KEY `product_id` (`product_id`),
  KEY `provides_bundle_id` (`provides_bundle_id`),
  KEY `disables_bundle_id` (`disables_bundle_id`),
  KEY `enables_bundle_id` (`enables_bundle_id`),
  KEY `sets_max_bundle_id` (`sets_max_bundle_id`),
  KEY `sets_min_bundle_id` (`sets_min_bundle_id`),
  KEY `requires_bundle_id` (`requires_bundle_id`),
  CONSTRAINT `bundle_relationship_ibfk_1` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bundle_relationship_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `bundle_relationship_ibfk_3` FOREIGN KEY (`provides_bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE SET NULL,
  CONSTRAINT `bundle_relationship_ibfk_4` FOREIGN KEY (`disables_bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE SET NULL,
  CONSTRAINT `bundle_relationship_ibfk_5` FOREIGN KEY (`enables_bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE SET NULL,
  CONSTRAINT `bundle_relationship_ibfk_6` FOREIGN KEY (`sets_max_bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE SET NULL,
  CONSTRAINT `bundle_relationship_ibfk_7` FOREIGN KEY (`sets_min_bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE SET NULL,
  CONSTRAINT `bundle_relationship_ibfk_8` FOREIGN KEY (`requires_bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `collector_permission`
--

DROP TABLE IF EXISTS `collector_permission`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `collector_permission` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `user_id` int(10) unsigned NOT NULL,
  `application` varchar(28) NOT NULL default '',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `user_id_2` (`user_id`,`application`),
  KEY `user_id` (`user_id`),
  KEY `application` (`application`),
  CONSTRAINT `collector_permission_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `collector_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `collector_user`
--

DROP TABLE IF EXISTS `collector_user`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `collector_user` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `username` varchar(50) NOT NULL,
  `first_name` varchar(36) NOT NULL default '',
  `last_name` varchar(36) NOT NULL default '',
  `email` varchar(64) NOT NULL default '',
  `api_key` varchar(46) NOT NULL,
  `salt` varchar(16) NOT NULL,
  `api_key_updated` int(10) unsigned NOT NULL default '0',
  `lockout` int(1) unsigned default '0',
  `last_login_ip` varchar(39) NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username_2` (`username`),
  KEY `first_name` (`first_name`),
  KEY `last_name` (`last_name`),
  KEY `username` (`username`),
  KEY `lockout` (`lockout`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `collector_user_ip`
--

DROP TABLE IF EXISTS `collector_user_ip`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `collector_user_ip` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `user_id` int(10) unsigned NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `user_id_2` (`user_id`,`ip_address`),
  KEY `user_id` (`user_id`),
  KEY `ip_address` (`ip_address`),
  CONSTRAINT `collector_user_ip_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `collector_user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `concord_cdr_test`
--

DROP TABLE IF EXISTS `concord_cdr_test`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `concord_cdr_test` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `SalesOrgId` varchar(16) default NULL,
  `CompanyID` varchar(16) default NULL,
  `CountryCode` varchar(8) default NULL,
  `AreaCode` varchar(8) default NULL,
  `FaxPhoneNumber` varchar(20) default NULL,
  `DepartmentCode` varchar(32) default NULL,
  `CustomCode1` varchar(16) default NULL,
  `CustomCode2` int(11) unsigned default NULL,
  `CustomCode3` varchar(16) default NULL,
  `CustomCode4` varchar(16) default NULL,
  `TollFreeFlag` enum('True','False') default NULL,
  `UserID` varchar(16) default NULL,
  `LastName` varchar(32) default NULL,
  `FirstName` varchar(32) default NULL,
  `EmailAddress` varchar(128) default NULL,
  `PageCount` int(11) unsigned default NULL,
  `Date` varchar(16) default NULL,
  `Time` varchar(16) default NULL,
  `TimeZone` varchar(32) default NULL,
  `FaxDestNumber` varchar(20) default NULL,
  `FaxSourceCSID` varchar(20) default NULL,
  `ReferenceId` varchar(20) default NULL,
  `EventTypeDescription` enum('FaxFwd','FaxRcvd','FaxDlvry') default NULL,
  `Subject` varchar(32) default NULL,
  `UserField1` varchar(16) default NULL,
  `UserField2` varchar(16) default NULL,
  `UserField3` varchar(16) default NULL,
  `UserField4` varchar(16) default NULL,
  `UserField5` varchar(16) default NULL,
  `UserField6` varchar(16) default NULL,
  `UserField7` varchar(16) default NULL,
  `UserField8` varchar(16) default NULL,
  `UserField9` varchar(16) default NULL,
  `UserField10` varchar(16) default NULL,
  `UserField11` varchar(16) default NULL,
  `UserField12` varchar(16) default NULL,
  `FaxSourceSenderNumber` varchar(20) default NULL,
  `epochGMT` int(11) unsigned NOT NULL,
  `invoice_id` int(11) unsigned default NULL,
  `MessageId` varchar(128) NOT NULL,
  `RecordId` varchar(128) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `RecordId` (`RecordId`),
  KEY `invoice_id` (`invoice_id`),
  KEY `epochGMT` (`epochGMT`),
  KEY `CustomCode2` (`CustomCode2`)
) ENGINE=InnoDB AUTO_INCREMENT=492650 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `country`
--

DROP TABLE IF EXISTS `country`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `country` (
  `country_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(80) NOT NULL,
  `dialing_code` varchar(255) NOT NULL default '',
  `national_prefix` varchar(255) NOT NULL default '',
  `numeric_code` char(3) default NULL,
  `alpha_code_2` char(2) NOT NULL default '',
  `alpha_code_3` char(3) NOT NULL default '',
  `loadzone` char(2) NOT NULL default '',
  `default_language` varchar(80) NOT NULL default '',
  PRIMARY KEY  (`country_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `country_region`
--

DROP TABLE IF EXISTS `country_region`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `country_region` (
  `country_region_id` int(10) unsigned NOT NULL auto_increment,
  `country_id` int(10) unsigned NOT NULL,
  `region_code` varchar(3) NOT NULL default '',
  `region_name` varchar(28) NOT NULL default '',
  PRIMARY KEY  (`country_region_id`),
  KEY `country_id` (`country_id`),
  CONSTRAINT `region_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `country` (`country_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `customer_address`
--

DROP TABLE IF EXISTS `customer_address`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `customer_address` (
  `customer_address_id` int(10) unsigned NOT NULL auto_increment,
  `customer_id` int(10) unsigned NOT NULL,
  `address_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`customer_address_id`),
  UNIQUE KEY `customer_id` (`customer_id`,`address_id`),
  KEY `address_id` (`address_id`),
  CONSTRAINT `customer_address_ibfk_1` FOREIGN KEY (`address_id`) REFERENCES `entity_address` (`entity_address_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `customer_contact`
--

DROP TABLE IF EXISTS `customer_contact`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `customer_contact` (
  `customer_contact_id` int(10) unsigned NOT NULL auto_increment,
  `customer_id` int(10) unsigned NOT NULL,
  `contact_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`customer_contact_id`),
  UNIQUE KEY `customer_id` (`customer_id`,`contact_id`),
  KEY `contact_id` (`contact_id`),
  CONSTRAINT `customer_contact_ibfk_1` FOREIGN KEY (`contact_id`) REFERENCES `entity_contact` (`entity_contact_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `datacenter`
--

DROP TABLE IF EXISTS `datacenter`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `datacenter` (
  `datacenter_id` int(10) unsigned NOT NULL auto_increment,
  `country_id` int(10) unsigned NOT NULL,
  `state_prov` varchar(10) NOT NULL default '',
  `location` enum('LA','VA','JPN','AUS') NOT NULL default 'LA',
  PRIMARY KEY  (`datacenter_id`),
  UNIQUE KEY `country_id` (`country_id`,`state_prov`,`location`),
  CONSTRAINT `datacenter_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `country` (`country_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `deployment`
--

DROP TABLE IF EXISTS `deployment`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `deployment` (
  `deployment_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(80) NOT NULL,
  `description` mediumtext NOT NULL,
  `is_hosted` tinyint(1) unsigned NOT NULL default '0',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`deployment_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `discount`
--

DROP TABLE IF EXISTS `discount`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `discount` (
  `discount_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(55) NOT NULL,
  `category_id` int(10) unsigned NOT NULL,
  `min_value` int(11) NOT NULL default '0',
  `max_value` int(11) NOT NULL default '0',
  `percent` decimal(5,2) NOT NULL default '0.00',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`discount_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `discount_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `discount_category` (`discount_category_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `discount_category`
--

DROP TABLE IF EXISTS `discount_category`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `discount_category` (
  `discount_category_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`discount_category_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `discount_limit`
--

DROP TABLE IF EXISTS `discount_limit`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `discount_limit` (
  `discount_limit_id` int(10) unsigned NOT NULL auto_increment,
  `category_id` int(10) unsigned NOT NULL,
  `percent` decimal(2,2) NOT NULL default '0.00',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`discount_limit_id`),
  UNIQUE KEY `category_id` (`category_id`),
  CONSTRAINT `discount_limit_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `discount_category` (`discount_category_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `discount_type`
--

DROP TABLE IF EXISTS `discount_type`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `discount_type` (
  `discount_type_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`discount_type_id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `name_2` (`name`),
  UNIQUE KEY `name_3` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `entity_address`
--

DROP TABLE IF EXISTS `entity_address`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `entity_address` (
  `entity_address_id` int(10) unsigned NOT NULL auto_increment,
  `label` varchar(128) NOT NULL default '',
  `type` enum('BILLING','SHIPPING') NOT NULL default 'SHIPPING',
  `addr1` varchar(128) NOT NULL default '',
  `addr2` varchar(128) NOT NULL default '',
  `city` varchar(128) NOT NULL default '',
  `state_prov` varchar(10) NOT NULL default '',
  `postal` varchar(20) NOT NULL default '',
  `country` varchar(3) NOT NULL default '',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`entity_address_id`),
  UNIQUE KEY `type` (`type`,`addr1`,`city`,`state_prov`,`postal`),
  KEY `idx_addr` (`addr1`,`city`,`state_prov`,`postal`,`country`)
) ENGINE=InnoDB AUTO_INCREMENT=20235 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `entity_contact`
--

DROP TABLE IF EXISTS `entity_contact`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `entity_contact` (
  `entity_contact_id` int(10) unsigned NOT NULL auto_increment,
  `netsuite_id` bigint(20) unsigned default NULL,
  `role` enum('ADMIN','TECH','BILLING') NOT NULL default 'ADMIN',
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `email` varchar(128) NOT NULL default '',
  `phone` varchar(20) NOT NULL default '',
  `extension` int(10) default NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`entity_contact_id`),
  UNIQUE KEY `first_name` (`first_name`,`last_name`,`email`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `entity_credit_card`
--

DROP TABLE IF EXISTS `entity_credit_card`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `entity_credit_card` (
  `entity_credit_card_id` int(10) unsigned NOT NULL auto_increment,
  `customer_id` int(10) unsigned NOT NULL,
  `billing_address_id` int(10) unsigned NOT NULL,
  `netsuite_card_id` int(10) unsigned NOT NULL,
  `cardholder_name` varchar(255) default NULL,
  `first_four` char(4) default NULL,
  `last_four` char(4) default NULL,
  `expiration_month` tinyint(2) default NULL,
  `expiration_year` smallint(4) default NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`entity_credit_card_id`),
  UNIQUE KEY `customer_id` (`customer_id`,`netsuite_card_id`),
  KEY `billing_address_id` (`billing_address_id`),
  CONSTRAINT `entity_credit_card_ibfk_1` FOREIGN KEY (`billing_address_id`) REFERENCES `entity_address` (`entity_address_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `feature`
--

DROP TABLE IF EXISTS `feature`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `feature` (
  `feature_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(128) NOT NULL,
  `description` mediumtext NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`feature_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `group_user`
--

DROP TABLE IF EXISTS `group_user`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `group_user` (
  `group_user_id` int(10) unsigned NOT NULL auto_increment,
  `group_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`group_user_id`),
  UNIQUE KEY `group_id` (`group_id`,`user_id`),
  CONSTRAINT `group_user_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3016 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `groups` (
  `group_id` int(10) unsigned NOT NULL auto_increment,
  `server_id` int(11) NOT NULL,
  `name` varchar(80) NOT NULL,
  `extension` int(10) unsigned default NULL,
  `auto_add_user` tinyint(1) NOT NULL default '0',
  `is_department` tinyint(1) NOT NULL default '0',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`group_id`),
  UNIQUE KEY `server_id_2` (`server_id`,`name`),
  UNIQUE KEY `server_id` (`server_id`,`extension`)
) ENGINE=InnoDB AUTO_INCREMENT=210 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `hud_license_map`
--

DROP TABLE IF EXISTS `hud_license_map`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `hud_license_map` (
  `hud_license_map_id` int(10) unsigned NOT NULL auto_increment,
  `license_type_id` int(10) unsigned NOT NULL,
  `hud_fc` varchar(255) NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`hud_license_map_id`),
  UNIQUE KEY `license_type_id` (`license_type_id`),
  UNIQUE KEY `license_type_id_2` (`license_type_id`),
  UNIQUE KEY `license_type_id_3` (`license_type_id`),
  CONSTRAINT `hud_license_map_ibfk_1` FOREIGN KEY (`license_type_id`) REFERENCES `license_type` (`license_type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_audit`
--

DROP TABLE IF EXISTS `intranet_audit`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_audit` (
  `intranet_audit_id` int(10) unsigned NOT NULL auto_increment,
  `intranet_user_id` int(10) unsigned NOT NULL,
  `customer_id` int(10) unsigned default NULL,
  `server_id` int(10) unsigned default NULL,
  `module` varchar(36) NOT NULL default '',
  `function` varchar(128) NOT NULL default '',
  `audit` varchar(128) NOT NULL default '',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`intranet_audit_id`),
  KEY `intranet_audit_ibfk_1` (`intranet_user_id`),
  CONSTRAINT `intranet_audit_ibfk_1` FOREIGN KEY (`intranet_user_id`) REFERENCES `intranet_user` (`intranet_user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_log`
--

DROP TABLE IF EXISTS `intranet_log`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_log` (
  `intranet_log_id` int(10) unsigned NOT NULL auto_increment,
  `intranet_user` varchar(50) NOT NULL default '',
  `module` varchar(36) NOT NULL default '',
  `level` varchar(16) NOT NULL default 'INFO',
  `function` varchar(128) NOT NULL default '',
  `message` mediumtext NOT NULL,
  `ip_address` varchar(45) NOT NULL default '',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`intranet_log_id`),
  KEY `intranet_log_ibfk_1` (`intranet_user`)
) ENGINE=InnoDB AUTO_INCREMENT=667014 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_permission`
--

DROP TABLE IF EXISTS `intranet_permission`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_permission` (
  `intranet_permission_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(36) NOT NULL,
  `parent_id` int(10) unsigned default NULL,
  `description` varchar(128) NOT NULL,
  `access` varchar(3) NOT NULL default 'r',
  PRIMARY KEY  (`intranet_permission_id`),
  UNIQUE KEY `name` (`name`),
  KEY `intranet_permission_ibfk_1` (`parent_id`),
  CONSTRAINT `intranet_permission_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `intranet_permission` (`intranet_permission_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_role`
--

DROP TABLE IF EXISTS `intranet_role`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_role` (
  `intranet_role_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `description` mediumtext NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`intranet_role_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_role_xref`
--

DROP TABLE IF EXISTS `intranet_role_xref`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_role_xref` (
  `intranet_role_xref_id` int(10) unsigned NOT NULL auto_increment,
  `role_id` int(10) unsigned NOT NULL,
  `permission_id` int(10) unsigned NOT NULL,
  `access` varchar(3) NOT NULL default 'r',
  PRIMARY KEY  (`intranet_role_xref_id`),
  UNIQUE KEY `role_id` (`role_id`,`permission_id`),
  KEY `intranet_role_xref_ibfk_1` (`permission_id`),
  CONSTRAINT `intranet_role_xref_ibfk_1` FOREIGN KEY (`permission_id`) REFERENCES `intranet_permission` (`intranet_permission_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `intranet_role_xref_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `intranet_role` (`intranet_role_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_searchable`
--

DROP TABLE IF EXISTS `intranet_searchable`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_searchable` (
  `intranet_searchable_id` int(10) unsigned NOT NULL auto_increment,
  `mode` varchar(36) NOT NULL,
  `format` varchar(72) NOT NULL,
  `action` varchar(36) NOT NULL default 'searchable',
  `param` varchar(36) NOT NULL default 'query',
  PRIMARY KEY  (`intranet_searchable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_session`
--

DROP TABLE IF EXISTS `intranet_session`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_session` (
  `intranet_session_id` int(10) unsigned NOT NULL auto_increment,
  `guid` varchar(32) NOT NULL,
  `session` text NOT NULL,
  `ip_address` varchar(45) NOT NULL default '',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`intranet_session_id`),
  UNIQUE KEY `guid_unq` (`guid`),
  KEY `guid` (`guid`)
) ENGINE=InnoDB AUTO_INCREMENT=249 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_setting`
--

DROP TABLE IF EXISTS `intranet_setting`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_setting` (
  `intranet_setting_id` int(10) unsigned NOT NULL auto_increment,
  `setting` varchar(128) NOT NULL,
  `value` varchar(128) NOT NULL,
  PRIMARY KEY  (`intranet_setting_id`),
  UNIQUE KEY `setting` (`setting`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_user`
--

DROP TABLE IF EXISTS `intranet_user`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_user` (
  `intranet_user_id` int(10) unsigned NOT NULL auto_increment,
  `username` varchar(50) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `email` varchar(128) NOT NULL,
  `password` varchar(46) NOT NULL,
  `salt` varchar(16) NOT NULL,
  `password_updated` int(10) unsigned NOT NULL default '0',
  `lockout` tinyint(1) unsigned NOT NULL default '0',
  `disabled` tinyint(1) unsigned NOT NULL default '0',
  `disabled_date` timestamp NOT NULL default '1970-01-01 08:00:00',
  `last_login_ip` varchar(45) NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`intranet_user_id`),
  UNIQUE KEY `username_2` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_user_permission_xref`
--

DROP TABLE IF EXISTS `intranet_user_permission_xref`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_user_permission_xref` (
  `intranet_user_permission_xref_id` int(10) unsigned NOT NULL auto_increment,
  `intranet_user_id` int(10) unsigned NOT NULL,
  `permission_id` int(10) unsigned NOT NULL,
  `access` varchar(3) NOT NULL default 'r',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`intranet_user_permission_xref_id`),
  UNIQUE KEY `intranet_user_id` (`intranet_user_id`,`permission_id`),
  KEY `intranet_user_permission_xref_ibfk_2` (`permission_id`),
  CONSTRAINT `intranet_user_permission_xref_ibfk_1` FOREIGN KEY (`intranet_user_id`) REFERENCES `intranet_user` (`intranet_user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `intranet_user_permission_xref_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `intranet_permission` (`intranet_permission_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `intranet_user_role_xref`
--

DROP TABLE IF EXISTS `intranet_user_role_xref`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `intranet_user_role_xref` (
  `intranet_user_role_xref_id` int(10) unsigned NOT NULL auto_increment,
  `intranet_user_id` int(10) unsigned NOT NULL,
  `role_id` int(10) unsigned NOT NULL,
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`intranet_user_role_xref_id`),
  UNIQUE KEY `intranet_user_id` (`intranet_user_id`,`role_id`),
  KEY `intranet_user_role_xref_ibfk_2` (`role_id`),
  CONSTRAINT `intranet_user_role_xref_ibfk_1` FOREIGN KEY (`intranet_user_id`) REFERENCES `intranet_user` (`intranet_user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `intranet_user_role_xref_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `intranet_role` (`intranet_role_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `license_feature`
--

DROP TABLE IF EXISTS `license_feature`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `license_feature` (
  `license_feature_id` int(10) unsigned NOT NULL auto_increment,
  `license_type_id` int(10) unsigned NOT NULL,
  `feature_id` int(10) unsigned NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`license_feature_id`),
  UNIQUE KEY `license_type_id` (`license_type_id`,`feature_id`),
  KEY `license_feature_ibfk_1` (`feature_id`),
  CONSTRAINT `license_feature_ibfk_2` FOREIGN KEY (`license_type_id`) REFERENCES `license_type` (`license_type_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `license_feature_ibfk_3` FOREIGN KEY (`feature_id`) REFERENCES `feature` (`feature_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=95 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `license_perm`
--

DROP TABLE IF EXISTS `license_perm`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `license_perm` (
  `license_perm_id` int(10) unsigned NOT NULL auto_increment,
  `license_type_id` int(10) unsigned NOT NULL,
  `perm_id` int(10) unsigned NOT NULL,
  `type` enum('USER','GROUP') NOT NULL default 'USER',
  PRIMARY KEY  (`license_perm_id`),
  UNIQUE KEY `license_type_id` (`license_type_id`,`perm_id`),
  KEY `perm_id` (`perm_id`),
  CONSTRAINT `license_perm_ibfk_1` FOREIGN KEY (`license_type_id`) REFERENCES `license_type` (`license_type_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `license_perm_ibfk_2` FOREIGN KEY (`perm_id`) REFERENCES `perm` (`perm_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `license_prereq`
--

DROP TABLE IF EXISTS `license_prereq`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `license_prereq` (
  `license_prereq_id` int(10) unsigned NOT NULL auto_increment,
  `license_type_id` int(10) unsigned NOT NULL,
  `prereq_license_type_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`license_prereq_id`),
  UNIQUE KEY `license_type_id` (`license_type_id`,`prereq_license_type_id`),
  KEY `prereq_license_type_id` (`prereq_license_type_id`),
  CONSTRAINT `license_prereq_ibfk_1` FOREIGN KEY (`license_type_id`) REFERENCES `license_type` (`license_type_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `license_prereq_ibfk_2` FOREIGN KEY (`prereq_license_type_id`) REFERENCES `license_type` (`license_type_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `license_type`
--

DROP TABLE IF EXISTS `license_type`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `license_type` (
  `license_type_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(20) NOT NULL,
  `label` varchar(255) NOT NULL,
  PRIMARY KEY  (`license_type_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `netsuite_salesperson`
--

DROP TABLE IF EXISTS `netsuite_salesperson`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `netsuite_salesperson` (
  `salesperson_id` int(10) unsigned NOT NULL auto_increment,
  `netsuite_id` bigint(20) unsigned NOT NULL,
  `intranet_username` varchar(255) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `phone` varchar(20) NOT NULL default '',
  `email` varchar(128) NOT NULL,
  `title` varchar(128) NOT NULL default '',
  `can_deduct` tinyint(1) NOT NULL default '0',
  `is_active` tinyint(1) NOT NULL default '1',
  `extension` int(10) default NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`salesperson_id`),
  KEY `idx_netsuite_id` (`netsuite_id`)
) ENGINE=InnoDB AUTO_INCREMENT=842 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_bundle`
--

DROP TABLE IF EXISTS `order_bundle`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_bundle` (
  `order_bundle_id` int(10) unsigned NOT NULL auto_increment,
  `bundle_id` int(10) unsigned NOT NULL,
  `order_group_id` int(10) unsigned NOT NULL,
  `quantity` int(10) unsigned NOT NULL default '1',
  `list_price` decimal(10,2) NOT NULL default '0.00',
  `discounted_price` decimal(10,2) NOT NULL default '0.00',
  `one_time_total` decimal(10,2) default NULL,
  `mrc_total` decimal(10,2) NOT NULL default '0.00',
  `is_rented` tinyint(1) NOT NULL default '0',
  `provisioned_on` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`order_bundle_id`),
  KEY `idx_bid_f_idx` (`bundle_id`),
  KEY `order_bundle_ibfk_4` (`order_group_id`),
  CONSTRAINT `order_bundle_ibfk_2` FOREIGN KEY (`order_group_id`) REFERENCES `order_group` (`order_group_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_bundle_ibfk_3` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38815 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_bundle_detail`
--

DROP TABLE IF EXISTS `order_bundle_detail`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_bundle_detail` (
  `order_bundle_detail_id` int(10) unsigned NOT NULL auto_increment,
  `order_bundle_id` int(10) unsigned NOT NULL,
  `extension_number` int(10) unsigned default NULL,
  `mac_address` varchar(12) default NULL,
  `did_number` varchar(20) NOT NULL default '',
  `desired_did_number` varchar(20) default NULL,
  `is_lnp` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`order_bundle_detail_id`),
  UNIQUE KEY `order_bundle_id` (`order_bundle_id`,`extension_number`),
  UNIQUE KEY `order_bundle_id_2` (`order_bundle_id`,`mac_address`),
  CONSTRAINT `order_bundle_detail_ibfk_1` FOREIGN KEY (`order_bundle_id`) REFERENCES `order_bundle` (`order_bundle_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28684 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_category`
--

DROP TABLE IF EXISTS `order_category`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_category` (
  `category_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` mediumtext NOT NULL,
  `priority` tinyint(3) unsigned NOT NULL default '0',
  `display_type` varchar(128) NOT NULL default '',
  `product_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`category_id`),
  KEY `order_category_ibfk_1` (`product_id`),
  CONSTRAINT `order_category_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_category_label_xref`
--

DROP TABLE IF EXISTS `order_category_label_xref`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_category_label_xref` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `category_id` int(10) unsigned NOT NULL,
  `label_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `category_id_2` (`category_id`,`label_id`),
  KEY `category_id` (`category_id`),
  KEY `label_id` (`label_id`),
  CONSTRAINT `order_category_label_xref_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `order_category` (`category_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_category_label_xref_ibfk_2` FOREIGN KEY (`label_id`) REFERENCES `order_label` (`label_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_discount`
--

DROP TABLE IF EXISTS `order_discount`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_discount` (
  `order_discount_id` int(10) unsigned NOT NULL auto_increment,
  `order_id` int(10) unsigned NOT NULL,
  `discount_type_id` int(10) unsigned NOT NULL,
  `promo_code_id` int(10) unsigned default NULL,
  `one_time_discount` decimal(10,2) NOT NULL default '0.00',
  `mrc_discount` decimal(10,2) NOT NULL default '0.00',
  PRIMARY KEY  (`order_discount_id`),
  UNIQUE KEY `order_id` (`order_id`,`promo_code_id`),
  KEY `order_discount_ibfk_2` (`promo_code_id`),
  KEY `order_discount_ibfk_3` (`discount_type_id`),
  CONSTRAINT `order_discount_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_discount_ibfk_2` FOREIGN KEY (`promo_code_id`) REFERENCES `promo_code` (`promo_code_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `order_discount_ibfk_3` FOREIGN KEY (`discount_type_id`) REFERENCES `discount_type` (`discount_type_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=240 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_group`
--

DROP TABLE IF EXISTS `order_group`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_group` (
  `order_group_id` int(10) unsigned NOT NULL auto_increment,
  `order_id` int(10) unsigned NOT NULL,
  `server_id` int(10) unsigned default NULL,
  `is_primary` tinyint(1) NOT NULL default '0',
  `shipping_address_id` int(10) unsigned NOT NULL,
  `billing_address_id` int(10) unsigned default NULL,
  `chosen_shipping_id` int(10) unsigned default NULL,
  `product_id` int(10) unsigned NOT NULL,
  `netsuite_sales_order_id` bigint(20) unsigned default NULL,
  `netsuite_echosign_id` bigint(20) unsigned default NULL,
  `one_time_total` decimal(10,2) NOT NULL default '0.00',
  `mrc_total` decimal(10,2) NOT NULL default '0.00',
  `one_time_tax_total` decimal(10,2) NOT NULL default '0.00',
  `mrc_tax_total` decimal(10,2) NOT NULL default '0.00',
  PRIMARY KEY  (`order_group_id`),
  UNIQUE KEY `order_id` (`order_id`,`netsuite_sales_order_id`),
  UNIQUE KEY `order_id_2` (`order_id`,`server_id`,`shipping_address_id`),
  KEY `shipping_address_id` (`shipping_address_id`),
  KEY `order_group_ibfk_2` (`billing_address_id`),
  KEY `order_group_ibfk_11` (`chosen_shipping_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `order_group_ibfk_10` FOREIGN KEY (`billing_address_id`) REFERENCES `entity_address` (`entity_address_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `order_group_ibfk_11` FOREIGN KEY (`chosen_shipping_id`) REFERENCES `order_shipping` (`order_shipping_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `order_group_ibfk_12` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`) ON UPDATE CASCADE,
  CONSTRAINT `order_group_ibfk_6` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_group_ibfk_9` FOREIGN KEY (`shipping_address_id`) REFERENCES `entity_address` (`entity_address_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36490 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_label`
--

DROP TABLE IF EXISTS `order_label`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_label` (
  `label_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` mediumtext NOT NULL,
  `priority` tinyint(3) unsigned NOT NULL default '0',
  `display` enum('DROPDOWN','NUMBER','RADIO','CHECKBOX','TEXT') NOT NULL default 'DROPDOWN',
  `required` enum('YES','NO') NOT NULL default 'NO',
  `validation_type` enum('DEFAULT','ALPHANUMERIC','FORM_NAME','FORM_COMPANYNAME','FORM_POSTAL_CODE','FORM_PHONE_NUMBER','FORM_CC_NUMBER','COMMENTS','EMAIL_ADDRESS','NUMBERS','LETTERS','PRICE','TEXT','URL') NOT NULL default 'DEFAULT',
  `max` varchar(255) NOT NULL default '',
  `min` varchar(255) NOT NULL default '',
  `dropdown_has_null` tinyint(1) NOT NULL default '0',
  `dropdown_null_text` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`label_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_shipping`
--

DROP TABLE IF EXISTS `order_shipping`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_shipping` (
  `order_shipping_id` int(10) unsigned NOT NULL auto_increment,
  `order_group_id` int(10) unsigned NOT NULL,
  `shipping_text` varchar(64) NOT NULL,
  `shipping_rate` decimal(10,2) NOT NULL default '0.00',
  PRIMARY KEY  (`order_shipping_id`),
  UNIQUE KEY `order_group_id_2` (`order_group_id`,`shipping_text`),
  KEY `order_group_id` (`order_group_id`),
  CONSTRAINT `order_shipping_ibfk_1` FOREIGN KEY (`order_group_id`) REFERENCES `order_group` (`order_group_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1778 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_status`
--

DROP TABLE IF EXISTS `order_status`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_status` (
  `order_status_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  `description` mediumtext NOT NULL,
  PRIMARY KEY  (`order_status_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_transaction`
--

DROP TABLE IF EXISTS `order_transaction`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_transaction` (
  `order_transaction_id` int(10) unsigned NOT NULL auto_increment,
  `server_id` int(10) unsigned default NULL,
  `customer_id` int(10) unsigned default NULL,
  `order_group_id` int(10) unsigned default NULL,
  `billing_schedule_id` int(10) unsigned default NULL,
  `netsuite_trans_id` bigint(20) unsigned default NULL,
  `payment_method_id` int(10) unsigned NOT NULL,
  `credit_card_id` int(10) unsigned default NULL,
  `amount` decimal(10,2) NOT NULL default '0.00',
  `type` enum('CASH_SALE','INVOICE','ORDER') default NULL,
  `status` enum('NOT_PROCESSED','READY_TO_PROCESS','PROCESSING','PROCESSED') NOT NULL default 'NOT_PROCESSED',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`order_transaction_id`),
  KEY `order_transaction_ibfk_1` (`order_group_id`),
  KEY `payment_method_id` (`payment_method_id`),
  KEY `billing_schedule_id` (`billing_schedule_id`),
  KEY `credit_card_id` (`credit_card_id`),
  CONSTRAINT `order_transaction_ibfk_10` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_method` (`payment_method_id`) ON UPDATE CASCADE,
  CONSTRAINT `order_transaction_ibfk_11` FOREIGN KEY (`billing_schedule_id`) REFERENCES `billing_schedule` (`billing_schedule_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `order_transaction_ibfk_12` FOREIGN KEY (`credit_card_id`) REFERENCES `entity_credit_card` (`entity_credit_card_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `order_transaction_ibfk_7` FOREIGN KEY (`order_group_id`) REFERENCES `order_group` (`order_group_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1783 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_transaction_item`
--

DROP TABLE IF EXISTS `order_transaction_item`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_transaction_item` (
  `order_transaction_item_id` int(10) unsigned NOT NULL auto_increment,
  `order_transaction_id` int(10) unsigned NOT NULL,
  `order_group_id` int(10) unsigned NOT NULL,
  `parent_trans_item_id` int(10) unsigned default NULL,
  `bundle_id` int(10) unsigned NOT NULL,
  `netsuite_item_id` bigint(20) unsigned NOT NULL,
  `quantity` int(10) unsigned NOT NULL default '1',
  `list_price` decimal(10,2) NOT NULL default '0.00',
  `description` mediumtext NOT NULL,
  `monthly_usage` int(10) unsigned NOT NULL default '0',
  `amount` decimal(10,2) NOT NULL default '0.00',
  PRIMARY KEY  (`order_transaction_item_id`),
  KEY `order_transaction_item_ibfk_1` (`order_transaction_id`),
  KEY `order_transaction_item_ibfk_2` (`bundle_id`),
  KEY `parent_trans_item_id` (`parent_trans_item_id`),
  KEY `order_group_id` (`order_group_id`),
  CONSTRAINT `order_transaction_item_ibfk_4` FOREIGN KEY (`order_group_id`) REFERENCES `order_group` (`order_group_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_transaction_item_ibfk_1` FOREIGN KEY (`order_transaction_id`) REFERENCES `order_transaction` (`order_transaction_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_transaction_item_ibfk_2` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON UPDATE CASCADE,
  CONSTRAINT `order_transaction_item_ibfk_3` FOREIGN KEY (`parent_trans_item_id`) REFERENCES `order_transaction_item` (`order_transaction_item_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10163 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `order_transaction_log`
--

DROP TABLE IF EXISTS `order_transaction_log`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `order_transaction_log` (
  `order_transaction_log_id` int(10) unsigned NOT NULL auto_increment,
  `order_transaction_id` int(10) unsigned default NULL,
  `billing_schedule_id` int(10) unsigned default NULL,
  `level` enum('INFO','DEBUG','ERROR','WARN') NOT NULL default 'INFO',
  `module` varchar(128) NOT NULL default '',
  `function` varchar(128) NOT NULL default '',
  `message` mediumtext NOT NULL,
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`order_transaction_log_id`),
  KEY `order_transaction_log_ibfk_1` (`order_transaction_id`),
  KEY `order_transaction_log_ibfk_2` (`billing_schedule_id`),
  CONSTRAINT `order_transaction_log_ibfk_1` FOREIGN KEY (`order_transaction_id`) REFERENCES `order_transaction` (`order_transaction_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `order_transaction_log_ibfk_2` FOREIGN KEY (`billing_schedule_id`) REFERENCES `billing_schedule` (`billing_schedule_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `orders` (
  `order_id` int(10) unsigned NOT NULL auto_increment,
  `transaction_submit_id` int(10) unsigned default NULL,
  `prepay_amount` decimal(10,2) NOT NULL default '0.00',
  `one_time_total` decimal(10,2) NOT NULL default '0.00',
  `mrc_total` decimal(10,2) NOT NULL default '0.00',
  `contract_total` decimal(10,2) NOT NULL default '0.00',
  `contract_balance` decimal(10,2) NOT NULL default '0.00',
  `avg_cost_per_user` decimal(10,2) NOT NULL default '0.00',
  `cost_add_user` varchar(255) NOT NULL default '',
  `term_in_months` int(3) unsigned NOT NULL default '12',
  `contract_start_date` timestamp NOT NULL default '1970-01-01 08:00:00',
  `billing_interval_in_months` int(3) unsigned NOT NULL default '1',
  `reseller_id` int(10) unsigned default NULL,
  `customer_id` int(10) unsigned default NULL,
  `contact_id` int(10) unsigned NOT NULL,
  `company_name` varchar(80) NOT NULL,
  `website` varchar(255) NOT NULL default '',
  `industry` varchar(255) NOT NULL default '',
  `netsuite_entity_id` bigint(20) unsigned NOT NULL,
  `netsuite_salesperson_id` int(10) unsigned default NULL,
  `credit_card_id` int(10) unsigned default NULL,
  `payment_method_id` int(10) unsigned default NULL,
  `order_status_id` int(10) unsigned default NULL,
  `order_creator_id` int(10) unsigned default NULL,
  `provisioning_status_id` int(10) unsigned default NULL,
  `note` mediumtext NOT NULL,
  `proposal_pdf` varchar(255) default NULL,
  `manager_reviewer_id` int(10) unsigned default NULL,
  `manager_approval_status_id` int(10) unsigned default NULL,
  `manager_approval_date` timestamp NOT NULL default '1970-01-01 08:00:00',
  `billing_reviewer_id` int(10) unsigned default NULL,
  `billing_approval_status_id` int(10) unsigned default NULL,
  `billing_approval_date` timestamp NOT NULL default '1970-01-01 08:00:00',
  `credit_reviewer_id` int(10) unsigned default NULL,
  `credit_approval_status_id` int(10) unsigned default NULL,
  `credit_approval_date` timestamp NOT NULL default '1970-01-01 08:00:00',
  `approval_comment` mediumtext NOT NULL,
  `order_type` enum('NEW','ADDON') NOT NULL default 'NEW',
  `record_type` enum('QUOTE','ORDER') NOT NULL default 'QUOTE',
  `quote_expiry` timestamp NOT NULL default '1970-01-01 08:00:00',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`order_id`),
  KEY `netsuite_salesperson_id` (`netsuite_salesperson_id`),
  KEY `order_status_id` (`order_status_id`),
  KEY `provisioning_status_id` (`provisioning_status_id`),
  KEY `manager_approval_status_id` (`manager_approval_status_id`),
  KEY `billing_approval_status_id` (`billing_approval_status_id`),
  KEY `credit_approval_status_id` (`credit_approval_status_id`),
  KEY `contact_id` (`contact_id`),
  KEY `payment_method_id` (`payment_method_id`),
  KEY `transaction_submit_id` (`transaction_submit_id`),
  KEY `credit_card_id` (`credit_card_id`),
  CONSTRAINT `orders_ibfk_10` FOREIGN KEY (`credit_card_id`) REFERENCES `entity_credit_card` (`entity_credit_card_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`order_status_id`) REFERENCES `order_status` (`order_status_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`provisioning_status_id`) REFERENCES `order_status` (`order_status_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_4` FOREIGN KEY (`manager_approval_status_id`) REFERENCES `order_status` (`order_status_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_5` FOREIGN KEY (`billing_approval_status_id`) REFERENCES `order_status` (`order_status_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_6` FOREIGN KEY (`credit_approval_status_id`) REFERENCES `order_status` (`order_status_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_7` FOREIGN KEY (`contact_id`) REFERENCES `entity_contact` (`entity_contact_id`) ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_8` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_method` (`payment_method_id`) ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_9` FOREIGN KEY (`transaction_submit_id`) REFERENCES `transaction_submit` (`transaction_submit_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59193 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `payment_method`
--

DROP TABLE IF EXISTS `payment_method`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `payment_method` (
  `payment_method_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY  (`payment_method_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `perm`
--

DROP TABLE IF EXISTS `perm`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `perm` (
  `perm_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `code` varchar(50) NOT NULL default '',
  `cp_version` varchar(20) NOT NULL default '',
  `feature_id` int(10) unsigned default NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`perm_id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `name` (`name`),
  KEY `perm_ibfk_2` (`feature_id`),
  CONSTRAINT `perm_ibfk_1` FOREIGN KEY (`feature_id`) REFERENCES `feature` (`feature_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `price_model`
--

DROP TABLE IF EXISTS `price_model`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `price_model` (
  `price_model_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`price_model_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `product` (
  `product_id` int(10) unsigned NOT NULL auto_increment,
  `deployment_id` int(10) unsigned NOT NULL,
  `name` varchar(80) NOT NULL,
  `description` mediumtext NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`product_id`),
  UNIQUE KEY `deployment_id` (`deployment_id`),
  UNIQUE KEY `name` (`name`),
  CONSTRAINT `product_ibfk_1` FOREIGN KEY (`deployment_id`) REFERENCES `deployment` (`deployment_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `promo_action`
--

DROP TABLE IF EXISTS `promo_action`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `promo_action` (
  `promo_action_id` int(10) unsigned NOT NULL auto_increment,
  `promo_code_id` int(10) unsigned NOT NULL,
  `action` enum('BUNDLE_BOGO','BUNDLE_DISCOUNT','BUNDLE_UPGRADE','SHIPPING_DISCOUNT') NOT NULL default 'BUNDLE_DISCOUNT',
  `bundle_id` int(10) unsigned NOT NULL,
  `upgrade_bundle_id` int(10) unsigned default NULL,
  `discount_type` enum('ONE_TIME','MRC','ALL') NOT NULL default 'MRC',
  `discount_amount` decimal(10,2) NOT NULL default '0.00',
  `discount_percent` decimal(5,2) NOT NULL default '0.00',
  `discount_months` int(3) unsigned default NULL,
  `min_quantity` int(3) unsigned NOT NULL default '1',
  `max_quantity` int(3) unsigned default NULL,
  PRIMARY KEY  (`promo_action_id`),
  UNIQUE KEY `promo_code_id` (`promo_code_id`,`action`,`bundle_id`),
  KEY `promo_action_ibfk_2` (`bundle_id`),
  KEY `promo_action_ibfk_3` (`upgrade_bundle_id`),
  CONSTRAINT `promo_action_ibfk_1` FOREIGN KEY (`promo_code_id`) REFERENCES `promo_code` (`promo_code_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `promo_action_ibfk_2` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON UPDATE CASCADE,
  CONSTRAINT `promo_action_ibfk_3` FOREIGN KEY (`upgrade_bundle_id`) REFERENCES `bundle` (`bundle_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `promo_code`
--

DROP TABLE IF EXISTS `promo_code`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `promo_code` (
  `promo_code_id` int(10) unsigned NOT NULL auto_increment,
  `promo_code` varchar(50) NOT NULL,
  `name` varchar(80) NOT NULL,
  `description` mediumtext NOT NULL,
  `netsuite_campaign_id` bigint(20) default NULL,
  `type` enum('promo','kit') NOT NULL default 'promo',
  `start_date` timestamp NOT NULL default '1970-01-01 08:00:00',
  `expire_date` timestamp NOT NULL default '1970-01-01 08:00:00',
  `is_stackable` tinyint(1) unsigned NOT NULL default '1',
  `new_business_only` tinyint(1) NOT NULL default '1',
  `term_in_months` int(3) unsigned default NULL,
  `force_prepay` tinyint(1) unsigned NOT NULL default '0',
  `prepay_percent` decimal(5,2) NOT NULL default '0.00',
  `min_users` int(3) unsigned NOT NULL default '1',
  `max_users` int(3) unsigned default NULL,
  `kit_user_bundle_id` int(10) unsigned default NULL,
  `one_time_price` decimal(10,2) NOT NULL default '0.00',
  `mrc_price` decimal(10,2) NOT NULL default '0.00',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`promo_code_id`),
  UNIQUE KEY `promo_code` (`promo_code`),
  KEY `promo_code_ibfk_1` (`kit_user_bundle_id`),
  CONSTRAINT `promo_code_ibfk_1` FOREIGN KEY (`kit_user_bundle_id`) REFERENCES `bundle` (`bundle_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `promo_deployment`
--

DROP TABLE IF EXISTS `promo_deployment`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `promo_deployment` (
  `promo_deployment_id` int(10) unsigned NOT NULL auto_increment,
  `promo_code_id` int(10) unsigned NOT NULL,
  `deployment_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`promo_deployment_id`),
  UNIQUE KEY `promo_code_id` (`promo_code_id`,`deployment_id`),
  KEY `promo_deployment_ibfk_2` (`deployment_id`),
  CONSTRAINT `promo_deployment_ibfk_1` FOREIGN KEY (`promo_code_id`) REFERENCES `promo_code` (`promo_code_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `promo_deployment_ibfk_2` FOREIGN KEY (`deployment_id`) REFERENCES `deployment` (`deployment_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `promo_kit`
--

DROP TABLE IF EXISTS `promo_kit`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `promo_kit` (
  `promo_kit_id` int(10) unsigned NOT NULL auto_increment,
  `promo_code_id` int(10) unsigned NOT NULL,
  `bundle_id` int(10) unsigned NOT NULL,
  `quantity` int(3) unsigned NOT NULL default '1',
  `bundle_limit` int(3) default NULL,
  PRIMARY KEY  (`promo_kit_id`),
  KEY `promo_kit_ibfk_1` (`promo_code_id`),
  KEY `promo_kit_ibfk_2` (`bundle_id`),
  CONSTRAINT `promo_kit_ibfk_1` FOREIGN KEY (`promo_code_id`) REFERENCES `promo_code` (`promo_code_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `promo_kit_ibfk_2` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `promo_role`
--

DROP TABLE IF EXISTS `promo_role`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `promo_role` (
  `promo_role_id` int(10) unsigned NOT NULL auto_increment,
  `promo_code_id` int(10) unsigned NOT NULL,
  `intranet_role_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`promo_role_id`),
  UNIQUE KEY `promo_code_id` (`promo_code_id`,`intranet_role_id`),
  KEY `promo_role_ibfk_2` (`intranet_role_id`),
  CONSTRAINT `promo_role_ibfk_1` FOREIGN KEY (`promo_code_id`) REFERENCES `promo_code` (`promo_code_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `promo_role_ibfk_2` FOREIGN KEY (`intranet_role_id`) REFERENCES `intranet_role` (`intranet_role_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `provider`
--

DROP TABLE IF EXISTS `provider`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `provider` (
  `provider_id` int(10) unsigned NOT NULL auto_increment,
  `provider_reseller_id` int(10) unsigned default NULL,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY  (`provider_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `provider_country`
--

DROP TABLE IF EXISTS `provider_country`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `provider_country` (
  `provider_country_id` int(10) unsigned NOT NULL auto_increment,
  `provider_id` int(10) unsigned NOT NULL,
  `country_id` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`provider_country_id`),
  UNIQUE KEY `provider_id` (`provider_id`,`country_id`),
  KEY `provider_country_ibfk_2` (`country_id`),
  CONSTRAINT `provider_country_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `provider` (`provider_id`) ON UPDATE CASCADE,
  CONSTRAINT `provider_country_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `country` (`country_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `region_area_code`
--

DROP TABLE IF EXISTS `region_area_code`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `region_area_code` (
  `region_area_code_id` int(10) unsigned NOT NULL auto_increment,
  `country_region_id` int(10) unsigned NOT NULL,
  `area_code` int(3) unsigned NOT NULL,
  `region_name` varchar(28) NOT NULL default '',
  PRIMARY KEY  (`region_area_code_id`),
  KEY `country_region_id` (`country_region_id`),
  KEY `area_code` (`area_code`),
  CONSTRAINT `region_area_code_ibfk_1` FOREIGN KEY (`country_region_id`) REFERENCES `country_region` (`country_region_id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `reseller_discount`
--

DROP TABLE IF EXISTS `reseller_discount`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `reseller_discount` (
  `reseller_discount_id` int(10) unsigned NOT NULL auto_increment,
  `reseller_type_id` int(10) unsigned NOT NULL,
  `discount_type_id` int(10) unsigned NOT NULL,
  `discount_percent` decimal(5,2) NOT NULL default '0.00',
  PRIMARY KEY  (`reseller_discount_id`),
  UNIQUE KEY `reseller_type_id` (`reseller_type_id`,`discount_type_id`),
  KEY `discount_type_id` (`discount_type_id`),
  CONSTRAINT `reseller_discount_ibfk_2` FOREIGN KEY (`discount_type_id`) REFERENCES `discount_type` (`discount_type_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reseller_discount_ibfk_1` FOREIGN KEY (`reseller_type_id`) REFERENCES `reseller_type` (`reseller_type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `reseller_type`
--

DROP TABLE IF EXISTS `reseller_type`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `reseller_type` (
  `reseller_type_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY  (`reseller_type_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `role` (
  `role_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(50) NOT NULL default '',
  `license_type_id` int(10) unsigned NOT NULL,
  `auto_add_user` tinyint(1) NOT NULL default '0',
  `server_id` int(10) unsigned NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`role_id`),
  UNIQUE KEY `name` (`name`,`server_id`),
  KEY `license_type_id` (`license_type_id`),
  CONSTRAINT `role_ibfk_1` FOREIGN KEY (`license_type_id`) REFERENCES `license_type` (`license_type_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=250 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `role_perm`
--

DROP TABLE IF EXISTS `role_perm`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `role_perm` (
  `role_perm_id` int(10) unsigned NOT NULL auto_increment,
  `role_id` int(10) unsigned NOT NULL,
  `perm_id` int(10) unsigned NOT NULL,
  `type` enum('USER','GROUP','HUD_CONF') NOT NULL default 'USER',
  `group_id` int(10) unsigned default NULL,
  `conference_no` int(10) unsigned default NULL,
  `conference_server_id` int(10) unsigned default NULL,
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`role_perm_id`),
  KEY `role_id` (`role_id`),
  KEY `group_id` (`group_id`),
  KEY `perm_id` (`perm_id`),
  CONSTRAINT `role_perm_ibfk_4` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `role_perm_ibfk_6` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `role_perm_ibfk_7` FOREIGN KEY (`perm_id`) REFERENCES `perm` (`perm_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6250 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `role_tollrestriction`
--

DROP TABLE IF EXISTS `role_tollrestriction`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `role_tollrestriction` (
  `role_tollrestriction_id` int(10) unsigned NOT NULL auto_increment,
  `role_id` int(10) unsigned NOT NULL,
  `type` enum('DIAL_STRING','LINKED_SERVER') NOT NULL default 'DIAL_STRING',
  `content` varchar(80) NOT NULL,
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`role_tollrestriction_id`),
  UNIQUE KEY `role_id` (`role_id`,`content`),
  CONSTRAINT `role_tollrestriction_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2451 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `server_bundle`
--

DROP TABLE IF EXISTS `server_bundle`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `server_bundle` (
  `server_bundle_id` int(10) unsigned NOT NULL auto_increment,
  `server_id` int(10) unsigned NOT NULL,
  `bundle_id` int(10) unsigned NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`server_bundle_id`),
  UNIQUE KEY `server_id` (`server_id`,`bundle_id`),
  KEY `server_bundle_ibfk_3` (`bundle_id`),
  CONSTRAINT `server_bundle_ibfk_1` FOREIGN KEY (`bundle_id`) REFERENCES `bundle` (`bundle_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=601 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `server_license`
--

DROP TABLE IF EXISTS `server_license`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `server_license` (
  `server_license_id` int(10) unsigned NOT NULL auto_increment,
  `server_id` int(10) unsigned NOT NULL,
  `license_type_id` int(10) unsigned NOT NULL,
  `qty` int(11) NOT NULL default '1',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`server_license_id`),
  KEY `server_license_ibfk_1` (`license_type_id`),
  CONSTRAINT `server_license_ibfk_1` FOREIGN KEY (`license_type_id`) REFERENCES `license_type` (`license_type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=499 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `server_provider`
--

DROP TABLE IF EXISTS `server_provider`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `server_provider` (
  `server_provider_id` int(10) unsigned NOT NULL auto_increment,
  `server_id` int(10) unsigned NOT NULL,
  `provider_id` int(10) unsigned NOT NULL,
  `provider_customer_id` int(10) unsigned default NULL,
  `provider_username` varchar(40) default NULL,
  `provider_password` char(32) default NULL,
  `provider_pin` char(5) default NULL,
  PRIMARY KEY  (`server_provider_id`),
  UNIQUE KEY `server_id` (`server_id`,`provider_id`),
  KEY `server_provider_ibfk_1` (`provider_id`),
  CONSTRAINT `server_provider_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `provider` (`provider_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=767 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `tax_mapping`
--

DROP TABLE IF EXISTS `tax_mapping`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `tax_mapping` (
  `tax_mapping_id` int(10) unsigned NOT NULL auto_increment,
  `ns_tax_schedule` varchar(10) NOT NULL,
  `ns_description` mediumtext NOT NULL,
  `bs_trans_type` int(10) unsigned NOT NULL default '0',
  `bs_service_type` int(10) unsigned NOT NULL default '0',
  `bs_description` mediumtext NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`tax_mapping_id`),
  UNIQUE KEY `ns_tax_schedule` (`ns_tax_schedule`,`bs_trans_type`,`bs_service_type`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `transaction_job`
--

DROP TABLE IF EXISTS `transaction_job`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `transaction_job` (
  `transaction_job_id` int(10) unsigned NOT NULL auto_increment,
  `transaction_submit_id` int(10) unsigned NOT NULL,
  `transaction_step_id` int(10) unsigned NOT NULL,
  `sequence_name` varchar(8) NOT NULL,
  `iterations` tinyint(3) unsigned NOT NULL default '3',
  `rollback_iterations` tinyint(3) NOT NULL default '3',
  `input` blob NOT NULL,
  `output` blob NOT NULL,
  `rollback_output` blob NOT NULL,
  `error` blob NOT NULL,
  `rollback_error` blob NOT NULL,
  `status` enum('NEW','HALTED','RESTART','FAILURE','ROLLBACK_FAILURE','ROLLBACK_SUCCESS','SUCCESS','RUNNING') NOT NULL default 'NEW',
  `execution_time` int(10) unsigned NOT NULL default '0',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`transaction_job_id`),
  KEY `transaction_job_ibfk_1` (`transaction_submit_id`),
  KEY `transaction_job_ibfk_2` (`transaction_step_id`),
  CONSTRAINT `transaction_job_ibfk_1` FOREIGN KEY (`transaction_submit_id`) REFERENCES `transaction_submit` (`transaction_submit_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `transaction_job_ibfk_2` FOREIGN KEY (`transaction_step_id`) REFERENCES `transaction_step` (`transaction_step_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1295 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `transaction_step`
--

DROP TABLE IF EXISTS `transaction_step`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `transaction_step` (
  `transaction_step_id` int(10) unsigned NOT NULL auto_increment,
  `familyname` varchar(16) NOT NULL,
  `sequence_name` varchar(8) NOT NULL,
  `objectname` varchar(255) NOT NULL,
  `objectargs` varchar(255) NOT NULL default '',
  `sequence_success` varchar(8) NOT NULL default '',
  `sequence_failure` varchar(8) NOT NULL default '',
  `objectlocation` varchar(255) NOT NULL,
  `iterations` tinyint(3) unsigned NOT NULL default '3',
  PRIMARY KEY  (`transaction_step_id`),
  UNIQUE KEY `familyname_2` (`familyname`,`sequence_name`),
  KEY `familyname` (`familyname`)
) ENGINE=InnoDB AUTO_INCREMENT=1412 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `transaction_submit`
--

DROP TABLE IF EXISTS `transaction_submit`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `transaction_submit` (
  `transaction_submit_id` int(10) unsigned NOT NULL auto_increment,
  `familyname` varchar(16) NOT NULL,
  `input` blob NOT NULL,
  `status` enum('NEW','FAILURE','RUNNING','SUCCESS','HALTED') NOT NULL default 'NEW',
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`transaction_submit_id`),
  KEY `familyname` (`familyname`)
) ENGINE=InnoDB AUTO_INCREMENT=352 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `unbound_cdr_test`
--

DROP TABLE IF EXISTS `unbound_cdr_test`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `unbound_cdr_test` (
  `server_id` int(11) NOT NULL,
  `unique_id` varchar(32) NOT NULL,
  `invoice_id` int(11) default NULL,
  `calldate` datetime NOT NULL,
  `did` varchar(20) default NULL,
  `ani` varchar(20) default NULL,
  `dialed_number` varchar(20) default NULL,
  `is_mobile` varchar(1) default NULL,
  `call_duration` int(10) default NULL,
  `billable_duration` int(10) default NULL,
  `billed_amount` float default NULL,
  `customer_billed_amount` float default NULL,
  `disposition` varchar(10) default NULL,
  `virtual_phone` varchar(7) default NULL,
  `inphonex_id` varchar(7) default NULL,
  `country` varchar(2) default NULL,
  `info` varchar(100) default NULL,
  `provider_id` varchar(20) default NULL,
  `provider_type` varchar(40) default NULL,
  `provider_customer_id` varchar(20) default NULL,
  `international` tinyint(1) default NULL,
  `direction` enum('inbound','outbound') default NULL,
  `call_type` enum('standard','mobile','tollfree','emergency','premium') default NULL,
  PRIMARY KEY  (`unique_id`),
  KEY `idx_invoice` (`invoice_id`),
  KEY `sid_calldate_dispos` (`server_id`,`calldate`,`disposition`),
  KEY `calldate2` (`calldate`),
  KEY `cust_calldate` (`provider_customer_id`,`calldate`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `user_license`
--

DROP TABLE IF EXISTS `user_license`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `user_license` (
  `user_license_id` int(10) unsigned NOT NULL auto_increment,
  `user_id` int(10) unsigned NOT NULL,
  `license_type_id` int(10) unsigned NOT NULL,
  `created` timestamp NOT NULL default '1970-01-01 08:00:00',
  PRIMARY KEY  (`user_license_id`),
  UNIQUE KEY `user_id` (`user_id`,`license_type_id`),
  UNIQUE KEY `user_id_2` (`user_id`,`license_type_id`),
  KEY `user_license_ibfk_1` (`license_type_id`),
  CONSTRAINT `user_license_ibfk_1` FOREIGN KEY (`license_type_id`) REFERENCES `license_type` (`license_type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1663 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `user_role` (
  `user_role_id` int(10) unsigned NOT NULL auto_increment,
  `role_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `updated` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`user_role_id`),
  UNIQUE KEY `role_id` (`role_id`,`user_id`),
  CONSTRAINT `user_role_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2393 DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'fcs'
--
DELIMITER ;;
/*!50003 DROP FUNCTION IF EXISTS `find_column` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 FUNCTION `find_column`(tbl VARCHAR(100), col VARCHAR(100)) RETURNS int(1)
RETURN (
    SELECT COUNT(COLUMN_NAME) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = tbl 
    AND COLUMN_NAME = col
) */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP FUNCTION IF EXISTS `find_constraint_by_name` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 FUNCTION `find_constraint_by_name`(tbl VARCHAR(100), name VARCHAR(100)) RETURNS int(1)
RETURN (
    SELECT COUNT(CONSTRAINT_NAME)
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = tbl
    AND CONSTRAINT_NAME = name
) */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP FUNCTION IF EXISTS `find_fk_name_by_col` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 FUNCTION `find_fk_name_by_col`(tbl VARCHAR(100), fk_col VARCHAR(100)) RETURNS varchar(100) CHARSET utf8
RETURN (
    SELECT K.CONSTRAINT_NAME
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE K JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS C
    ON (K.CONSTRAINT_NAME = C.CONSTRAINT_NAME AND K.TABLE_SCHEMA = C.TABLE_SCHEMA)
    WHERE K.TABLE_SCHEMA = DATABASE()
    AND K.TABLE_NAME = tbl
    AND K.COLUMN_NAME = fk_col
    AND C.CONSTRAINT_TYPE = 'Foreign Key'
) */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP FUNCTION IF EXISTS `find_key_by_col` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 FUNCTION `find_key_by_col`(tbl VARCHAR(100), col VARCHAR(100), key_type VARCHAR(100)) RETURNS int(1)
RETURN (
    SELECT COUNT(COLUMN_NAME)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = tbl
    AND COLUMN_NAME = col
    AND COLUMN_KEY = key_type
    
) */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `add_column` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 PROCEDURE `add_column`(IN tbl VARCHAR(100), IN col VARCHAR(100), IN col_def MEDIUMTEXT)
BEGIN
    SET @col_exists = find_column(tbl, col); 

    IF @col_exists = 0 THEN
        SET @add_col = CONCAT('ALTER TABLE', ' ', tbl);
        SET @add_col = CONCAT(@add_col, ' ', 'ADD COLUMN');
        SET @add_col = CONCAT(@add_col, ' ', col);
        SET @add_col = CONCAT(@add_col, ' ', col_def);

        PREPARE stmt FROM @add_col;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT @add_col;
    END IF;
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `add_fk` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 PROCEDURE `add_fk`(IN tbl VARCHAR(100), IN fk_col VARCHAR(100), IN ref_tbl VARCHAR(100), IN ref_col VARCHAR(100), IN fk_def VARCHAR(100))
BEGIN
    SET @fk_name = find_fk_name_by_col(tbl, fk_col); 

    IF @fk_name IS NULL THEN
        SET @add_fk = CONCAT('ALTER TABLE', ' ', tbl);
        SET @add_fk = CONCAT(@add_fk, ' ', 'ADD FOREIGN KEY');
        SET @add_fk = CONCAT(@add_fk, ' (', fk_col, ')');
        SET @add_fk = CONCAT(@add_fk, ' ', 'REFERENCES');
        SET @add_fk = CONCAT(@add_fk, ' ', ref_tbl);
        SET @add_fk = CONCAT(@add_fk, ' (', ref_col, ')');
        SET @add_fk = CONCAT(@add_fk, ' ', fk_def);

        PREPARE stmt FROM @add_fk;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @fk_name = find_fk_name_by_col(tbl, fk_col); 

        SELECT @add_fk;
        
    
    
    END IF;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `add_index` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 PROCEDURE `add_index`(IN tbl VARCHAR(100), IN cols VARCHAR(100))
BEGIN
    SET @index_exists = find_key_by_col(tbl, cols, 'MUL');

    IF @index_exists = 0 THEN
        SET @add_index = CONCAT('ALTER TABLE', ' ', tbl);
        SET @add_index = CONCAT(@add_index, ' ', 'ADD INDEX');
        SET @add_index = CONCAT(@add_index, ' (', cols, ')');

        PREPARE stmt FROM @add_index;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT @add_index;
    END IF;
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `add_unique` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 PROCEDURE `add_unique`(IN tbl VARCHAR(100), IN unq_name VARCHAR(100), IN cols VARCHAR(100))
BEGIN
    SET @unq_exists = find_constraint_by_name(tbl, unq_name); 

    IF @unq_exists = 0 THEN
        SET @add_unq = CONCAT('ALTER TABLE', ' ', tbl);
        SET @add_unq = CONCAT(@add_unq, ' ', 'ADD UNIQUE');
        SET @add_unq = CONCAT(@add_unq, ' ', unq_name);
        SET @add_unq = CONCAT(@add_unq, ' (', cols, ')');

        PREPARE stmt FROM @add_unq;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT @add_unq;
        
    
    
    END IF;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `change_column` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 PROCEDURE `change_column`(IN tbl VARCHAR(100), IN old_col VARCHAR(100), IN new_col VARCHAR(100), IN col_def MEDIUMTEXT)
BEGIN
    SET @col_exists = find_column(tbl, old_col); 

    IF @col_exists = 1 THEN
        SET @change_col = CONCAT('ALTER TABLE', ' ', tbl);
        SET @change_col = CONCAT(@change_col, ' ', 'CHANGE');
        SET @change_col = CONCAT(@change_col, ' ', old_col);
        SET @change_col = CONCAT(@change_col, ' ', new_col);
        SET @change_col = CONCAT(@change_col, ' ', col_def);

        PREPARE stmt FROM @change_col;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT @change_col;
    END IF;
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `drop_column` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 PROCEDURE `drop_column`(IN tbl VARCHAR(100), IN col VARCHAR(100))
BEGIN
    SET @col_exists = find_column(tbl, col); 

    IF @col_exists = 1 THEN
        SET @drop_col = CONCAT('ALTER TABLE', ' ', tbl);
        SET @drop_col = CONCAT(@drop_col, ' ', 'DROP COLUMN');
        SET @drop_col = CONCAT(@drop_col, ' ', col);

        PREPARE stmt FROM @drop_col;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT @drop_col;
        
    
    
    END IF;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `drop_fk` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 PROCEDURE `drop_fk`(IN tbl VARCHAR(100), IN fk_col VARCHAR(100))
BEGIN
    SET @fk_name = find_fk_name_by_col(tbl, fk_col);

    IF @fk_name IS NOT NULL THEN
        SET @drop_fk = CONCAT('ALTER TABLE', ' ', tbl);
        SET @drop_fk = CONCAT(@drop_fk, ' ', 'DROP FOREIGN KEY');
        SET @drop_fk = CONCAT(@drop_fk, ' ', @fk_name);

        PREPARE stmt FROM @drop_fk;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT @drop_fk;
        
    
    
    END IF;

END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `drop_key` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 PROCEDURE `drop_key`(IN tbl VARCHAR(100), IN key_name VARCHAR(100))
BEGIN
    SET @key_exists = find_constraint_by_name(tbl, key_name);

    IF @key_exists > 0 THEN
        SET @drop_key = CONCAT('ALTER TABLE', ' ', tbl);
        SET @drop_key = CONCAT(@drop_key, ' ', 'DROP KEY');
        SET @drop_key = CONCAT(@drop_key, ' ', key_name);

        PREPARE stmt FROM @drop_key;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT @drop_key;

    END IF;
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
/*!50003 DROP PROCEDURE IF EXISTS `modify_column` */;;
/*!50003 SET SESSION SQL_MODE=""*/;;
/*!50003 CREATE*/ /*!50020 DEFINER=`fonality`@`%`*/ /*!50003 PROCEDURE `modify_column`(IN tbl VARCHAR(100), IN col VARCHAR(100), IN col_def MEDIUMTEXT)
BEGIN
    SET @col_exists = find_column(tbl, col); 

    IF @col_exists = 1 THEN
        SET @modify_col = CONCAT('ALTER TABLE', ' ', tbl);
        SET @modify_col = CONCAT(@modify_col, ' ', 'MODIFY');
        SET @modify_col = CONCAT(@modify_col, ' ', col);
        SET @modify_col = CONCAT(@modify_col, ' ', col_def);

        PREPARE stmt FROM @modify_col;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT @modify_col;
    END IF;
END */;;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE*/;;
DELIMITER ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-03-21 21:39:47
