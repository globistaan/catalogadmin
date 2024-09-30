import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/grid_item.dart';
import 'package:logger/logger.dart';

class GridItemService {
  static final logger = Logger();

  static Future<List<GridItem>> fetchGridData() async {
    var s3excelUrl = dotenv.env['SERVER_EXCEL_URL'];
    // Simulating loading time
    await Future.delayed(const Duration(seconds: 1));

    final data = await streamExcelData(s3excelUrl!);
    var gridItems = <GridItem>[];

    if (data.isNotEmpty) {
      final excelFile = Excel.decodeBytes(data);
      final sheet = excelFile.tables[excelFile.tables.keys.first];
      if (sheet != null) {
        for (var row in sheet.rows.skip(1)) {
          String excelItemid = row[0]?.value?.toString() ?? '';
          String excelItemdescription = row[1]?.value?.toString() ?? '';
          String excelCategory = row[2]?.value?.toString() ?? '';
          String excelSubcategory = row[3]?.value?.toString() ?? '';
          String price = row[4]?.value?.toString() ?? '';
          String excelSpecifications = row[5]?.value?.toString() ?? '';
          String excelImages = row[6]?.value?.toString() ?? '';
          String excelDimension = row[7]?.value?.toString() ?? '';
          String excelUnit = row[8]?.value?.toString() ?? '';
          gridItems.add(GridItem(
            itemId: excelItemid,
            itemDescription: excelItemdescription,
            images: excelImages.split(","),
            category: excelCategory,
            subCategory: excelSubcategory,
            price: price,
            specifications: excelSpecifications,
            dimension: excelDimension,
            unit:excelUnit
          ));
        }
      }
    }
    return gridItems;
  }

  static Future<List<int>> streamExcelData(String s3Url) async {
    logger.d('Streaming Excel data from URL: $s3Url');
    final uriWithCacheBuster = Uri.parse('$s3Url?cacheBuster=${DateTime.now().millisecondsSinceEpoch}');
    final response = await http.get(uriWithCacheBuster);
    if (response.statusCode == 200) {
      logger.d('Excel data streamed successfully');
      return response.bodyBytes;
    } else {
      logger.e('Failed to load Excel data: ${response.statusCode}');
      return [];
    }
  }


  static Future<void> uploadToS3(String presignedUrl, List<int> fileBytes) async {
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

  static Future<String> getPresignedUrl(String fileName) async {
    var apiGatewayUrl = dotenv.env["API_GATEWAY_URL"];
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

 static Future<void> downloadExcel(gridItems) async {
    logger.d('Downloading Excel file');
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow(['Item Id', 'Item Description', 'Category', 'Subcategory', 'Price', 'Specifications', 'Image','Dimension', 'Unit', 'SlotPriceMapping']);

    for (var item in gridItems) {
      sheet.appendRow([
        item.itemId,
        item.itemDescription,
        item.category,
        item.subCategory,
        item.price,
        item.specifications,
        item.images.join(","),
        item.dimension,
        item.unit,
        item.mapSlotPrice
      ]);
    }

    excel.save();
    logger.d('Excel file downloaded successfully');
  }

  static Future<void> downloadLatestFromServer() async {
    logger.d('Downloading latest data from server');
    try {
      var s3excelUrl = dotenv.env['SERVER_EXCEL_URL'];
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

  static Future<bool> saveChanges(List<GridItem> gridItems) async {
    logger.d('Saving changes...');
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow(['Item Id', 'Item Description', 'Category', 'Subcategory', 'Price', 'Specifications', 'Image','Dimension', 'Unit', 'SlotPriceMapping']);

    for (var item in gridItems) {
      sheet.appendRow([
        item.itemId,
        item.itemDescription,
        item.category,
        item.subCategory,
        item.price,
        item.specifications,
        item.images.join(","),
        item.dimension,
        item.unit,
        item.mapSlotPrice
      ]);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      try {
        final presignedUrl = await GridItemService.getPresignedUrl('grid_data.xlsx');
        await GridItemService.uploadToS3(presignedUrl, bytes);
        logger.d('Changes saved successfully');
        return true;  // Indicate success
      } catch (e) {
        logger.e('Error saving changes: $e');
        return false; // Indicate failure
      }
    } else {
      logger.e('Failed to encode Excel file');
      return false; // Indicate failure
    }
  }

  static Future<List<GridItem>> uploadFromExcel() async {
    logger.d('Uploading from Excel...');
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.xlsx';
    uploadInput.click();

    // Create a completer to handle async return value
    Completer<List<GridItem>> completer = Completer<List<GridItem>>();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files?.length == 1) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files![0]);

        reader.onLoadEnd.listen((e) {
          final excelFile = Excel.decodeBytes(reader.result as Uint8List);
          List<GridItem> gridItems = [];

          final sheet = excelFile.tables[excelFile.tables.keys.first];
          if (sheet != null) {
            for (var row in sheet.rows.skip(1)) {
              String excelItemId = row[0]?.value?.toString() ?? '';
              String excelItemDescription = row[1]?.value?.toString() ?? '';
              String excelCategory = row[2]?.value?.toString() ?? '';
              String excelSubcategory = row[3]?.value?.toString() ?? '';
              String price = row[4]?.value?.toString() ?? '';
              String specifications = row[5]?.value?.toString() ?? '';
              String excelImages = row[6]?.value?.toString() ?? '';

              gridItems.add(GridItem(
                itemId: excelItemId,
                itemDescription: excelItemDescription,
                category: excelCategory,
                subCategory: excelSubcategory,
                price: price,
                specifications: specifications,
                images: excelImages.split(","),
              ));
            }
          }

          // Complete the future with the updated gridItems
          completer.complete(gridItems);
          logger.d('Uploaded from Excel and gridItems updated');
        });
      } else {
        completer.complete([]); // No files selected
      }
    });

    return completer.future; // Return the future
  }
  static Future<List<String>> processImageUpload(html.File file, GridItem item) async {
    List<String> presignedUrls = []; // List to store presigned URLs

    try {
      final reader = html.FileReader();

      // Use a completer to wait for the read to finish
      Completer<void> completer = Completer<void>();

      reader.readAsArrayBuffer(file);

      // Set up the onLoadEnd event to complete the completer
      reader.onLoadEnd.listen((event) {
        completer.complete(); // Complete the completer when the file is read
      });

      // Wait for the reading to complete
      await completer.future;

      final presignedUrl = await getPresignedUrl(file.name);
      logger.d('Presigned URL obtained: $presignedUrl');
      await uploadToS3(presignedUrl, reader.result as List<int>);
      logger.d('Image uploaded successfully for item: ${item.itemId}');

      // Update item images
      if (item.images == null) {
        item.images = [];
      }
      presignedUrls.add(presignedUrl.split('?').first); // Add the presigned URL to the list
      item.images.add(presignedUrls.last); // Update the item with the latest URL

      return presignedUrls; // Return the list of presigned URLs
    } catch (e) {
      logger.e('Error during upload for item: ${item.itemId}, error: $e');
      return []; // Return an empty list on failure
    }
  }

}

