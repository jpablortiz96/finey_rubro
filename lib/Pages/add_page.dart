import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../login_state.dart';
import 'category_selection_widget.dart';

class AddPage extends StatefulWidget {

  final Rect buttonRect;

  const AddPage({Key key, this.buttonRect}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with SingleTickerProviderStateMixin{
  AnimationController _controller;
  Animation _buttonAnimation;
  Animation _pageAnimation;
  String category;
  double value = 0;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
    );
    _buttonAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn)
    );
    _pageAnimation = Tween<double>(begin: -1, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn)
    );
    _controller.addListener((){
      setState(() {
      });
    });
    _controller.addStatusListener((status){
      if(status == AnimationStatus.dismissed){
        Navigator.of(context).pop();
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return Stack(
      children:[
       Transform.translate(
         offset: Offset(0, h * (1 - _pageAnimation.value)),
         child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blueAccent,
            elevation: 0.0,
            title: Text("Categorias",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.close),
                  onPressed: (){
                    _controller.reverse();
                  })
            ],
          ),
          body: _body(),
      ),
       ),
        _submit(),
    ]
    );
  }


  Widget _body(){
    var h = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        _categorySelector(),
        _currentValue(),
        _numpad(),
        SizedBox(
          height: h - widget.buttonRect.top,
        )
      ],
    );
  }

  Widget _categorySelector(){
    return Container(
      height: 80.0,
      child: CategorySelectionWidget(
        categories: {
          "Compras": Icons.shopping_cart,
          "Rumba": FontAwesomeIcons.beer,
          "Comida": FontAwesomeIcons.hamburger,
          "Cuentas": FontAwesomeIcons.wallet,
          "Cine": FontAwesomeIcons.video,
          "Servicios": FontAwesomeIcons.lightbulb,
          "Arriendo": Icons.home
        },
        onValueChanged: (newCategory) => category = newCategory,
      ),
    );
  }


  Widget _currentValue(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Text(" \$${value.toStringAsFixed(2)}",
        style: TextStyle(
          fontSize: 50.0,
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }



  Widget _num(String text, double height) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          if (text == ",") {
            value = value * 100;
          } else {
            value = value * 10 + int.parse(text);
          }
        });
      },
      child: Container(
        height: height,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 40,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _numpad() {
    return Expanded(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            var height = constraints.biggest.height / 4;

            return Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 1.0,
              ),
              children: [
                TableRow(children: [
                  _num("1", height),
                  _num("2", height),
                  _num("3", height),
                ]),
                TableRow(children: [
                  _num("4", height),
                  _num("5", height),
                  _num("6", height),
                ]),
                TableRow(children: [
                  _num("7", height),
                  _num("8", height),
                  _num("9", height),
                ]),
                TableRow(children: [
                  _num(",", height),
                  _num("0", height),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        value = value ~/ 10 + (value - value.toInt());
                      });
                    },
                    child: Container(
                      height: height,
                      child: Center(
                        child: Icon(
                          Icons.backspace,
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ]),
              ],
            );
          }),
    );
  }



  Widget _submit() {
    if(_controller.value < 1){
      var buttonWidth = widget.buttonRect.right - widget.buttonRect.left;
      return Positioned(
        top: widget.buttonRect.top,
        left: widget.buttonRect.left * (1-_buttonAnimation.value),
        right: widget.buttonRect.right * (1-_buttonAnimation.value),
        bottom: widget.buttonRect.bottom * (1-_buttonAnimation.value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              buttonWidth * (1 - _buttonAnimation.value),
            ),
              color: Colors.blueAccent),
        ),
      );
    }else {
      return Positioned(
        top: widget.buttonRect.top,
        bottom: 0,
        left: 0,
        right: 0,
        child: Builder(builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: MaterialButton(
              child: Text(
                "Añadir gasto",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                ),
              ),
              onPressed: () {
                var user = Provider.of<LoginState>(context).currentUser();
                if (category != null) {
                  if (value > 0 && category != "") {
                    Firestore.instance
                        .collection('users')
                        .document(user.uid)
                        .collection('expenses')
                        .document()
                        .setData({
                      "category": category,
                      "value": value / 1.0,
                      "month": DateTime
                          .now()
                          .month,
                      "day": DateTime
                          .now()
                          .day,
                      "year": DateTime
                          .now()
                          .year,
                    });
                    _controller.reverse();
                    //Navigator.of(context).pop();
                  } else {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text(
                            "Selecciona un valor con su categoria"))
                    );
                  }
                } else {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Selecciona un valor con su categoria")));
                }
              },
            ),
          );
        }),
      );
    }
  }
}
