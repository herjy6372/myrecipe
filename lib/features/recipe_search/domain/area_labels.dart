/// TheMealDB의 지역(area) 값은 영어 고정이라 API 호출엔 그대로 쓰고,
/// 화면에 보여줄 라벨만 로케일에 맞게 바꾼다.
/// TheMealDB에는 한식(Korean) 데이터가 없다.
const Map<String, String> _koreanAreaLabels = {
  'American': '미국식',
  'British': '영국식',
  'Canadian': '캐나다식',
  'Chinese': '중식',
  'Croatian': '크로아티아식',
  'Dutch': '네덜란드식',
  'Egyptian': '이집트식',
  'Filipino': '필리핀식',
  'French': '프랑스식',
  'Greek': '그리스식',
  'Indian': '인도식',
  'Irish': '아일랜드식',
  'Italian': '이탈리아식',
  'Jamaican': '자메이카식',
  'Japanese': '일식',
  'Kenyan': '케냐식',
  'Malaysian': '말레이시아식',
  'Mexican': '멕시코식',
  'Moroccan': '모로코식',
  'Polish': '폴란드식',
  'Portuguese': '포르투갈식',
  'Russian': '러시아식',
  'Spanish': '스페인식',
  'Thai': '태국식',
  'Tunisian': '튀니지식',
  'Turkish': '터키식',
  'Ukrainian': '우크라이나식',
  'Uruguayan': '우루과이식',
  'Vietnamese': '베트남식',
};

String areaLabel(String englishArea, {required bool useKorean}) {
  if (!useKorean) return englishArea;
  return _koreanAreaLabels[englishArea] ?? englishArea;
}
