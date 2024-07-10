import 'package:flutter/material.dart'; // Mengimpor package Flutter material design
import 'login_page.dart'; // Mengimpor file login_page.dart yang berisi widget LoginPage

void main() => runApp(MyApp()); // Fungsi main yang memanggil runApp dengan instance MyApp

class MyApp extends StatelessWidget { // Mendefinisikan kelas MyApp yang merupakan StatelessWidget
  @override
  Widget build(BuildContext context) { // Override method build untuk membangun UI aplikasi
    return MaterialApp( // Mengembalikan widget MaterialApp sebagai root widget
      title: 'Sistem Voting', // Menetapkan judul aplikasi
      theme: ThemeData(primarySwatch: Colors.blue), // Mengatur tema aplikasi dengan warna utama biru
      debugShowCheckedModeBanner: false, // Menyembunyikan banner debug di pojok kanan atas
      home: LoginPage(), // Menetapkan LoginPage sebagai halaman awal aplikasi
    );
  }
}