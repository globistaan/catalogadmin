class GridItem {
  String itemId;
  String itemDescription;
  List<String> images;
  String? category;
  String? subCategory;
  String? price;
  String? specifications;
  String? dimension;
  String? unit;
  String? mapSlotPrice;

  GridItem({
    required this.itemId,
    required this.itemDescription,
    required this.images,
    this.category,
    this.subCategory,
    this.price,
    this.specifications,
    this.dimension,
    this.unit,
    this.mapSlotPrice,
  });

  // Clone method
  GridItem clone() {
    return GridItem(
      itemId: this.itemId,
      itemDescription: this.itemDescription,
      images: List.from(this.images), // Create a new list to avoid reference issues
      category: this.category,
      subCategory: this.subCategory,
      price: this.price,
      specifications: this.specifications,
      dimension: this.dimension,
      unit: this.unit,
      mapSlotPrice: this.mapSlotPrice,
    );
  }
}
