# Genie Agent setup: TokoNusa Sales

Create this Genie Agent in the UI (Genie > New).

- **Name:** TokoNusa Sales
- **Description:** Penjualan TokoNusa: omzet bersih, GMV dan transaksi per wilayah, toko dan metode bayar. Data sintetis.
- **Data:** `workspace.tokonusa.mv_penjualan` (the metric view only)
- **SQL warehouse:** any serverless SQL warehouse

## General instructions

Keep these short on purpose. Business definitions live in Pages, not here, so you can see what Genie Ontology adds.

```
Answer in the same language as the question. If the question mixes Bahasa Indonesia and English, answer in Bahasa Indonesia.
Show money in Rupiah with thousand separators, for example Rp 8.786.296.168.
Do not ask clarifying questions. State your assumption and answer.
```

## Sample questions

```
Berapa omzet bersih per wilayah tahun 2026?
Tren GMV per bulan di Jawa Timur
Berapa jumlah transaksi QRIS bulan September 2026?
```
