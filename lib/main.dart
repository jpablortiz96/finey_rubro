
import 'package:finey/Pages/add_page_transtition.dart';
import 'package:finey/login_state.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'Pages/add_page.dart';
import 'Pages/details_page.dart';
import 'Pages/home_page.dart';
import 'Pages/login_page.dart';
import 'graph_widget.dart';
import 'login_state.dart';
import 'month_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginState>(
      create: (BuildContext context) => LoginState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: (settings) {
          if(settings.name == '/details'){
            DetailsParams params = settings.arguments;
            return MaterialPageRoute(
              builder: (BuildContext context){
                return DetailsPage(
                  params: params,
                );
              }
            );
          }
        },
        routes: {
          '/': (BuildContext context) {
            var state = Provider.of<LoginState>(context);
            if (state.isLoggedIn()) {
              return HomePage();
            } else {
              return LoginPage(
              );
            }
          },
        },
      ),
    );
  }
}
