-- TokoNusa synthetic retail data (Indonesia). All names and numbers are fake.
-- Run in the Databricks SQL editor on a SQL warehouse.
-- Change the catalog name below if you do not have a catalog called "workspace".

USE CATALOG workspace;
CREATE SCHEMA IF NOT EXISTS tokonusa COMMENT 'TokoNusa demo: synthetic Indonesian retail sales for Genie Ontology';
USE SCHEMA tokonusa;

-- Stores: own stores (Toko Sendiri) and partner shops (Mitra Warung).
-- Jabodetabek is a sales region that spans 3 provinces: DKI Jakarta, Jawa Barat and Banten.
CREATE OR REPLACE TABLE dim_toko (
  toko_id   INT    COMMENT 'ID toko (store ID)',
  nama_toko STRING COMMENT 'Nama toko (store name)',
  tipe_toko STRING COMMENT 'Tipe toko: Toko Sendiri (own store) atau Mitra Warung (partner shop)',
  kota      STRING COMMENT 'Kota (city)',
  provinsi  STRING COMMENT 'Provinsi (province)',
  wilayah   STRING COMMENT 'Wilayah penjualan (sales region), e.g. Jabodetabek'
) COMMENT 'Daftar toko TokoNusa (store master)';

WITH kota AS (
  SELECT * FROM VALUES
    (1,  'Jakarta Selatan', 'DKI Jakarta',      'Jabodetabek'),
    (2,  'Jakarta Barat',   'DKI Jakarta',      'Jabodetabek'),
    (3,  'Bogor',           'Jawa Barat',       'Jabodetabek'),
    (4,  'Depok',           'Jawa Barat',       'Jabodetabek'),
    (5,  'Bekasi',          'Jawa Barat',       'Jabodetabek'),
    (6,  'Tangerang',       'Banten',           'Jabodetabek'),
    (7,  'Bandung',         'Jawa Barat',       'Jawa Barat Lainnya'),
    (8,  'Surabaya',        'Jawa Timur',       'Jawa Timur'),
    (9,  'Malang',          'Jawa Timur',       'Jawa Timur'),
    (10, 'Denpasar',        'Bali',             'Bali'),
    (11, 'Medan',           'Sumatera Utara',   'Sumatera'),
    (12, 'Makassar',        'Sulawesi Selatan', 'Sulawesi')
  AS t(kota_id, kota, provinsi, wilayah)
),
pemilik AS (
  SELECT * FROM VALUES
    (0, 'Bu Sri'), (1, 'Pak Budi'), (2, 'Bu Wati')
  AS t(idx, nama)
)
INSERT INTO dim_toko
SELECT
  k.kota_id * 10 + n                                   AS toko_id,
  CASE WHEN n = 0 THEN concat('TokoNusa ', k.kota)
       ELSE concat('Warung ', p.nama, ' ', k.kota) END AS nama_toko,
  CASE WHEN n = 0 THEN 'Toko Sendiri' ELSE 'Mitra Warung' END AS tipe_toko,
  k.kota, k.provinsi, k.wilayah
FROM kota k
CROSS JOIN (SELECT explode(sequence(0, 2)) AS n) s
LEFT JOIN pemilik p ON p.idx = (k.kota_id + s.n) % 3;

-- Calendar with the Lebaran period: H-30 to H+7 around Idul Fitri.
CREATE OR REPLACE TABLE dim_kalender (
  tanggal            DATE    COMMENT 'Tanggal (date)',
  tahun              INT     COMMENT 'Tahun (year)',
  bulan              INT     COMMENT 'Bulan (month number)',
  idul_fitri         DATE    COMMENT 'Tanggal Idul Fitri tahun ini (Eid al-Fitr date for the year)',
  is_periode_lebaran BOOLEAN COMMENT 'TRUE jika tanggal dalam periode Lebaran, H-30 sampai H+7 Idul Fitri (Eid season flag)'
) COMMENT 'Kalender dengan penanda periode Lebaran (calendar with Eid season flag)';

