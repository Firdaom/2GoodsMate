class ItemFilter {
  final String query;
  final String category;
  final String rarity;

  ItemFilter({
    this.query = '',
    this.category = 'All',
    this.rarity = 'All',
  });

  ItemFilter copyWith({String? query, String? category, String? rarity}) {
    return ItemFilter(
      query: query ?? this.query,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
    );
  }
}