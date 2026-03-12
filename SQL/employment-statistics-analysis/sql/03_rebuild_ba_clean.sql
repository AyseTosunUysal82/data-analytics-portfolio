/*
03_rebuild_ba_clean.sql
Projekt: BA-Beschäftigungsstatistik (Option B) – Frauen, Deutsche vs. Ausländer
Schema: ba_svb_frauen

STAGE: 03_rebuild (deterministischer Rebuild)
Zweck:
- ba_raw bleibt unverändert (kann Mojibake enthalten)
- ba_clean wird deterministisch, typisiert & normalisiert aufgebaut
- Bundeslandname kommt kanonisch aus dim_bundesland
Voraussetzung:
- 01_schema.sql ausgeführt (ba_raw, ba_clean existieren)
- CSV per Workbench Wizard in ba_raw importiert
- 02_dim_bundesland.sql ausgeführt (dim_bundesland existiert)
*/

USE ba_svb_frauen;

-- =====================================================================================
-- STAGE 03_rebuild: Ziel leeren (ba_raw bleibt unverändert)
-- =====================================================================================
TRUNCATE TABLE ba_clean;

-- =====================================================================================
-- STAGE 03_rebuild: Rebuild aus ba_raw (Key bevorzugt aus Bundesland-Namen)
-- =====================================================================================
INSERT INTO ba_clean (
  stichtag, stichtag_label, geschlecht, staatsangehoerigkeit,
  bundesland_schluessel, bundesland, berufsabschluss, svb
)
SELECT
  x.stichtag,
  x.stichtag_label,
  'Frauen' AS geschlecht,
  x.staatsangehoerigkeit,
  x.bundesland_schluessel,
  d.bundesland AS bundesland,     -- kanonisch aus Dimension
  x.berufsabschluss,
  x.svb
FROM (
  SELECT
    /* ------------------ Zeit ------------------ */
    STR_TO_DATE(
      CONCAT(
        '20', RIGHT(TRIM(r.stichtag_raw), 2), '-',
        LPAD(
          CASE LEFT(TRIM(r.stichtag_raw), 3)
            WHEN 'Jan' THEN 1
            WHEN 'Feb' THEN 2
            WHEN 'Mär' THEN 3
            WHEN 'Mrz' THEN 3
            WHEN 'MÃ¤' THEN 3
            WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4
            WHEN 'Mai' THEN 5
            WHEN 'May' THEN 5
            WHEN 'Jun' THEN 6
            WHEN 'Jul' THEN 7
            WHEN 'Aug' THEN 8
            WHEN 'Sep' THEN 9
            WHEN 'Okt' THEN 10
            WHEN 'Oct' THEN 10
            WHEN 'Nov' THEN 11
            WHEN 'Dez' THEN 12
            WHEN 'Dec' THEN 12
            ELSE NULL
          END,
          2, '0'
        ),
        '-01'
      ),
      '%Y-%m-%d'
    ) AS stichtag,
    TRIM(r.stichtag_raw) AS stichtag_label,

    /* ------------------ Staatsangehörigkeit ------------------ */
    CASE
      WHEN TRIM(r.staatsangehoerigkeit_raw) IN ('Deutsche','DEUTSCHE') THEN 'Deutsche'
      WHEN TRIM(r.staatsangehoerigkeit_raw) IN ('Ausländer','Auslaender','AuslÃ¤nder') THEN 'Ausländer'
      ELSE NULL
    END AS staatsangehoerigkeit,

    /* ------------------ Bundesland-Schlüssel (WICHTIG) ------------------
       1) zuerst aus Bundesland-NAMEN (damit führende 0 nicht verloren geht)
       2) fallback: aus bundesland_schluessel_raw (LPAD + bekannte Fixes)
    */
    COALESCE(
      CASE TRIM(r.bundesland_raw)
        WHEN 'Schleswig-Holstein'       THEN '0100000'
        WHEN 'Hamburg'                  THEN '0200000'
        WHEN 'Niedersachsen'            THEN '0300000'
        WHEN 'Bremen'                   THEN '0400000'
        WHEN 'Nordrhein-Westfalen'      THEN '0500000'
        WHEN 'Hessen'                   THEN '0600000'
        WHEN 'Rheinland-Pfalz'          THEN '0700000'
        WHEN 'Baden-Württemberg'        THEN '0800000'
        WHEN 'Baden-WÃ¼rttemberg'       THEN '0800000'
        WHEN 'Bayern'                   THEN '0900000'
        WHEN 'Saarland'                 THEN '1000000'
        WHEN 'Berlin'                   THEN '1100000'
        WHEN 'Brandenburg'              THEN '1200000'
        WHEN 'Mecklenburg-Vorpommern'   THEN '1300000'
        WHEN 'Sachsen'                  THEN '1400000'
        WHEN 'Sachsen-Anhalt'           THEN '1500000'
        WHEN 'Thüringen'                THEN '1600000'
        WHEN 'ThÃ¼ringen'               THEN '1600000'
        ELSE NULL
      END,
      CASE
        WHEN LPAD(TRIM(r.bundesland_schluessel_raw), 7, '0') = '8000000' THEN '0800000'
        WHEN LPAD(TRIM(r.bundesland_schluessel_raw), 7, '0') = '9000000' THEN '0900000'
        ELSE LPAD(TRIM(r.bundesland_schluessel_raw), 7, '0')
      END
    ) AS bundesland_schluessel,

    TRIM(r.berufsabschluss_raw) AS berufsabschluss,

    /* ------------------ SvB ------------------ */
    CAST(
      NULLIF(
        REPLACE(REPLACE(REPLACE(TRIM(r.svb_raw), '.', ''), ',', ''), ' ', ''),
        ''
      ) AS UNSIGNED
    ) AS svb

  FROM ba_raw r
  WHERE
    TRIM(r.geschlecht_raw)='Frauen'
    AND TRIM(r.stichtag_raw) <> ''
    AND TRIM(r.berufsabschluss_raw) <> ''
    AND TRIM(r.svb_raw) <> ''
) x
JOIN dim_bundesland d
  ON d.bundesland_schluessel = x.bundesland_schluessel
WHERE
  x.stichtag IS NOT NULL
  AND x.svb IS NOT NULL
  AND x.staatsangehoerigkeit IN ('Deutsche','Ausländer');
 
 
 -- =====================================================================================
-- 						CHECK
-- =====================================================================================
  
  
  -- Soll: 4032
SELECT COUNT(*) FROM ba_clean;

-- Soll: 2016 / 2016
SELECT staatsangehoerigkeit, COUNT(*) FROM ba_clean GROUP BY staatsangehoerigkeit;

-- Soll: 16 Bundesländer
SELECT COUNT(DISTINCT bundesland_schluessel) FROM ba_clean;

