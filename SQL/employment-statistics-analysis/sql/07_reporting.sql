/*
07_reporting.sql
Projekt: BA-Beschäftigungsstatistik (Option B) – Frauen, Deutsche vs. Ausländer
Schema: ba_svb_frauen

STAGE: 07_reporting (Abgabe/Ergebnisse)
Zweck:
- Report-Queries für Tabellen/Charts
- Kurzinterpretation der zentralen KPIs

Voraussetzung:
- 05_views_kpis.sql wurde ausgeführt (Views existieren)
*/

USE ba_svb_frauen;

-- =====================================================================================
-- Report 1: Top 5 Bundesländer je Staatsangehörigkeit im letzten Monat
-- =====================================================================================
WITH last_month AS (
  SELECT MAX(stichtag) AS stichtag_max FROM ba_clean
),
ranked AS (
  SELECT
    k.ym,
    k.staatsangehoerigkeit,
    k.bundesland,
    k.svb_sum,
    DENSE_RANK() OVER (
      PARTITION BY k.staatsangehoerigkeit
      ORDER BY k.svb_sum DESC
    ) AS rnk
  FROM vw_kpi_bl_by_month_nat k
  JOIN last_month lm ON lm.stichtag_max = k.stichtag
)
SELECT ym, staatsangehoerigkeit, bundesland, svb_sum
FROM ranked
WHERE rnk <= 5
ORDER BY staatsangehoerigkeit, rnk, bundesland;

-- =====================================================================================
-- Report 2: Anteil Ausländerinnen (SvB) gesamt je Monat
-- =====================================================================================
SELECT
  stichtag,
  ym,
  ROUND(share_auslaender * 100, 2) AS share_auslaender_pct
FROM vw_kpi_share_auslaender_total
ORDER BY stichtag;

-- Interpretation (kurz):
-- share_auslaender_pct = Anteil der SvB von Ausländerinnen an der Gesamt-SvB (Frauen) je Monat.
-- Beispiel: 9,43% bedeutet: Von allen sozialversicherungspflichtig beschäftigten Frauen sind 9,43% Ausländerinnen.

-- =====================================================================================
-- Report 3: SvB nach Berufsabschluss im letzten Monat, getrennt nach Staatsangehörigkeit
-- =====================================================================================
SELECT
  berufsabschluss,
  staatsangehoerigkeit,
  SUM(svb) AS svb_sum
FROM vw_ba_clean_base
WHERE stichtag = (SELECT MAX(stichtag) FROM ba_clean)
GROUP BY berufsabschluss, staatsangehoerigkeit
ORDER BY berufsabschluss, staatsangehoerigkeit;

-- =====================================================================================
-- Report 3b: Anteil Ausländer je Berufsabschluss im letzten Monat
-- =====================================================================================
SELECT
  berufsabschluss,
  ROUND(
    SUM(CASE WHEN staatsangehoerigkeit='Ausländer' THEN svb ELSE 0 END) / NULLIF(SUM(svb),0) * 100,
    2
  ) AS share_auslaender_pct
FROM vw_ba_clean_base
WHERE stichtag = (SELECT MAX(stichtag) FROM ba_clean)
GROUP BY berufsabschluss
ORDER BY share_auslaender_pct DESC;

-- =====================================================================================
-- Report 4 (optional): YoY Veränderung (gesamt) je Staatsangehörigkeit
-- =====================================================================================
SELECT
  stichtag,
  ym,
  staatsangehoerigkeit,
  svb_sum,
  yoy_abs,
  ROUND(yoy_pct * 100, 2) AS yoy_pct
FROM vw_kpi_yoy_total_nat
ORDER BY staatsangehoerigkeit, stichtag;


-- =====================================================================================
-- Report 5: Index (Basis 2022-01 = 100) je Staatsangehörigkeit
-- =====================================================================================
SELECT
  stichtag,
  ym,
  staatsangehoerigkeit,
  index_svb_2022_01_100
FROM vw_kpi_index_total_nat
ORDER BY staatsangehoerigkeit, stichtag;

