# Genie Ontology in Bahasa Indonesia: TokoNusa demo

This repo rebuilds the demo from the article "Genie Enterprise Context with Mixed Language - English and Bahasa". You create synthetic Indonesian retail data, a metric view, a dashboard and a Genie Agent, then add Unity Catalog Pages, some in Bahasa Indonesia and one in English, and compare how Genie One answers before and after.

All data is synthetic. TokoNusa is a fictional company. Steps 1 to 6 also run on [Databricks Free Edition](https://www.databricks.com/learn/free-edition), but Genie Ontology may not be available there yet as of October 2026, so the before and after comparison may not show a difference.

Have these ready:

| Requirement | Notes |
|---|---|
| A Databricks workspace | With Genie One and Genie Ontology enabled. Never load real company or customer data into it |
| A SQL warehouse | Free Edition includes a 2X-Small serverless warehouse |
| The `workspace` catalog | Exists by default in Free Edition. On other workspaces, change `USE CATALOG` at the top of each SQL file |
| Genie One and Pages | Pages is in Beta and Genie Ontology is in Public Preview |

```
genie-ontology-with-bahasa/
├── sql/01_setup_data.sql          synthetic stores, calendar and daily sales
├── sql/02_metric_view.sql         mv_penjualan: omzet bersih, GMV, jumlah transaksi
├── sql/03_expected_answers.sql    correct answers to the test questions
├── dashboard/kinerja_penjualan.lvdash.json
├── genie/agent_setup.md           Genie Agent name, instructions, sample questions
├── genie/test_questions.md        7 test questions with expected numbers
└── pages/glosarium_tokonusa.md    3 Pages: 2 in Bahasa Indonesia, 1 in English
```

## Step 1 · Create the synthetic data (est: 2 min)

Open the **SQL Editor**, paste `sql/01_setup_data.sql` and click **Run all**.

**Expected Result:**
- Schema `workspace.tokonusa` with 3 tables: `dim_toko` (36 rows), `dim_kalender` (638 rows), `fact_penjualan` (91,872 rows).
- Every table and column has a bilingual comment.

## Step 2 · Create the metric view (est: 1 min)

Run `sql/02_metric_view.sql` in the SQL Editor.

Why: the metric view is the one place where omzet bersih, GMV and jumlah transaksi are calculated.

**Expected Result:**
- Metric view `workspace.tokonusa.mv_penjualan` with 3 measures and 10 dimensions.
- The check query returns omzet bersih per wilayah for Lebaran 2026, with Jabodetabek highest (Rp 8.786.296.168).

## Step 3 · Import the dashboard (est: 2 min)

1. If your catalog is not `workspace`, find and replace `workspace.tokonusa` in `dashboard/kinerja_penjualan.lvdash.json`.
2. Go to **Dashboards**, click the arrow next to **Create dashboard**, choose **Import dashboard from file** and pick the JSON file.
3. Click **Publish**.

**Expected Result:**
- A published dashboard "Kinerja Penjualan Nasional" with 3 charts: omzet bersih per month (with Lebaran peaks in March 2025 and March 2026), per wilayah, and transactions per payment method.

## Step 4 · Create the Genie Agent (est: 5 min)

Follow `genie/agent_setup.md`. Use the metric view as the only data source and paste the short instructions.

Why: the instructions do not define business terms on purpose, so you can see what Pages add later.

**Expected Result:**
- A Genie Agent "TokoNusa Sales" that answers questions over `mv_penjualan`.

## Step 5 · Test before adding Pages (est: 10 min)

Open **Genie One** (app switcher in the top right, or add `/one` to your workspace URL). Ask the 7 questions in `genie/test_questions.md`, each in a new chat, because Genie One can reuse earlier conversations. Note which measure, filter and source each answer used, and compare the numbers with `sql/03_expected_answers.sql`.

**Expected Result:**
- A baseline table of answers. In a workspace with other data, questions 2, 6 and 7 are the most likely to go wrong without Pages. Questions 4 and 5 have no Page and act as controls.

## Step 6 · Create the Pages (est: 15 min)

In Genie One, go to **Discover**, filter by **Pages** and click **Create page**. Create the 3 Pages in `pages/glosarium_tokonusa.md` in a domain called **Penjualan**. For each Page, fill in the synonyms, description and body, and link the related asset `mv_penjualan`.

Faster option: paste `pages/glosarium_tokonusa.md` into Genie Code and use **Bulk import pages**. Review the proposals before publishing.

Optional: certify the metric view, dashboard and Genie Agent so Genie Ontology treats them as authoritative.

**Expected Result:**
- 3 published Pages: Definisi Omzet and Periode Lebaran (Bahasa Indonesia), Jakarta and outer Jakarta region (English).

## Step 7 · Test again with Pages (est: 10 min)

Ask the same 7 questions in Genie One, each in a new chat. Open the citations on each answer.

**Expected Result:**
- A second table of answers. Compare it with the baseline from step 5, and check which answers cite a Page.

## Clean up

```sql
DROP SCHEMA workspace.tokonusa CASCADE;
```

Then delete the dashboard, the Genie Agent and the 3 Pages.

## Notes

- Genie Ontology is in Public Preview and Pages are in Beta. Features and UI may change.
- Genie works in languages other than English, but its prompts are in English, so some answers may come back in English.
- The metric view comments are bilingual, and Genie Ontology learns from metric views too. Some answers may already be right before Pages. Pages add the rules that comments cannot hold, such as "compare Lebaran with Lebaran".
- Page data uses Databricks-managed encryption keys. Customer-managed keys are not supported yet.

References: [Genie Ontology](https://docs.databricks.com/aws/en/genie/genie-ontology) · [Pages](https://docs.databricks.com/aws/en/uc-semantics/pages) · [Metric views](https://docs.databricks.com/aws/en/metric-views/)
