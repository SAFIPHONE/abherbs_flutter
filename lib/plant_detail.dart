import 'package:abherbs_flutter/constants.dart';
import 'package:flutter/material.dart';
import 'package:abherbs_flutter/drawer.dart';
import 'package:abherbs_flutter/entity/plant.dart';
import 'package:abherbs_flutter/entity/plant_translation.dart';
import 'package:abherbs_flutter/generated/i18n.dart';
import 'package:abherbs_flutter/main.dart';
import 'package:abherbs_flutter/keys.dart';
import 'package:abherbs_flutter/entity/translations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final plantsReference = FirebaseDatabase.instance.reference().child(firebasePlants);
final translationsReference = FirebaseDatabase.instance.reference().child(firebaseTranslations);

class PlantDetail extends StatefulWidget {
  final Locale myLocale;
  final void Function(String) onChangeLanguage;
  final Map<String, String> filter;
  final String plantName;
  PlantDetail(this.myLocale, this.onChangeLanguage, this.filter, this.plantName);

  @override
  _PlantDetailState createState() => _PlantDetailState();
}

class _PlantDetailState extends State<PlantDetail> {
  Future<Plant> _plantF;
  Future<PlantTranslation> _plantTranslationF;

  @override
  void initState() {
    super.initState();

    Ads.hideBannerAd();

    _plantF = plantsReference.child(widget.plantName).once().then((DataSnapshot snapshot) {
      return Plant.fromJson(snapshot.key, snapshot.value);
    });

    _plantTranslationF = translationsReference.child(widget.myLocale.languageCode).child(widget.plantName).once().then((DataSnapshot snapshot) {
      var plantTranslation = PlantTranslation.fromJson(snapshot.value);
      if (plantTranslation != null && plantTranslation.isTranslated()) {
        return plantTranslation;
      } else {
        return translationsReference
            .child(widget.myLocale.languageCode + languageGTSuffix)
            .child(widget.plantName)
            .once()
            .then((DataSnapshot snapshot) {
          var plantTranslationGT = PlantTranslation.copy(plantTranslation);
          if (snapshot.value != null) {
            plantTranslationGT = PlantTranslation.fromJson(snapshot.value);
            plantTranslationGT.mergeWith(plantTranslation);
          }
          if (plantTranslationGT.label == null) {
            plantTranslationGT.label = widget.plantName;
          }
          if (plantTranslationGT.isTranslated()) {
            return plantTranslationGT;
          } else {
            return translationsReference
                .child(widget.myLocale.languageCode == 'cs' ? languageSlovak : languageEnglish)
                .child(widget.plantName)
                .once()
                .then((DataSnapshot snapshot) {
              var plantTranslationOriginal = PlantTranslation.fromJson(snapshot.value);
              var uri = googleTranslateEndpoint + '?key=' + translateAPIKey;
              uri += '&source=' + ('cs' == widget.myLocale.languageCode ? 'sk' : 'en');
              uri += '&target=' + widget.myLocale.languageCode;
              for (var text in plantTranslation.getTextsToTranslate(plantTranslationOriginal)) {
                uri += '&q=' + text;
              }
              return http.get(uri).then((response) {
                if (response.statusCode == 200) {
                  Translations translations = Translations.fromJson(json.decode(response.body));
                  PlantTranslation onlyGoogleTranslation = plantTranslation.fillTranslations(translations.translatedTexts, plantTranslationOriginal);
                  translationsReference
                      .child(widget.myLocale.languageCode + languageGTSuffix)
                      .child(widget.plantName)
                      .set(onlyGoogleTranslation.toJson());
                  return plantTranslation;
                } else {
                  return plantTranslation.mergeWith(plantTranslationOriginal);
                }
              });
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plantName),
      ),
      drawer: AppDrawer(widget.onChangeLanguage, widget.filter, null),
      body: FutureBuilder<PlantTranslation>(
          future: _plantTranslationF,
          builder: (BuildContext context, AsyncSnapshot<PlantTranslation> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                List<Widget> cards = [];
                cards.add(Card(
                  child: Container(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        snapshot.data.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        snapshot.data.names == null ? '' : snapshot.data.names.take(3).join(', '),
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ]),
                  ),
                ));
                cards.add(Card(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        snapshot.data.description,
                      ),
                    ]),
                  ),
                ));
                cards.add(Card(
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ListTile(
                        title: Text(S.of(context).filter_color),
                        leading: Image(
                          image: AssetImage('res/images/ic_inflorescence_grey_24dp.png'),
                          width: 24.0,
                          height: 24.0,
                        ),
                      ),
                      Text(
                        snapshot.data.inflorescence,
                      ),
                    ]),
                  ),
                ));
                cards.add(Card(
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ListTile(
                        title: Text(S.of(context).filter_color),
                        leading: Image(
                          image: AssetImage('res/images/ic_flower_grey_24dp.png'),
                          width: 24.0,
                          height: 24.0,
                        ),
                      ),
                      Text(
                        snapshot.data.flower,
                      ),
                    ]),
                  ),
                ));
                cards.add(Card(
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ListTile(
                        title: Text(S.of(context).filter_color),
                        leading: Image(
                          image: AssetImage('res/images/ic_fruit_grey_24dp.png'),
                          width: 24.0,
                          height: 24.0,
                        ),
                      ),
                      Text(
                        snapshot.data.fruit,
                      ),
                    ]),
                  ),
                ));
                cards.add(Card(
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ListTile(
                        title: Text(S.of(context).filter_color),
                        leading: Image(
                          image: AssetImage('res/images/ic_leaf_grey_24dp.png'),
                          width: 24.0,
                          height: 24.0,
                        ),
                      ),
                      Text(
                        snapshot.data.leaf,
                      ),
                    ]),
                  ),
                ));
                cards.add(Card(
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ListTile(
                        title: Text(S.of(context).filter_color),
                        leading: Image(
                          image: AssetImage('res/images/ic_stem_grey_24dp.png'),
                          width: 24.0,
                          height: 24.0,
                        ),
                      ),
                      Text(
                        snapshot.data.stem,
                      ),
                    ]),
                  ),
                ));
                cards.add(Card(
                  child: Container(
                    padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ListTile(
                        title: Text(S.of(context).filter_color),
                        leading: Image(
                          image: AssetImage('res/images/ic_home_grey_24dp.png'),
                          width: 24.0,
                          height: 24.0,
                        ),
                      ),
                      Text(
                        snapshot.data.habitat,
                      ),
                    ]),
                  ),
                ));

                // optional attributes
                if (snapshot.data.toxicity != null) {
                  cards.add(Card(
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ListTile(
                          title: Text(S.of(context).filter_color),
                          leading: Image(
                            image: AssetImage('res/images/ic_toxicity_grey_24dp.png'),
                            width: 24.0,
                            height: 24.0,
                          ),
                        ),
                        Text(
                          snapshot.data.toxicity,
                        ),
                      ]),
                    ),
                  ));
                }
                if (snapshot.data.herbalism != null) {
                  cards.add(Card(
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ListTile(
                          title: Text(S.of(context).filter_color),
                          leading: Image(
                            image: AssetImage('res/images/ic_local_pharmacy_grey_24dp.png'),
                            width: 24.0,
                            height: 24.0,
                          ),
                        ),
                        Text(
                          snapshot.data.herbalism,
                        ),
                      ]),
                    ),
                  ));
                }
                if (snapshot.data.trivia != null) {
                  cards.add(Card(
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ListTile(
                          title: Text(S.of(context).filter_color),
                          leading: Image(
                            image: AssetImage('res/images/ic_question_mark_grey_24dp.png'),
                            width: 24.0,
                            height: 24.0,
                          ),
                        ),
                        Text(
                          snapshot.data.trivia,
                        ),
                      ]),
                    ),
                  ));
                }

                return ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(5.0),
                  children: cards,
                );
              default:
                return Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator()]);
            }
          }),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.info), title: Text(S.of(context).filter_habitat)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), title: Text(S.of(context).filter_petal)),
          BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), title: Text(S.of(context).filter_distribution)),
        ],
        fixedColor: Colors.blue,
        onTap: (index) {},
      ),
    );
  }
}