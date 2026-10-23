# Test questions

Ask each question in Genie One twice: before you create the Pages, and after. Record which definition and source Genie One used, the answer language and whether the number matches.

The expected numbers come from `sql/03_expected_answers.sql`. The data is deterministic, so you should get the same numbers.

| # | Question | Style | What a correct answer does | Expected |
|---|---|---|---|---|
| 1 | Berapa omzet bersih Jabodetabek selama periode Lebaran 2026? | Bahasa Indonesia | Uses `omzet_bersih`, `wilayah = 'Jabodetabek'`, `is_periode_lebaran` | Rp 8.786.296.168 |
| 2 | What was net revenue in Greater Jakarta during Eid season 2026? | English | Same as Q1, through English synonyms | Rp 8.786.296.168 |
| 3 | Omzet bersih Jabodetabek pas Lebaran 2026, compare sama Lebaran 2025 dong | Mixed | Compares Lebaran periods, not calendar months | 2025: Rp 8.670.604.998, 2026: Rp 8.786.296.168 |
| 4 | Share transaksi QRIS vs COD per provinsi bulan September 2026 | Mixed | Uses `jumlah_transaksi` by `provinsi` and `metode_bayar` | e.g. DKI Jakarta: QRIS 8.343, COD 4.325 |
| 5 | Top 3 mitra warung by GMV di Jawa Timur tahun 2026 | Mixed | Filters `tipe_toko = 'Mitra Warung'`, uses `gmv` | #1 Warung Bu Sri Surabaya, Rp 1.748.518.669 |
| 6 | Berapa revenue bulan September 2026? | Mixed, ambiguous | Picks omzet bersih, not GMV | Rp 8.654.499.576 (GMV would be Rp 10.519.178.100) |
| 7 | Berapa omzet bersih Jakarta tahun 2026? | Bahasa Indonesia, ambiguous | States whether it means DKI Jakarta or Jabodetabek | DKI Jakarta: Rp 14.027.483.959, Jabodetabek: Rp 42.355.138.002 |

## Where Pages should make a difference

- **Q2:** "Greater Jakarta", "Eid season" and "net revenue" are English synonyms on the Pages, so this tests whether an English question finds the Bahasa Indonesia Pages.
- **Q3:** the Periode Lebaran Page says to compare Lebaran periods, not the same calendar month.
- **Q6:** the Definisi Omzet Page says "revenue" means TokoNusa omzet bersih, not GMV and not another business.
- **Q7:** the Jakarta and outer Jakarta region Page says "Jakarta" alone is ambiguous and both numbers should be given.

## Control questions

- **Q4 (QRIS)** and **Q5 (mitra warung)** have no Page on purpose. If Q2, Q6 and Q7 improve while Q4 and Q5 stay the same, the change came from the Pages.

Note: the metric view comments are bilingual (for example, "Omzet bersih (net revenue)"), and Genie Ontology also learns from metric views. Some questions may already be answered well before Pages. That is expected: Pages add the rules that comments cannot hold.
