# Harga penuh ukuran/kemasan

Backend tetap mengirim `optionPrice` sebagai selisih. `pricing_mode: full` hanya menandai kelompok ukuran/kemasan. Aplikasi menampilkan harga dasar + selisih untuk pilihan tersebut. Mode yang hilang/tidak dikenal memakai perilaku tambahan lama.

Perubahan:
- Detail produk, kartu katalog, dan item keranjang memakai helper `VariationPricing`.
- Harga ukuran masuk ke tampilan harga barang; tambahan biasa tetap terpisah. Nilai transaksi tidak dijumlahkan dua kali.
- Kelompok full wajib satu pilihan. Edit keranjang mencocokkan pilihan dengan ID opsi, atau nama kelompok/label untuk data lama tanpa ID.
- Harga dan pilihan di-refresh sebelum masuk checkout dan sebelum mengirim order dari keranjang. Jika berubah, pengguna harus meninjau kembali keranjangnya. Kegagalan refresh menghentikan checkout dan tidak menghapus keranjang yang ada.
- Subtotal dihitung kembali setelah pembatasan diskon restoran. Minimum belanja menggunakan nilai sebelum diskon, mengikuti perhitungan checkout.
- Payload order tetap menggunakan label pilihan dan ID opsi yang sudah dipakai backend.

## Verifikasi

Gunakan Flutter 3.41.9 sesuai `.fvmrc`, tanpa upgrade dependency:

```sh
flutter test --no-pub test/variation_pricing_test.dart
```

18 tes mencakup mode lama/baru, cache model, harga awal, pilihan wajib/stok, pengurutan ulang opsi, diskon nominal/persen, batas diskon, minimum belanja, kuantitas, payload pilihan, snapshot harga, dan refresh gagal/berhasil. Tidak ada koneksi ke production atau database aplikasi dalam tes ini.

Analisis file yang diubah tidak menemukan error atau warning; dua informasi deprecation Radio `groupValue`/`onChanged` sudah berasal dari widget lama.

## Pemeriksaan sebelum rilis

- Uji pada perangkat: produk biasa, full 500 gram 20000, premium 1 kg 38500, tambahan box 2000, kuantitas 1/2.
- Cocokkan nominal keranjang, checkout, transaksi backend, dan detail pesanan dengan diskon aktif/nonaktif.
- Edit harga/opsi pada backend staging ketika keranjang masih terbuka; pastikan pengguna diminta meninjau ulang.
- Periksa tampilan Android/iOS dan web serta jaringan gagal saat refresh.
- Tentukan versionCode berikutnya berdasarkan rilis Play Console sebelum membuat AAB. Nomor versi dan signing belum diubah dalam pekerjaan ini.

Build AAB dan uji perangkat terhadap backend staging belum dilakukan. Berat per varian tetap pekerjaan terpisah; aplikasi masih menggunakan berat produk dari backend. Tidak ada perubahan pada backend maupun aplikasi kurir pada tahap mobile ini.
