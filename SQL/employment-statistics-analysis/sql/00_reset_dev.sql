/*
00_reset_dev.sql  (DEV ONLY – sehr gefährlich)
Projekt: BA-Beschäftigungsstatistik (Option B) – Frauen, Deutsche vs. Ausländer
Schema: ba_svb_frauen

STAGE: 00_reset_dev
Zweck:
- Kompletter Reset der Datenbank (DROP DATABASE)
- Nur nutzen, wenn du bewusst alles neu aufsetzen willst

WICHTIG:
- Niemals "Execute All" mit anderen Scripts zusammen!
- Nur einzeln ausführen, wenn du wirklich resetten willst.
*/

-- erst Kommentar bewusst entfernen!!!!
/*
DROP DATABASE IF EXISTS ba_svb_frauen;
*/