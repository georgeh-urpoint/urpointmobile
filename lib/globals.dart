library my_prj.globals;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Dio client = Dio();

String currentLink = '';
bool refresh = false;
var notifNum = 0;
var msgNum = 0;
bool isNotif = false;
bool isMsg = false;
bool hashGot = false;
String hash = '';
var notiHTML;
var cookieUserId = '';
var requestCookie = '';

dynamic logIn() async {

  FormData formData = FormData.fromMap({
    "username": "georgehudson8",
    "password": "Aquaisuseless1",
  });

  Response request = await client.post('https://www.ur-point.com/requests.php?f=login', data: formData);

  var sessionHash = await http.get(Uri.parse('https://www.ur-point.com/index.php?login=1'));
  print('hash here');
  print(await sessionHash.toString());
}

void makeRequest(request) async{
  //makes the request
  print('getting from url with cookie request: $request');
  if(cookieUserId != '' && hashGot == true){
    http.Response response = await http.get(Uri.parse('https://www.ur-point.com/requests.php?hash=$hash&f=update_data&user_id=0&before_post_id=3285&check_posts=false&hash_posts=false&_=1672832554334'), headers: {'cookie': request});
    print('request made, waiting...');
    print('requesting from url: https://www.ur-point.com/requests.php?hash=$hash&f=update_data&user_id=0&before_post_id=3285&check_posts=false&hash_posts=false&_=1672832554334');
    print('response gotten: ${response.body}');
  }
}