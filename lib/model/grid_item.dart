class GridItem {
  String itemId;
  String itemDescription;
  List<String> images;
  String? category;
  String? subCategory;
  String? price;
  String? specifications;

  GridItem({
    required this.itemId,
    required this.itemDescription,
    required this.images,
    this.category,
    this.subCategory,
    this.price,
    this.specifications
  });
}