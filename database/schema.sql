-- ==============================================================================
-- TrustCert: Blockchain-Based Certificate Verification System
-- Database Schema Definition
-- Target: MySQL 8.0+ / MariaDB 10.4+ (XAMPP / Docker)
-- ==============================================================================

-- Create Database if not exists
CREATE DATABASE IF NOT EXISTS `trustcert_db` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `trustcert_db`;

-- Drop existing tables in reverse dependency order (clean reset)
DROP TABLE IF EXISTS `verification_logs`;
DROP TABLE IF EXISTS `blocks_node3`;
DROP TABLE IF EXISTS `blocks_node2`;
DROP TABLE IF EXISTS `blocks_node1`;
DROP TABLE IF EXISTS `certificates`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `institutes`;

-- ==============================================================================
-- 1. Institutes Table
-- Stores authorized academic and governmental issuing authorities.
-- Each institute owns an RSA asymmetric keypair for digital signing.
-- ==============================================================================
CREATE TABLE `institutes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(150) NOT NULL COMMENT 'Full official name of the institute',
    `code` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Short unique code (e.g. NIBM, UOC, SLIIT)',
    `contact_email` VARCHAR(150) NOT NULL,
    `public_key_path` VARCHAR(255) NOT NULL COMMENT 'Filename or path to RSA public key in storage/keys',
    `status` ENUM('active', 'suspended') NOT NULL DEFAULT 'active' COMMENT 'Registration state',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 2. Users Table
-- Supports Role-Based Access Control (RBAC): 'admin' (system level) and 'institute'.
-- Passwords stored as secure cryptographic hashes using bcrypt (password_hash).
-- ==============================================================================
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `institute_id` INT NULL COMMENT 'Associated institute; NULL for global system admins',
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL COMMENT 'Bcrypt hashed password',
    `full_name` VARCHAR(100) NOT NULL,
    `role` ENUM('admin', 'institute') NOT NULL DEFAULT 'institute',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_users_institute` 
        FOREIGN KEY (`institute_id`) REFERENCES `institutes`(`id`) 
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 3. Certificates Table
-- Metadata and state of certificates issued by institutes.
-- Original files are stored encrypted on disk (AES-256); only the SHA-256
-- fingerprint and RSA digital signature are linked into the blockchain ledger.
-- ==============================================================================
CREATE TABLE `certificates` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `certificate_number` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Unique identifier printed on the certificate',
    `holder_name` VARCHAR(150) NOT NULL COMMENT 'Recipient student or professional name',
    `title` VARCHAR(200) NOT NULL COMMENT 'Award title (e.g. HND in Software Engineering)',
    `institute_id` INT NOT NULL COMMENT 'Issuing authority',
    `issue_date` DATE NOT NULL,
    `expiry_date` DATE NULL COMMENT 'Optional expiry date for temporary credentials',
    `file_hash` CHAR(64) NOT NULL COMMENT 'SHA-256 cryptographic hash of original unencrypted document',
    `encrypted_file_path` VARCHAR(255) NOT NULL COMMENT 'Relative path to AES-256-CBC encrypted file in storage/uploads',
    `signature` TEXT NOT NULL COMMENT 'Base64 encoded RSA-SHA256 digital signature',
    `status` ENUM('valid', 'revoked') NOT NULL DEFAULT 'valid',
    `revoked_at` DATETIME NULL COMMENT 'Timestamp when revoked',
    `revoked_reason` VARCHAR(255) NULL COMMENT 'Reason for certificate revocation',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_certificates_institute` 
        FOREIGN KEY (`institute_id`) REFERENCES `institutes`(`id`) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_cert_file_hash` (`file_hash`),
    INDEX `idx_cert_number` (`certificate_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 4. Distributed Ledger Simulation Tables (Node 1, Node 2, Node 3)
-- To simulate a decentralized community cloud network, 3 independent ledger nodes
-- store identical copies of the blockchain.
-- Each block is cryptographically linked to the previous block hash.
-- Formula: block_hash = SHA256(block_index . data_hash . previous_hash . timestamp)
-- ==============================================================================

-- Node 1 Ledger (Primary / Reference Node)
CREATE TABLE `blocks_node1` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `block_index` INT NOT NULL COMMENT 'Incremental sequence number (0 = Genesis)',
    `certificate_id` INT NULL COMMENT 'References certificates.id; NULL for Genesis',
    `data_hash` CHAR(64) NOT NULL COMMENT 'SHA-256 digest of certificate payload',
    `previous_hash` CHAR(64) NOT NULL COMMENT 'SHA-256 digest of previous block in chain',
    `signature` TEXT NULL COMMENT 'Base64 RSA signature by issuing institute',
    `block_hash` CHAR(64) NOT NULL COMMENT 'Computed SHA-256 block header hash',
    `timestamp` BIGINT NOT NULL COMMENT 'Unix epoch timestamp when block was minted',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_node1_index` (`block_index`),
    INDEX `idx_node1_data_hash` (`data_hash`),
    INDEX `idx_node1_block_hash` (`block_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Node 2 Ledger (Simulated Peer Node 2 - used for tamper demonstrations)
CREATE TABLE `blocks_node2` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `block_index` INT NOT NULL,
    `certificate_id` INT NULL,
    `data_hash` CHAR(64) NOT NULL,
    `previous_hash` CHAR(64) NOT NULL,
    `signature` TEXT NULL,
    `block_hash` CHAR(64) NOT NULL,
    `timestamp` BIGINT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_node2_index` (`block_index`),
    INDEX `idx_node2_data_hash` (`data_hash`),
    INDEX `idx_node2_block_hash` (`block_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Node 3 Ledger (Simulated Peer Node 3 - quorum verifier)
CREATE TABLE `blocks_node3` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `block_index` INT NOT NULL,
    `certificate_id` INT NULL,
    `data_hash` CHAR(64) NOT NULL,
    `previous_hash` CHAR(64) NOT NULL,
    `signature` TEXT NULL,
    `block_hash` CHAR(64) NOT NULL,
    `timestamp` BIGINT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_node3_index` (`block_index`),
    INDEX `idx_node3_data_hash` (`data_hash`),
    INDEX `idx_node3_block_hash` (`block_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- 5. Verification Logs Table
-- Public audit trail recording every verification query performed through the portal.
-- Useful for analytics and detecting repeated tampering or probing attempts.
-- ==============================================================================
CREATE TABLE `verification_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `certificate_number` VARCHAR(100) NULL,
    `searched_hash` CHAR(64) NULL,
    `verification_result` ENUM('VALID', 'TAMPERED', 'NOT_FOUND', 'REVOKED', 'EXPIRED') NOT NULL,
    `verifier_ip` VARCHAR(45) NULL COMMENT 'IPv4 or IPv6 of the verifier client',
    `user_agent` VARCHAR(255) NULL COMMENT 'Browser user-agent string',
    `verified_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_vlog_result` (`verification_result`),
    INDEX `idx_vlog_time` (`verified_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

