-- ==============================================================================
-- TrustCert: Initial Seed Data & Genesis Block
-- Seeds the default administrator, sample institute (NIBM), and genesis blocks.
-- ==============================================================================

USE `trustcert_db`;

-- 1. Insert Initial Academic Institute: NIBM
-- Note: The institute's RSA public key file is stored in storage/keys/nibm_public.pem
INSERT INTO `institutes` (`id`, `name`, `code`, `contact_email`, `public_key_path`, `status`) 
VALUES (
    1, 
    'National Institute of Business Management', 
    'NIBM', 
    'examinations@nibm.lk', 
    'nibm_public.pem', 
    'active'
);

-- 2. Insert Users
-- Default Admin Account:
--   Username: admin
--   Password: Admin@123 (bcrypt hashed below)
-- Institute Issuer Account:
--   Username: nibm_admin
--   Password: Nibm@123 (bcrypt hashed below)
INSERT INTO `users` (`id`, `institute_id`, `username`, `password_hash`, `full_name`, `role`) 
VALUES 
(
    1, 
    NULL, 
    'admin', 
    '$2y$10$p0XDpAuRV9fptcePJ.pRw..N2utbQVcEvX2vwuNqpg1gDPV4XT9Pq', 
    'TrustCert System Administrator', 
    'admin'
),
(
    2, 
    1, 
    'nibm_admin', 
    '$2y$10$fa2C8qzrQJJnGnfNwSmpIeR8Fpd2M4DgAeNgDiGdE04EMzxqvEVu2', 
    'NIBM Examination Registry Officer', 
    'institute'
);

-- 3. Insert Genesis Block into all 3 Ledger Nodes
-- Genesis Block (Block 0) marks the cryptographic origin of the blockchain.
-- block_hash = SHA256('0' + 64 zeros + 64 zeros + '1700000000')
-- Result: 2c56f3b4f51ec2209832491d8514e31c9f639d6a1baf600e64ac4b38761bdbc4

-- Node 1 Genesis Block
INSERT INTO `blocks_node1` 
(`block_index`, `certificate_id`, `data_hash`, `previous_hash`, `signature`, `block_hash`, `timestamp`, `created_at`)
VALUES (
    0, 
    NULL, 
    '0000000000000000000000000000000000000000000000000000000000000000', 
    '0000000000000000000000000000000000000000000000000000000000000000', 
    'GENESIS_BLOCK_SIGNATURE_TRUSTCERT_NETWORK_ROOT', 
    '2c56f3b4f51ec2209832491d8514e31c9f639d6a1baf600e64ac4b38761bdbc4', 
    1700000000, 
    '2024-01-01 00:00:00'
);

-- Node 2 Genesis Block
INSERT INTO `blocks_node2` 
(`block_index`, `certificate_id`, `data_hash`, `previous_hash`, `signature`, `block_hash`, `timestamp`, `created_at`)
VALUES (
    0, 
    NULL, 
    '0000000000000000000000000000000000000000000000000000000000000000', 
    '0000000000000000000000000000000000000000000000000000000000000000', 
    'GENESIS_BLOCK_SIGNATURE_TRUSTCERT_NETWORK_ROOT', 
    '2c56f3b4f51ec2209832491d8514e31c9f639d6a1baf600e64ac4b38761bdbc4', 
    1700000000, 
    '2024-01-01 00:00:00'
);

-- Node 3 Genesis Block
INSERT INTO `blocks_node3` 
(`block_index`, `certificate_id`, `data_hash`, `previous_hash`, `signature`, `block_hash`, `timestamp`, `created_at`)
VALUES (
    0, 
    NULL, 
    '0000000000000000000000000000000000000000000000000000000000000000', 
    '0000000000000000000000000000000000000000000000000000000000000000', 
    'GENESIS_BLOCK_SIGNATURE_TRUSTCERT_NETWORK_ROOT', 
    '2c56f3b4f51ec2209832491d8514e31c9f639d6a1baf600e64ac4b38761bdbc4', 
    1700000000, 
    '2024-01-01 00:00:00'
);

