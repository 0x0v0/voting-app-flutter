import 'package:flutter/material.dart'; // Mengimpor paket Flutter Material untuk komponen UI.
import 'dart:convert'; // Mengimpor paket Dart convert untuk encoding dan decoding JSON.
import 'package:http/http.dart' as http; // Mengimpor paket HTTP untuk membuat permintaan jaringan.

class ResultsPage extends StatefulWidget { // Mendefinisikan widget stateful untuk halaman hasil.
  @override
  _ResultsPageState createState() => _ResultsPageState(); // Membuat state untuk halaman hasil.
}

class _ResultsPageState extends State<ResultsPage> {
  List<Map<String, dynamic>> electionResults = []; // Daftar untuk menyimpan hasil pemilihan.

  @override
  void initState() {
    super.initState();
    _fetchElectionResults(); // Memanggil fungsi untuk mengambil hasil pemilihan saat halaman diinisialisasi.
  }

  Future<void> _fetchElectionResults() async {
    final response = await http.get(Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/get_results.php')); // Membuat permintaan GET untuk mengambil hasil pemilihan.
    if (response.statusCode == 200) { // Jika permintaan berhasil,
      final data = json.decode(response.body); // Mendecode respons JSON.
      setState(() {
        electionResults = List<Map<String, dynamic>>.from(data['results']); // Memperbarui state dengan daftar hasil pemilihan.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hasil Suara')), // Mengatur judul app bar.
      body: ListView.builder( // Membuat daftar yang dapat di-scroll.
        itemCount: electionResults.length, // Jumlah item dalam daftar.
        itemBuilder: (context, index) {
          final election = electionResults[index]; // Mendapatkan data pemilihan saat ini.
          return ExpansionTile( // Membuat tile yang dapat diperluas.
            title: Text(election['title']), // Menampilkan judul pemilihan.
            subtitle: Text('${election['start_date']} - ${election['end_date']}'), // Menampilkan tanggal mulai dan akhir pemilihan.
            children: [
              ListView.builder( // Membuat daftar kandidat yang dapat di-scroll.
                shrinkWrap: true, // Mengatur ukuran daftar sesuai dengan kontennya.
                physics: NeverScrollableScrollPhysics(), // Menonaktifkan scrolling untuk daftar ini.
                itemCount: election['candidates'].length, // Jumlah kandidat.
                itemBuilder: (context, candidateIndex) {
                  final candidate = election['candidates'][candidateIndex]; // Mendapatkan data kandidat saat ini.
                  return ExpansionTile( // Membuat tile yang dapat diperluas untuk setiap kandidat.
                    title: Text(candidate['name']), // Menampilkan nama kandidat.
                    subtitle: Text('${candidate['vote_count']} suara'), // Menampilkan jumlah suara kandidat.
                    children: [
                      ListView.builder( // Membuat daftar pemilih yang dapat di-scroll.
                        shrinkWrap: true, // Mengatur ukuran daftar sesuai dengan kontennya.
                        physics: NeverScrollableScrollPhysics(), // Menonaktifkan scrolling untuk daftar ini.
                        itemCount: candidate['voters'].length, // Jumlah pemilih.
                        itemBuilder: (context, voterIndex) {
                          final voter = candidate['voters'][voterIndex]; // Mendapatkan data pemilih saat ini.
                          return ListTile( // Membuat tile untuk setiap pemilih.
                            title: Text(voter['full_name']), // Menampilkan nama lengkap pemilih.
                            subtitle: Text('Voted at: ${voter['voted_at']}'), // Menampilkan waktu pemilihan.
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}