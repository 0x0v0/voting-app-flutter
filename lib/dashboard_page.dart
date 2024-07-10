import 'package:flutter/material.dart'; // Mengimpor package Flutter untuk membuat UI.
import 'package:shared_preferences/shared_preferences.dart'; // Untuk penyimpanan data lokal.
import 'package:http/http.dart' as http; // Untuk mengirim HTTP requests.
import 'dart:convert'; // Untuk konversi JSON.
import 'dart:ui'; // Untuk fitur UI tambahan.
import 'manage_elections_page.dart'; // Mengimpor halaman manajemen pemilihan.
import 'manage_candidates_page.dart'; // Mengimpor halaman manajemen kandidat.
import 'voting_page.dart'; // Mengimpor halaman voting.
import 'results_page.dart'; // Mengimpor halaman hasil pemilihan.
import 'login_page.dart'; // Mengimpor halaman login.
import 'account_settings_page.dart'; // Mengimpor halaman pengaturan akun.

class DashboardPage extends StatefulWidget { // Deklarasi widget DashboardPage sebagai StatefulWidget.
  @override
  _DashboardPageState createState() => _DashboardPageState(); // Membuat state untuk DashboardPage.
}

class _DashboardPageState extends State<DashboardPage> { // State untuk DashboardPage.
  String username = ''; // Variabel untuk menyimpan username pengguna.
  int userLevel = 2; // Variabel untuk menyimpan level akses pengguna (default: 2).
  Map<String, dynamic> dashboardData = {}; // Variabel untuk menyimpan data dashboard.
  List<Map<String, dynamic>> allElections = []; // Variabel untuk menyimpan semua data pemilihan.
  List<Map<String, dynamic>> filteredElections = []; // Variabel untuk menyimpan data pemilihan terfilter.

  ScrollController _scrollController = ScrollController(); // Controller untuk mengatur scroll.
  Color _textColor = Colors.white; // Variabel untuk mengubah warna teks saat scroll.

  @override
  void initState() { // Inisialisasi state.
    super.initState(); // Memanggil initState dari superclass.
    _loadUserData(); // Memuat data pengguna dari penyimpanan lokal.
    _fetchDashboardData(); // Mengambil data dashboard dari server.
    _fetchElections(); // Mengambil data pemilihan dari server.
    _scrollController.addListener(_onScroll); // Menambahkan listener untuk mengatur perubahan UI saat scroll.
  }

  @override
  void dispose() { // Pembersihan resources saat widget dihancurkan.
    _scrollController.removeListener(_onScroll); // Menghapus listener scroll.
    _scrollController.dispose(); // Membuang controller scroll.
    super.dispose(); // Memanggil dispose dari superclass.
  }

  void _onScroll() { // Mengubah warna teks saat scroll berdasarkan posisi scroll.
    setState(() { // Memicu rebuild widget.
      _textColor = _scrollController.offset > 140 ? Colors.black : Colors.white; // Mengubah warna teks berdasarkan posisi scroll.
    });
  }

  Future<void> _loadUserData() async { // Memuat data pengguna dari penyimpanan lokal.
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    setState(() { // Memicu rebuild widget.
      username = prefs.getString('username') ?? ''; // Mengambil username dari SharedPreferences.
      userLevel = prefs.getInt('user_level') ?? 2; // Mengambil level pengguna dari SharedPreferences.
    });
  }

