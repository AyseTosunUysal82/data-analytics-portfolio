/*
06_quality_checks.sql
Projekt: BA-Beschäftigungsstatistik (Option B) – Frauen, Deutsche vs. Ausländer
Schema: ba_svb_frauen

STAGE: 06_quality (Validierung / Abnahme)
Soll:
- 4032 Zeilen
- 42 Monate (2022-01 bis 2025-06)
- 16 Bundesländer (0100000–1600000)
- 2016 Deutsche / 2016 Ausländer
Hinweis: ba_raw darf Encoding-Probleme enthalten. Entscheidend ist ba_clean.
*/

USE ba_svb_frauen;

-- =====================================================================================
-- 1) Rowcount (Soll: 4032)
-- =====================================================================================
SELECT COUNT(*) AS clean_rows
FROM ba_clean;

-- =====================================================================================
-- 2) Verteilung Staatsangehörigkeit (Soll: 2016/2016)
-- =====================================================================================
SELECT staatsangehoerigkeit, COUNT(*) AS c
FROM ba_clean
GROUP BY staatsangehoerigkeit
ORDER BY staatsangehoerigkeit;

-- =====================================================================================
-- 3) Zeitabdeckung (Soll: 42 Monate; min/max passend)
-- =====================================================================================
SELECT
  MIN(stichtag) AS min_date,
  MAX(stichtag) AS max_date,
  COUNT(DISTINCT stichtag_label) AS distinct_months
FROM ba_clean;

-- =====================================================================================
-- 4) Bundesland-Schlüssel (Soll: 16; max_key = 1600000)
-- =====================================================================================
SELECT
  MIN(bundesland_schluessel) AS min_key,
  MAX(bundesland_schluessel) AS max_key,
  COUNT(DISTINCT bundesland_schluessel) AS distinct_keys
FROM ba_clean;

-- =====================================================================================
-- 5) Bundesländer-Listing (soll 16 Zeilen liefern, Namen sauber)
-- =====================================================================================
SELECT bundesland_schluessel, bundesland, COUNT(*) AS c
FROM ba_clean
GROUP BY bundesland_schluessel, bundesland
ORDER BY bundesland_schluessel;

-- =====================================================================================
-- 6) Referenz-Check: stimmen die Namen zur Dimension? (muss 0 Zeilen liefern)
-- =====================================================================================
SELECT c.bundesland_schluessel, c.bundesland AS clean_name, d.bundesland AS dim_name
FROM ba_clean c
JOIN dim_bundesland d ON d.bundesland_schluessel = c.bundesland_schluessel
WHERE c.bundesland <> d.bundesland
LIMIT 50;

-- =====================================================================================
-- 7) FK-Check ohne FK (muss 0 Zeilen liefern): "fremde" BL-Keys
-- =====================================================================================
SELECT c.bundesland_schluessel
FROM ba_clean c
LEFT JOIN dim_bundesland d ON d.bundesland_schluessel = c.bundesland_schluessel
WHERE d.bundesland_schluessel IS NULL
GROUP BY c.bundesland_schluessel;


