import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translateio/utils/styles.dart';
import 'package:translateio/widgets/input_field.dart';
import 'package:translator/translator.dart';

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
  int listeningStatus = 0;

  final TextEditingController _controller = TextEditingController();
  final translator = GoogleTranslator();

  void listen() async {
    if (!isListenting) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => print('$status'),
        onError: (errorNotification) => print('$errorNotification'),
      );
      if (available) {
        _speechToText.listen(
            onSoundLevelChange: (level) {
              ;
              setState(() {
                listeningStatus = level.round();
              });
            },
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

  @override
  void initState() {
    _speechToText = stt.SpeechToText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Voice Translator",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(top: 20, left: 20, bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      child: DropdownButton<String>(
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 1, vertical: 16),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AvatarGlow(
        animate: listeningStatus != 0 ? true : false,
        glowColor: Colors.red,
        endRadius: 90.0,
        duration: Duration(milliseconds: 1500),
        repeat: true,
        showTwoGlows: true,
        repeatPauseDuration: Duration(milliseconds: 100),
        child: FloatingActionButton(
          child: Icon(
            Icons.mic,
            color: Colors.white,
          ),
          onPressed: () {
            listen();
          },
        ),
      ),
    );
  }

  void translated_text(String locale) {
    translator.translate(_controller.text, to: locale).then((value) {
      setState(() {
        translatedText = value.text;
      });
    });
  }
}
