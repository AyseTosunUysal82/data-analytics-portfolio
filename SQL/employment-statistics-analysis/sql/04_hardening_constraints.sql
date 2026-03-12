/*
04_hardening_constraints.sql
Projekt: BA-Beschäftigungsstatistik (Option B) – Frauen, Deutsche vs. Ausländer
Schema: ba_svb_frauen

STAGE: 04_hardening (Constraints / Datenqualität erzwingen)
Zweck:
- Erzwingt Eindeutigkeit (UNIQUE) auf Fakt-Granularität
- Erzwingt gültige BL-Schlüssel via FK auf dim_bundesland
- Erzwingt Scope-Regeln via CHECK Constraints (MySQL 8)

Wichtig:
- Dieses Script i.d.R. nur 1x ausführen (nach erfolgreichem Rebuild).
- Wenn du komplett neu aufsetzt (DROP DB), dann wieder ausführen.
*/

USE ba_svb_frauen;

-- =====================================================================================
-- STAGE 04_hardening: UNIQUE Grain (ein Fakt pro Monat/Nat/BL/Abschluss + Geschlecht)
-- =====================================================================================
ALTER TABLE ba_clean
  ADD CONSTRAINT uq_ba_clean_grain
  UNIQUE KEY (stichtag, geschlecht, staatsangehoerigkeit, bundesland_schluessel, berufsabschluss);

-- =====================================================================================
-- STAGE 04_hardening: FK + Index (nur gültige Bundesland-Schlüssel)
-- =====================================================================================
CREATE INDEX ix_ba_clean_bl ON ba_clean (bundesland_schluessel);

ALTER TABLE ba_clean
  ADD CONSTRAINT fk_ba_clean_dim_bundesland
  FOREIGN KEY (bundesland_schluessel)
  REFERENCES dim_bundesland (bundesland_schluessel)
  ON UPDATE RESTRICT
  ON DELETE RESTRICT;

-- =====================================================================================
-- STAGE 04_hardening: CHECK Constraints (Scope fix)
-- =====================================================================================
ALTER TABLE ba_clean
  ADD CONSTRAINT chk_geschlecht_frauen CHECK (geschlecht = 'Frauen');

ALTER TABLE ba_clean
  ADD CONSTRAINT chk_nat_2vals CHECK (staatsangehoerigkeit IN ('Deutsche','Ausländer'));

ALTER TABLE ba_clean
  ADD CONSTRAINT chk_bl_key_format CHECK (bundesland_schluessel REGEXP '^[0-9]{7}$');
