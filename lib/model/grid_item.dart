class GridItem {
  String itemId;
  String itemDescription;
  String image;
  String? category;
  String? subCategory;
  String? price;
  String? remarks;

  GridItem({
    required this.itemId,
    required this.itemDescription,
    required this.image,
    this.category,
    this.subCategory,
    this.price,
    this.remarks
  });
}