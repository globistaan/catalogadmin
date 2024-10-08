import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../buttons/button_widget.dart';
import '../grid/grid_row_widget.dart';
import '../grid/header.dart';
import '../grid/header_serial_no.dart';
import '../grid/loading_widget.dart';
import '../model/grid_item.dart';
import '../service/grid_item_service.dart';
import '../snackbar/top_snackbar.dart';

class MasterDataUpload extends StatefulWidget {

  final ValueNotifier<String> searchQueryNotifier;
   MasterDataUpload({super.key, required this.searchQueryNotifier});

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
    widget.searchQueryNotifier.addListener(() {
      setState(() {
       // _filteredGridItems();
      });
      // Update UI on search query change
    });
  }

  @override
  Widget build(BuildContext context) {
    List<GridItem> filteredGridItems = _filteredGridItems();
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
                    itemCount: filteredGridItems.length,
                    itemBuilder: (context, index) {
                      return GridRowWidget(
                        index: index,
                        item: filteredGridItems[index],
                        onRemove: (index){
                          _removeRow(index, filteredGridItems);
                      },
                        onGridRowImageUploaded: (List<String> imageUrls) {
                          setState(() {
                            filteredGridItems[index].images.clear();
                            filteredGridItems[index].images.addAll(imageUrls);
                          });
                          TopSnackBar.show(context, 'Image(s) uploaded successfully');
                        },
                        onGridRowImageUploadFailed: () {
                          TopSnackBar.show(context, 'Image(s) upload failed');
                        },
                        onApply: (int index) {
                          final currentItem = filteredGridItems[index];
                          if (currentItem.category == null) return;
                          setState(() {
                            // Wrap the entire loop in a single setState
                            for (var i = 0; i < filteredGridItems.length; i++) {
                              // var item = filteredGridItems[i];
                              if (filteredGridItems[i].category == currentItem.category && filteredGridItems[i].itemId != currentItem.itemId) {
                                filteredGridItems[i].dimension = currentItem.dimension;
                                filteredGridItems[i].unit = currentItem.unit;
                                filteredGridItems[i].mapSlotPrice = currentItem
                                    .mapSlotPrice; // Copy price slot mapping
                              }
                            }
                          });
                          TopSnackBar.show(context, 'Applied dimensions, unit, and slot mapping to all products in the same category');
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(filteredGridItems),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return const Row(
      children: [
        HeaderSrNoWidget(title: 'Sr No'),
        Expanded(child: HeaderWidget(title: 'Item Id')),
        Expanded(child: HeaderWidget(title: 'Item Name')),
        Expanded(child: HeaderWidget(title: 'Category')),
        Expanded(child: HeaderWidget(title: 'Subcategory')),
        Expanded(child: HeaderWidget(title: 'Price (INR)')),
        Expanded(child: HeaderWidget(title: 'Specs')),
        Expanded(child: HeaderWidget(title: 'Dimension')),
        Expanded(child: HeaderWidget(title: 'Unit')),
        Expanded(
            child: HeaderWidget(
                title: 'Slot:Price')),
        Expanded(child: HeaderWidget(title: 'Apply')), // New header for Apply
        Expanded(child: HeaderWidget(title: 'Image')),
        SizedBox(width: 24),
      ],
    );
  }


  Widget _buildActionButtons(List<GridItem> filteredGridItems) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ButtonWidget(
          text: 'Upload From Excel',
          onPressed: () async {
            await _uploadFromExcel(filteredGridItems);
            TopSnackBar.show(context, 'Excel file uploaded successfully');
          },
        ),
        const SizedBox(width: 16),
        ButtonWidget(text: 'Add Row', onPressed:(){
          _addRow(filteredGridItems);
        }),
        const SizedBox(width: 16),
        ButtonWidget(text: 'Delete All', onPressed :(){
          _deleteAll(filteredGridItems);
        }),
        const Spacer(),
        ButtonWidget(
          text: 'Save Changes',
          onPressed: () async {
            bool success = await GridItemService.saveChanges(filteredGridItems);
            if (success) {
              TopSnackBar.show(context, 'Changes saved successfully');
            } else {
              TopSnackBar.show(context, 'Failed to save changes');
            }
          },
        ),
        const SizedBox(width: 16),
        ButtonWidget(
          text: 'Download To Excel',
          onPressed: () async {
            await GridItemService.downloadExcel(filteredGridItems);
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

  List<GridItem> _filteredGridItems() {
    final searchText = widget.searchQueryNotifier.value.toLowerCase();
    final filteredGridItems = searchText.isEmpty
        ? gridItems
        : gridItems.where((item) {
   return item.itemId.toLowerCase().contains(searchText) ||
          item.itemDescription.toLowerCase().contains(searchText) ||
          (item.category?.toLowerCase() ?? '').contains(searchText) ||
          (item.subCategory?.toLowerCase() ?? '').contains(searchText);
    }).toList();
    return filteredGridItems;
  }

  void _deleteAll(filteredGridItems) {
    logger.d('Deleting all rows');
    setState(() {
      filteredGridItems.clear();
    });
  }

  void _addRow(filteredGridItems) {
    logger.d('Adding a new row');
    setState(() {
      filteredGridItems.add(GridItem(
          itemId: '',
          itemDescription: '',
          category: '',
          subCategory: '',
          images: []));
    });
  }

  void _removeRow(int index,filteredGridItems) {
    logger.d('Removing row at index: $index');
    setState(() {
      filteredGridItems.removeAt(index);
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

  Future<void> _uploadFromExcel(filteredGridItems) async {
    List<GridItem> items = await GridItemService.uploadFromExcel();
    setState(() {
      filteredGridItems.clear();
      filteredGridItems.addAll(items); // Update filteredGridItems with new data
    });
  }
}
