// Mengimpor package Flutter untuk membangun UI dan menggunakan widget material design
import 'package:flutter/material.dart';
// Mengimpor package http untuk melakukan request HTTP ke server, dialiaskan sebagai 'http'
import 'package:http/http.dart' as http;
// Mengimpor library dart:convert untuk mengonversi data antara format JSON dan Dart objects
import 'dart:convert';

// Mendefinisikan widget RegisterPage sebagai StatefulWidget karena akan memiliki state yang berubah
class RegisterPage extends StatefulWidget {
  @override
  // Membuat state untuk RegisterPage, dipanggil oleh framework Flutter
  _RegisterPageState createState() => _RegisterPageState();
}

// Kelas state untuk RegisterPage, berisi logika dan UI untuk halaman registrasi
class _RegisterPageState extends State<RegisterPage> {
  // Controller untuk mengelola dan mengakses input teks username
  final _usernameController = TextEditingController();
  // Controller untuk mengelola dan mengakses input teks password
  final _passwordController = TextEditingController();
  // Controller untuk mengelola dan mengakses input teks email
  final _emailController = TextEditingController();
  // Controller untuk mengelola dan mengakses input teks nama lengkap
  final _fullNameController = TextEditingController();

  // Fungsi untuk memvalidasi format email menggunakan regular expression
  bool isValidEmail(String email) {
    // Pola regex sederhana untuk validasi email
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    // Membuat objek RegExp dari pola untuk melakukan pencocokan
    RegExp regex = new RegExp(pattern.toString());
    // Mengembalikan true jika email cocok dengan pola, false jika tidak
    return regex.hasMatch(email);
  }

  // Fungsi asynchronous untuk melakukan proses registrasi
  Future<void> _register() async {
    // Validasi email sebelum mengirim request ke server
    if (!isValidEmail(_emailController.text)) {
      // Menampilkan pesan error menggunakan SnackBar jika email tidak valid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email tidak valid. Pastikan format email benar.')),
      );
      return; // Menghentikan eksekusi fungsi jika email tidak valid
    }

    // Melakukan HTTP POST request ke endpoint registrasi API
    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/register.php'),
      // Mengonversi data registrasi ke format JSON untuk dikirim ke server
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'email': _emailController.text,
        'full_name': _fullNameController.text,
      }),
      // Menentukan tipe konten sebagai JSON dalam header request
      headers: {"Content-Type": "application/json"},
    );

    // Memeriksa status code response dari server
    if (response.statusCode == 200) {
      // Mendecode response body JSON dari server menjadi Map
      final data = json.decode(response.body);
      if (data['success']) {
        // Menampilkan pesan sukses menggunakan SnackBar jika registrasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi berhasil. Silakan login.')),
        );
        // Kembali ke halaman sebelumnya (login) setelah registrasi berhasil
        Navigator.pop(context);
      } else {
        // Menampilkan pesan error dari server menggunakan SnackBar jika registrasi gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi gagal. ${data['message']}')),
        );
      }
    } else {
      // Menampilkan pesan error umum menggunakan SnackBar jika terjadi kesalahan pada request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi gagal. Silakan coba lagi.')),
      );
    }
  }

  @override
  // Metode build untuk membangun UI halaman registrasi
  Widget build(BuildContext context) {
    return Scaffold(
      // Membuat app bar dengan judul dan warna latar belakang
      appBar: AppBar(
        title: Text('Register - VotingIn'),
        backgroundColor: Colors.indigo[200], // Warna latar belakang app bar
      ),
      // Mengatur warna latar belakang halaman
      backgroundColor: Colors.grey[50],
      // Menggunakan SingleChildScrollView agar konten dapat di-scroll jika melebihi layar
      body: SingleChildScrollView(
        child: Padding(
          // Memberikan padding pada seluruh sisi, termasuk bottom padding untuk mengakomodasi keyboard
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 16.0 + MediaQuery.of(context).viewInsets.bottom,
          ),
          // Menggunakan Column untuk menyusun widget-widget secara vertikal
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Perataan vertikal di tengah
            children: [
              // Menampilkan logo aplikasi dari asset
              Image.asset('assets/logo.png', height: 100),
              SizedBox(height: 20), // Memberikan jarak vertikal
              // TextField untuk input username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              // TextField untuk input password
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true, // Menyembunyikan teks password
              ),
              // TextField untuk input email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress, // Menampilkan keyboard khusus email
              ),
              // TextField untuk input nama lengkap
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              SizedBox(height: 20), // Memberikan jarak vertikal
              // Tombol untuk melakukan registrasi
              ElevatedButton(
                onPressed: _register, // Memanggil fungsi _register saat tombol ditekan
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}