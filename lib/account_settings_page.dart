import 'package:flutter/material.dart'; // Mengimpor paket Flutter Material untuk komponen UI.
import 'package:http/http.dart' as http; // Mengimpor paket HTTP untuk membuat permintaan jaringan.
import 'dart:convert'; // Mengimpor paket Dart convert untuk encoding dan decoding JSON.
import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor paket Shared Preferences untuk menyimpan dan mengambil data secara lokal.

class AccountSettingsPage extends StatefulWidget { // Mendefinisikan widget stateful untuk halaman pengaturan akun.
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState(); // Membuat state untuk halaman pengaturan akun.
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>(); // Membuat kunci global untuk form.
  final _currentPasswordController = TextEditingController(); // Controller untuk input password saat ini.
  final _newPasswordController = TextEditingController(); // Controller untuk input password baru.
  final _confirmPasswordController = TextEditingController(); // Controller untuk input konfirmasi password baru.

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) { // Memvalidasi form.
      SharedPreferences prefs = await SharedPreferences.getInstance(); // Mendapatkan instance dari shared preferences.
      int? userId = prefs.getInt('user_id'); // Mengambil ID pengguna dari shared preferences.
      String? token = prefs.getString('token'); // Mengambil token dari shared preferences.

      final response = await http.post( // Membuat permintaan POST untuk mengubah password.
        Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/change_password.php'), // URL endpoint untuk mengubah password.
        headers: {
          "Content-Type": "application/json", // Menentukan tipe konten sebagai JSON.
          "Authorization": "Bearer $token", // Menambahkan token ke header permintaan.
        },
        body: json.encode({ // Mengubah data menjadi format JSON.
          'user_id': userId, // Menyertakan ID pengguna.
          'current_password': _currentPasswordController.text, // Menyertakan password saat ini.
          'new_password': _newPasswordController.text, // Menyertakan password baru.
        }),
      );

      if (response.statusCode == 200) { // Jika permintaan berhasil,
        final data = json.decode(response.body); // Mendecode respons JSON.
        if (data['success']) { // Jika perubahan password berhasil,
          ScaffoldMessenger.of(context).showSnackBar( // Menampilkan pesan sukses.
            SnackBar(content: Text('Password berhasil diubah')),
          );
          Navigator.pop(context); // Kembali ke halaman sebelumnya.
        } else { // Jika terjadi kesalahan,
          ScaffoldMessenger.of(context).showSnackBar( // Menampilkan pesan kesalahan.
            SnackBar(content: Text(data['message'])),
          );
        }
      } else { // Jika terjadi kesalahan jaringan,
        ScaffoldMessenger.of(context).showSnackBar( // Menampilkan pesan kesalahan.
          SnackBar(content: Text('Gagal mengubah password. Silakan coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengaturan Akun')), // Mengatur judul app bar.
      body: Padding(
        padding: EdgeInsets.all(16.0), // Mengatur padding untuk konten.
        child: Form(
          key: _formKey, // Mengatur kunci form.
          child: Column(
            children: [
              TextFormField( // Input field untuk password saat ini.
                controller: _currentPasswordController, // Menggunakan controller untuk password saat ini.
                decoration: InputDecoration(labelText: 'Password Saat Ini'), // Label untuk field input.
                obscureText: true, // Menyembunyikan teks input.
                validator: (value) { // Validasi input.
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan password saat ini';
                  }
                  return null;
                },
              ),
              TextFormField( // Input field untuk password baru.
                controller: _newPasswordController, // Menggunakan controller untuk password baru.
                decoration: InputDecoration(labelText: 'Password Baru'), // Label untuk field input.
                obscureText: true, // Menyembunyikan teks input.
                validator: (value) { // Validasi input.
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan password baru';
                  }
                  return null;
                },
              ),
              TextFormField( // Input field untuk konfirmasi password baru.
                controller: _confirmPasswordController, // Menggunakan controller untuk konfirmasi password baru.
                decoration: InputDecoration(labelText: 'Konfirmasi Password Baru'), // Label untuk field input.
                obscureText: true, // Menyembunyikan teks input.
                validator: (value) { // Validasi input.
                  if (value == null || value.isEmpty) {
                    return 'Mohon konfirmasi password baru';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Memberikan jarak vertikal.
              ElevatedButton( // Tombol untuk mengubah password.
                onPressed: _changePassword, // Memanggil fungsi _changePassword saat tombol ditekan.
                child: Text('Ubah Password'), // Teks pada tombol.
              ),
            ],
          ),
        ),
      ),
    );
  }
}