// Mengimpor package-package yang diperlukan untuk aplikasi
import 'package:flutter/material.dart'; // Package utama Flutter untuk membangun UI dan komponen material design
import 'package:shared_preferences/shared_preferences.dart'; // Package untuk menyimpan data sederhana secara lokal menggunakan key-value pairs
import 'package:http/http.dart' as http; // Package untuk melakukan HTTP requests ke server, dialiaskan sebagai 'http'
import 'dart:convert'; // Library untuk encoding dan decoding data JSON, diperlukan untuk komunikasi dengan API
import 'dashboard_page.dart'; // Mengimpor file yang berisi widget DashboardPage untuk navigasi setelah login
import 'register_page.dart'; // Mengimpor file yang berisi widget RegisterPage untuk navigasi ke halaman registrasi

// Mendefinisikan widget LoginPage sebagai StatefulWidget karena akan memiliki state yang bisa berubah
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState(); // Membuat instance dari state LoginPage
}

// Kelas state untuk LoginPage yang berisi logika dan UI
class _LoginPageState extends State<LoginPage> {
  // Controller untuk mengelola dan mengakses input teks username
  final _usernameController = TextEditingController();
  // Controller untuk mengelola dan mengakses input teks password
  final _passwordController = TextEditingController();

  // Fungsi asynchronous untuk melakukan proses login
  Future<void> _login() async {
    // Melakukan HTTP POST request ke endpoint login API
    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/login.php'), // URL endpoint API login
      // Mengubah data login menjadi format JSON untuk dikirim ke server
      body: json.encode({
        'username': _usernameController.text, // Mengambil teks dari controller username
        'password': _passwordController.text, // Mengambil teks dari controller password
      }),
      headers: {"Content-Type": "application/json"}, // Menentukan tipe konten sebagai JSON dalam header request
    );

    // Memeriksa status code response dari server
    if (response.statusCode == 200) { // Jika response sukses (status code 200)
      final data = json.decode(response.body); // Mendecode response body JSON dari server menjadi Map
      if (data['success']) { // Jika login berhasil (server mengembalikan success: true)
        // Inisialisasi SharedPreferences untuk menyimpan data login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Menyimpan data pengguna yang diterima dari server ke penyimpanan lokal
        await prefs.setString('token', data['token']); // Menyimpan token autentikasi
        await prefs.setString('username', data['username']); // Menyimpan username
        await prefs.setInt('user_id', data['user_id']); // Menyimpan ID pengguna
        await prefs.setInt('user_level', data['user_level']); // Menyimpan level akses pengguna

        // Menampilkan dialog selamat datang setelah login berhasil
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog( // Membuat pesan yang tampil dalam dialog alert
              title: Text('Selamat Datang'), // Judul pesan dialog
              content: Text('Selamat datang, ${data['username']}!'), // Isi pesan dialog dengan nama pengguna
              actions: <Widget>[
                TextButton( // Tombol OK pada dialog
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Menutup dialog
                    // Navigasi ke halaman dashboard dan menggantikan halaman login di stack navigasi
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardPage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else { // Jika login gagal (server mengembalikan success: false)
        // Menampilkan pesan error menggunakan SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal. ${data['message']}')), // Menampilkan pesan error dari server
        );
      }
    } else { // Jika terjadi error pada request (status code bukan 200)
      // Menampilkan pesan error umum menggunakan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal. Silakan coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) { // Metode untuk membangun UI halaman login
    return Scaffold( // Widget utama yang menyediakan struktur dasar visual untuk halaman material design
      appBar: AppBar( // Bar atas aplikasi
        title: Text('Login - VotingIn'), // Judul yang ditampilkan di AppBar
        backgroundColor: Colors.indigo[200], // Warna latar belakang AppBar
      ),
      backgroundColor: Colors.grey[50], // Warna latar belakang halaman
      body: Container( // Kontainer utama untuk konten halaman
        padding: EdgeInsets.all(16.0), // Padding di sekeliling konten sebesar 16 logical pixels
        child: Column( // Kolom untuk menyusun widget-widget secara vertikal
          mainAxisAlignment: MainAxisAlignment.center, // Perataan tengah secara vertikal
          children: [
            Image.asset('assets/logo.png', height: 100), // Menampilkan logo aplikasi dari assets
            SizedBox(height: 20), // Memberikan jarak vertikal sebesar 20 logical pixels
            TextField( // Input field untuk username
              controller: _usernameController, // Menggunakan controller yang telah didefinisikan
              decoration: InputDecoration(labelText: 'Username'), // Label untuk field username
            ),
            TextField( // Input field untuk password
              controller: _passwordController, // Menggunakan controller yang telah didefinisikan
              decoration: InputDecoration(labelText: 'Password'), // Label untuk field password
              obscureText: true, // Menyembunyikan teks password
            ),
            SizedBox(height: 20), // Memberikan jarak vertikal sebesar 20 logical pixels
            ElevatedButton( // Tombol untuk melakukan login
              onPressed: _login, // Memanggil fungsi _login saat tombol ditekan
              child: Text('Login'), // Teks yang ditampilkan pada tombol
            ),
            SizedBox(height: 20), // Memberikan jarak vertikal sebesar 20 logical pixels
            GestureDetector( // Widget yang dapat menerima gesture (sentuhan)
              onTap: () { // Fungsi yang dipanggil saat widget di-tap
                // Navigasi ke halaman registrasi
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text( // Teks yang berfungsi sebagai link ke halaman registrasi
                "Belum punya akun? Register",
                style: TextStyle(
                  color: Colors.indigo, // Warna teks
                  decoration: TextDecoration.underline, // Menambahkan garis bawah pada teks
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}