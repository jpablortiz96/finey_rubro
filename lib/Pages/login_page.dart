import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../login_state.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TapGestureRecognizer _recognizer1;
  TapGestureRecognizer _recognizer2;

  @override
  Widget build(BuildContext context) {
    var assetImage = new AssetImage('assets/proyecto_login.png');
    var image = new Image(image: assetImage, width:50.0 ,height: 50.0,);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
                child: Container(),
            ),
            Text(
              "Controla tus ingresos y gastos",
              style: Theme.of(context).textTheme.display1,
              textAlign: TextAlign.center,  
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Image.asset('images/proyecto_login.png'),
            ),
            Text(
                "Tu asistente de finanzas personales",
                style: Theme.of(context).textTheme.caption,
            ),
            Expanded(
                flex: 1,
                child: Container()
            ),
            Consumer<LoginState>(
                builder: (BuildContext context, LoginState value, Widget child){
                  if (value.isloading()){
                    return CircularProgressIndicator();
                  }else{
                    return child;
                  }
                },
              child: RaisedButton(
                child: Text("Accede con Google"),
                onPressed: (){
                  Provider.of<LoginState>(context).login();
                },
              ),
            ),
            Expanded(child: Container()),
            Padding(
                padding: const EdgeInsets.all(32.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.body1,
                    text: "Para usar esta app debes aceptar los ",
                    children: [
                      TextSpan(
                        text: "Términos y condiciones",
                        recognizer: _recognizer1,
                        style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: " y "),
                      TextSpan(
                        text: "Política de Privacidad",
                        recognizer: _recognizer2,
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ]
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

