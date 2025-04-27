import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:absensi_app/providers/riwayat_absen_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class RiwayatAbsenPage extends StatefulWidget {
  const RiwayatAbsenPage({super.key});

  @override
  State<RiwayatAbsenPage> createState() => _RiwayatAbsenPageState();
}

class _RiwayatAbsenPageState extends State<RiwayatAbsenPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory(_selectedDay);
    });
  }

  void _loadHistory(DateTime? date) {
    if (date == null) return;
    final provider = Provider.of<RiwayatAbsenProvider>(context, listen: false);
    provider.setSelectedDate(date);
    provider.getHistoryAbsens(
      context: context,
      startDate: DateFormat('yyyy-MM-dd').format(date),
      endDate: DateFormat('yyyy-MM-dd').format(date),
    );
  }

  String _getKelurahan(String? fullLocationName) {
    if (fullLocationName == null || fullLocationName.isEmpty) return '-';
    final parts = fullLocationName.split(', ');
    if (parts.length >= 3) return parts[parts.length - 3];
    if (parts.length >= 1) return parts[0];
    return fullLocationName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absen')),
      body: Column(
        children: [
          _buildCalendar(),
          _buildSelectedDateInfo(),
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2010, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _loadHistory(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          headerStyle: const HeaderStyle(
            formatButtonTextStyle: TextStyle(color: Colors.white),
            formatButtonDecoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
          ),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        _selectedDay == null
            ? 'Pilih tanggal untuk melihat riwayat'
            : 'Riwayat absen tanggal: ${DateFormat('dd-MM-yyyy').format(_selectedDay!)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Expanded(
      child: Consumer<RiwayatAbsenProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text(provider.errorMessage));
          }
          if (provider.historyAbsens.isEmpty) {
            return const Center(child: Text('Tidak ada data absen.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: provider.historyAbsens.length,
            itemBuilder: (context, index) {
              final absen = provider.historyAbsens[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      'Absen Masuk: ${absen['check_in'] != null ? DateFormat('HH:mm').format(DateTime.parse(absen['check_in'])) : '-'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lokasi: ${_getKelurahan(absen['location_in_name'])}',
                          ),
                          if (absen['check_out'] != null)
                            Text(
                              'Absen Pulang: ${DateFormat('HH:mm').format(DateTime.parse(absen['check_out']))}',
                            ),
                          if (absen['status'] != null)
                            Text('Status: ${absen['status']}'),
                          if (absen['alasan_izin'] != null)
                            Text('Alasan: ${absen['alasan_izin']}'),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(absen['id']),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(int absenId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus riwayat absen ini?',
            ),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.pop(context); // Tutup dialog
                  final success = await Provider.of<RiwayatAbsenProvider>(
                    context,
                    listen: false,
                  ).deleteHistoryAbsen(context, absenId);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Riwayat absen berhasil dihapus.'
                              : 'Gagal menghapus riwayat absen.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }
}
