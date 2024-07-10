import 'package:flutter/material.dart'; // Mengimpor package Flutter untuk membuat UI
import 'dart:convert'; // Mengimpor package untuk encoding dan decoding JSON
import 'package:http/http.dart' as http; // Mengimpor package untuk melakukan HTTP requests

class ManageCandidatesPage extends StatefulWidget { // Mendefinisikan widget halaman manajemen kandidat
  @override
  _ManageCandidatesPageState createState() => _ManageCandidatesPageState(); // Membuat state untuk halaman manajemen kandidat
}

class _ManageCandidatesPageState extends State<ManageCandidatesPage> { // State untuk halaman manajemen kandidat
  List<Map<String, dynamic>> candidates = []; // List untuk menyimpan data kandidat
  List<Map<String, dynamic>> elections = []; // List untuk menyimpan data pemilihan

  @override
  void initState() { // Metode yang dipanggil saat widget pertama kali dibuat
    super.initState(); // Memanggil initState dari superclass
    _fetchCandidates(); // Memanggil fungsi untuk mengambil data kandidat
    _fetchElections(); // Memanggil fungsi untuk mengambil data pemilihan
  }

  Future<void> _fetchCandidates() async { // Fungsi untuk mengambil data kandidat dari API
    try {
      final response = await http.get(Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/candidates/get_candidates.php')); // Melakukan GET request ke API
      if (response.statusCode == 200) { // Jika response sukses
        final data = json.decode(response.body); // Mendecode response JSON
        if (data['success'] == true && data['candidates'] is List) { // Jika data valid
          setState(() { // Memperbarui state
            candidates = List<Map<String, dynamic>>.from(data['candidates']); // Menyimpan data kandidat ke dalam list
          });
        } else {
          print('Invalid response format or no candidates: ${response.body}'); // Mencetak pesan error jika format respons tidak valid
          setState(() {
            candidates = []; // Mengosongkan list kandidat
          });
        }
      } else {
        print('Failed to fetch candidates. Status code: ${response.statusCode}'); // Mencetak pesan error jika gagal mengambil data
        setState(() {
          candidates = []; // Mengosongkan list kandidat
        });
      }
    } catch (e) {
      print('Error fetching candidates: $e'); // Mencetak pesan error jika terjadi exception
      setState(() {
        candidates = []; // Mengosongkan list kandidat
      });
    }
  }

  Future<void> _fetchElections() async { // Fungsi untuk mengambil data pemilihan dari API
    try {
      final response = await http.get(Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/elections/get_elections_for_dropdown.php')); // Melakukan GET request ke API
      if (response.statusCode == 200) { // Jika response sukses
        final data = json.decode(response.body); // Mendecode response JSON
        if (data['success'] == true && data['elections'] is List) { // Jika data valid
          setState(() { // Memperbarui state
            elections = List<Map<String, dynamic>>.from(data['elections']); // Menyimpan data pemilihan ke dalam list
          });
        } else {
          print('Invalid elections response format: ${response.body}'); // Mencetak pesan error jika format respons tidak valid
          setState(() {
            elections = []; // Mengosongkan list pemilihan
          });
        }
      } else {
        print('Failed to fetch elections. Status code: ${response.statusCode}'); // Mencetak pesan error jika gagal mengambil data
        setState(() {
          elections = []; // Mengosongkan list pemilihan
        });
      }
    } catch (e) {
      print('Error fetching elections: $e'); // Mencetak pesan error jika terjadi exception
      setState(() {
        elections = []; // Mengosongkan list pemilihan
      });
    }
  }

  String getElectionTitle(int electionId) { // Fungsi untuk mendapatkan judul pemilihan berdasarkan ID
    if (elections.isEmpty) { // Jika list pemilihan kosong
      return 'Loading...'; // Mengembalikan teks 'Loading...'
    }
    var election = elections.firstWhere( // Mencari pemilihan dengan ID yang sesuai
          (e) => e['id'] == electionId.toString(),
      orElse: () => <String, dynamic>{}, // Jika tidak ditemukan, mengembalikan map kosong
    );
    return '${election['id']}: ${election['title']}'; // Mengembalikan string berisi ID dan judul pemilihan
  }

  Future<void> _addCandidate() async { // Fungsi untuk menambahkan kandidat baru
    final result = await showDialog( // Menampilkan dialog untuk input data kandidat
      context: context,
      builder: (context) => _CandidateDialog(elections: elections), // Menggunakan widget _CandidateDialog
    );
    if (result != null) { // Jika hasil dialog tidak null (user menekan tombol Simpan)
      final response = await http.post( // Melakukan POST request ke API untuk menambahkan kandidat
        Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/candidates/add_candidate.php'),
        headers: {"Content-Type": "application/json"}, // Menentukan header request
        body: json.encode(result), // Mengubah data menjadi JSON
      );
      if (response.statusCode == 200) { // Jika response sukses
        final responseData = json.decode(response.body); // Mendecode response JSON
        if (responseData['success']) { // Jika penambahan kandidat berhasil
          _fetchCandidates(); // Memperbarui daftar kandidat
          ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar sukses
            SnackBar(content: Text('Kandidat berhasil ditambahkan')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar error
            SnackBar(content: Text(responseData['message'])),
          );
        }
      }
    }
  }

  Future<void> _editCandidate(Map<String, dynamic> candidate) async { // Fungsi untuk mengedit kandidat
    final result = await showDialog( // Menampilkan dialog untuk edit data kandidat
      context: context,
      builder: (context) => _CandidateDialog( // Menggunakan widget _CandidateDialog
        candidate: candidate,
        elections: elections,
      ),
    );
    if (result != null) { // Jika hasil dialog tidak null (user menekan tombol Simpan)
      final response = await http.post( // Melakukan POST request ke API untuk mengupdate kandidat
        Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/candidates/update_candidate.php'),
        headers: {"Content-Type": "application/json"}, // Menentukan header request
        body: json.encode(result), // Mengubah data menjadi JSON
      );
      if (response.statusCode == 200) { // Jika response sukses
        final responseData = json.decode(response.body); // Mendecode response JSON
        if (responseData['success']) { // Jika update kandidat berhasil
          _fetchCandidates(); // Memperbarui daftar kandidat
          ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar sukses
            SnackBar(content: Text('Kandidat berhasil diperbarui')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar error
            SnackBar(content: Text(responseData['message'])),
          );
        }
      }
    }
  }

  Future<void> _deleteCandidate(int id) async { // Fungsi untuk menghapus kandidat
    final confirm = await showDialog( // Menampilkan dialog konfirmasi
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menghapus kandidat ini?'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.of(context).pop(false), // Menutup dialog tanpa menghapus
          ),
          ElevatedButton(
            child: Text('Hapus'),
            onPressed: () => Navigator.of(context).pop(true), // Menutup dialog dan konfirmasi penghapusan
          ),
        ],
      ),
    );

