import 'package:flutter/material.dart';
import 'package:about/about.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AboutPage(
      values: {'version': '1.0.0', 'year': DateTime.now().year.toString()},
      title: const Text('About AbsensiGo'),
      applicationVersion: 'Version {{ version }}',
      applicationIcon: const CircleAvatar(
        radius: 40,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image(
            image: AssetImage('assets/icons/logos/appLogo.png'),
            fit: BoxFit.cover,
            height: 80,
            width: 80,
          ),
        ),
      ),

      applicationLegalese: '© {{ year }} AndikaPutraDev. All rights reserved.',
      applicationDescription: const Text(
        'AbsensiGo adalah sistem manajemen presensi pintar berbasis mobile untuk pegawai dan instansi/perusahaan. '
        'Dilengkapi pencatatan kehadiran masuk dan pulang secara real-time, validasi koordinat lokasi GPS (latitude & longitude), '
        'serta integrasi cloud database Firebase. '
        'Dikembangkan oleh AndikaPutraDev.',
      ),

      children: const <Widget>[
        ListTile(
          leading: Icon(Icons.email),
          title: Text('Kontak Pengembang'),
          subtitle: Text('wahyuandikaputra.co.id@gmail.com'),
        ),
        ListTile(
          leading: Icon(Icons.code),
          title: Text('Developer'),
          subtitle: Text('AndikaPutraDev'),
        ),
      ],
    );
  }
}
