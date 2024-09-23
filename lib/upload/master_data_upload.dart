import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:html' as html;
import 'package:flutter_excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:webcatalogmaster/buttons/delete_row_button.dart';

import '../buttons/clear_image_button.dart';
import '../buttons/custom_elevated_button.dart';
import '../grid/editable_text_cell.dart';
import '../grid/header.dart';
import '../grid/header_serial_no.dart';
import '../grid/text_cell.dart';
import '../model/grid_item.dart';

class MasterDataUpload extends StatefulWidget {
  const MasterDataUpload({super.key});

  @override
  _MasterDataUpload createState() => _MasterDataUpload();
}

class _MasterDataUpload extends State<MasterDataUpload> {
  final logger = Logger();
  List<GridItem> gridItems = [
    GridItem(itemId: '', itemDescription: '', image: '', price: '', remarks: '')
  ];

  @override
  void initState() {
    super.initState(); // Always call super.initState() first
    logger.d('initState called');
    _fetchDataonPageLoad();
  }

  @override
  Widget build(BuildContext context) {
    logger.d('build called');
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blueGrey[100]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              HeaderSrNoWidget(title: 'Sr.No'),
              Expanded(child: HeaderWidget(title: 'Item Id')),
              Expanded(child: HeaderWidget(title: 'Item Name')),
              Expanded(child: HeaderWidget(title: 'Category')),
              Expanded(child: HeaderWidget(title: 'Subcategory')),
              Expanded(child: HeaderWidget(title: 'Price (INR)')),
              Expanded(child: HeaderWidget(title: 'Remarks')),
              Expanded(child: HeaderWidget(title: 'Image')),
              SizedBox(width: 24), // Space for remove icon
            ],
          ),
          Divider(thickness: 2, color: Colors.grey[400]),
          Expanded(
            child: ListView.builder(
              itemCount: gridItems.length,
              itemBuilder: (context, index) {
                return _buildRow(index);
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers the buttons along the main axis (horizontally)
            children: [
              CustomElevatedButton(onPressed: _uploadFromExcel, text: 'Upload From Excel'),
              const SizedBox(width: 16), // Optional: Adds spacing between buttons
              CustomElevatedButton(onPressed: _addRow, text: 'Add Row'),
              const SizedBox(width: 16), // Optional: Adds spacing between buttons
              CustomElevatedButton(onPressed: _deleteAll, text: 'Delete All'),
              const Spacer(),
              CustomElevatedButton(onPressed: saveChanges, text: 'Save Changes'),
              const SizedBox(width: 16),
              CustomElevatedButton(onPressed: downloadExcel, text: 'Download To Excel'),
              const SizedBox(width: 16),
              CustomElevatedButton(onPressed: downloadLatestFromServer, text: 'Download Latest From Server'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int index) {
    final item = gridItems[index];
    logger.d('Building row for index: $index with item: ${item.itemId}');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
        Container(width: 40, child:  TextCell( text: (index + 1).toString())),
          Expanded(flex:1, child: EditableTextCell(text: item.itemId, onChanged: (value) {
            logger.d('Item Id changed to: $value at index: $index');
            item.itemId = value;
          })),
          Expanded(child: EditableTextCell(text: item.itemDescription, onChanged: (value) {
            logger.d('Item Description changed to: $value at index: $index');
            item.itemDescription = value;
          })),
          Expanded(child: EditableTextCell(text: item.category, onChanged: (value) {
            logger.d('Category changed to: $value at index: $index');
            item.category = value;
          })),
          Expanded(child: EditableTextCell(text: item.subCategory, onChanged: (value) {
            logger.d('Subcategory changed to: $value at index: $index');
            item.subCategory = value;
          })),
          Expanded(child: EditableTextCell(text: item.price, onChanged: (value) {
            logger.d('Price changed to: $value at index: $index');
            item.price = value;
          })),
          Expanded(child: EditableTextCell(text: item.remarks, onChanged: (value) {
            logger.d('Remarks changed to: $value at index: $index');
            item.remarks = value;
          })),
          Expanded(
            child: Align( // Wrap _buildImageCell in Align for center alignment
              alignment: Alignment.center,
              child: _buildImageCell(item),
            ),
          ),
         RemoveRowButton(index: index, onPressed: () =>_removeRow(index)),
        ],
      ),
    );
  }

  Widget _buildImageCell(GridItem item) {
    logger.d('Building image cell for item: ${item.itemId}');
    return GestureDetector(
      onTap: () async {
        html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.click();

        uploadInput.onChange.listen((e) async {
          final files = uploadInput.files;
          if (files?.length == 1) {
            final file = files![0];
            final reader = html.FileReader();

            reader.readAsArrayBuffer(file);

            reader.onLoadEnd.listen((e) async {
              try {
                // 1. Get Presigned URL
                final presignedUrl = await getPresignedUrl(file.name);
                logger.d('Presigned URL obtained: $presignedUrl');
                // 2. Upload to S3
                await uploadToS3(presignedUrl, reader.result as List<int>);
                logger.d('Image uploaded successfully for item: ${item.itemId}');
                // 3. Update UI (Display image and link)
                setState(() {
                  item.image = presignedUrl.split('?').first;
                });
              } catch (e) {
                logger.e('Error during upload for item: ${item.itemId}, error: $e');
              }
            });
          }
        });
      },
      child: Stack( // Use a Stack to overlay the cross icon
        children: [
          Container(
            height: 100,
            width: 400,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: item.image.isEmpty
                ? Center(
              child: Text(
                'Click to Upload Image',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[400]),
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.image, fit: BoxFit.cover),
            ),
          ),
          if (item.image.isNotEmpty) // Show cross only if there's an image
            ClearImageButton(clearImage: (item) {
              setState(() {
                item.image = ''; // Clear the image
              });
            },
              item: item,  // Pass the item to ClearImageButton
            ),
        ],
      ),
    );
  }

  void _deleteAll() {
    logger.d('Deleting all rows');
    setState(() {
      gridItems.clear();
    });
  }

  void _addRow() {
    logger.d('Adding a new row');
    setState(() {
      gridItems.add(GridItem(itemId: '', itemDescription: '', category: '', subCategory: '', image: ''));
    });
  }

  Future<String> getPresignedUrl(String fileName) async {
    var apiGatewayUrl =  dotenv.env["API_GATEWAY_URL"]; // Replace with your actual URL

    try {
      final response = await http.post(
        Uri.parse(apiGatewayUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'file_name': fileName}),
      );

      if (response.statusCode == 200) {
        final presignedUrl = jsonDecode(response.body)['presignedUrl'];
        logger.d('Received presigned URL: $presignedUrl');
        return presignedUrl;
      } else {
        throw Exception('Failed to get presigned URL');
      }
    } catch (e) {
      logger.e('Error fetching presigned URL for file: $fileName, error: $e');
      rethrow;
    }
  }

  Future<void> downloadExcel() async {
    logger.d('Downloading Excel file');
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Add the header row
    sheet.appendRow(['Item Id', 'Item Description', 'Category', 'Subcategory','Price','Remarks', 'Image']);

    for (var item in gridItems) {
      sheet.appendRow([
        item.itemId,
        item.itemDescription,
        item.category,
        item.subCategory,
        item.price,
        item.remarks,
        item.image
      ]);
    }

    excel.save();
    logger.d('Excel file downloaded successfully');
  }

  Future<void> saveChanges() async {
    logger.d('Saving changes');
    // Generate the Excel file from gridItems
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Add the header row
    sheet.appendRow(['Item Id', 'Item Description', 'Category', 'Subcategory','Price','Remarks', 'Image']);

    for (var item in gridItems) {
      sheet.appendRow([
        item.itemId,
        item.itemDescription,
        item.category,
        item.subCategory,
        item.price,
        item.remarks,
        item.image
      ]);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      var fileName = dotenv.env['SERVER_EXCEL_NAME'];
      try {
        final presignedUrl = await getPresignedUrl(fileName!);
        await uploadToS3(presignedUrl, bytes);
        logger.d('Changes saved successfully to $fileName');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved successfully')));
      } catch (e) {
        logger.e('Error saving changes: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save changes')));
      }
    } else {
      logger.e('Failed to encode Excel file');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save changes')));
    }
  }

  Future<void> uploadToS3(String presignedUrl, List<int> fileBytes) async {
    logger.d('Uploading to S3 with URL: $presignedUrl');
    try {
      await http.put(
        Uri.parse(presignedUrl),
        body: fileBytes,
      );
      logger.d('Upload to S3 completed');
    } catch (e) {
      logger.e('Error uploading to S3: $e');
      rethrow;
    }
  }

  Future<void> downloadLatestFromServer() async {
    logger.d('Downloading latest data from server');
    try {
      var s3excelUrl = dotenv.env['SERVER_EXCEL_URL'];// Replace with your actual URL

      final downloadResponse = await http.get(Uri.parse(s3excelUrl!));
      if (downloadResponse.statusCode == 200) {
        final blob = html.Blob([downloadResponse.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'latest_grid_data.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
        logger.d('Latest data downloaded successfully');
      } else {
        throw Exception('Failed to download the file');
      }
    } catch (e) {
      logger.e('Error downloading latest data from server: $e');
      rethrow;
    }
  }

  void _removeRow(int index) {
    logger.d('Removing row at index: $index');
    setState(() {
      gridItems.removeAt(index);
    });
  }

  Future<Uint8List> streamExcelData(String s3Url) async {
    logger.d('Streaming Excel data from URL: $s3Url');
    final response = await http.get(Uri.parse(s3Url), headers: {
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    });
    if (response.statusCode == 200) {
      logger.d('Excel data streamed successfully');
      return response.bodyBytes; // Directly get Uint8List from response
    } else {
      logger.e('Failed to load Excel data: ${response.statusCode}');
      return Uint8List(0);
    }
  }

  Future<void> _fetchDataonPageLoad() async {
    logger.d('Fetching data on page load');
    var s3excelUrl = dotenv.env['SERVER_EXCEL_URL'];
    logger.d('SERVER_EXCEL_URL='+ s3excelUrl!);
    final data = await streamExcelData(s3excelUrl);
    var excelFile = null;
    if (data.isNotEmpty && data.length>0) {
        excelFile =  Excel.decodeBytes(data);
      setState(() {
        gridItems.clear();
        final sheet = excelFile.tables[excelFile.tables.keys.first];
        if (sheet != null) {
          for (var row in sheet.rows.skip(1)) { // Skip header row
              // Safely extract itemId, itemDescription, category, subCategory, and image
              String excelItemid = row[0]?.value?.toString() ?? '';
              String excelItemdescription = row[1]?.value?.toString() ?? '';
              String excelCategory = row[2]?.value?.toString() ?? '';
              String excelSubcategory = row[3]?.value?.toString() ?? '';
              String price = row[4]?.value?.toString() ?? '';
              String remarks = row[5]?.value?.toString() ?? '';
              String excelImage = row[6]?.value?.toString() ?? '';
              gridItems.add(GridItem(
                itemId: excelItemid,
                itemDescription: excelItemdescription,
                image: excelImage,
                category: excelCategory,
                subCategory: excelSubcategory,
                price: price,
                remarks: remarks
              ));

          }
        }
      });
      logger.d('Data fetched and gridItems updated');
    } else {
      logger.e('Data fetched is empty');
    }
  }

  Future<void> _uploadFromExcel() async {
    logger.d('Uploading from Excel');
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.xlsx';
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files?.length == 1) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files![0]);
        reader.onLoadEnd.listen((e) {
          final excelFile = Excel.decodeBytes(reader.result as Uint8List);
          setState(() {
            gridItems.clear();
            final sheet = excelFile.tables[excelFile.tables.keys.first];
            if (sheet != null) {
              for (var row in sheet.rows.skip(1)) { // Skip header row
                  // Safely extract itemId, itemDescription, category, subCategory, and image
                  String excelItemid = row[0]?.value?.toString() ?? '';
                  String excelItemdescription = row[1]?.value?.toString() ?? '';
                  String excelCategory = row[2]?.value?.toString() ?? ''; // Read category
                  String excelSubcategory = row[3]?.value?.toString() ?? ''; // Read subCategory
                  String price = row[4]?.value?.toString() ?? '';
                  String remarks = row[5]?.value?.toString() ?? '';
                  String excelImage = row[6]?.value?.toString() ?? '';

                  gridItems.add(GridItem(
                    itemId: excelItemid,
                    itemDescription: excelItemdescription,
                    category: excelCategory,
                    subCategory: excelSubcategory,
                    price: price,
                    remarks: remarks,
                    image: excelImage,
                  ));

              }
            }
          });
          logger.d('Uploaded from Excel and gridItems updated');
        });
      }
    });
  }
}
