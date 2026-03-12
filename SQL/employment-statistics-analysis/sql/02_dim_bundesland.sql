/*
02_dim_bundesland.sql
Projekt: BA-Beschäftigungsstatistik (Option B) – Frauen, Deutsche vs. Ausländer
Schema: ba_svb_frauen

STAGE: 02_dim (Dimensionen)
Zweck:
- Referenztabelle für gültige Bundesland-Schlüssel (0100000–1600000)
- Kanonische Bundeslandnamen (UTF-8 sauber)
- Wird im Rebuild genutzt, um Encoding-Probleme aus ba_raw zu umgehen
*/

USE ba_svb_frauen;

-- =====================================================================================
-- STAGE 02_dim: Dimensionstabelle neu erstellen (deterministisch)
-- =====================================================================================
DROP TABLE IF EXISTS dim_bundesland;

CREATE TABLE dim_bundesland (
  bundesland_schluessel CHAR(7) NOT NULL PRIMARY KEY,
  bundesland            VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- =====================================================================================
-- STAGE 02_dim: 16 Bundesländer (kanonische Schreibweise)
-- =====================================================================================
INSERT INTO dim_bundesland (bundesland_schluessel, bundesland) VALUES
('0100000','Schleswig-Holstein'),
('0200000','Hamburg'),
('0300000','Niedersachsen'),
('0400000','Bremen'),
('0500000','Nordrhein-Westfalen'),
('0600000','Hessen'),
('0700000','Rheinland-Pfalz'),
('0800000','Baden-Württemberg'),
('0900000','Bayern'),
('1000000','Saarland'),
('1100000','Berlin'),
('1200000','Brandenburg'),
('1300000','Mecklenburg-Vorpommern'),
('1400000','Sachsen'),
('1500000','Sachsen-Anhalt'),
('1600000','Thüringen');

-- =====================================================================================
-- STAGE 02_dim: Quick Checks
-- =====================================================================================
SELECT COUNT(*) AS dim_rows FROM dim_bundesland;          -- Soll: 16
SELECT * FROM dim_bundesland ORDER BY bundesland_schluessel;
