-- Expected answers for the test questions in genie/test_questions.md.
-- Compare these numbers with what Genie One returns.

USE CATALOG workspace;
USE SCHEMA tokonusa;

-- Q1, Q2: omzet bersih Jabodetabek, periode Lebaran 2026
SELECT MEASURE(omzet_bersih) AS omzet_bersih
FROM mv_penjualan
WHERE wilayah = 'Jabodetabek' AND tahun = 2026 AND is_periode_lebaran;

-- Q3: same, 2026 vs 2025
SELECT tahun, MEASURE(omzet_bersih) AS omzet_bersih
FROM mv_penjualan
WHERE wilayah = 'Jabodetabek' AND tahun IN (2025, 2026) AND is_periode_lebaran
GROUP BY tahun
ORDER BY tahun;

-- Q4: share of QRIS vs COD transactions per provinsi, last full month in the data (September 2026)
SELECT provinsi, metode_bayar,
       MEASURE(jumlah_transaksi) AS jumlah_transaksi
FROM mv_penjualan
WHERE bulan = DATE'2026-09-01' AND metode_bayar IN ('QRIS', 'COD')
GROUP BY provinsi, metode_bayar
ORDER BY provinsi, metode_bayar;

-- Q5: top 3 mitra warung by GMV in Jawa Timur, 2026
SELECT nama_toko, MEASURE(gmv) AS gmv
FROM mv_penjualan
WHERE provinsi = 'Jawa Timur' AND tipe_toko = 'Mitra Warung' AND tahun = 2026
GROUP BY nama_toko
ORDER BY gmv DESC
LIMIT 3;

-- Q6: "revenue bulan lalu" should use omzet bersih, not GMV (September 2026)
SELECT MEASURE(omzet_bersih) AS omzet_bersih, MEASURE(gmv) AS gmv
FROM mv_penjualan
WHERE bulan = DATE'2026-09-01';

-- Q7: Jabodetabek is a region, not a province. It spans 3 provinces.
SELECT provinsi, MEASURE(omzet_bersih) AS omzet_bersih
FROM mv_penjualan
WHERE wilayah = 'Jabodetabek' AND tahun = 2026
GROUP BY provinsi;
