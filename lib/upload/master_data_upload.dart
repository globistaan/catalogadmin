import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:logger/logger.dart';
import '../buttons/button_widget.dart';
import '../grid/grid_row_widget.dart';
import '../grid/header.dart';
import '../grid/header_serial_no.dart';
import '../grid/loading_widget.dart';
import '../model/grid_item.dart';
import '../service/grid_item_service.dart';

class MasterDataUpload extends StatefulWidget {
  const MasterDataUpload({super.key});

  @override
  _MasterDataUpload createState() => _MasterDataUpload();
}

class _MasterDataUpload extends State<MasterDataUpload> {
  final logger = Logger();
  List<GridItem> gridItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    logger.d('initState called');
    _fetchDataOnPageLoad();
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
          _buildHeaderRow(),
          Divider(thickness: 2, color: Colors.grey[400]),
          Expanded(
            child: _isLoading
                ? LoadingWidget()
                : ListView.builder(
                    itemCount: gridItems.length,
                    itemBuilder: (context, index) {
                      return GridRowWidget(
                        index: index,
                        item: gridItems[index],
                        onRemove: _removeRow,
                        onGridRowImageUploaded: (List<String> imageUrls) {
                          setState(() {
                            gridItems[index].images.clear();
                            gridItems[index].images.addAll(imageUrls);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Image(s) uploaded successfully')),
                          );
                        },
                        onGridRowImageUploadFailed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Image(s) upload failed')),
                          );
                        },
                        onApply: (int index) {
                          final currentItem = gridItems[index];
                          if (currentItem.category == null) return;
                          setState(() {
                            // Wrap the entire loop in a single setState
                            for (var i = 0; i < gridItems.length; i++) {
                              // var item = gridItems[i];
                              if (gridItems[i].category == currentItem.category && gridItems[i].itemId != currentItem.itemId) {
                                gridItems[i].dimension = currentItem.dimension;
                                gridItems[i].unit = currentItem.unit;
                                gridItems[i].mapSlotPrice = currentItem
                                    .mapSlotPrice; // Copy price slot mapping
                              }
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Applied dimensions, unit, and slot mapping to all products in the same category')),
                          );

                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return const Row(
      children: [
        HeaderSrNoWidget(title: 'Sr.No'),
        Expanded(child: HeaderWidget(title: 'Item Id')),
        Expanded(child: HeaderWidget(title: 'Item Name')),
        Expanded(child: HeaderWidget(title: 'Category')),
        Expanded(child: HeaderWidget(title: 'Subcategory')),
        Expanded(child: HeaderWidget(title: 'Price (INR)')),
        Expanded(child: HeaderWidget(title: 'Specifications')),
        Expanded(child: HeaderWidget(title: 'Dimension')),
        Expanded(child: HeaderWidget(title: 'Unit')),
        Expanded(
            child: HeaderWidget(
                title: 'Slot/Price Map (slot1:price1,slot2:price2)')),
        Expanded(child: HeaderWidget(title: 'Apply')), // New header for Apply
        Expanded(child: HeaderWidget(title: 'Image')),
        SizedBox(width: 24),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ButtonWidget(
          text: 'Upload From Excel',
          onPressed: () async {
            await _uploadFromExcel();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Excel file uploaded successfully')),
            );
          },
        ),
        const SizedBox(width: 16),
        ButtonWidget(text: 'Add Row', onPressed: _addRow),
        const SizedBox(width: 16),
        ButtonWidget(text: 'Delete All', onPressed: _deleteAll),
        const Spacer(),
        ButtonWidget(
          text: 'Save Changes',
          onPressed: () async {
            bool success = await GridItemService.saveChanges(gridItems);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Changes saved successfully')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to save changes')),
              );
            }
          },
        ),
        const SizedBox(width: 16),
        ButtonWidget(
          text: 'Download To Excel',
          onPressed: () async {
            await GridItemService.downloadExcel(gridItems);
          },
        ),
        const SizedBox(width: 16),
        ButtonWidget(
          text: 'Download Latest From Server',
          onPressed: () async {
            await GridItemService.downloadLatestFromServer();
          },
        ),
      ],
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
      gridItems.add(GridItem(
          itemId: '',
          itemDescription: '',
          category: '',
          subCategory: '',
          images: []));
    });
  }

  void _removeRow(int index) {
    logger.d('Removing row at index: $index');
    setState(() {
      gridItems.removeAt(index);
    });
  }

  Future<void> _fetchDataOnPageLoad() async {
    logger.d('Fetching data on page load');
    final data = await GridItemService.fetchGridData();
    setState(() {
      gridItems = data;
      _isLoading = false;
    });
  }

  Future<void> _uploadFromExcel() async {
    List<GridItem> items = await GridItemService.uploadFromExcel();
    setState(() {
      gridItems.clear();
      gridItems.addAll(items); // Update gridItems with new data
    });
  }
}
