import 'package:absensi_app/providers/riwayat_absen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class RiwayatAbsenPage extends StatefulWidget {
  const RiwayatAbsenPage({super.key});

  @override
  _RiwayatAbsenPageState createState() => _RiwayatAbsenPageState();
}

class _RiwayatAbsenPageState extends State<RiwayatAbsenPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    // Ambil riwayat absen untuk hari ini saat halaman pertama kali dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RiwayatAbsenProvider>(
        context,
        listen: false,
      ).getHistoryAbsens(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final riwayatAbsenProvider = Provider.of<RiwayatAbsenProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absen')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              riwayatAbsenProvider.setSelectedDate(
                selectedDay,
              ); // Set tanggal yang dipilih
              Provider.of<RiwayatAbsenProvider>(
                context,
                listen: false,
              ).getHistoryAbsens(
                context: context,
                startDate: DateFormat('yyyy-MM-dd').format(selectedDay),
                endDate: DateFormat('yyyy-MM-dd').format(selectedDay),
              );
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _selectedDay == null
                  ? 'Pilih tanggal untuk melihat riwayat'
                  : 'Riwayat absen tanggal: ${DateFormat('dd-MM-yyyy').format(_selectedDay!)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Consumer<RiwayatAbsenProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage.isNotEmpty) {
                  return Center(child: Text(provider.errorMessage));
                }
                return ListView.builder(
                  itemCount: provider.historyAbsens.length,
                  itemBuilder: (context, index) {
                    final absen = provider.historyAbsens[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Absen Masuk: ${absen['check_in'] ?? '-'}',
                                ),
                                Text(
                                  'Lokasi Masuk: ${absen['location_in_name'] ?? '-'}',
                                ),
                                Text('Status: ${absen['status'] ?? '-'}'),
                                if (absen['alasan_izin'] != null)
                                  Text('Alasan Izin: ${absen['alasan_izin']}'),
                                if (absen['check_out'] != null)
                                  Text(
                                    'Absen Pulang: ${absen['check_out'] ?? '-'}',
                                  ),
                              ],
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: const Text(
                                          'Apakah Anda yakin ingin menghapus riwayat absen ini?',
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Batal'),
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            onPressed: () {
                                              provider.deleteHistoryAbsen(
                                                context,
                                                absen['id'],
                                              );
                                              Navigator.of(dialogContext).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
