class GridItem {
  String itemId;
  String itemDescription;
  String image;
  String? category;
  String? subCategory;
  GridItem({
    required this.itemId,
    required this.itemDescription,
    required this.image,
    this.category,
    this.subCategory
  });
}