import 'package:flutter/material.dart'; // Mengimpor package Flutter untuk membuat UI
import 'dart:convert'; // Mengimpor package untuk encoding dan decoding JSON
import 'package:http/http.dart' as http; // Mengimpor package untuk melakukan HTTP requests

class ManageElectionsPage extends StatefulWidget { // Mendefinisikan widget halaman manajemen pemilihan
  @override
  _ManageElectionsPageState createState() => _ManageElectionsPageState(); // Membuat state untuk halaman manajemen pemilihan
}

class _ManageElectionsPageState extends State<ManageElectionsPage> { // State untuk halaman manajemen pemilihan
  List<Map<String, dynamic>> elections = []; // List untuk menyimpan data pemilihan

  @override
  void initState() { // Metode yang dipanggil saat widget pertama kali dibuat
    super.initState(); // Memanggil initState dari superclass
    _fetchElections(); // Memanggil fungsi untuk mengambil data pemilihan
  }

  Future<void> _fetchElections() async { // Fungsi untuk mengambil data pemilihan dari API
    final response = await http.get(Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/elections/get_elections.php')); // Melakukan GET request ke API
    if (response.statusCode == 200) { // Jika response sukses
      final data = json.decode(response.body); // Mendecode response JSON
      setState(() { // Memperbarui state
        elections = List<Map<String, dynamic>>.from(data['elections']); // Menyimpan data pemilihan ke dalam list
      });
    }
  }

  Future<void> _addElection() async { // Fungsi untuk menambahkan pemilihan baru
    final result = await showDialog( // Menampilkan dialog untuk input data pemilihan
      context: context,
      builder: (context) => _ElectionDialog(), // Menggunakan widget _ElectionDialog untuk form input
    );

    if (result != null) { // Jika hasil dialog tidak null (user menekan tombol Simpan)
      try {
        print("Sending data to API: ${json.encode(result)}"); // Mencetak data yang akan dikirim ke API untuk debugging
        final response = await http.post( // Melakukan POST request ke API untuk menambahkan pemilihan
          Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/elections/add_election.php'),
          headers: {"Content-Type": "application/json"}, // Menentukan header request sebagai JSON
          body: json.encode(result), // Mengubah data menjadi JSON string
        );

        print("API Response Status Code: ${response.statusCode}"); // Mencetak status code response untuk debugging
        print("API Response Body: ${response.body}"); // Mencetak body response untuk debugging

        if (response.statusCode == 200) { // Jika response sukses
          final responseData = json.decode(response.body); // Mendecode response JSON
          if (responseData['success']) { // Jika penambahan pemilihan berhasil
            ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar sukses
              SnackBar(content: Text("Pemilihan berhasil ditambahkan")),
            );
            _fetchElections(); // Memperbarui daftar pemilihan
          } else { // Jika penambahan pemilihan gagal
            ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar error
              SnackBar(content: Text("Gagal: ${responseData['message']}")),
            );
          }
        } else { // Jika response tidak sukses
          ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar error
            SnackBar(content: Text("Error: Status code ${response.statusCode}")),
          );
        }
      } catch (e) { // Menangkap error yang mungkin terjadi
        print("Error: $e"); // Mencetak error untuk debugging
        ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar error
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }

  Future<void> _editElection(Map<String, dynamic> election) async { // Fungsi untuk mengedit pemilihan
    final result = await showDialog( // Menampilkan dialog untuk edit data pemilihan
      context: context,
      builder: (context) => _ElectionDialog(election: election), // Menggunakan widget _ElectionDialog dengan data pemilihan yang akan diedit
    );

    if (result != null) { // Jika hasil dialog tidak null (user menekan tombol Simpan)
      // Update election in API
      final response = await http.post( // Melakukan POST request ke API untuk mengupdate pemilihan
        Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/elections/update_election.php'),
        body: json.encode(result), // Mengubah data menjadi JSON string
      );

      if (response.statusCode == 200) { // Jika response sukses
        _fetchElections(); // Memperbarui daftar pemilihan
      }
    }
  }

  Future<void> _deleteElection(int id) async { // Fungsi untuk menghapus pemilihan
    final response = await http.post( // Melakukan POST request ke API untuk menghapus pemilihan
      Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/elections/delete_election.php'),
      body: json.encode({'id': id}), // Mengirim ID pemilihan yang akan dihapus sebagai JSON
    );

    if (response.statusCode == 200) { // Jika response sukses
      _fetchElections(); // Memperbarui daftar pemilihan
    }
  }

