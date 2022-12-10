import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translateio/utils/styles.dart';
import 'package:translateio/widgets/input_field.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _dropdownValue;
  String? text;
  String? translatedText;
  var _speechToText = stt.SpeechToText();
  bool isListenting = false;
  bool connection = false;
  late StreamSubscription<InternetConnectionStatus> _connectionListener;

  final TextEditingController _controller = TextEditingController();
  final translator = GoogleTranslator();

  //Listen the Voice and Convert it to Text
  void listen() async {
    if (!isListenting) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => print('$status'),
        onError: (errorNotification) => print('$errorNotification'),
      );
      if (available) {
        _speechToText.listen(
            onResult: ((result) => setState(() {
                  text = result.recognizedWords;
                  _controller.value = _controller.value.copyWith(
                    text: text,
                    selection: TextSelection.collapsed(offset: text!.length),
                  );
                })));
      }
    } else {
      setState(() {
        isListenting == false;
      });
      _speechToText.stop();
    }
  }

  //Display the Translated Text.
  void translated_text(String locale) {
    translator.translate(_controller.text, to: locale).then((value) {
      setState(() {
        translatedText = value.text;
      });
    });
  }

  @override
  void initState() {
    _speechToText = stt.SpeechToText();
    _connectionListener = InternetConnectionChecker()
        .onStatusChange
        .listen((InternetConnectionStatus status) async {
      switch (status) {
        case InternetConnectionStatus.connected:
          setState(() {
            connection = true;
          });
          break;
        case InternetConnectionStatus.disconnected:
          setState(() {
            connection = false;
          });
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _connectionListener.cancel();
    super.dispose();
  }

  final Uri _url = Uri.parse('https://sites.google.com/view/translateio/home');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Voice Translator",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.privacy_tip_outlined),
            ),
            onTap: _launchUrl,
          )
        ],
        centerTitle: true,
      ),
      body: connection
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.all(20),
                    child: InputField(
                      title: "From",
                      hint: "Enter your text here.",
                      controller: _controller,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: Offset(
                                      0, 1), // changes position of shadow
                                ),
                              ],
                            ),
                            margin:
                                EdgeInsets.only(top: 20, left: 20, bottom: 20),
                            padding: EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 10.0),
                            child: DropdownButton<String>(
                              underline: Container(
                                height: 0,
                              ),
                              style: headingStyle,
                              isExpanded: true,
                              hint: _dropdownValue == null
                                  ? Text(
                                      "Language",
                                      style: headingStyle,
                                    )
                                  : Text(_dropdownValue!),
                              items: <String>[
                                'Chinese',
                                'Spanash',
                                'Bengali',
                                'Germany',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _dropdownValue = newValue.toString();
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_dropdownValue == "Bengali") {
                                translated_text('bn');
                              } else if (_dropdownValue == "Spanash") {
                                translated_text('es');
                              } else if (_dropdownValue == "Chinese") {
                                translated_text('zh-cn');
                              } else if (_dropdownValue == "Germany") {
                                translated_text('de');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1, vertical: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Translate',
                                    style: headingStyle,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    // <-- Icon
                                    Icons.translate_outlined,
                                    size: 24.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 20),
                    child: Text(
                      "To",
                      style: headingStyle,
                    ),
                  ),
                  Container(
                    height: 150,
                    width: 320,
                    margin: EdgeInsets.only(top: 10, left: 20),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.circular(12)),
                    child: translatedText != null
                        ? Text(
                            translatedText!,
                            style: subTitleStyle,
                          )
                        : Text(""),
                  )
                ],
              ),
            )
          : Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 35,
                    ),
                    Text(
                      "Connecting...",
                      style: titleStyle,
                    )
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: connection
          ? FloatingActionButton(
              child: Icon(
                Icons.mic,
                color: Colors.white,
              ),
              onPressed: () {
                listen();
              },
            )
          : Container(),
    );
  }
}
