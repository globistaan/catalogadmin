import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:html' as html;
import '../model/grid_item.dart';
import '../buttons/clear_image_button.dart';
import '../service/grid_item_service.dart';

class ImageCellWidget extends StatelessWidget {
  final GridItem item;
  final Function(List<String>) onImageUploaded;// Callback to notify when an image is uploaded
  final Function() onImageUploadFailed;

  const ImageCellWidget({required this.item, required this.onImageUploaded, Key? key, required this.onImageUploadFailed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logger = Logger();

    return GestureDetector(
      onTap: () async {
        html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.multiple = true;
        uploadInput.click();

        uploadInput.onChange.listen((e) async {
          final files = uploadInput.files;
          if (files != null) {
            for (var file in files) {
              logger.d('Uploading file for: ${item.itemId}, filename: ${file.name}');
              List<String> presignedUrls  = await GridItemService.processImageUpload(file, item);
              if (presignedUrls.length>0) {
                logger.d('File uploaded successufully: ${item.itemId}, filename: ${file.name}');
                onImageUploaded(presignedUrls); // Notify that the image was uploaded successfully
              } else {
                // Handle failure (e.g., show a Snackbar or dialog)
                logger.e('Failed to upload image for item: ${item.itemId}');
                onImageUploadFailed();
              }
            }
          }
        });
      },
      child: Stack(
        children: [
          Container(
            height: 75,
            width: 400,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: item.images.isEmpty
                ? Center(child: Text('Click to Upload Image', style: TextStyle(fontSize: 16, color: Colors.blueGrey[400])))
                : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.images[0], fit: BoxFit.cover),
            ),
          ),
          if (item.images.isNotEmpty)
            ClearImageButton(
              clearImage: (item) {
                item.images.clear();
                onImageUploaded([]); // Notify that the image was cleared
              },
              item: item,
            ),
        ],
      ),
    );
  }
}
