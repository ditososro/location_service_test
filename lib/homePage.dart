import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Placemark> lokasi;
  String alamat = "";
  Future<Map<String, dynamic>> LocData;

  Future<Position> _getLoc() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true);
  }

  Future<Map<String, dynamic>> _getAddress() async {
    Position posisi = await _getLoc();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(posisi.latitude, posisi.longitude);
    alamat =
        "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, "
        "${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea} ${placemarks[0].postalCode}, "
        "${placemarks[0].country}";
    return {
      "latitude": posisi.latitude,
      "longitude": posisi.longitude,
      "alamat": alamat
    };
  }

  getData() async {
    setState(() {
      LocData = _getAddress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 12));
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Location Information"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: style,
              onPressed: getData,
              child: const Text('Get Location'),
            ),
            Container(
              child: FutureBuilder<Map<String, dynamic>>(
                  future: _getAddress(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('an error accured');
                    } else {
                      return Column(
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Longitude : ',
                              children: <TextSpan>[
                                TextSpan(
                                    text: snapshot.data["longitude"].toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'Latitude : ',
                              children: <TextSpan>[
                                TextSpan(
                                    text: snapshot.data["latitude"].toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Text(snapshot.data["alamat"],
                              overflow: TextOverflow.ellipsis),
                        ],
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
