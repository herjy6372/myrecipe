/// TheMealDB의 카테고리 값은 영어 고정이라 API 호출엔 그대로 쓰고,
/// 화면에 보여줄 라벨만 로케일에 맞게 바꾼다.
const Map<String, String> _koreanCategoryLabels = {
  'Beef': '소고기',
  'Breakfast': '아침식사',
  'Chicken': '치킨',
  'Dessert': '디저트',
  'Goat': '염소고기',
  'Lamb': '양고기',
  'Miscellaneous': '기타',
  'Pasta': '파스타',
  'Pork': '돼지고기',
  'Seafood': '해산물',
  'Side': '사이드',
  'Starter': '애피타이저',
  'Vegan': '비건',
  'Vegetarian': '채식',
};

String categoryLabel(String englishCategory, {required bool useKorean}) {
  if (!useKorean) return englishCategory;
  return _koreanCategoryLabels[englishCategory] ?? englishCategory;
}
