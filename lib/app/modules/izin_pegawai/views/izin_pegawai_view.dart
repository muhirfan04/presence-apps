import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:presenceapp/app/modules/home/views/home_view.dart';

class AbsencePage extends StatefulWidget {
  AbsencePage(
      {Key? key,
      required this.lokasi,
      required this.name,
      required this.nip,
      required this.position,
      required this.clockedInTimes})
      : super(key: key);
  String lokasi, nip, name, position, clockedInTimes;

  @override
  _AbsencePageState createState() => _AbsencePageState();
}

class _AbsencePageState extends State<AbsencePage> {
  File? image;

  TextEditingController _keteranganController = TextEditingController();

  // Metode untuk memilih dan mengunggah file
  Future<void> _uploadFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      image = File(imagePicked.path);
      setState(() {});
    }
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Metode untuk menyimpan waktu clock in ke Firebase
  void saveClockInTimeToFirebase(DateTime clockedInTime, String name,
      String nip, String position, String absenceFlag) {
    String email = FirebaseAuth.instance.currentUser!.email!;
    String formattedDate = DateFormat('yyyy-MM-dd').format(clockedInTime);
    FirebaseFirestore.instance
        .collection('time_logs')
        .doc(email)
        .collection('clock_times')
        .doc(formattedDate)
        .set({
      'date': clockedInTime,
      'name': name,
      'nip': nip,
      'position': position,
      'location': widget.lokasi,
      'absenceFlag': absenceFlag,
      'description': _keteranganController.text
    }).then((value) {
      showCustomBottomSheet(context, 'File Berhasil di Unggah');
    }).catchError((error) {
      showCustomBottomSheet(context, 'Ungah File gagal: $error');
    });
  }

  // Metode untuk menampilkan bottom sheet kustom
  void showCustomBottomSheet(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(12, 20, 12, 1),
          content: Container(
            padding: EdgeInsets.all(10),
            child: Text(text),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeView(),
                    )); // Menutup dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PERIZINAN'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Unggah File Absensi',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _uploadFile();
                },
                child: Text('Pilih File'),
              ),
              SizedBox(height: 16),
              image != null
                  ? Container(
                      height: 400,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(image!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    )
                  : Container(),
              SizedBox(height: 16),
              TextFormField(
                controller: _keteranganController,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Memanggil metode untuk menyimpan waktu clock in ke Firebase
                  DateTime clockedInTime = DateTime.now();
                  String name = widget.name; // Ganti dengan nama yang sesuai
                  String nip = widget.nip; // Ganti dengan NIP yang sesuai
                  String position =
                      widget.position; // Ganti dengan posisi yang sesuai
                  String absenceFlag = "1";

                  if (image != null) {
                    if (_keteranganController.text.isNotEmpty) {
                      if (widget.clockedInTimes.isEmpty == true) {
                        print("gagal");
                        saveClockInTimeToFirebase(
                            clockedInTime, name, nip, position, absenceFlag);
                      } else {
                        showCustomBottomSheet(
                            context, 'Anda sudah absen masuk');
                        print('in berhasil');
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: EdgeInsets.fromLTRB(12, 20, 12, 1),
                            content: Container(
                              padding: EdgeInsets.all(10),
                              child: Text('keterangan tidak boleh kosong'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  ); // Menutup dialog
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentPadding: EdgeInsets.fromLTRB(12, 20, 12, 1),
                            content: Container(
                              padding: EdgeInsets.all(10),
                              child: Text('File tidak boleh kosong'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  ); // Menutup dialog
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        });
                  }
                },
                child: Text('Unggah'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
