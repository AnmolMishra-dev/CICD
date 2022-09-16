import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
void main() {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '',),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    _initPackageInfo();
    super.initState();
    fetchProducts();

  }
  Future<dynamic> fetchProducts() async {
    final authority = "https://api.github.com/repos/AnmolMishra-dev/CICD/releases";



    final response = await http.get(Uri.parse(authority));
    if (response.statusCode == 200) {
      var jsonResponse =
    jsonDecode(response.body) as List< dynamic>;
      String Version = jsonResponse[0]['tag_name'];
      var assets = jsonResponse[0]['assets']  as List< dynamic>;
      var a=assets[1]["browser_download_url"];
      var Nameapk=assets[1]["name"];
      print(Nameapk);
      launchURL() async {
      var url = a.toString();
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String stringValue = prefs.getString('stringValue')!;
      var tag_name=Version.split("v");

      if(tag_name[1]!=stringValue){
        print('tag_name ${tag_name[1]}');
        print('assets $a.');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title:  Text("Curent Version:$stringValue",style: TextStyle(color: Colors.black),),
            content:  Text("Update Version :${tag_name[1]}",style: TextStyle(color: Colors.black),),
            actions: <Widget>[
              TextButton(
                onPressed:()=>launchURL(),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: const Text("Update",style: TextStyle(color: Colors.black),),
                ),
              ),
            ],
          ),
        );

      }else{

        print("no");
      }


    } else {
      throw Exception('Unable to fetch products from the REST API');
    }
  }

    Future<void> _initPackageInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final info = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = info;
      prefs.setString('stringValue', "${_packageInfo.version}");



    });
  }

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle.isEmpty ? 'Not set' : subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _infoTile('App name', _packageInfo.appName),
          _infoTile('Package name', _packageInfo.packageName),
          _infoTile('App version', _packageInfo.version),
          _infoTile('Build number', _packageInfo.buildNumber),
          _infoTile('Build signature', _packageInfo.buildSignature),
        ],
      ),
    );
  }
}
