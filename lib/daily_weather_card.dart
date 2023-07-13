import 'package:flutter/material.dart';

class DailyWeather extends StatelessWidget {
  const DailyWeather(
      {Key? key, required this.icon, required this.temp, required this.date})
      : super(key: key);
  final String icon;
  final double temp;
  final String date;
  @override
  Widget build(BuildContext context) {
    List<String> weekdays = [
      'pazartesi',
      'salı',
      'çarşamba',
      'perşembe',
      'cuma',
      'cumartesi',
      'pazar'
    ];
    String weekday = weekdays[DateTime.parse(date).weekday - 1];
    return Card(
      color: Colors.transparent,
      child: SizedBox(
        height: 350.0,
        width: 100.0,
        child: Column(
          children: [
            Image.network('https://openweathermap.org/img/wn/$icon@2x.png'),
            Text(
              '$temp ℃',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text(weekday),
          ],
        ),
      ),
    );
  }
}
