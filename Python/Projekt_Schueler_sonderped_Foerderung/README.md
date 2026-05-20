# Sonderpädagogische Förderung in Deutschland (2000–2024)

## Projektüberblick

Dieses Python-Projekt untersucht die Entwicklung sonderpädagogischer Förderung in Deutschland im Zeitraum **2000 bis 2024**. Im Mittelpunkt stehen die langfristige Gesamtentwicklung, strukturelle Unterschiede nach Schularten und Förderschwerpunkten sowie eine vorsichtige Einordnung möglicher externer Einflussfaktoren.

Die Analyse ist bewusst **deskriptiv** aufgebaut. Sie zeigt Entwicklungen, Muster und zeitliche Zusammenhänge, weist aber methodisch darauf hin, dass mit aggregierten Statistikdaten **keine Kausalität** nachgewiesen werden kann.

## Ziel der Analyse

Ziel ist es, datenbasiert zu beantworten, wie sich sonderpädagogische Förderung in Deutschland entwickelt hat und welche strukturellen Veränderungen sichtbar werden.

Zentrale Analyseperspektiven:

- Entwicklung der Gesamtzahl der Schülerinnen und Schüler mit sonderpädagogischer Förderung
- Entwicklung des Förderanteils relativ zur Gesamtschülerzahl
- Verteilung nach Schularten
- Verteilung und Dynamik der Förderschwerpunkte
- Treiber des Anstiegs seit 2015
- Kontextualisierung externer Ereignisse wie Migration ab 2015 und COVID-19

## Datenquellen

Die Analyse basiert auf aggregierten Daten aus **Destatis / GENESIS-Online**.

Verwendete Datensätze:

| Datensatz | Zweck |
|---|---|
| `schueler_mit_foerderung_21111_0007_de_flat.csv` | Kerndatensatz zur sonderpädagogischen Förderung nach Jahr, Schulart und Förderschwerpunkt |
| `schueler_gesamt_21111_0002_de_flat.csv` | Referenzdatensatz zur Gesamtzahl der Schülerinnen und Schüler zur Berechnung des Förderanteils |

## Projektstruktur

```text
project_schueler_sonderp_foerderung/
│
├── data/
│   └── processed/
│       ├── schueler_mit_foerderung_21111_0007_de_flat.csv
│       └── schueler_gesamt_21111_0002_de_flat.csv
│
├── notebooks/
│   └── concept_1_einfach/
│       └── ssf_analysis_final_abgabe.ipynb
│
├── outputs/
│   ├── charts/
│   └── exports/
│
├── README.md
└── requirements.txt
```

## Methodisches Vorgehen

### 1. Datenimport und erste Prüfung

Die Rohdaten werden unverändert eingelesen und zunächst technisch geprüft:

- Spaltenstruktur
- Datentypen
- Zeitraum
- fehlende Werte
- erste Plausibilitätschecks

### 2. Bereinigung und Transformation

Für die Analyse werden die technischen GENESIS-Spalten auf fachlich relevante Analysevariablen reduziert:

| Zielvariable | Bedeutung |
|---|---|
| `jahr` | Kalenderjahr / Schuljahr als Zeitdimension |
| `schulart` | Schulart bzw. Schulform |
| `foerderschwerpunkt` | Art der sonderpädagogischen Förderung |
| `anzahl_schueler` | Anzahl der Schülerinnen und Schüler |

Wichtige Bereinigungsschritte:

- technische Codes und redundante Beschreibungsspalten entfernt
- `value` in numerische Variable `anzahl_schueler` umgewandelt
- Jahr aus der Zeitangabe abgeleitet
- `Insgesamt`-Kategorien entfernt, um Doppelzählungen zu vermeiden
- fehlende bzw. nicht ausgewiesene Werte nicht als 0 interpretiert, sondern für Detailanalysen ausgeschlossen

### 3. Analyse und Visualisierung

Die Analyse ist in mehrere Fragestellungen gegliedert. Alle Visualisierungen werden zusätzlich als PNG-Dateien in `outputs/charts/` gespeichert und können direkt für Präsentationen genutzt werden.

## Fragestellungen und Ergebnisse