    if (confirm == true) { // Jika user mengkonfirmasi penghapusan
      final response = await http.post( // Melakukan POST request ke API untuk menghapus kandidat
        Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/candidates/delete_candidate.php'),
        headers: {"Content-Type": "application/json"}, // Menentukan header request
        body: json.encode({'id': id}), // Mengirim ID kandidat yang akan dihapus
      );
      if (response.statusCode == 200) { // Jika response sukses
        final responseData = json.decode(response.body); // Mendecode response JSON
        if (responseData['success']) { // Jika penghapusan kandidat berhasil
          _fetchCandidates(); // Memperbarui daftar kandidat
          ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar sukses
            SnackBar(content: Text('Kandidat berhasil dihapus')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar( // Menampilkan snackbar error
            SnackBar(content: Text(responseData['message'])),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) { // Membangun UI halaman
    return Scaffold( // Menggunakan widget Scaffold sebagai struktur dasar halaman
      appBar: AppBar(title: Text('Mengelola Kandidat')), // Menambahkan AppBar dengan judul
      body: candidates.isEmpty // Jika tidak ada kandidat
          ? Center(child: Text('Belum ada kandidat atau gagal memuat data')) // Menampilkan pesan jika tidak ada kandidat
          : ListView.builder( // Menggunakan ListView.builder untuk menampilkan daftar kandidat
        itemCount: candidates.length, // Jumlah item adalah jumlah kandidat
        itemBuilder: (context, index) { // Builder untuk setiap item
          final candidate = candidates[index]; // Mengambil data kandidat
          return Card( // Menggunakan Card untuk setiap kandidat
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile( // Menampilkan informasi utama kandidat
                  leading: CircleAvatar( // Menampilkan gambar kandidat
                    backgroundImage: NetworkImage(candidate['image_url'] ?? ''),
                  ),
                  title: Text(candidate['name']), // Menampilkan nama kandidat
                  subtitle: Text(getElectionTitle(candidate['election_id'])), // Menampilkan judul pemilihan
                ),
                Padding( // Menampilkan deskripsi kandidat
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(candidate['description'] ?? ''),
                ),
                ButtonBar( // Menambahkan tombol aksi
                  children: [
                    TextButton(
                      child: Text('Edit'),
                      onPressed: () => _editCandidate(candidate), // Memanggil fungsi edit kandidat
                    ),
                    TextButton(
                      child: Text('Hapus'),
                      onPressed: () => _deleteCandidate(candidate['id']), // Memanggil fungsi hapus kandidat
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton( // Menambahkan Floating Action Button untuk menambah kandidat
        onPressed: _addCandidate, // Memanggil fungsi tambah kandidat saat ditekan
        child: Icon(Icons.add), // Menggunakan ikon tambah
      ),
    );
  }
}

class _CandidateDialog extends StatefulWidget { // Widget dialog untuk menambah/mengedit kandidat
  final Map<String, dynamic>? candidate; // Data kandidat yang akan diedit (opsional)
  final List<Map<String, dynamic>> elections; // Daftar pemilihan untuk dropdown

  _CandidateDialog({this.candidate, required this.elections}); // Konstruktor

  @override
  __CandidateDialogState createState() => __CandidateDialogState(); // Membuat state untuk dialog
}

class __CandidateDialogState extends State<_CandidateDialog> { // State untuk dialog kandidat
  final _formKey = GlobalKey<FormState>(); // Key untuk form
  late TextEditingController _nameController; // Controller untuk input nama
  late TextEditingController _descriptionController; // Controller untuk input deskripsi
  late TextEditingController _imageUrlController; // Controller untuk input URL gambar
  int? _selectedElectionId; // ID pemilihan yang dipilih

  @override
  void initState() { // Metode yang dipanggil saat widget pertama kali dibuat
    super.initState(); // Memanggil initState dari superclass
    _nameController = TextEditingController(text: widget.candidate?['name'] ?? ''); // Inisialisasi controller nama
    _descriptionController = TextEditingController(text: widget.candidate?['description'] ?? ''); // Inisialisasi controller deskripsi
    _imageUrlController = TextEditingController(text: widget.candidate?['image_url'] ?? ''); // Inisialisasi controller URL gambar
    _selectedElectionId = widget.candidate != null // Inisialisasi ID pemilihan yang dipilih
        ? int.tryParse(widget.candidate!['election_id'].toString())
        : null;
  }

  @override
  Widget build(BuildContext context) { // Membangun UI dialog
    return AlertDialog( // Menggunakan AlertDialog sebagai container utama
      title: Text(widget.candidate == null ? 'Tambah Kandidat' : 'Edit Kandidat'), // Judul dialog
      content: Form( // Form untuk input data
        key: _formKey, // Menggunakan _formKey sebagai key form
        child: SingleChildScrollView( // Menggunakan SingleChildScrollView agar konten dapat di-scroll
          child: Column( // Kolom untuk menyusun input fields
            mainAxisSize: MainAxisSize.min, // Mengatur ukuran kolom menjadi minimal
            children: [
              DropdownButtonFormField<int>( // Dropdown untuk memilih pemilihan
                value: _selectedElectionId, // Nilai yang dipilih saat ini
                items: widget.elections.map((election) { // Membuat item dropdown dari daftar pemilihan
                  return DropdownMenuItem<int>(
                    value: int.parse(election['id'].toString()), // Nilai item adalah ID pemilihan
                    child: Text(election['title']), // Teks yang ditampilkan adalah judul pemilihan
                  );
                }).toList(),
                onChanged: (value) { // Fungsi yang dipanggil saat nilai berubah
                  setState(() {
                    _selectedElectionId = value; // Memperbarui ID pemilihan yang dipilih
                  });
                },
                decoration: InputDecoration(labelText: 'Pemilihan'), // Label untuk dropdown
                validator: (value) => value == null ? 'Pilih pemilihan' : null, // Validasi input
              ),
              TextFormField( // Input field untuk nama kandidat
                controller: _nameController, // Menggunakan controller nama
                decoration: InputDecoration(labelText: 'Nama'), // Label untuk input nama
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null, // Validasi input nama
              ),
              TextFormField( // Input field untuk deskripsi kandidat
                controller: _descriptionController, // Menggunakan controller deskripsi
                decoration: InputDecoration(labelText: 'Deskripsi'), // Label untuk input deskripsi
              ),
              TextFormField( // Input field untuk URL gambar kandidat
                controller: _imageUrlController, // Menggunakan controller URL gambar
                decoration: InputDecoration(labelText: 'URL Gambar'), // Label untuk input URL gambar
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton( // Tombol untuk membatalkan input
          child: Text('Batal'),
          onPressed: () => Navigator.of(context).pop(), // Menutup dialog tanpa menyimpan data
        ),
        ElevatedButton( // Tombol untuk menyimpan data
          child: Text('Simpan'),
          onPressed: () {
            if (_formKey.currentState!.validate()) { // Validasi form
              Navigator.of(context).pop({ // Menutup dialog dan mengembalikan data kandidat
                'id': widget.candidate?['id'], // ID kandidat (jika sedang mengedit)
                'election_id': _selectedElectionId, // ID pemilihan yang dipilih
                'name': _nameController.text, // Nama kandidat
                'description': _descriptionController.text, // Deskripsi kandidat
                'image_url': _imageUrlController.text, // URL gambar kandidat
              });
            }
          },
        ),
      ],
    );
  }
}