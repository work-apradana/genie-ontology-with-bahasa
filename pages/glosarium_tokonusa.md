# Glosarium Bisnis TokoNusa (TokoNusa business glossary)

Three business concepts for the TokoNusa demo: two Pages in Bahasa Indonesia and one in English. Each Page has synonyms in the other language, so questions in either language find it.
Create each one as a Unity Catalog Page in the domain **Penjualan**, or paste this file into Genie Code and use **Bulk import pages**.

---

## Definisi Omzet

- **Type:** Term
- **Language:** Bahasa Indonesia
- **Synonyms:** omzet bersih, omzet, pendapatan bersih, pendapatan, net revenue, net sales, revenue
- **Description:** Definisi resmi omzet bersih TokoNusa: penjualan kotor dikurangi diskon, retur, dan PPN.
- **Related asset:** metric view `mv_penjualan`, measure `omzet_bersih`

**Body:**

Omzet bersih adalah penjualan kotor dikurangi diskon, retur, dan PPN. Ini adalah angka resmi TokoNusa untuk laporan ke manajemen, dalam Rupiah.

GMV adalah penjualan kotor sebelum diskon dan retur, jadi GMV selalu lebih besar dari omzet bersih. Omzet bersih biasanya sekitar 82% dari GMV. Jangan gunakan GMV untuk laporan ke manajemen.

Aturan untuk pertanyaan:

- Jika seseorang bertanya tentang "revenue", "pendapatan" atau "omzet" tanpa keterangan lain, gunakan omzet bersih TokoNusa dalam Rupiah.
- Jangan gunakan data bisnis lain di workspace untuk pertanyaan omzet TokoNusa.
- Gunakan GMV hanya jika GMV disebut secara langsung.

Sumber resmi: metric view `mv_penjualan`, measure `omzet_bersih`.

---

## Periode Lebaran

- **Type:** Term
- **Language:** Bahasa Indonesia
- **Synonyms:** Lebaran, musim Lebaran, musim mudik, Eid season, Eid al-Fitr season, Lebaran season, Ramadan season
- **Description:** Periode penjualan Lebaran TokoNusa: H-30 sampai H+7 Idul Fitri.
- **Related asset:** metric view `mv_penjualan`, dimension `is_periode_lebaran`

**Body:**

Periode Lebaran dihitung dari H-30 sampai H+7 Idul Fitri, yaitu 30 hari sebelum sampai 7 hari sesudah Idul Fitri. Ini adalah musim penjualan terbesar TokoNusa.

Tanggal Idul Fitri mengikuti kalender Hijriah, jadi berubah setiap tahun. Idul Fitri 2025 jatuh pada 31 Maret 2025 dan Idul Fitri 2026 pada 20 Maret 2026.

Aturan untuk pertanyaan:

- Gunakan dimensi `is_periode_lebaran` di `mv_penjualan`. Jangan hitung tanggal secara manual dan jangan anggap Lebaran selalu di bulan April.
- Untuk perbandingan dengan tahun lalu, bandingkan periode Lebaran tahun ini dengan periode Lebaran tahun lalu, bukan bulan kalender yang sama.

---

## Jakarta and outer Jakarta region

- **Type:** Term
- **Language:** English
- **Synonyms:** Jabodetabek, wilayah Jabodetabek, Jakarta, Jakarta raya, Greater Jakarta, Jakarta metro
- **Description:** How TokoNusa separates Jakarta (DKI Jakarta province) from the Jabodetabek sales region.
- **Related asset:** metric view `mv_penjualan`, dimensions `wilayah` and `provinsi`

**Body:**

Jabodetabek stands for Jakarta, Bogor, Depok, Tangerang and Bekasi. At TokoNusa it is a sales region (`wilayah = 'Jabodetabek'`), not a province. Greater Jakarta and Jakarta metro mean the same region.

Jabodetabek spans three provinces:

- DKI Jakarta: Jakarta Selatan and Jakarta Barat
- Jawa Barat: Bogor, Depok and Bekasi
- Banten: Tangerang

Bandung is in Jawa Barat but is not part of Jabodetabek.

Rules for questions:

- "Jakarta" on its own is ambiguous. Give both numbers and label them: DKI Jakarta (`provinsi = 'DKI Jakarta'`) and Jabodetabek (`wilayah = 'Jabodetabek'`).
- For Jabodetabek, filter by `wilayah`. Do not filter by `provinsi = 'DKI Jakarta'`, because that misses Bogor, Depok, Tangerang and Bekasi.