  Future<void> _fetchDashboardData() async { // Mengambil data dashboard dari server.
    try {
      final response = await http.get(Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/dashboard.php')); // Mengirim GET request ke API.
      if (response.statusCode == 200) { // Jika respons berhasil.
        final data = json.decode(response.body); // Decode JSON dari respons.
        if (data['success']) { // Jika data berhasil diambil.
          setState(() { // Memicu rebuild widget.
            dashboardData = data['data']; // Menyimpan data dashboard.
          });
        } else {
          _showMessage('Gagal memuat data: ${data['message']}'); // Menampilkan pesan error jika gagal memuat data.
        }
      } else {
        _showMessage('Gagal memuat data. Status code: ${response.statusCode}'); // Menampilkan pesan error berdasarkan status code.
      }
    } catch (e) {
      _showMessage('Error: $e'); // Menampilkan pesan error jika terjadi exception.
    }
  }

  Future<void> _fetchElections() async { // Mengambil data pemilihan dari server.
    try {
      final response = await http.get(Uri.parse('https://mobilecomputing.my.id/api_faiz/api_voteapp/elections/get_elections.php')); // Mengirim GET request ke API.
      if (response.statusCode == 200) { // Jika respons berhasil.
        final data = json.decode(response.body); // Decode JSON dari respons.
        if (data['success']) { // Jika data berhasil diambil.
          setState(() { // Memicu rebuild widget.
            allElections = List<Map<String, dynamic>>.from(data['elections']); // Menyimpan semua data pemilihan.
            filteredElections = allElections.where((e) => e['status'] == 'active').toList(); // Menyimpan data pemilihan yang aktif.
          });
        }
      }
    } catch (e) {
      print('Error fetching elections: $e'); // Mencetak pesan error jika terjadi exception.
    }
  }

  void _showMessage(String message) { // Menampilkan pesan menggunakan SnackBar.
    ScaffoldMessenger.of(context).showSnackBar( // Menampilkan SnackBar.
      SnackBar(content: Text(message)), // Membuat SnackBar dengan pesan.
    );
  }

  String _getElectionTypeText() { // Mendapatkan teks tipe pemilihan berdasarkan filter.
    if (filteredElections == allElections) { // Jika semua pemilihan ditampilkan.
      return "";
    } else if (filteredElections.every((e) => e['status'] == 'active')) { // Jika hanya pemilihan aktif yang ditampilkan.
      return "Aktif";
    } else if (filteredElections.every((e) => e['status'] == 'ended')) { // Jika hanya pemilihan yang berakhir yang ditampilkan.
      return "Berakhir";
    } else {
      return "";
    }
  }

  void _logout() async { // Fungsi untuk logout.
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences.
    await prefs.clear(); // Menghapus semua data lokal.
    Navigator.pushReplacement( // Navigasi ke halaman login.
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) { // Membangun UI.
    return Scaffold( // Membuat struktur dasar aplikasi.
      body: CustomScrollView( // CustomScrollView untuk mengatur scroll.
        controller: _scrollController, // Menggunakan ScrollController.
        slivers: <Widget>[ // Daftar widget sliver.
          SliverAppBar( // SliverAppBar yang bisa di-scroll.
            expandedHeight: 200.0, // Tinggi maksimum saat di-expand.
            floating: false, // Tidak mengambang.
            pinned: true, // Tetap terlihat saat di-scroll.
            flexibleSpace: FlexibleSpaceBar( // Konten fleksibel di AppBar.
              title: Text( // Judul AppBar.
                'Selamat Datang, @$username!', // Menampilkan username di title.
                style: TextStyle( // Gaya teks judul.
                  color: _textColor, // Mengubah warna teks berdasarkan posisi scroll.
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 16, bottom: 16), // Padding untuk judul.
              background: Stack( // Latar belakang AppBar.
                fit: StackFit.expand,
                children: [
                  Image.network( // Gambar latar belakang.
                    'https://i.imgur.com/OztEbmb.png',
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox( // Overlay dengan gradient.
                    decoration: BoxDecoration(
                      gradient: LinearGradient( // Gradient untuk efek bayangan.
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              collapseMode: CollapseMode.pin, // Mode collapse untuk AppBar.
            ),
          ),
          SliverToBoxAdapter( // Konten utama dashboard.
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Judul ringkasan.
                  SizedBox(height: 10), // Spasi vertikal.
                  _buildSummaryCard('Total Kandidat', '${dashboardData['total_candidates'] ?? 0}'), // Card ringkasan total kandidat.
                  _buildSummaryCard('Total Suara', '${dashboardData['total_votes'] ?? 0}'), // Card ringkasan total suara.
                  SizedBox(height: 20), // Spasi vertikal.
                  Text('Daftar Pemilihan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Judul daftar pemilihan.
                  SizedBox(height: 10), // Spasi vertikal.
                  Row( // Tombol filter pemilihan.
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton( // Tombol filter pemilihan aktif.
                        onPressed: () {
                          setState(() {
                            filteredElections = allElections.where((e) => e['status'] == 'active').toList(); // Memfilter pemilihan aktif.
                          });
                        },
                        child: Text('Aktif'),
                      ),
                      ElevatedButton( // Tombol filter pemilihan berakhir.
                        onPressed: () {
                          setState(() {
                            filteredElections = allElections.where((e) => e['status'] == 'ended').toList(); // Memfilter pemilihan berakhir.
                          });
                        },
                        child: Text('Berakhir'),
                      ),
                      ElevatedButton( // Tombol menampilkan semua pemilihan.
                        onPressed: () {
                          setState(() {
                            filteredElections = allElections; // Menampilkan semua pemilihan.
                          });
                        },
                        child: Text('Semua'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10), // Spasi vertikal.
                  filteredElections.isEmpty
                      ? Center( // Tampilan jika tidak ada pemilihan.
                    child: Text(
                      'Tidak ada pemilihan ${_getElectionTypeText()}',
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  )
                      : ListView.builder( // Daftar pemilihan.
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredElections.length,
                    itemBuilder: (context, index) {
                      final election = filteredElections[index];
                      return Card( // Card untuk setiap pemilihan.
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        child: ListTile(
                          leading: Icon( // Ikon status pemilihan.
                            election['status'] == 'active' ? Icons.how_to_vote : Icons.event_busy,
                            color: election['status'] == 'active' ? Colors.green : Colors.red,
                          ),
                          title: Text( // Judul pemilihan.
                            election['title'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column( // Informasi tambahan pemilihan.
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${election['start_date']} - ${election['end_date']}'), // Tanggal pemilihan.
                              Text( // Status pemilihan.
                                election['status'] == 'active' ? 'Aktif' : 'Berakhir',
                                style: TextStyle(
                                  color: election['status'] == 'active' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: election['status'] == 'active' // Aksi saat pemilihan ditekan.
                              ? () {
                            Navigator.push( // Navigasi ke halaman detail voting.
                              context,
                              MaterialPageRoute(
                                builder: (context) => VotingDetailsPage(election: election),
                              ),
                            );
                          }
                              : null,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20), // Spasi vertikal.
                  Text('Menu:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Judul menu.
                  GridView.count( // Grid menu.
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      if (userLevel == 1) ...[ // Menu khusus admin.
                        _buildMenuButton(context, 'Pemilihan', Icons.how_to_vote, ManageElectionsPage()),
                        _buildMenuButton(context, 'Kandidat', Icons.person, ManageCandidatesPage()),
                      ],
                      _buildMenuButton(context, 'Voting', Icons.ballot, VotingPage()),
                      if (userLevel == 1)
                        _buildMenuButton(context, 'Hasil Suara', Icons.bar_chart, ResultsPage()),
                      _buildMenuButton(context, 'Pengaturan Akun', Icons.settings, AccountSettingsPage()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( // Tombol logout.
        onPressed: _logout, // Memanggil fungsi logout saat ditekan.
        child: Icon(Icons.exit_to_app), // Ikon untuk tombol logout.
        tooltip: 'Logout', // Teks yang muncul saat tombol dihover.
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) { // Membangun card ringkasan.
    return Card(
      elevation: 2, // Elevasi card untuk efek bayangan.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16)), // Judul ringkasan.
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Nilai ringkasan.
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Widget page) { // Membangun tombol menu.
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)), // Navigasi ke halaman yang sesuai saat ditekan.
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Membuat sudut tombol melengkung.
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36), // Ikon menu.
            SizedBox(height: 8), // Spasi antara ikon dan teks.
            Text(title, textAlign: TextAlign.center), // Judul menu.
          ],
        ),
      ),
    );
  }
}