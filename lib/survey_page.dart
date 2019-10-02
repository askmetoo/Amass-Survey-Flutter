import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'scan_page.dart';
import 'auth.dart';
import 'package:firebase_database/firebase_database.dart';

const color = Color.fromRGBO(122, 214, 217, 1);

class SurveyPage extends StatefulWidget {
  String surveyKey;

  SurveyPage({this.surveyKey});
  @override
  _SurveyPageState createState() => _SurveyPageState(surveyKey: surveyKey);
}

class _SurveyPageState extends State<SurveyPage> {
  String surveyKey;
  List<SurveyModel> items;

  Map<int, SelectedQuestion> selectedQuestionMap = Map();

  _SurveyPageState({this.surveyKey});

  var surveyFound = false;

  var authHandler = Auth();
  var _uid = '';
  final surveysReference =
      FirebaseDatabase.instance.reference().child('surveys');
  final resultsReference =
      FirebaseDatabase.instance.reference().child('results');
  StreamSubscription<Event> _onSurveyAddedSubscription;

  @override
  void initState() {
    super.initState();
    authHandler.getUser().then((var user) {
      _uid = user.uid;
    });
    items = new List();
    _onSurveyAddedSubscription =
        surveysReference.onChildAdded.listen(_onSurveyAdded);
  }

  @override
  void dispose() {
    _onSurveyAddedSubscription.cancel();
    super.dispose();
  }

  void _showMaterialDialog(BuildContext mainContext) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text(
                'Survey Submitted Successfully, You Have Received 100 Points'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(mainContext).pop();
                  },
                  child: Text('Close')),
            ],
          );
        });
  }

  void _onSurveyAdded(Event event) {
    print("key: ${event.snapshot.key} ---> $surveyKey");

    if (event.snapshot.key == surveyKey) {
      setState(() {
        surveyFound = true;
        items.add(SurveyModel.fromSnapshot(event.snapshot));
      });
    } else {
      setState(() {
        if (!surveyFound) {
          surveyFound = false;
        }
      });
    }
  }

  var _title = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Text(
          _title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: surveyFound
            ? Center(
                child: items.length > 0
                    ? _buildColumn(context)
                    : CircularProgressIndicator(),
              )
            : Center(
                child: Text('No Survey Found'),
              ),
      ),
    );
  }

  Column _buildColumn(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: Text(
              'Survey Name: ${items.first._name}',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.first.questions.length,
            itemBuilder: (BuildContext context, int index) {
              var item = items.first.questions[index];
              return Container(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'Question: ${item.value}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _buildEmoticonContainer(
                                1, item, 'assets/images/mad.png', false),
                            _buildEmoticonContainer(
                                2, item, 'assets/images/suspicious.png', true),
                            _buildEmoticonContainer(
                                3, item, 'assets/images/confused.png', false),
                            _buildEmoticonContainer(
                                4, item, 'assets/images/smiling.png', false),
                            _buildEmoticonContainer(
                                5, item, 'assets/images/happy.png', false),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width,
              );
            },
          ),
        ),
        Container(
          margin: EdgeInsets.all(40),
          child: Center(
            child: RaisedButton(
              onPressed: () {
                var results = ResultModel(
                    uid: _uid, selectedQuestionMap: selectedQuestionMap);
                resultsReference
                    .push()
                    .child(surveyKey)
                    .set(results.toJson())
                    .then((var value) {
                  _showMaterialDialog(context);
                });
              },
              color: color,
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  Container _buildEmoticonContainer(
      int id, Question item, String image, bool selected) {
    var question = SelectedQuestion(question: item, answer: id);

    var _color = Colors.white;

    if (selectedQuestionMap.containsKey(question.question.id)) {
      var s = selectedQuestionMap[question.question.id];
      if (id == s.answer) {
        _color = color;
      }
    }

    return Container(
      padding: EdgeInsets.all(6),
      color: _color,
      child: InkWell(
        onTap: () {
          setState(() {
            if (selectedQuestionMap.containsKey(question.question.id)) {
              var s = selectedQuestionMap[question.question.id];
              selectedQuestionMap.remove(question.question.id);

              if (s.answer != id) {
                selectedQuestionMap[question.question.id] = question;
              }
            } else {
              selectedQuestionMap[question.question.id] = question;
            }
          });
        },
        child: Image.asset(image),
      ),
    );
  }
}

class SurveyModel {
  String _id;
  String _uid;
  String _name;
  List<Question> _questions = List();

  SurveyModel(this._id, this._uid, this._questions);

  String get id => _id;
  String get uid => _uid;
  List<Question> get questions => _questions;

  SurveyModel.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _uid = snapshot.value['uid'];
    _name = snapshot.value['name'];

    var questionsList = List.from(snapshot.value['questions']).toSet();
    questionsList.forEach((f) {
      var m = Map.from(f);

      var id = m['id'];
      var value = m['value'];

      var q = Question(id: id, value: value);
      _questions.add(q);
    });
  }
}

class Question {
  int id;
  String value;

  Question({this.id, this.value});

  Map<String, dynamic> toJson() => {'id': id, 'value': value};
}

class SelectedQuestion {
  Question question;
  int answer;

  SelectedQuestion({this.question, this.answer});

  Map<String, dynamic> toJson() =>
      {'answer': answer, 'question': question.toJson()};
}

class ResultModel {
  String uid;
  Map<int, SelectedQuestion> selectedQuestionMap = Map();

  ResultModel({this.uid, this.selectedQuestionMap});

  _results() {
    var data = [];
    selectedQuestionMap.keys.forEach((var k) {
      var value = selectedQuestionMap[k];
      print(value);
      data.add(value.toJson());
    });
    print(data);
    return data.toList();
  }

  Map<String, dynamic> toJson() => {'uid': uid, 'answers': _results()};
}
