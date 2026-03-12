/*
05_views_kpis.sql
Projekt: BA-Beschäftigungsstatistik (Option B) – Frauen, Deutsche vs. Ausländer
Schema: ba_svb_frauen

STAGE: 05_semantic_layer (Views & KPIs)
Zweck:
- Base View mit einheitlichen Zeitfeldern (ym, jahr, monat)
- KPI Views für Standardauswertungen (Trend, Ranking, Shares, YoY)
Hinweis:
- CREATE OR REPLACE ist idempotent (kann beliebig oft ausgeführt werden)
*/

USE ba_svb_frauen;

-- =====================================================================================
-- STAGE 05: Base View (Zeitattribute + Dimension-Join)
-- =====================================================================================
CREATE OR REPLACE VIEW vw_ba_clean_base AS
SELECT
  c.stichtag,
  DATE_FORMAT(c.stichtag, '%Y-%m') AS ym,
  YEAR(c.stichtag) AS jahr,
  MONTH(c.stichtag) AS monat,
  c.geschlecht,
  c.staatsangehoerigkeit,
  c.bundesland_schluessel,
  d.bundesland AS bundesland,     -- kanonisch
  c.berufsabschluss,
  c.svb
FROM ba_clean c
JOIN dim_bundesland d
  ON d.bundesland_schluessel = c.bundesland_schluessel;

/* ============================================================================
Feature Engineering / Enrichment Layer
Ziel: abgeleitete Analyse-Features (Zeit-Keys etc.) klar sichtbar machen.
============================================================================ */

CREATE OR REPLACE VIEW vw_ba_clean_enriched AS
SELECT
  b.*,
  /* Numerischer Monats-Key für Sortierung/Join, z.B. 202506 */
  CAST(DATE_FORMAT(b.stichtag, '%Y%m') AS UNSIGNED) AS ym_key,

  /* Monate seit Start (2022-01) -> gut für Trendmodelle / Index */
  PERIOD_DIFF(DATE_FORMAT(b.stichtag, '%Y%m'), '202201') AS months_since_2022_01

FROM vw_ba_clean_base b;

-- Feature Engineering = Zeitfeatures (ym_key, months_since_start) + standardisierte Zeitdimension in Base/Enriched Views

-- =====================================================================================
-- KPI 1: Gesamtsumme pro Monat und Staatsangehörigkeit
-- =====================================================================================
CREATE OR REPLACE VIEW vw_kpi_total_by_month_nat AS
SELECT
  stichtag,
  ym,
  staatsangehoerigkeit,
  SUM(svb) AS svb_sum
FROM vw_ba_clean_base
GROUP BY stichtag, ym, staatsangehoerigkeit;

-- =====================================================================================
-- KPI 2: Bundeslandtrend pro Monat und Nat
-- =====================================================================================
CREATE OR REPLACE VIEW vw_kpi_bl_by_month_nat AS
SELECT
  stichtag,
  ym,
  bundesland_schluessel,
  bundesland,
  staatsangehoerigkeit,
  SUM(svb) AS svb_sum
FROM vw_ba_clean_base
GROUP BY stichtag, ym, bundesland_schluessel, bundesland, staatsangehoerigkeit;

-- =====================================================================================
-- KPI 3: Berufsabschluss pro Monat und Nat
-- =====================================================================================
CREATE OR REPLACE VIEW vw_kpi_abschluss_by_month_nat AS
SELECT
  stichtag,
  ym,
  berufsabschluss,
  staatsangehoerigkeit,
  SUM(svb) AS svb_sum
FROM vw_ba_clean_base
GROUP BY stichtag, ym, berufsabschluss, staatsangehoerigkeit;

-- =====================================================================================
-- KPI 4: Anteil Ausländerinnen (gesamt) je Monat
-- share = Ausländer / (Deutsche + Ausländer)
-- =====================================================================================
CREATE OR REPLACE VIEW vw_kpi_share_auslaender_total AS
SELECT
  stichtag,
  ym,
  SUM(CASE WHEN staatsangehoerigkeit = 'Ausländer' THEN svb ELSE 0 END) AS svb_auslaender,
  SUM(svb) AS svb_total,
  ROUND(
    SUM(CASE WHEN staatsangehoerigkeit = 'Ausländer' THEN svb ELSE 0 END) / NULLIF(SUM(svb), 0),
    6
  ) AS share_auslaender
