main() {
  List<String> liste = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];
  DateTime simdi = DateTime.now();
  print(simdi);
  DateTime cumhuriyet = DateTime.utc(1923, 10, 29, 9, 30);
  print('cumhuriyet$cumhuriyet');
  DateTime localTime = DateTime.parse('1923-10-29');
  print(localTime);
  print(localTime.weekday);
  print(liste[localTime.weekday - 1]);
  DateTime simdiArtiDoksanGun = simdi.subtract(Duration(days: 90));
  print(simdiArtiDoksanGun);
}
//weekDay[((DateTime.parse(dates[i])).weekday)-1]
