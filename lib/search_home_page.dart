import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class searchPage extends StatefulWidget {
  const searchPage();
  @override
  State<searchPage> createState() => _searchPageState();
}
class _searchPageState extends State<searchPage> {
  String selectedCity = '';
  @override
  Widget build(BuildContext context) {
    return
      Container(
        decoration: BoxDecoration(image: DecorationImage(
          image: AssetImage('assets/weather/search.jpg'),
          fit: BoxFit.cover,
        ),),
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTextField(),
                searchButton(context),
              ],
            ),

          ),
        ),
      );
  }
  SizedBox searchButton(BuildContext context) {
    return SizedBox(

                height: 80.0,
                width: 80.0,
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.amberAccent),
                    onPressed: () async {
                      var response = await http.get(Uri.parse(
                          'https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=ad103257c6c28c194bacd315af4cdaa8&units=metric'));
                      if (response.statusCode == 200) {
                        Navigator.pop(context, selectedCity);
                      }
                      else {
                        _showMyDialog();

                      }
                    }, child: Text('selectedCity')),
              );
  }
  TextField buildTextField() {
    return TextField(
                onChanged: (value) {
                  selectedCity = value;
                },
                decoration: InputDecoration(
                  hintText: 'ŞEHİR SEÇİNİZ',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                style: TextStyle(fontSize: 30.0),
                textAlign: TextAlign.center,
              );
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('loacation not found'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('select not city'),

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


