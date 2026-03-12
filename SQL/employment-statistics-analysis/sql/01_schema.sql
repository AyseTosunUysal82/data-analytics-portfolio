/*
01_schema.sql
Projekt: BA-Beschäftigungsstatistik (Option B) – Frauen, Deutsche vs. Ausländer
Schema: ba_svb_frauen

STAGE: 01_schema (Schema & Tabellen)
Zweck:
- Legt Datenbank + Tabellenstruktur an
- Keine Imports, keine Rebuilds, keine Fix-Updates
- Sicher in Workbench: immer "Execute Selection" nutzen

Run-Hinweis:
1) Dieses Script ausführen (DB + Tabellen)
2) CSV-Import per Workbench Table Data Import Wizard -> ba_raw
3) Danach: 02_dim_bundesland.sql -> 03_rebuild_ba_clean.sql -> 06_quality_checks.sql -> ...
*/

-- =====================================================================================
-- STAGE 01_schema: Datenbank anlegen
-- =====================================================================================
CREATE DATABASE IF NOT EXISTS ba_svb_frauen
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE ba_svb_frauen;

-- =====================================================================================
-- STAGE 01_schema: Staging-Tabelle ba_raw (1:1 Import, alles Text)
-- =====================================================================================
DROP TABLE IF EXISTS ba_raw;

CREATE TABLE ba_raw (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  stichtag_raw               VARCHAR(20),
  geschlecht_raw             VARCHAR(20),
  staatsangehoerigkeit_raw   VARCHAR(40),
  bundesland_schluessel_raw  VARCHAR(20),
  bundesland_raw             VARCHAR(100),
  berufsabschluss_raw        VARCHAR(100),
  svb_raw                    VARCHAR(30)
) ENGINE=InnoDB;

-- =====================================================================================
-- STAGE 01_schema: Clean/Fakt-Tabelle ba_clean (typisiert, für Analysen)
-- Hinweis: Constraints (UNIQUE/FK/CHECK) kommen später in 04_hardening_constraints.sql
-- =====================================================================================
DROP TABLE IF EXISTS ba_clean;

CREATE TABLE ba_clean (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,

  stichtag DATE NOT NULL,                    -- Monatsanfang (z.B. 2025-06-01)
  stichtag_label VARCHAR(20) NOT NULL,       -- Original-Label (z.B. "Jun 25")

  geschlecht VARCHAR(20) NOT NULL,           -- Scope: nur "Frauen"
  staatsangehoerigkeit VARCHAR(20) NOT NULL, -- "Deutsche" | "Ausländer"

  bundesland_schluessel CHAR(7) NOT NULL,    -- 7-stellig, führende Nullen relevant
  bundesland VARCHAR(100) NOT NULL,          -- kanonischer Name (aus dim_bundesland)

  berufsabschluss VARCHAR(100) NOT NULL,     -- 3 Kategorien
  svb INT UNSIGNED NOT NULL,                 -- Kennzahl (Tausenderpunkte entfernt)

  -- Basis-Indizes für Filter/Joins (keine Constraints)
  KEY ix_stichtag (stichtag),
  KEY ix_nat (staatsangehoerigkeit),
  KEY ix_bl (bundesland_schluessel),
  KEY ix_abschluss (berufsabschluss)
) ENGINE=InnoDB;

-- =====================================================================================
-- STAGE 01_schema: Quick Checks (optional)
-- =====================================================================================
SELECT DATABASE() AS current_db;
SHOW TABLES;
