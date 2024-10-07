import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webcatalogmaster/upload/master_data_upload.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<String> searchQueryNotifier = ValueNotifier<String>(''); // Notifier for search query

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Row(
            children: [
              // Search TextField with search icon
              IntrinsicWidth(
                child: SearchField(
                  onSearchChanged: (value) {
                    searchQueryNotifier.value = value; // Update the search query
                  },
                ),
              ),
          //    const SizedBox(width: 5), // Spacing between search field and title
              const Spacer(),
              const Text(
                'Product Master Data',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                const url = 'https://ecommbalaji.github.io';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text(
                'Live Ecomm Balaji',
                style: TextStyle(color: Colors.yellow),
              ),
            ),
          ],
        ),
        body: MasterDataUpload(searchQueryNotifier: searchQueryNotifier), // Pass the notifier to the child
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final ValueChanged<String> onSearchChanged; // Callback function
  const SearchField({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by Item Id, Item Name, Category, Subcategory',
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.blue[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: onSearchChanged,
    );
  }
}