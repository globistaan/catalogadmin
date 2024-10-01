import 'package:flutter/material.dart';
import '../buttons/delete_row_button.dart';
import '../image/image_cell_widget.dart';
import '../model/grid_item.dart';
import 'editable_text_cell.dart';

class GridRowWidget extends StatelessWidget {
  final int index;
  final GridItem item;
  final Function(int) onRemove;
  final Function(List<String>) onGridRowImageUploaded;
  final Function() onGridRowImageUploadFailed;
  final Function(int) onApply; // Add this line

  const GridRowWidget({
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onGridRowImageUploaded,
    required this.onGridRowImageUploadFailed,
    required this.onApply, // Add this line
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 40, child: Text((index + 1).toString())),
          Expanded(child: EditableTextCell(text: item.itemId, onChanged: (value) => item.itemId = value)),
          Expanded(child: EditableTextCell(text: item.itemDescription, onChanged: (value) => item.itemDescription = value)),
          Expanded(child: EditableTextCell(text: item.category ?? '', onChanged: (value) => item.category = value)),
          Expanded(child: EditableTextCell(text: item.subCategory ?? '', onChanged: (value) => item.subCategory = value)),
          Expanded(child: EditableTextCell(text: item.price ?? '', onChanged: (value) => item.price = value)),
          Expanded(child: EditableTextCell(text: item.specifications ?? '', onChanged: (value) => item.specifications = value)),
          Expanded(child: EditableTextCell(text: item.dimension ?? '', onChanged: (value) => item.dimension = value)),
          Expanded(child: EditableTextCell(text: item.unit ?? '', onChanged: (value) => item.unit = value)),
          Expanded(child: EditableTextCell(text: item.mapSlotPrice ?? '', onChanged: (value) => item.mapSlotPrice = value)),
          // New Apply Button
          ElevatedButton(
            child: Text("Apply"),
            style: ElevatedButton.styleFrom(
              backgroundColor:  Colors.blue, // Background color
              textStyle: TextStyle(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Sharp edges
              ),
            ), onPressed: () {
              onApply(index);
              },
          ),

          Expanded(child: ImageCellWidget(item: item, onImageUploaded: (imageUrls) {
            onGridRowImageUploaded(imageUrls);
          }, onImageUploadFailed: () {
            onGridRowImageUploadFailed();
          })),
          RemoveRowButton(index: index, onPressed: () => onRemove(index)),
        ],
      ),
    );
  }

}
