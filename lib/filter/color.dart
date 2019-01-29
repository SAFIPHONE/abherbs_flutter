import 'dart:async';
import 'dart:io';

import 'package:abherbs_flutter/ads.dart';
import 'package:abherbs_flutter/drawer.dart';
import 'package:abherbs_flutter/filter/distribution.dart';
import 'package:abherbs_flutter/filter/filter_utils.dart';
import 'package:abherbs_flutter/filter/habitat.dart';
import 'package:abherbs_flutter/filter/petal.dart';
import 'package:abherbs_flutter/generated/i18n.dart';
import 'package:abherbs_flutter/plant_list.dart';
import 'package:abherbs_flutter/prefs.dart';
import 'package:abherbs_flutter/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

final countsReference = FirebaseDatabase.instance.reference().child(firebaseCounts);

class Color extends StatefulWidget {
  final void Function(String) onChangeLanguage;
  final void Function() onBuyProduct;
  final Map<String, String> filter;
  Color(this.onChangeLanguage, this.onBuyProduct, this.filter);

  @override
  _ColorState createState() => _ColorState();
}

class _ColorState extends State<Color> {
  Future<int> _count;
  Future<String> _rateStateF;
  Map<String, String> _filter;
  GlobalKey<ScaffoldState> _key;

  _navigate(String value) {
    var newFilter = new Map<String, String>();
    newFilter.addAll(_filter);
    newFilter[filterColor] = value;

    countsReference.child(getFilterKey(newFilter)).once().then((DataSnapshot snapshot) {
      if (snapshot.value != null && snapshot.value > 0) {
        Navigator.push(context, getNextFilterRoute(context, widget.onChangeLanguage, widget.onBuyProduct, newFilter)).then((value) {
          Ads.showBannerAd(this);
        });
      } else {
        _key.currentState.showSnackBar(SnackBar(
          content: Text(S.of(context).snack_no_flowers),
        ));
      }
    });
  }

  _setCount() {
    _count = countsReference.child(getFilterKey(_filter)).once().then((DataSnapshot snapshot) {
      return snapshot.value;
    });
  }

  Future<void> _rateDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).rate_question),
          content: Text(S.of(context).rate_text),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).rate_never),
              onPressed: () {
                Prefs.setString(keyRateState, rateStateNever).then((value) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  Navigator.of(context).pop();
                });
              },
            ),
            FlatButton(
              child: Text(S.of(context).rate_later),
              onPressed: () {
                Prefs.setInt(keyRateCount, rateCountInitial);
                Prefs.setString(keyRateState, rateStateInitial).then((value) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  Navigator.of(context).pop();
                });
              },
            ),
            FlatButton(
              child: Text(S.of(context).rate),
              onPressed: () {
                Prefs.setString(keyRateState, rateStateDid).then((value) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  Navigator.of(context).pop();
                });
                if (Platform.isAndroid) {
                  launchURL(playStore);
                } else {
                  launchURL(appStore);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _filter = new Map<String, String>();
    _filter.addAll(widget.filter);
    _filter.remove(filterColor);
    _key = new GlobalKey<ScaffoldState>();
    _rateStateF = Prefs.getStringF(keyRateState, rateStateInitial);

    _setCount();

    Ads.showBannerAd(this);
  }

  @override
  void dispose() {
    filterRoutes[filterColor] = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mainContext = context;
    var _widgets = <Widget>[];
    _widgets.add(Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            child: FlatButton(
              child: Image(
                image: AssetImage('res/images/white.webp'),
              ),
              onPressed: () {
                _navigate('1');
              },
            ),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              child: Image(
                image: AssetImage('res/images/yellow.webp'),
              ),
              onPressed: () {
                _navigate('2');
              },
            ),
            flex: 1,
          ),
        ],
      ),
    ));
    _widgets.add(Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: FlatButton(
              child: Image(
                image: AssetImage('res/images/red.webp'),
              ),
              onPressed: () {
                _navigate('3');
              },
            ),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              child: Image(
                image: AssetImage('res/images/blue.webp'),
              ),
              onPressed: () {
                _navigate('4');
              },
            ),
            flex: 1,
          ),
        ],
      ),
    ));
    _widgets.add(Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: FlatButton(
        child: Image(
          image: AssetImage('res/images/green.webp'),
        ),
        onPressed: () {
          _navigate('5');
        },
      ),
    ));
    _widgets.add(Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 70.0, right: 70.0),
      child: Text(S.of(context).color_message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
    ));

    _widgets.add(FutureBuilder<String>(
        future: _rateStateF,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data == rateStateShould) {
            return Column(children: [
              Container(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(16.0),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        S.of(context).rate_question,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      RaisedButton(
                        child: Text(S.of(context).yes),
                        onPressed: () {
                          _rateDialog().then((_) {
                            setState(() {
                              _rateStateF = Prefs.getStringF(keyRateState, rateStateInitial);
                            });
                          });
                        },
                      ),
                      RaisedButton(
                        child: Text(S.of(context).no),
                        onPressed: () {
                          Prefs.setString(keyRateState, rateStateInitial).then((result) {
                            if (result) {
                              setState(() {
                                _rateStateF = Prefs.getStringF(keyRateState, rateStateInitial);
                              });
                            }
                          });
                          Prefs.setInt(keyRateCount, rateCountInitial);
                        },
                      ),
                    ]),
                  ],
                ),
              ),
              getAdMobBanner(),
            ]);
          } else {
            return getAdMobBanner();
          }
        }));

    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(S.of(context).filter_color),
      ),
      drawer: AppDrawer(widget.onChangeLanguage, widget.onBuyProduct, _filter, null),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              "res/images/app_background.webp",
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),
          ListView(
            padding: EdgeInsets.all(5.0),
            children: _widgets,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: getBottomNavigationBarItems(context, _filter),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          var route;
          var nextFilterAttribute;
          switch (index) {
            case 1:
              route = MaterialPageRoute(builder: (context) => Habitat(widget.onChangeLanguage, widget.onBuyProduct, _filter));
              nextFilterAttribute = filterHabitat;
              break;
            case 2:
              route = MaterialPageRoute(builder: (context) => Petal(widget.onChangeLanguage, widget.onBuyProduct, _filter));
              nextFilterAttribute = filterPetal;
              break;
            case 3:
              route = MaterialPageRoute(builder: (context) => Distribution(widget.onChangeLanguage, widget.onBuyProduct, _filter));
              nextFilterAttribute = filterDistribution;
              break;
          }
          if (filterRoutes[nextFilterAttribute] != null) {
            Navigator.removeRoute(context, filterRoutes[nextFilterAttribute]);
          }
          filterRoutes[nextFilterAttribute] = route;
          Navigator.push(context, route);
        },
      ),
      floatingActionButton: Container(
        height: 70.0 + getFABPadding(),
        width: 70.0,
        padding: EdgeInsets.only(bottom: getFABPadding()),
        child: FittedBox(
          fit: BoxFit.fill,
          child: FutureBuilder<int>(
              future: _count,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          clearFilter(_filter, _setCount);
                        });
                      },
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            mainContext,
                            MaterialPageRoute(builder: (context) => PlantList(widget.onChangeLanguage, widget.onBuyProduct, _filter)),
                          ).then((value) {
                            Ads.showBannerAd(this);
                          });
                        },
                        child: Text(snapshot.data == null ? '' : snapshot.data.toString()),
                      ),
                    );
                }
              }),
        ),
      ),
    );
  }
}
