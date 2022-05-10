import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:intl/intl.dart' as international;
import 'package:keyboard_actions/keyboard_actions.dart';

void main() {
  runApp(const ResistorApp());
}

class ResistorApp extends StatelessWidget {
  const ResistorApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Podbirator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class ResultItem {
  final String result;
  final List<String> resultList;
  bool main;
  final double realValue;
  double realDiff = 0;
  double realDiffPercents = 0;
  ResultItem(this.result, this.resultList, this.main, this.realValue);
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _txtController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int selectedIndex = 0;
  double resistanceText = 0;
  int alg = 2;
  List<double> resistances = [];

  @override
  void initState() {
    setState(() {
      _txtController.text = "0.4";
      resistanceText = 0.4;
    });

    for (int i = -48; i < 160; i++) {
      resistances.add(calcResistanceMicroOhm(lineE24, i));
    }

    super.initState();
  }

  @override
  void dispose() {
    _txtController.dispose();
    super.dispose();
  }

  final List<int> lineE24 = [
    10,
    11,
    12,
    13,
    15,
    16,
    18,
    20,
    22,
    24,
    27,
    30,
    33,
    36,
    39,
    43,
    47,
    51,
    56,
    62,
    68,
    75,
    82,
    91,
  ];

  double calcResistanceMicroOhm(List<int> line, int index) {
    int indexInLine = (index % 24).toInt();
    int p = index ~/ 24;
    return ((line[indexInLine] / 10.0) * pow(10, p));
  }

  final f = international.NumberFormat("#.######");
  String formatValue(double value) {
    String result = "";
    result = f.format(value);
    return result;
  }

  final f0 = international.NumberFormat("#");
  final f1 = international.NumberFormat("#.#");

  String formatValue1(num n) {
    if ((n.round() - n).abs() < 0.0000001) {
      return f0.format(n);
    }
    return f1.format(n);
  }

  final f3 = international.NumberFormat("#.###");
  String formatValue3(num n) {
    return f3.format(n);
  }

  final f6 = international.NumberFormat("#.######");
  String formatValue6(num n) {
    return f6.format(n);
  }

  List<ResultItem> getResult1(double filter) {
    List<ResultItem> result = [];

    if (filter == 0) {
      return result;
    }

    Map<String, bool> repetitions = {};

    var itemsCount = resistances.length;
    for (int i = 0; i < itemsCount; i++) {
      double r = 0;
      r = resistances[i];
      var diff = (filter - r).abs();
      var percents01 = (diff / filter) * 100;
      if (percents01 < 15) {
        var resNames = formatValue(resistances[i]);
        if (!repetitions.containsKey(resNames)) {
          var resItem = ResultItem(resNames, [resNames], false, r);
          resItem.realDiffPercents = percents01;
          resItem.realDiff = diff;
          result.add(resItem);
          repetitions[resNames] = true;
        }
      }
    }

    result.sort((a, b) => a.realDiff.compareTo(b.realDiff));

    return result;
  }

  List<ResultItem> getResult2(double filter) {
    List<ResultItem> result = [];

    if (filter == 0) {
      return result;
    }

    Map<String, bool> repetitions = {};

    var itemsCount = resistances.length;
    for (int i = 0; i < itemsCount; i++) {
      for (int j = 0; j < itemsCount; j++) {
        double r = 0;
        var r1 = resistances[i];
        var r2 = resistances[j];

        r = (r1 * r2) / (r1 + r2);

        if ((r1 - filter).abs() < 0.001) {
          continue;
        }
        if ((r2 - filter).abs() < 0.001) {
          continue;
        }

        var diff = (filter - r).abs();
        var percents01 = (diff / filter) * 100;
        if (percents01 < 1) {
          var resNames =
              keyOfSet([(resistances[i] * 1000), (resistances[j] * 1000)]);
          if (!repetitions.containsKey(resNames)) {
            List<String> namesList = [];
            namesList.add(formatValue(resistances[i]));
            namesList.add(formatValue(resistances[j]));
            var resItem = ResultItem(resNames, namesList, false, r);
            resItem.realDiffPercents = percents01;
            resItem.realDiff = diff;
            result.add(resItem);
            repetitions[resNames] = true;
          }
        }
      }
    }

    result.sort((a, b) => a.realDiff.compareTo(b.realDiff));

    return result;
  }

  String keyOfSet(List<double> l) {
    String result = "";
    l.sort((a, b) => a.compareTo(b));
    for (var i in l) {
      if (result.isNotEmpty) {
        result += "  |  ";
      }
      result += formatValue(i / 1000.0);
    }
    return result;
  }

  List<ResultItem> getResult3(double filter) {
    List<ResultItem> result = [];

    if (filter == 0) {
      return result;
    }

    Map<String, bool> repetitions = {};

    var itemsCount = resistances.length;
    for (int i = 0; i < itemsCount; i++) {
      for (int j = 0; j < itemsCount; j++) {
        for (int k = 0; k < itemsCount; k++) {
          var r1 = resistances[i];
          var r2 = resistances[j];
          var r3 = resistances[k];

          if ((r1 - filter).abs() < 0.001) {
            continue;
          }
          if ((r2 - filter).abs() < 0.001) {
            continue;
          }
          if ((r3 - filter).abs() < 0.001) {
            continue;
          }

          double r = 0;
          r = (r1 * r2 * r3) / (r1 * r2 + r2 * r3 + r1 * r3);
          var diff = (filter - r).abs();
          var percents01 = (diff / filter) * 100;
          if (percents01 < 0.1) {
            var resNames = keyOfSet([
              (resistances[i] * 1000),
              (resistances[j] * 1000),
              (resistances[k] * 1000)
            ]);
            if (!repetitions.containsKey(resNames)) {
              List<String> namesList = [];
              namesList.add(formatValue(resistances[i]));
              namesList.add(formatValue(resistances[j]));
              namesList.add(formatValue(resistances[k]));
              var resItem = ResultItem(resNames, namesList, false, r);
              resItem.realDiffPercents = percents01;
              resItem.realDiff = diff;
              result.add(resItem);
              repetitions[resNames] = true;
            }
          }
        }
      }
    }

    result.sort((a, b) => a.realDiff.compareTo(b.realDiff));

    return result;
  }

  List<ResultItem> getResult(double filter) {
    List<ResultItem> result = [];

    double value = filter;

    if (value == 0) {
      result.add(ResultItem("0", [], true, 0));
      return result;
    }

    int p = 0;
    if (value < 100) {
      while (value < 100) {
        value = value * 10;
        p--;
      }
      value = value / 10;
      p++;
    } else {
      while (value > 100) {
        value = value / 10;
        p++;
      }
    }

    var intVal = value.round();

    int nearestIndex = -1;
    int nearestDiff = 0x7FFFFFFF;
    for (int i = 0; i < lineE24.length; i++) {
      int diff = (lineE24[i] - intVal).abs();
      if (diff < nearestDiff) {
        nearestDiff = diff;
        nearestIndex = i;
      }
    }

    if (nearestIndex < 0) {
      return result;
    }

    for (int i = nearestIndex - 2; i <= nearestIndex + 2; i++) {
      int realIndex = i;
      int realP = p;
      if (realIndex < 0) {
        realIndex = 24 + realIndex;
        realP -= 1;
      }
      if (realIndex > 23) {
        realIndex = realIndex - 24;
        realP += 1;
      }

      String strValue = "";
      if (realP > 0) {
        strValue = lineE24[realIndex].toString();
        for (int z = 0; z < realP; z++) {
          strValue += "0";
        }
      }
      if (realP == 0) {
        strValue = lineE24[realIndex].toString();
      }
      if (realP == -1) {
        strValue = lineE24[realIndex].toString()[0] +
            "." +
            lineE24[realIndex].toString()[1];
      }
      if (realP < -1) {
        strValue = "0.";
        for (int z = 0; z < -(realP + 2); z++) {
          strValue += "0";
        }
        strValue += lineE24[realIndex].toString();
      }

      var resValue = lineE24[realIndex] * pow(10, realP);
      result.add(ResultItem(strValue, [], false, resValue.toDouble()));
    }

    int finalNearestIndex = -1;
    double finalNearestDiff = 10000000000000000000000;

    for (int i = 0; i < result.length; i++) {
      var diff = (result[i].realValue - filter).abs();
      if (diff < finalNearestDiff) {
        finalNearestDiff = diff;
        finalNearestIndex = i;
      }
      result[i].realDiff = result[i].realValue - filter;
      result[i].realDiffPercents = ((1 - (filter / result[i].realValue)) * 100);
    }

    if (finalNearestIndex > -1) {
      result[finalNearestIndex].main = true;
    }

    return result;
  }

  Widget buildTable() {
    List<ResultItem> result = [];
    if (alg == 1) {
      result = getResult1(resistanceText);
    }
    if (alg == 2) {
      result = getResult2(resistanceText);
    }
    if (alg == 3) {
      result = getResult3(resistanceText);
    }

    int maxCount = 20;
    if (result.length < maxCount) {
      maxCount = result.length;
    }

    result = result.getRange(0, maxCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: result.asMap().keys.map<Container>((rowIndex) {
        return Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: (result[rowIndex].main ? Colors.green : Colors.black26),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: result[rowIndex].resultList.map<Widget>((e) {
                    return Container(
                      margin: const EdgeInsets.all(5),
                      constraints: const BoxConstraints(minWidth: 70),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          e,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(minWidth: 70),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        " = " + formatValue6(result[rowIndex].realValue),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    constraints: const BoxConstraints(minWidth: 70),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        formatValue3(result[rowIndex].realDiffPercents) + " %",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //config: _buildConfig(context),
        child: Container(
          alignment: Alignment.topCenter,
          child: Container(
            //color: Colors.red,
            constraints: const BoxConstraints(maxWidth: 700),
            margin: const EdgeInsets.all(5),
            child: Scrollbar(
              isAlwaysShown: true,
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "PODBIRATOR",
                      style: TextStyle(fontSize: 24, color: Colors.blue),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: const Text(
                      "'Resistors In Parallel' edition\r\n(E24 series of preferred numbers)",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: alg,
                            onChanged: (int? value) {
                              setState(() {
                                alg = value!;
                              });
                            },
                          ),
                          const Text("1R"),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: 2,
                            groupValue: alg,
                            onChanged: (int? value) {
                              setState(() {
                                alg = value!;
                              });
                            },
                          ),
                          const Text("2R"),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<int>(
                            value: 3,
                            groupValue: alg,
                            onChanged: (int? value) {
                              setState(() {
                                alg = value!;
                              });
                            },
                          ),
                          const Text("3R"),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      focusNode: _nodeText1,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: "Value",
                      ),
                      controller: _txtController,
                      style: const TextStyle(
                        fontSize: 36,
                      ),
                      onChanged: (value) {
                        setState(() {
                          try {
                            resistanceText = double.parse(value);
                          } catch (ex) {
                            resistanceText = 0;
                          }
                        });
                      },
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 50),
                    margin: const EdgeInsets.fromLTRB(50, 5, 50, 0),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: const Text(
                      "Result",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    padding: const EdgeInsets.all(5),
                    child: buildTable(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();
  final FocusNode _nodeText5 = FocusNode();
  final FocusNode _nodeText6 = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
        KeyboardActionsItem(focusNode: _nodeText2, toolbarButtons: [
              (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
        KeyboardActionsItem(
          focusNode: _nodeText3,
          onTapAction: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text("Custom Action"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  );
                });
          },
        ),
        KeyboardActionsItem(
          focusNode: _nodeText4,
          //displayCloseWidget: false,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText5,
          toolbarButtons: [
            //button 1
                (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "CLOSE",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            },
            //button 2
                (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Container(
                  color: Colors.black,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "DONE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          ],
        ),
        KeyboardActionsItem(
          focusNode: _nodeText6,
          footerBuilder: (_) => PreferredSize(
              child: SizedBox(
                  height: 40,
                  child: Center(
                    child: Text('Custom Footer'),
                  )),
              preferredSize: Size.fromHeight(40)),
        ),
      ],
    );
  }
}