/*
Beispiel für Dezimalzahl
*/
SELECT
    stichtag,
    ym,
    staatsangehoerigkeit,
    FORMAT(index_svb_2022_01_100, 2, 'de_DE') AS index_svb_komma
FROM vw_kpi_index_total_nat
ORDER BY staatsangehoerigkeit, stichtag;

-- =====================================================================================
-- Report 6: Anteil Ausländerinnen – Prozent + MA12 + Index
-- =====================================================================================

SELECT
  stichtag,
  ym,
  share_auslaender_pct,
  ma12_share_auslaender_pct,
  index_share_2022_01_100
FROM vw_kpi_share_auslaender_trend
ORDER BY stichtag;


-- =====================================================================================
-- Report 7: Wachstumsranking Bundesländer (Start->Ende) je Staatsangehörigkeit
-- Basis: vw_kpi_bl_by_month_nat (SvB-Summe je Monat x BL x Staatsangehörigkeit)
-- Zeitraum: 2022-01 bis 2024-12 (gemäß neuem Scope)
-- Kennzahlen:
--   growth_abs = svb_end - svb_start
--   growth_pct = (svb_end / svb_start) - 1
-- Output: Top/Bottom 5 je Staatsangehörigkeit
-- =====================================================================================

WITH params AS (
  SELECT
    MIN(stichtag) AS start_month,
    MAX(stichtag) AS end_month
  FROM vw_kpi_bl_by_month_nat
  WHERE stichtag >= '2022-01-01'
    AND stichtag <= '2024-12-31'
),
start_vals AS (
  SELECT
    k.staatsangehoerigkeit,
    k.bundesland_schluessel,
    k.bundesland,
    k.svb_sum AS svb_start
  FROM vw_kpi_bl_by_month_nat k
  JOIN params p ON k.stichtag = p.start_month
),
end_vals AS (
  SELECT
    k.staatsangehoerigkeit,
    k.bundesland_schluessel,
    k.bundesland,
    k.svb_sum AS svb_end
  FROM vw_kpi_bl_by_month_nat k
  JOIN params p ON k.stichtag = p.end_month
),
growth AS (
  SELECT
    e.staatsangehoerigkeit,
    e.bundesland_schluessel,
    e.bundesland,
    s.svb_start,
    e.svb_end,
    (e.svb_end - s.svb_start) AS growth_abs,
    ROUND((e.svb_end / NULLIF(s.svb_start, 0) - 1) * 100, 2) AS growth_pct
  FROM end_vals e
  JOIN start_vals s
    ON s.staatsangehoerigkeit = e.staatsangehoerigkeit
   AND s.bundesland_schluessel = e.bundesland_schluessel
),
ranked AS (
  SELECT
    g.*,
    DENSE_RANK() OVER (
      PARTITION BY g.staatsangehoerigkeit
      ORDER BY g.growth_pct DESC
    ) AS rnk_top,
    DENSE_RANK() OVER (
      PARTITION BY g.staatsangehoerigkeit
      ORDER BY g.growth_pct ASC
    ) AS rnk_bottom
  FROM growth g
)

-- Top 5 je Staatsangehörigkeit
SELECT
  'TOP' AS ranking_type,
  staatsangehoerigkeit,
  bundesland,
  svb_start,
  svb_end,
  growth_abs,
  growth_pct
FROM ranked
WHERE rnk_top <= 5

UNION ALL

-- Bottom 5 je Staatsangehörigkeit
SELECT
  'BOTTOM' AS ranking_type,
  staatsangehoerigkeit,
  bundesland,
  svb_start,
  svb_end,
  growth_abs,
  growth_pct
FROM ranked
WHERE rnk_bottom <= 5

ORDER BY staatsangehoerigkeit, ranking_type, growth_pct DESC;

-- =====================================================================================
-- Report 7: Regionaler Abstand (Deutsche - Ausländerinnen) im letzten Monat
-- Basis: vw_kpi_gap_nat_by_bl_month (liefert Ausländerinnen - Deutsche)
-- =====================================================================================
WITH last_month AS (
  SELECT MAX(stichtag) AS stichtag_max
  FROM ba_clean
)
SELECT
  g.ym,
  g.bundesland_schluessel,
  g.bundesland,
  (-1) * g.gap_ausl_minus_dt AS gap_dt_minus_ausl
