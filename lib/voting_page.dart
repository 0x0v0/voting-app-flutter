import 'package:flutter/material.dart'; // Mengimpor paket Flutter Material untuk komponen UI.
import 'dart:convert'; // Mengimpor paket Dart convert untuk encoding dan decoding JSON.
import 'package:http/http.dart' as http; // Mengimpor paket HTTP untuk membuat permintaan jaringan.
import 'package:shared_preferences/shared_preferences.dart'; // Mengimpor paket Shared Preferences untuk menyimpan dan mengambil data secara lokal.

class VotingPage extends StatefulWidget { // Mendefinisikan widget stateful untuk halaman voting.
  @override
  _VotingPageState createState() => _VotingPageState(); // Membuat state untuk halaman voting.
}

class _VotingPageState extends State<VotingPage> {
  List<Map<String, dynamic>> activeElections = []; // Daftar untuk menyimpan pemilihan aktif.
  int? userId; // Variabel untuk menyimpan ID pengguna.

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) => _fetchActiveElections()); // Memuat ID pengguna dan kemudian mengambil pemilihan aktif.
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Mendapatkan instance dari shared preferences.
    setState(() {
      userId = prefs.getInt('user_id'); // Mengambil ID pengguna dari shared preferences dan memperbarui state.
    });
  }

  Future<void> _fetchActiveElections() async {
    final response = await http.get(
      Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/elections/get_active_elections.php?user_id=$userId'), // Membuat permintaan GET untuk mengambil pemilihan aktif untuk pengguna.
    );
    if (response.statusCode == 200) { // Jika permintaan berhasil,
      final data = json.decode(response.body); // Mendecode respons JSON.
      setState(() {
        activeElections = List<Map<String, dynamic>>.from(data['elections']); // Memperbarui state dengan daftar pemilihan aktif.
      });
    }
  }

  void _navigateToVotingDetails(Map<String, dynamic> election) {
    bool hasVoted = election['has_voted'] == true; // Memeriksa apakah pengguna sudah melakukan voting dalam pemilihan ini.
    if (!hasVoted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VotingDetailsPage(election: election), // Navigasi ke halaman detail voting jika pengguna belum melakukan voting.
        ),
      ).then((_) => _fetchActiveElections()); // Setelah kembali dari halaman detail voting, menyegarkan daftar pemilihan aktif.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda sudah melakukan voting pada pemilihan ini')), // Menampilkan pesan jika pengguna sudah melakukan voting.
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voting')), // Mengatur judul app bar.
      body: ListView.builder(
        itemCount: activeElections.length, // Jumlah item dalam list view.
        itemBuilder: (context, index) {
          final election = activeElections[index]; // Mendapatkan pemilihan saat ini.
          bool hasVoted = election['has_voted'] == true; // Memeriksa apakah pengguna telah melakukan voting dalam pemilihan ini.
          return Card(
            margin: EdgeInsets.all(8.0), // Mengatur margin untuk card.
            child: ListTile(
              title: Text(election['title']), // Menampilkan judul pemilihan.
              subtitle: Text('${election['start_date']} - ${election['end_date']}'), // Menampilkan tanggal pemilihan.
              trailing: ElevatedButton(
                child: Text('Vote'), // Tombol untuk voting.
                onPressed: hasVoted ? null : () => _navigateToVotingDetails(election), // Jika pengguna sudah melakukan voting, nonaktifkan tombol.
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasVoted ? Colors.grey : null, // Mengatur warna tombol berdasarkan status voting.
                  disabledBackgroundColor: Colors.grey, // Mengatur warna tombol yang dinonaktifkan.
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class VotingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> election; // Detail pemilihan yang diteruskan ke halaman ini.
  VotingDetailsPage({required this.election}); // Konstruktor untuk menginisialisasi detail pemilihan.

  @override
  _VotingDetailsPageState createState() => _VotingDetailsPageState(); // Membuat state untuk halaman detail voting.
}

class _VotingDetailsPageState extends State<VotingDetailsPage> {
  List<Map<String, dynamic>> candidates = []; // Daftar untuk menyimpan kandidat.
  int? selectedCandidateId; // Variabel untuk menyimpan ID kandidat yang dipilih.

  @override
  void initState() {
    super.initState();
    _fetchCandidates(); // Mengambil kandidat saat halaman diinisialisasi.
  }

  Future<void> _fetchCandidates() async {
    final response = await http.get(
        Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/candidates/get_candidates.php?election_id=${widget.election['id']}') // Membuat permintaan GET untuk mengambil kandidat untuk pemilihan.
    );
    if (response.statusCode == 200) { // Jika permintaan berhasil,
      final data = json.decode(response.body); // Mendecode respons JSON.
      setState(() {
        candidates = List<Map<String, dynamic>>.from(data['candidates']); // Memperbarui state dengan daftar kandidat.
      });
    }
  }

  Future<void> _submitVote() async {
    if (selectedCandidateId == null) { // Jika tidak ada kandidat yang dipilih,
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silakan pilih kandidat terlebih dahulu')) // Menampilkan pesan meminta pengguna untuk memilih kandidat.
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance(); // Mendapatkan instance dari shared preferences.
    int? userId = prefs.getInt('user_id'); // Mengambil ID pengguna dari shared preferences.

    final response = await http.post(
      Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/submit_vote.php'), // Membuat permintaan POST untuk mengirimkan voting.
      body: json.encode({
        'user_id': userId,
        'election_id': widget.election['id'],
        'candidate_id': selectedCandidateId,
      }),
    );

    if (response.statusCode == 200) { // Jika permintaan berhasil,
      final data = json.decode(response.body); // Mendecode respons JSON.
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vote berhasil disubmit')) // Menampilkan pesan sukses.
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])) // Menampilkan pesan kesalahan jika pengiriman voting gagal.
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan. Silakan coba lagi.')) // Menampilkan pesan kesalahan jika terjadi kesalahan jaringan.
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.election['title'])), // Mengatur judul app bar.
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: candidates.length, // Jumlah kandidat.
              itemBuilder: (context, index) {
                final candidate = candidates[index]; // Mendapatkan kandidat saat ini.
                return RadioListTile<int>(
                  title: Text(candidate['name']), // Menampilkan nama kandidat.
                  subtitle: Text(candidate['description']), // Menampilkan deskripsi kandidat.
                  value: candidate['id'], // Mengatur nilai ke ID kandidat.
                  groupValue: selectedCandidateId, // Mengatur ID kandidat yang dipilih.
                  onChanged: (value) {
                    setState(() {
                      selectedCandidateId = value; // Memperbarui ID kandidat yang dipilih saat kandidat dipilih.
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0), // Mengatur padding untuk tombol.
            child: ElevatedButton(
              child: Text('Submit Vote'), // Tombol untuk mengirimkan voting.
              onPressed: _submitVote, // Memanggil fungsi submit vote saat tombol ditekan.
            ),
          ),
        ],
      ),
    );
  }
}