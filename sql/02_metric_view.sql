-- Metric view: the single, governed definition of omzet bersih, GMV and jumlah transaksi.
-- Every dashboard, Genie Agent and Genie One answer uses these formulas.

USE CATALOG workspace;
USE SCHEMA tokonusa;

CREATE OR REPLACE VIEW mv_penjualan
WITH METRICS LANGUAGE YAML
COMMENT 'Metrik penjualan TokoNusa (sales metrics): omzet bersih, GMV, jumlah transaksi'
AS $$
version: 1.1
source: fact_penjualan
joins:
  - name: toko
    source: dim_toko
    on: source.toko_id = toko.toko_id
  - name: kalender
    source: dim_kalender
    on: source.tanggal = kalender.tanggal
dimensions:
  - name: tanggal
    expr: source.tanggal
    comment: "Tanggal transaksi (transaction date)"
  - name: bulan
    expr: DATE_TRUNC('MONTH', source.tanggal)
    comment: "Bulan (month)"
  - name: tahun
    expr: kalender.tahun
    comment: "Tahun (year)"
  - name: is_periode_lebaran
    expr: kalender.is_periode_lebaran
    comment: "Periode Lebaran, H-30 sampai H+7 Idul Fitri (Eid season)"
  - name: wilayah
    expr: source.wilayah
    comment: "Wilayah penjualan (sales region), e.g. Jabodetabek"
  - name: provinsi
    expr: toko.provinsi
    comment: "Provinsi (province)"
  - name: kota
    expr: toko.kota
    comment: "Kota (city)"
  - name: nama_toko
    expr: toko.nama_toko
    comment: "Nama toko (store name)"
  - name: tipe_toko
    expr: toko.tipe_toko
    comment: "Toko Sendiri (own store) atau Mitra Warung (partner shop)"
  - name: metode_bayar
    expr: source.metode_bayar
    comment: "Metode bayar (payment method): QRIS, COD, E-Wallet, Transfer Bank"
measures:
  - name: omzet_bersih
    expr: SUM(source.nilai_kotor - source.diskon - source.retur - source.ppn)
    comment: "Omzet bersih (net revenue): penjualan kotor dikurangi diskon, retur, dan PPN. Rupiah."
  - name: gmv
    expr: SUM(source.nilai_kotor)
    comment: "GMV (gross merchandise value): penjualan kotor sebelum diskon dan retur. Rupiah."
  - name: jumlah_transaksi
    expr: SUM(source.jumlah_transaksi)
    comment: "Jumlah transaksi (number of transactions)"
$$;

-- Quick check: omzet bersih per wilayah during Lebaran 2026
SELECT wilayah, MEASURE(omzet_bersih) AS omzet_bersih, MEASURE(gmv) AS gmv
FROM mv_penjualan
WHERE tahun = 2026 AND is_periode_lebaran
GROUP BY wilayah
ORDER BY omzet_bersih DESC;
