import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyek2/models/menuModel.dart';
import 'package:proyek2/models/pecahanModel.dart';
import 'package:proyek2/views/kasir/kembalianKasir.dart';
import 'package:proyek2/controllers/pesananController.dart';

class BayarKasir extends StatefulWidget {
  final List<Menu> keranjang;
  final double totalHarga;
  final String nama;

  const BayarKasir({
    Key? key,
    required this.keranjang,
    required this.totalHarga,
    required this.nama,
  }) : super(key: key);

  @override
  _BayarKasirState createState() => _BayarKasirState();
}

class _BayarKasirState extends State<BayarKasir> {
  final PesananController _pesananController = PesananController(); // Instance controller
  List<Pecahan> pecahanList = [
    Pecahan(idPecahan: 1, pecahan: 100000, jumlah: 0),
    Pecahan(idPecahan: 2, pecahan: 50000, jumlah: 0),
    Pecahan(idPecahan: 3, pecahan: 20000, jumlah: 0),
    Pecahan(idPecahan: 4, pecahan: 10000, jumlah: 0),
    Pecahan(idPecahan: 5, pecahan: 5000, jumlah: 0),
    Pecahan(idPecahan: 6, pecahan: 2000, jumlah: 0),
    Pecahan(idPecahan: 7, pecahan: 1000, jumlah: 0),
    Pecahan(idPecahan: 8, pecahan: 500, jumlah: 0),
  ];

  final Map<int, String> pecahanImages = {
    100000: 'assets/100k.png',
    50000: 'assets/50k.png',
    20000: 'assets/20k.png',
    10000: 'assets/10k.png',
    5000: 'assets/5k.png',
    2000: 'assets/2k.png',
    1000: 'assets/1k.png',
    500: 'assets/500p.png',
  };

  double totalDibayar = 0.0;

  void _updateTotalDibayar() {
    setState(() {
      totalDibayar = pecahanList.fold(
          0.0,
          (sum, pecahan) =>
              sum + (pecahan.pecahan * pecahan.jumlah).toDouble());
    });
  }

  Future<void> _konfirmasiPembayaran() async {
    List<Map<String, dynamic>> pecahanData = pecahanList
        .where((pecahan) => pecahan.jumlah > 0) // Kirim hanya pecahan yang ada nilainya
        .map((pecahan) => {
              'pecahan': pecahan.pecahan,
              'jumlah': pecahan.jumlah,
            })
        .toList();

    try {
      bool berhasil = await _pesananController.simpanPecahan(
        namaPembeli: widget.nama,
        pecahanList: pecahanData,
      );

      if (berhasil) {
        double jumlahKembalian = totalDibayar - widget.totalHarga;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KembalianKasir(
              kembalian: jumlahKembalian,
            ),
          ),
        );
      } else {
        _showErrorSnackBar('Gagal menyimpan pecahan.');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900], // Set background to purple 900
      appBar: AppBar(
        title: Text('Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Pembeli and Total Harga inside a Card
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Pembeli: ${widget.nama}', // Display buyer's name
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(widget.totalHarga)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // The payment grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: pecahanList.length,
                itemBuilder: (context, index) {
                  final pecahan = pecahanList[index];
                  final imagePath =
                      pecahanImages[pecahan.pecahan] ?? 'assets/default.png';

                  return GestureDetector(
                    onTap: () {
                      _showInputDialog(context, pecahan);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            imagePath,
                            width: 400,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${pecahan.jumlah}x',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Dibayar: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(totalDibayar)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: totalDibayar >= widget.totalHarga
                      ? _konfirmasiPembayaran // Proses simpan
                      : null,
                  child: Text('Konfirmasi Pembayaran', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),  
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInputDialog(BuildContext context, Pecahan pecahan) {
    int jumlah = pecahan.jumlah;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Input Jumlah Pecahan'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Jumlah'),
            onChanged: (value) {
              jumlah = int.tryParse(value) ?? pecahan.jumlah;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  pecahan.jumlah = jumlah;
                  _updateTotalDibayar();
                });
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}