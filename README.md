# myportofolio_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Pertanyaan Reflektif
### Tugas 7
1. Widget tree merupakan struktur hierarkis yang menggambarkan bagaimana widget disusun dan saling berhubungan dalam aplikasi Flutter. Setiap komponen antarmuka pada Flutter, seperti teks, tombol, gambar, dan layout, direpresentasikan sebagai widget yang tersusun menyerupai struktur pohon (tree).

    Dalam widget tree, terdapat hubungan parent-child, yaitu widget induk (parent) yang membungkus atau menampung widget lain sebagai anaknya (child). Parent widget dapat mengatur tata letak, ukuran, posisi, atau tampilan child widget sesuai dengan fungsi dan batasan layout yang dimilikinya.

2. Berikut adalah widget yang ada pada proyek ini.	
    - MaterialApp:Widget utama aplikasi yang mengatur tema, judul aplikasi, dan halaman awal yang ditampilkan.
    - Scaffold: Menyediakan struktur dasar halaman aplikasi, seperti AppBar dan body.
    - AppBar: Menampilkan bagian header aplikasi dengan judul "MyPortofolio".
    - Text: Menampilkan teks, seperti NPM, nama, kelas, pesan selamat datang, dan nama menu.
    - Padding: Memberikan jarak di sekitar widget agar tampilan lebih rapi dan tidak terlalu rapat.
    - Column: Menyusun beberapa widget secara vertikal, seperti teks dan menu pada halaman utama.
    - Row: Menyusun widget secara horizontal, seperti tiga kartu informasi NPM, nama, dan kelas.
    - Center: Menempatkan widget anak di tengah area yang tersedia.
    - SizedBox: Memberikan jarak vertikal antara bagian informasi pengguna dan pesan selamat datang.
    - GridView.count: Menampilkan menu aplikasi dalam bentuk grid dengan tiga kolom.
    - Card: Membuat kartu informasi pengguna dengan efek bayangan menggunakan properti elevation.
    - Container: Mengatur ukuran, padding, dan tata letak konten di dalam kartu.
    - Material: Memberikan tampilan Material Design pada kartu menu, termasuk warna latar belakang dan sudut membulat.
    - InkWell: Membuat kartu menu dapat ditekan dan memberikan efek interaksi saat disentuh.
    - Icon: Menampilkan ikon untuk setiap menu, seperti folder, tambah proyek, dan logout.
    - SnackBar: Menampilkan pesan singkat ketika pengguna menekan salah satu kartu menu.

3. MaterialApp merupakan widget yang menyediakan konfigurasi dan berbagai fasilitas utama untuk membangun aplikasi Flutter menggunakan prinsip Material Design. Fungsi MaterialApp antara lain, mengatur tema aplikasi, mengelola navigasi, menentukan halaman awal, menyediakan fasilitas material design, dan mengatur judul aplikasi.

4. StatelessWidget dan StatefulWidget merupakan dua jenis widget utama dalam Flutter yang dibedakan berdasarkan cara pengelolaan state. StatelessWidget merupakan widget yang tidak memiliki objek State internal yang bersifat mutable. Tampilan widget ini dibangun berdasarkan konfigurasi dan data yang diterima. Sementara itu, StatefulWidget merupakan widget yang memiliki objek State terpisah untuk menyimpan data yang dapat berubah selama widget digunakan. Gunakan StatelessWidget ketika widget hanya perlu menampilkan data tanpa mengelola state lokal yang berubah. Sebaliknya, gunakan StatefulWidget ketika widget perlu mengelola perubahan data, seperti jumlah barang dalam keranjang, status checkbox, atau pilihan tab.

5. BuildContext merupakan objek yang merepresentasikan lokasi suatu widget dalam struktur element tree Flutter. Objek ini memungkinkan widget mengakses informasi maupun layanan yang tersedia dari ancestor widget, yaitu widget-widget yang berada di atasnya dalam hierarki.

