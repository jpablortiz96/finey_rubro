import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finey/Pages/add_page.dart';
import 'package:finey/Pages/add_page_transtition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rect_getter/rect_getter.dart';

import '../login_state.dart';
import '../month_widget.dart';
import '../utils.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

Widget _bottomAction(IconData icon, Function callback){
  return InkWell(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(icon),
    ),
    onTap: callback,
  );
}

class _HomePageState extends State<HomePage> {

  var globalKey = RectGetter.createGlobalKey();
  Rect buttonRect;

  PageController _controller;
  int currentPage = DateTime.now().month - 1;
  Stream<QuerySnapshot> _query;
  GraphType currentType = GraphType.LINES;

  @override
  void initState() {
    super.initState();

   /*_query = Firestore.instance
        .collection('expenses')
        .where("month", isEqualTo: currentPage + 1)
        .snapshots();*/

    _controller = PageController(
      initialPage: currentPage,
      viewportFraction: 0.4,
    );

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginState>(
      builder: (BuildContext context, LoginState state, Widget child){
        var user = Provider.of<LoginState>(context).currentUser();
        _query = Firestore.instance
            .collection('users')
            .document(user.uid)
            .collection('expenses')
            .where("month", isEqualTo: currentPage + 1)
            .snapshots();
        return  Scaffold(
        bottomNavigationBar: BottomAppBar(
          notchMargin: 8.0,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _bottomAction(FontAwesomeIcons.chartLine, () {
                setState(() {
                  currentType = GraphType.LINES;
                });
              }),
              _bottomAction(FontAwesomeIcons.chartPie, (){
                setState(() {
                  currentType = GraphType.PIE;
                });
              }),
              SizedBox(width: 48.0),
              _bottomAction(FontAwesomeIcons.wallet, (){}),
              _bottomAction(Icons.settings, (){}),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: RectGetter(
          key: globalKey,
          child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: (){
                buttonRect = RectGetter.getRectFromKey(globalKey);

                var page = AddPageTransition(
                  background: widget,
                  page: AddPage(
                    buttonRect: buttonRect,
                  )
                );

                Navigator.of(context).push(page);
              }
          ),
        ),
        body: _body(),
      );
      });
  }


  Widget _body(){
    return SafeArea(
      child: Column(
        children: <Widget>[
          _selector(),
          StreamBuilder<QuerySnapshot>(
              stream: _query,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> data){
                if(data.connectionState == ConnectionState.active){
                  if(data.data.documents.length > 0){
                      return MonthWidget(
                      days: daysInMonth(currentPage + 1),
                      documents: data.data.documents,
                      graphType: currentType,
                      month: currentPage,
                      );
                    }else{
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('images/gasto.png'),
                            SizedBox(height: 80,),
                            Text(
                              "¿De verdad no gastaste dinero este mes?",
                               style: Theme.of(context).textTheme.caption,
                            )
                          ],
                        ),
                      );
                  }
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
          )
        ],
      ),
    );
  }

  Widget _pageItem(String name, int position){
    var _alignment;

    final selected = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey,
    );
    final unselected = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.normal,
      color: Colors.blueGrey.withOpacity(0.4),
    );

    if(position == currentPage){
      _alignment = Alignment.center;
    } else if (position > currentPage){
      _alignment = Alignment.centerRight;
    } else {
      _alignment = Alignment.centerLeft;
    }

    return Align(
      child: Text(name,
        style: position == currentPage ? selected : unselected,
      ),
      alignment: _alignment,
    );
  }

  Widget _selector(){
    return SizedBox.fromSize(
      size: Size.fromHeight(70.0),
      child: PageView(
        onPageChanged: (newPage){
          setState(() {
            var user= Provider.of<LoginState>(context).currentUser();
            currentPage = newPage;
            _query = Firestore.instance
                .collection('users')
                .document(user.uid)
                .collection('expenses')
                .where("month", isEqualTo: currentPage + 1)
                .snapshots();
          });
        },
        controller: _controller,
        children: <Widget>[
          _pageItem("Enero", 0),
          _pageItem("Febrero", 1),
          _pageItem("Marzo", 2),
          _pageItem("Abril", 3),
          _pageItem("Mayo", 4),
          _pageItem("Junio", 5),
          _pageItem("Julio", 6),
          _pageItem("Agosto", 7),
          _pageItem("Septiembre", 8),
          _pageItem("Octubre", 9),
          _pageItem("Noviembre", 10),
          _pageItem("Diciembre", 11),
        ],
      ),
    );
  }

}