import 'package:absensi_app/providers/riwayat_absen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class RiwayatAbsenPage extends StatefulWidget {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absen')),
      body: Consumer<RiwayatAbsenProvider>(
        builder: (context, riwayatAbsenProvider, child) {
          if (riwayatAbsenProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (riwayatAbsenProvider.errorMessage.isNotEmpty) {
            return Center(child: Text(riwayatAbsenProvider.errorMessage));
          }

          return Column(
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
                child: ListView.builder(
                  itemCount: riwayatAbsenProvider.historyAbsens.length,
                  itemBuilder: (context, index) {
                    final absen = riwayatAbsenProvider.historyAbsens[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Check In: ${absen['check_in'] ?? '-'}'),
                            Text('Check Out: ${absen['check_out'] ?? '-'}'),
                            Text('Status: ${absen['status'] ?? '-'}'),
                            if (absen['alasan_izin'] != null)
                              Text('Alasan Izin: ${absen['alasan_izin']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
