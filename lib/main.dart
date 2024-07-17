import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webcatalogmaster/upload/master_data_upload.dart';

void main() async{
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Product Master Data', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
        ),
        body: const MasterDataUpload(),
      ),
    );
  }
}