INSERT INTO dim_kalender
SELECT
  d AS tanggal,
  year(d), month(d),
  f.idul_fitri,
  d BETWEEN date_sub(f.idul_fitri, 30) AND date_add(f.idul_fitri, 7)
FROM (SELECT explode(sequence(DATE'2025-01-01', DATE'2026-09-30')) AS d) c
JOIN (SELECT * FROM VALUES
        (2025, DATE'2025-03-31'),
        (2026, DATE'2026-03-20')
      AS t(tahun, idul_fitri)) f
  ON year(c.d) = f.tahun;

-- Daily sales per store per payment method, in Rupiah (about 92,000 rows).
-- nilai_kotor includes PPN (VAT) at an effective 11%.
CREATE OR REPLACE TABLE fact_penjualan (
  tanggal          DATE          COMMENT 'Tanggal transaksi (transaction date)',
  toko_id          INT           COMMENT 'ID toko (store ID)',
  wilayah          STRING        COMMENT 'Wilayah penjualan (sales region), e.g. Jabodetabek',
  metode_bayar     STRING        COMMENT 'Metode bayar (payment method): QRIS, COD, E-Wallet, Transfer Bank',
  jumlah_transaksi INT           COMMENT 'Jumlah transaksi (number of transactions)',
  nilai_kotor      DECIMAL(18,0) COMMENT 'Nilai penjualan kotor termasuk PPN, Rupiah (gross sales incl. VAT, IDR)',
  diskon           DECIMAL(18,0) COMMENT 'Diskon, Rupiah (discounts, IDR)',
  retur            DECIMAL(18,0) COMMENT 'Retur, Rupiah (returns, IDR)',
  ppn              DECIMAL(18,0) COMMENT 'PPN atau pajak pertambahan nilai, Rupiah (VAT, IDR)'
) COMMENT 'Penjualan harian per toko dan metode bayar (daily sales)';

INSERT INTO fact_penjualan
WITH base AS (
  SELECT
    k.tanggal, t.toko_id, t.wilayah, m.metode_bayar,
    -- Deterministic pseudo-random number between 0 and 1
    (abs(hash(t.toko_id, k.tanggal, m.metode_bayar)) % 1000) / 1000.0 AS r,
    CASE WHEN t.tipe_toko = 'Toko Sendiri' THEN 3.0 ELSE 1.0 END        AS skala_toko,
    CASE WHEN k.is_periode_lebaran THEN 1.6 ELSE 1.0 END                 AS faktor_lebaran,
    m.porsi
  FROM dim_kalender k
  CROSS JOIN dim_toko t
  CROSS JOIN (SELECT * FROM VALUES
                ('QRIS', 0.40), ('E-Wallet', 0.25), ('COD', 0.20), ('Transfer Bank', 0.15)
              AS x(metode_bayar, porsi)) m
),
nilai AS (
  SELECT *,
    CAST(round((40 + 60 * r) * skala_toko * faktor_lebaran * porsi) AS INT)                         AS jumlah_transaksi,
    CAST(round((40 + 60 * r) * skala_toko * faktor_lebaran * porsi * (60000 + 40000 * r)) AS DECIMAL(18,0)) AS nilai_kotor
  FROM base
)
SELECT
  tanggal, toko_id, wilayah, metode_bayar, jumlah_transaksi, nilai_kotor,
  CAST(round(nilai_kotor * 0.05) AS DECIMAL(18,0))                                   AS diskon,
  CAST(round(nilai_kotor * CASE WHEN metode_bayar = 'COD' THEN 0.06 ELSE 0.02 END) AS DECIMAL(18,0)) AS retur,
  CAST(round(nilai_kotor * 11 / 111) AS DECIMAL(18,0))                               AS ppn
FROM nilai;

SELECT 'dim_toko' AS tabel, count(*) AS jumlah_baris FROM dim_toko
UNION ALL SELECT 'dim_kalender', count(*) FROM dim_kalender
UNION ALL SELECT 'fact_penjualan', count(*) FROM fact_penjualan;