FROM vw_kpi_gap_nat_by_bl_month g
JOIN last_month lm
  ON lm.stichtag_max = g.stichtag
ORDER BY gap_dt_minus_ausl DESC;

-- =====================================================================================
-- Report 7c: Wachstumsranking je Bundesland (Index: Startmonat = 100)
-- Basis: vw_kpi_bl_by_month_nat
-- =====================================================================================
WITH params AS (
  SELECT
    DATE('2022-01-01') AS start_month,
    (SELECT MAX(stichtag) FROM ba_clean) AS end_month
),
base AS (
  SELECT
    k.staatsangehoerigkeit,
    k.bundesland_schluessel,
    k.bundesland,
    k.svb_sum AS svb_start
  FROM vw_kpi_bl_by_month_nat k
  JOIN params p ON p.start_month = k.stichtag
),
last AS (
  SELECT
    k.staatsangehoerigkeit,
    k.bundesland_schluessel,
    k.bundesland,
    k.svb_sum AS svb_end
  FROM vw_kpi_bl_by_month_nat k
  JOIN params p ON p.end_month = k.stichtag
),
calc AS (
  SELECT
    l.staatsangehoerigkeit,
    l.bundesland_schluessel,
    l.bundesland,
    b.svb_start,
    l.svb_end,
    ROUND(l.svb_end / NULLIF(b.svb_start,0) * 100, 2) AS index_start_100,
    ROUND((l.svb_end - b.svb_start) / NULLIF(b.svb_start,0) * 100, 2) AS growth_pct
  FROM last l
  JOIN base b
    ON b.staatsangehoerigkeit = l.staatsangehoerigkeit
   AND b.bundesland_schluessel = l.bundesland_schluessel
)
SELECT
  staatsangehoerigkeit,
  bundesland,
  svb_start,
  svb_end,
  index_start_100,
  growth_pct,
  DENSE_RANK() OVER (
    PARTITION BY staatsangehoerigkeit
    ORDER BY growth_pct DESC
  ) AS rnk_growth
FROM calc
ORDER BY staatsangehoerigkeit, rnk_growth, bundesland;

-- =====================================================================================
-- Report 7d: Wachstumsranking absolut (Ende - Start) je Bundesland
-- =====================================================================================
WITH params AS (
  SELECT
    DATE('2022-01-01') AS start_month,
    (SELECT MAX(stichtag) FROM ba_clean) AS end_month
),
base AS (
  SELECT staatsangehoerigkeit, bundesland_schluessel, bundesland, svb_sum AS svb_start
  FROM vw_kpi_bl_by_month_nat
  WHERE stichtag = (SELECT start_month FROM params)
),
last AS (
  SELECT staatsangehoerigkeit, bundesland_schluessel, bundesland, svb_sum AS svb_end
  FROM vw_kpi_bl_by_month_nat
  WHERE stichtag = (SELECT end_month FROM params)
),
calc AS (
  SELECT
    l.staatsangehoerigkeit,
    l.bundesland,
    b.svb_start,
    l.svb_end,
    (l.svb_end - b.svb_start) AS growth_abs
  FROM last l
  JOIN base b
    ON b.staatsangehoerigkeit = l.staatsangehoerigkeit
   AND b.bundesland_schluessel = l.bundesland_schluessel
)
SELECT
  staatsangehoerigkeit,
  bundesland,
  svb_start,
  svb_end,
  growth_abs,
  DENSE_RANK() OVER (
    PARTITION BY staatsangehoerigkeit
    ORDER BY growth_abs DESC
  ) AS rnk_growth_abs
FROM calc
ORDER BY staatsangehoerigkeit, rnk_growth_abs, bundesland;



-- =====================================================================================
-- aktuelle views
-- =====================================================================================
SHOW FULL TABLES WHERE Table_type='VIEW';