FROM vw_ba_clean_base
GROUP BY stichtag, ym;

-- =====================================================================================
-- KPI 5: Gap (Ausländer - Deutsche) je Bundesland und Monat
-- =====================================================================================
CREATE OR REPLACE VIEW vw_kpi_gap_nat_by_bl_month AS
SELECT
  stichtag,
  ym,
  bundesland_schluessel,
  bundesland,
  SUM(CASE WHEN staatsangehoerigkeit='Ausländer' THEN svb ELSE 0 END)
  - SUM(CASE WHEN staatsangehoerigkeit='Deutsche' THEN svb ELSE 0 END) AS gap_ausl_minus_dt
FROM vw_ba_clean_base
GROUP BY stichtag, ym, bundesland_schluessel, bundesland;

-- =====================================================================================
-- KPI 6: YoY Wachstum je Nat (gesamt)
-- =====================================================================================
CREATE OR REPLACE VIEW vw_kpi_yoy_total_nat AS
WITH t AS (
  SELECT stichtag, ym, staatsangehoerigkeit, SUM(svb) AS svb_sum
  FROM vw_ba_clean_base
  GROUP BY stichtag, ym, staatsangehoerigkeit
)
SELECT
  stichtag,
  ym,
  staatsangehoerigkeit,
  svb_sum,
  LAG(svb_sum, 12) OVER (PARTITION BY staatsangehoerigkeit ORDER BY stichtag) AS svb_sum_prev_year,
  (svb_sum - LAG(svb_sum, 12) OVER (PARTITION BY staatsangehoerigkeit ORDER BY stichtag)) AS yoy_abs,
  ROUND(
    (svb_sum - LAG(svb_sum, 12) OVER (PARTITION BY staatsangehoerigkeit ORDER BY stichtag))
    / NULLIF(LAG(svb_sum, 12) OVER (PARTITION BY staatsangehoerigkeit ORDER BY stichtag), 0),
    6
  ) AS yoy_pct
FROM t;

/* ============================================================================
Index-View: Trenddarstellung (Basis = erster Monat im Datensatz = 100)
Interpretation: relative Entwicklung statt Rohwerte.
============================================================================ */

CREATE OR REPLACE VIEW vw_kpi_index_total_nat AS
SELECT
  stichtag,
  ym,
  staatsangehoerigkeit,
  svb_sum,
  ROUND(
    svb_sum / NULLIF(FIRST_VALUE(svb_sum) OVER (
      PARTITION BY staatsangehoerigkeit
      ORDER BY stichtag
    ), 0) * 100
  , 2) AS index_svb_2022_01_100
FROM vw_kpi_total_by_month_nat;

-- Index je Staatsangehörigkeit (Basis = 2022-01 = 100)

/* ============================================================================
Trendglättung: 12-Monats Moving Average (MA12)
============================================================================ */

CREATE OR REPLACE VIEW vw_kpi_ma12_total_nat AS
SELECT
  stichtag,
  ym,
  staatsangehoerigkeit,
  svb_sum,
  ROUND(
    AVG(svb_sum) OVER (
      PARTITION BY staatsangehoerigkeit
      ORDER BY stichtag
      ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    )
  , 0) AS ma12_svb_sum
FROM vw_kpi_total_by_month_nat;

-- 12-Monats-Gleitender Durchschnitt (Trendglättung)

/* ============================================================================
Index/Trend für Anteil Ausländerinnen (gesamt)
============================================================================ */

CREATE OR REPLACE VIEW vw_kpi_share_auslaender_trend AS
SELECT
  stichtag,
  ym,
  share_auslaender,
  ROUND(share_auslaender * 100, 2) AS share_auslaender_pct,

  /* MA12 auf Anteil (Prozent) */
  ROUND(
    AVG(share_auslaender) OVER (
      ORDER BY stichtag
      ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ) * 100
  , 2) AS ma12_share_auslaender_pct,

  /* Index: Anteil relativ zum ersten Monat (Basis = 100) */
  ROUND(
    share_auslaender / NULLIF(FIRST_VALUE(share_auslaender) OVER (ORDER BY stichtag), 0) * 100
  , 2) AS index_share_2022_01_100
FROM vw_kpi_share_auslaender_total;

-- Index + MA12 für den Ausländerinnen-Anteil (optional, aber sehr stark fürs Storytelling)