  @override
  Widget build(BuildContext context) { // Membangun UI halaman
    return Scaffold( // Menggunakan widget Scaffold sebagai struktur dasar halaman
      appBar: AppBar(title: Text('Mengelola Pemilihan')), // Menambahkan AppBar dengan judul
      body: ListView.builder( // Menggunakan ListView.builder untuk menampilkan daftar pemilihan
        itemCount: elections.length, // Jumlah item adalah jumlah pemilihan
        itemBuilder: (context, index) { // Builder untuk setiap item
          return ListTile( // Menggunakan ListTile untuk setiap pemilihan
            title: Text(elections[index]['title']), // Menampilkan judul pemilihan
            subtitle: Text('${elections[index]['start_date']} - ${elections[index]['end_date']}'), // Menampilkan tanggal mulai dan selesai
            trailing: Row( // Menambahkan tombol aksi di bagian trailing
              mainAxisSize: MainAxisSize.min, // Mengatur ukuran row menjadi minimal
              children: [
                IconButton( // Tombol untuk mengedit pemilihan
                  icon: Icon(Icons.edit), // Ikon edit
                  onPressed: () => _editElection(elections[index]), // Memanggil fungsi _editElection saat ditekan
                ),
                IconButton( // Tombol untuk menghapus pemilihan
                  icon: Icon(Icons.delete), // Ikon delete
                  onPressed: () => _deleteElection(elections[index]['id']), // Memanggil fungsi _deleteElection saat ditekan
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton( // Menambahkan Floating Action Button untuk menambah pemilihan
        onPressed: _addElection, // Memanggil fungsi _addElection saat ditekan
        child: Icon(Icons.add), // Menggunakan ikon tambah
      ),
    );
  }
}

class _ElectionDialog extends StatefulWidget { // Widget dialog untuk menambah/mengedit pemilihan
  final Map<String, dynamic>? election; // Data pemilihan yang akan diedit (opsional)

  _ElectionDialog({this.election}); // Konstruktor

  @override
  __ElectionDialogState createState() => __ElectionDialogState(); // Membuat state untuk dialog
}

class __ElectionDialogState extends State<_ElectionDialog> { // State untuk dialog pemilihan
  final _formKey = GlobalKey<FormState>(); // Key untuk form
  late TextEditingController _titleController; // Controller untuk input judul
  late TextEditingController _descriptionController; // Controller untuk input deskripsi
  late TextEditingController _startDateController; // Controller untuk input tanggal mulai
  late TextEditingController _endDateController; // Controller untuk input tanggal selesai

  @override
  void initState() { // Metode yang dipanggil saat widget pertama kali dibuat
    super.initState(); // Memanggil initState dari superclass
    _titleController = TextEditingController(text: widget.election?['title'] ?? ''); // Inisialisasi controller judul
    _descriptionController = TextEditingController(text: widget.election?['description'] ?? ''); // Inisialisasi controller deskripsi
    _startDateController = TextEditingController(text: widget.election?['start_date'] ?? ''); // Inisialisasi controller tanggal mulai
    _endDateController = TextEditingController(text: widget.election?['end_date'] ?? ''); // Inisialisasi controller tanggal selesai
  }

  @override
  Widget build(BuildContext context) { // Membangun UI dialog
    return AlertDialog( // Menggunakan AlertDialog sebagai container utama
      title: Text(widget.election == null ? 'Tambah Pemilihan' : 'Edit Pemilihan'), // Judul dialog
      content: Form( // Form untuk input data
        key: _formKey, // Menggunakan _formKey sebagai key form
        child: Column( // Kolom untuk menyusun input fields
          mainAxisSize: MainAxisSize.min, // Mengatur ukuran kolom menjadi minimal
          children: [
            TextFormField( // Input field untuk judul
              controller: _titleController, // Menggunakan controller judul
              decoration: InputDecoration(labelText: 'Judul'), // Label untuk field
              validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null, // Validasi input
            ),
            TextFormField( // Input field untuk deskripsi
              controller: _descriptionController, // Menggunakan controller deskripsi
              decoration: InputDecoration(labelText: 'Deskripsi'), // Label untuk field
            ),
            TextFormField( // Input field untuk tanggal mulai
              controller: _startDateController, // Menggunakan controller tanggal mulai
              decoration: InputDecoration(labelText: 'Tanggal Mulai (YYYY-MM-DD)'), // Label untuk field
              validator: (value) => value!.isEmpty ? 'Tanggal mulai tidak boleh kosong' : null, // Validasi input
            ),
            TextFormField( // Input field untuk tanggal selesai
              controller: _endDateController, // Menggunakan controller tanggal selesai
              decoration: InputDecoration(labelText: 'Tanggal Selesai (YYYY-MM-DD)'), // Label untuk field
              validator: (value) => value!.isEmpty ? 'Tanggal selesai tidak boleh kosong' : null, // Validasi input
            ),
          ],
        ),
      ),
      actions: [ // Tombol-tombol aksi dialog
        TextButton( // Tombol Batal
          child: Text('Batal'),
          onPressed: () => Navigator.of(context).pop(), // Menutup dialog tanpa menyimpan
        ),
        ElevatedButton( // Tombol Simpan
          child: Text('Simpan'),
          onPressed: () {
            if (_formKey.currentState!.validate()) { // Validasi form
              Navigator.of(context).pop({ // Menutup dialog dan mengembalikan data pemilihan
                'id': widget.election?['id'], // ID pemilihan (jika mengedit)
                'title': _titleController.text, // Judul pemilihan
                'description': _descriptionController.text, // Deskripsi pemilihan
                'start_date': _startDateController.text, // Tanggal mulai pemilihan
                'end_date': _endDateController.text, // Tanggal selesai pemilihan
              });
            }
          },
        ),
      ],
    );
  }
}