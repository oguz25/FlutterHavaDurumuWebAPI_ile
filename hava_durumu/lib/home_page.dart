import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/search_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = 'Ankara';
  int sicaklik;
  var locationData;
  var weatherData;
  var woeid;
  var arkaPlan = 'c';
  Position position;
  List<int> temps = List(5);
  List<String> arkaPlanlar = List(5);
  List<String> dates = List(5);
  List<String> weekDay = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (error) {
      print('Bir Hata Oluştu $error');
    } finally {
      //ne olursa burada yapar
    }
  }

  Future<void> getLocationData() async {
    locationData = await http
        .get('https://www.metaweather.com/api/location/search/?query=$sehir');
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
  }

  Future<void> getLocationDataLatLong() async {
    locationData = await http.get(
        'https://www.metaweather.com/api/location/search/?lattlong=${position.latitude},${position.longitude}');
    //var locationDataParsed = jsonDecode(locationData.body);
    var locationDataParsed = jsonDecode(utf8.decode(locationData.bodyBytes));
    woeid = locationDataParsed[0]['woeid'];
    sehir = locationDataParsed[0]['title'];
  }

  Future<void> getWeatherData() async {
    weatherData =
        await http.get('https://www.metaweather.com/api/location/$woeid/');
    var weatherDataParsed = jsonDecode(weatherData.body);

    setState(() {
      sicaklik =
          weatherDataParsed['consolidated_weather'][0]['the_temp'].round();

      for (int i = 0; i < 5; i++) {
        temps[i] = weatherDataParsed['consolidated_weather'][i + 1]['the_temp']
            .round();
        arkaPlanlar[i] = weatherDataParsed['consolidated_weather'][i + 1]
            ['weather_state_abbr'];
        dates[i] =
            weatherDataParsed['consolidated_weather'][i + 1]['applicable_date'];
      }

      arkaPlan =
          weatherDataParsed['consolidated_weather'][0]['weather_state_abbr'];
      print(sicaklik);
    });
  }

  void getDataFromAPI() async {
    await getDevicePosition(); //cihazdan konum bilgisi çekiliyor
    await getLocationDataLatLong(); //lat ve long ile woeid bilgisini API'dan çekiyoruzd
    print(woeid);
    getWeatherData(); // woeid bilgisi ile sıcaklık verisi çekiliyor.
  }

  void getDataFromAPIbyCity() async {
    await getLocationData(); //şehir ile woeid bilgisini API'dan çekiyoruzd
    print(woeid);
    getWeatherData(); // woeid bilgisi ile sıcaklık verisi çekiliyor.
  }

  @override
  void initState() {
    super.initState();

    getDataFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/$arkaPlan.jpg'),
        ),
      ),
      child: sicaklik == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 60,
                      width: 60,
                      child: Image.network(
                          'https://www.metaweather.com/static/img/weather/png/$arkaPlan.png'),
                    ),
                    Text(
                      '$sicaklik °C',
                      style: TextStyle(
                        shadows: <Shadow>[
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 2,
                            offset: Offset(-4, 3),
                          ),
                        ],
                        fontWeight: FontWeight.bold,
                        fontSize: 70,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$sehir',
                          style: TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 2,
                                offset: Offset(-4, 3),
                              ),
                            ],
                            fontSize: 30,
                          ),
                        ),
                        IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () async {
                              sehir = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchPage()));
                              getDataFromAPIbyCity();
                              setState(() {
                                sehir = sehir;
                              });
                            })
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    buildDailyWeatherCards(context),
                  ],
                ),
              ),
            ),
    );
  }

  Container buildDailyWeatherCards(BuildContext context) {
    List<Widget> cards = List(5);
    for (int i = 0; i < cards.length; i++) {
      cards[i] = DailyWeather(
        image: arkaPlanlar[i],
        temp: temps[i].toString(),
        date: weekDay[((DateTime.parse(dates[i])).weekday) - 1],
      );
    }

    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }
}

class DailyWeather extends StatelessWidget {
  final String image;
  final String temp;
  final String date;

  const DailyWeather(
      {Key key, @required this.image, @required this.temp, @required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.transparent,
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://www.metaweather.com/static/img/weather/png/$image.png',
              height: 50,
              width: 50,
            ),
            Text('$temp °C'),
            Text('$date'),
          ],
        ),
      ),
    );
  }
}
