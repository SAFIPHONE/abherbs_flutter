import 'package:abherbs_flutter/constants.dart';
import 'package:abherbs_flutter/filter/filter_utils.dart';
import 'package:abherbs_flutter/drawer.dart';
import 'package:abherbs_flutter/generated/i18n.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

final countsReference = FirebaseDatabase.instance.reference().child(firebaseCounts);

class Habitat extends StatefulWidget {
  final void Function(String) onChangeLanguage;
  final Map<String, String> filter;
  Habitat(this.onChangeLanguage, this.filter);

  @override
  _HabitatState createState() => _HabitatState();
}

class _HabitatState extends State<Habitat> {
  Future<int> _count;
  Map<String, String> _filter;

  _navigate(String value) {
    var newFilter = new Map<String, String>();
    newFilter.addAll(_filter);
    newFilter[filterHabitat] = value;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => getNextFilter(widget.onChangeLanguage, newFilter)),
    );
  }

  @override
  void initState() {
    super.initState();
    _filter = new Map<String, String>();
    _filter.addAll(widget.filter);
    _filter.remove(filterHabitat);

    _count = countsReference.child(getFilterKey(_filter)).once().then((DataSnapshot snapshot) {
      return snapshot.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(S.of(context).color_of_flower),
      ),
      drawer: AppDrawer(widget.onChangeLanguage),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(5.0),
        children: [
          FlatButton(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Image(
              image: AssetImage('res/images/meadow.webp'),
            ),
            onPressed: () {
              _navigate('1');
            },
          ),
          FlatButton(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Image(
              image: AssetImage('res/images/garden.webp'),
            ),
            onPressed: () {
              _navigate('2');
            },
          ),
          FlatButton(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Image(
              image: AssetImage('res/images/swamp.webp'),
            ),
            onPressed: () {
              _navigate('3');
            },
          ),
          FlatButton(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Image(
              image: AssetImage('res/images/forest.webp'),
            ),
            onPressed: () {
              _navigate('4');
            },
          ),
          FlatButton(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Image(
              image: AssetImage('res/images/mountain.webp'),
            ),
            onPressed: () {
              _navigate('5');
            },
          ),
          FlatButton(
            padding: EdgeInsets.only(bottom: 50.0),
            child: Image(
              image: AssetImage('res/images/tree.webp'),
            ),
            onPressed: () {
              _navigate('6');
            },
          ),
        ],
      ),
      floatingActionButton: new Container(
        padding: EdgeInsets.only(bottom: 50.0),
        height: 120.0,
        width: 70.0,
        child: FittedBox(
          fit: BoxFit.fill,
          child: FutureBuilder<int>(
              future: _count,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    return FloatingActionButton(
                      onPressed: () {},
                      child: Text(snapshot.data.toString()),
                    );
                }
              }),
        ),
      ),
    );
  }
}