| Nr. | Fragestellung | Ergebnis | Interpretation |
|---|---|---|---|
| F1 | Wie entwickelt sich die Gesamtzahl der Schülerinnen und Schüler mit sonderpädagogischer Förderung? | Langfristiger Anstieg, besonders ab 2017/2018 deutlich stärker. | Die Förderung nimmt im betrachteten Zeitraum sichtbar zu. |
| F2 | In welchen Schularten tritt sonderpädagogische Förderung besonders häufig auf? | Förderschulen dominieren, aber allgemeine Schularten gewinnen an Bedeutung. | Hinweise auf stärkere Sichtbarkeit bzw. Integration im Regelschulsystem. |
| F3 | Welche Förderschwerpunkte dominieren insgesamt? | `Lernen` ist der größte Bereich; danach folgen `Geistige Entwicklung` und `Emotionale und soziale Entwicklung`. | Das Fördervolumen ist stark auf wenige Bereiche konzentriert. |
| F4 | Wie verschieben sich die wichtigsten Förderschwerpunkte im Zeitverlauf? | `Lernen` verliert relativ an Anteil; `Emotionale und soziale Entwicklung` wächst stark. | Das System wird differenzierter; es zeigt sich eine strukturelle Verschiebung innerhalb der Förderung. |
| F5 | Welche Bereiche treiben den Anstieg seit 2015? | Wachstum wird von wenigen zentralen Förderschwerpunkten getragen. | Der Anstieg ist nicht gleichmäßig über alle Kategorien verteilt. |
| F6 | Steigt der Förderbedarf auch relativ zur Gesamtschülerzahl? | Förderanteil steigt von ca. 4,7 % auf ca. 6,9 %. | Der Anstieg ist nicht nur durch mehr Schülerinnen und Schüler erklärbar, sondern weist auf strukturelles Wachstum hin. |

## Hypothesenprüfung

Zusätzlich zur deskriptiven Analyse werden zwei Hypothesen geprüft. Diese Hypothesen entstehen aus der beobachteten Entwicklung und dienen der vorsichtigen Kontextualisierung.

| Hypothese | Erwartung | Ergebnis | Interpretation |
|---|---|---|---|
| H1: Die verstärkte Zuwanderung ab 2015 hängt mit einem zeitverzögerten Anstieg des Förderanteils zusammen. | Kein unmittelbarer Sprung 2015, aber sichtbare Veränderung in Folgejahren. | Teilweise gestützt: Anstieg zeigt sich zeitverzögert ab 2017/2018. | Zeitlicher Zusammenhang sichtbar, aber keine Kausalität. Zusätzliche Migrationsdaten wären erforderlich. |
| H2: COVID-19 führte zu einem starken zusätzlichen Anstieg des Förderanteils. | Klarer zusätzlicher Sprung im Zeitraum 2020–2022. | Nicht klar bestätigt: Trend setzt sich fort, kein isolierter zusätzlicher Sprung. | COVID-19 kann eher als möglicher Verstärker eines bestehenden Trends interpretiert werden, nicht als eigenständiger Haupttreiber. |

## Zentrale Erkenntnisse

- Die sonderpädagogische Förderung nimmt langfristig deutlich zu.
- Der Anstieg zeigt sich nicht nur absolut, sondern auch relativ zur Gesamtschülerzahl.
- Der sichtbarste Dynamikwechsel liegt ab etwa **2017/2018**.
- Förderschulen dominieren weiterhin, aber allgemeine Schularten gewinnen an Bedeutung.
- Der Förderschwerpunkt `Lernen` bleibt der größte Bereich, verliert aber relativ an Gewicht.
- `Emotionale und soziale Entwicklung` gewinnt deutlich an Bedeutung.
- Die Entwicklung lässt sich nicht eindeutig einem einzelnen externen Ereignis zuordnen.

## Limitationen

Die Ergebnisse müssen methodisch vorsichtig interpretiert werden:

- Es handelt sich um aggregierte Daten, nicht um Individualdaten.
- Direkte Variablen zu Migration oder COVID-19 sind im Datensatz nicht enthalten.
- Die Analyse zeigt zeitliche Zusammenhänge, aber keine kausalen Wirkungen.
- Fehlende Werte können unterschiedliche Bedeutungen haben, z. B. tatsächlicher Nullwert, nicht vorhandener Wert oder statistische Geheimhaltung.
- Schularten mussten zwischen Datensätzen harmonisiert werden, um vergleichbare Förderanteile zu berechnen.

## Verwendete Technologien

- Python
- pandas
- NumPy
- Matplotlib
- Jupyter Notebook / VS Code

## Ausführung

1. Repository klonen oder Projektordner öffnen.
2. Virtuelle Umgebung aktivieren.
3. Abhängigkeiten installieren:

```bash
pip install -r requirements.txt
```

4. Notebook öffnen:

```text
notebooks/concept_1_einfach/ssf_analysis_final_abgabe.ipynb
```

5. Notebook von oben nach unten ausführen.

## Ergebnisdateien

Die wichtigsten Diagramme werden automatisch als PNG-Dateien gespeichert:

```text
outputs/charts/
```

Diese Visuals wurden für die begleitende Präsentation genutzt.

## Gesamtfazit

Die Analyse zeigt eine langfristige Zunahme sonderpädagogischer Förderung in Deutschland. Besonders relevant ist, dass der Förderanteil nicht nur absolut, sondern auch relativ zur Gesamtschülerzahl steigt.

Der zentrale Wendepunkt liegt nicht unmittelbar bei einem einzelnen Ereignis, sondern wird ab etwa **2017/2018** sichtbar. Insgesamt spricht die Analyse für eine strukturelle Transformation des Bildungssystems mit wachsendem Unterstützungsbedarf und stärkerer Sichtbarkeit sonderpädagogischer Förderung im Regelschulsystem.