6. Hot reload merupakan fitur Flutter yang memungkinkan developer melihat perubahan kode secara cepat tanpa harus menjalankan ulang aplikasi dari awal. Fitur ini bekerja dengan memasukkan perubahan kode Dart ke Dart VM, kemudian memicu rebuild pada widget tree yang relevan. Sementara itu, hot restart menjalankan ulang aplikasi Flutter dari awal pada level kode Dart. Proses ini akan menghapus state aplikasi yang tersimpan di memori dan menjalankan kembali fungsi main().

### Tugas 8
1. Perbedaan antara Navigator.push(), Navigator.pushReplacement(), dan Navigaor.pop() adalah sebagai berikut.
    - Navigator.push() digunakan untuk membuka halaman baru dengan menambahkan halaman tersebut ke atas navigation stack. Halaman sebelumnya tetap tersimpan sehingga pengguna dapat kembali menggunakan tombol back.
    - Navigator.pushReplacement() digunakan untuk membuka halaman baru dengan menggantikan halaman yang sedang aktif. Halaman sebelumnya dihapus dari stack sehingga pengguna tidak dapat kembali ke halaman tersebut menggunakan tombol back.
    - Navigator.pop() digunakan untuk menutup halaman yang sedang aktif dan kembali ke halaman sebelumnya dalam navigation stack.
Sementara itu, opsi Home pada drawer membawa pengguna kembali ke halaman utama menggunaan Navigator.pushReplacement(). Dengan begitu, halaman sebelumnya digantikan oleh halaman home pada navigator stack.
2. Scaffold berfungsi sebagai kerangka utama yang menyediakan area untuk menempatkan komponen seperti AppBar, Drawer, dan body. AppBar digunakan untuk menampilkan judul halaman serta tombol navigasi, sedangkan Drawer menyediakan menu navigasi yang memungkinkan pengguna berpindah antarhalaman. Dengan menggunakan susunan tersebut, setiap halaman memiliki struktur yang seragam meskipun konten pada bagian body berbeda. Selanjutnya, contoh penggunaan warna tema portofolio di lebih dari satu halaman dapat menggunakan heme.of(context).colorScheme.primary. Dengan mengambil warna dari Theme.of(context), aplikasi dapat mempertahankan identitas visual yang konsisten tanpa perlu mendefinisikan warna secara manual pada setiap halaman.
3. Formulir menggunakan Column agar kolom input tersusun vertikal sesuai urutan pengisian. Susunan ini mudah dibaca pada layar ponsel. crossAxisAlignment: CrossAxisAlignment.start membantu meratakan isi ke sisi kiri. KKemudian, Padding memberi jarak antara kolom input dan tepi layar agar tampilan tidak berhimpitan. Widget seperti SizedBox menyediakan jarak kosong dengan ukuran tertentu. Selanjutnya, SingleChildScrollView memungkinkan seluruh formulir digulir ketika tinggi konten melebihi ruang layar, termasuk saat papan ketik terbuka. Dengan demikian, kolom bagian bawah dan tombol Save tetap dapat dijangkau.
4. GlobalKey<FormState> menghubungkan _formKey dengan state widget Form, sehingga kode tombol dapat mengakses fungsi validasi dan reset formulir. Setiap validator memeriksa nilai kolom input. Validator mengembalikan pesan kesalahan jika nilai tidak valid, atau null jika valid. Saat Save ditekan, _formKey.currentState!.validate() menjalankan seluruh validator dan mengembalikan true hanya jika semuanya lolos. Contoh nilai yang ditolak adalah nama proyek "   " yang hanya berisi spasi. Setelah trim(), nilainya menjadi kosong sehingga muncul pesan “Nama proyek tidak boleh kosong!”. Pemilihan jenis input atau papan ketik hanya membantu pengguna memasukkan data. Papan ketik tidak menjamin kolom terisi maupun nilainya sesuai aturan; pengguna juga dapat menempelkan teks. Karena itu, validasi tetap diperlukan.

# AI Disclosure
Untuk saat ini, proyek ini tidak menggunakan bantuan AI tools apa pun. Seiring berjalannya waktu, jika nantinya ada penggunaan AI tools, akan ada update dan penjelasan pada bagian ini.