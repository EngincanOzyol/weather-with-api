
import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:weather/daily_weather_card.dart';
import 'package:weather/search_home_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String? location='ankara';
  double? temp;
  String apiKey='ad103257c6c28c194bacd315af4cdaa8';
  String code='c';
  String? icon;
  var locationdata;
  Position? positionDevice;
  List<String> cards=[];
  List<double> tempeture=[];
  List<String> datetime=[];


  Future<void> getlocation() async{
    locationdata= await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric'));
    final locationdataparsed=jsonDecode(locationdata.body);
    setState(() {
      temp=locationdataparsed['main']['temp'];
      location=locationdataparsed['name'];
      code=locationdataparsed['weather'][0]['main'];
      icon=locationdataparsed['weather'].first['icon'];
    });
  }
  Future<void> getlocationLatLon() async{
    if (positionDevice!=null) {
      locationdata= await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${positionDevice!.latitude}&lon=${positionDevice!.longitude}&appid=$apiKey&units=metric'));
      final locationdataparsed=jsonDecode(locationdata.body);

      setState(() {
            temp=locationdataparsed['main']['temp'];
            location=locationdataparsed['name'];
            code=locationdataparsed['weather'][0]['main'];
            icon=locationdataparsed['weather'].first['icon'];
          });
    }
  }
  Future<void> getpositionDevice() async{
    positionDevice=await _determinePosition();
  }
  Future<void> getlocationlatlongForecastApi() async{
    var forecastData=await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=${positionDevice!.latitude}&lon=${positionDevice!.longitude}&appid=$apiKey&units=metric'));
    var forecastdataParsed=jsonDecode(forecastData.body);
    tempeture.clear();
    cards.clear();
    datetime.clear();
    setState(() {
for(int i=7;i<=39;i+=8){
  tempeture.add(forecastdataParsed['list'][i]['main']['temp']);
  cards.add(forecastdataParsed['list'][i]['weather'][0]['icon']);
  datetime.add(forecastdataParsed['list'][i]['dt_txt']);
}
    });
  }
  Future<void> getforecastLocationApi()async{
    var forecastData=await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$apiKey&units=metric'));
    var forecastdataParsed=jsonDecode(forecastData.body);
    tempeture.clear();
    cards.clear();
    datetime.clear();

    setState(() {
      for(int i=7;i<=39;i+=8){
        tempeture.add(forecastdataParsed['list'][i]['main']['temp']);
        cards.add(forecastdataParsed['list'][i]['weather'][0]['icon']);
        datetime.add(forecastdataParsed['list'][i]['dt_txt']);
      }
    });
  }
  void initialData()async{
  await  getpositionDevice();
   await getlocationLatLon();
   await getlocationlatlongForecastApi();
  }
  @override
  void initState() {
   initialData();
   // getlocation();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/weather/$code.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: (temp==null || positionDevice==null||datetime.isEmpty || cards.isEmpty)?Center(child: CircularProgressIndicator()):
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 100.0,
                  child: Image.network('https://openweathermap.org/img/wn/$icon@4x.png')),
              Text(
                '$temp ℃',
                style: TextStyle(fontSize: 70.0, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$location',
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () async{
                     final selectCity= await  Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => searchPage()));
                   location=selectCity;
                   getlocation();
                   getforecastLocationApi();

                      },
                      icon: Icon(Icons.search)),

                ],
              ),
              buildWeatherCard(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWeatherCard(BuildContext context) {
    List<DailyWeather> dailyweatherList=[];
    for(int i=0;i<5;i++){
      dailyweatherList.add(DailyWeather(icon: cards[i], temp:tempeture[i], date: datetime[i]));
    }
    return SizedBox(
              height: 250.0,
              width: MediaQuery.of(context).size.width*0.9,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:dailyweatherList,
              ),
            );
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
