import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart' show Platform;
import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:shaper_app/data/streams.dart';
import 'package:shaper_app/widgets/layout.dart';
import 'package:flutter_svg/flutter_svg.dart';

const choiceSymbols = {
  0: SizedBox.shrink(),
  1: Icon(Icons.airline_seat_legroom_extra),
  2: Icon(Icons.ac_unit_outlined),
  3: Icon(Icons.add_alarm_sharp),
  4: Icon(Icons.airport_shuttle)
};

class GameFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const previousScaleFactor = 1.0;
    const baseSizeIncrease = 2.0;
    return Center(
      child: Container(
        color: Colors.lightBlue.shade200,
        child: Column(
          children: [
            MyVerticalFlexConstrainBox(
              maxHeight: 50,
            ),
            context.watch<ConfigMod>().debug ? Text('DEBUG') : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text('Points', textScaleFactor: baseSizeIncrease),
                Score(
                  baseSizeIncrease: baseSizeIncrease,
                  individual: true,
                ),
                SizedBox(
                  width: 10 * baseSizeIncrease,
                ),
                Score(
                  baseSizeIncrease: baseSizeIncrease,
                  individual: false,
                ),
              ],
            ),
            Transform.scale(
              scale: previousScaleFactor,
              child: CycleInfo(
                currentCycle: false,
                baseSizeIncrease: baseSizeIncrease,
              ),
            ),
            CycleInfo(
              currentCycle: true,
              baseSizeIncrease: baseSizeIncrease,
            ),
            CycleChoice(
              baseSizeIncrease: baseSizeIncrease,
            ),
          ],
        ),
      ),
    );
  }
}

class Score extends StatelessWidget {
  const Score({
    Key key,
    @required this.baseSizeIncrease,
    @required this.individual,
  }) : super(key: key);

  final double baseSizeIncrease;
  final bool individual;

  @override
  Widget build(BuildContext context) {
    final double paddingScore = 2.0 * baseSizeIncrease;
    final double labelsMinWidth = 70 * baseSizeIncrease;
    return Card(
      color: Colors.brown.shade50,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(paddingScore),
            constraints: BoxConstraints(minWidth: labelsMinWidth),
            child: Text(individual ? 'Individual' : 'Group',
                textScaleFactor: baseSizeIncrease),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(
                paddingScore, 0.0, paddingScore, paddingScore),
            child: Text(individual ? '3' : '14',
                textScaleFactor: baseSizeIncrease),
          ),
        ],
      ),
    );
  }
}

class CycleInfo extends StatelessWidget {
  const CycleInfo({
    Key key,
    @required this.currentCycle,
    @required this.baseSizeIncrease,
  }) : super(key: key);

  final bool currentCycle;
  final double baseSizeIncrease;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(2 * baseSizeIncrease),
              child: CycleInfoTitle(
                  titleString: currentCycle ? 'Current' : 'Previous',
                  baseSizeIncrease: baseSizeIncrease),
            ),
            CycleInfoRow(
              currentCycle: currentCycle,
              baseSizeIncrease: baseSizeIncrease,
            ),
          ],
        ),
      ),
    );
  }
}

class CycleChoice extends StatelessWidget {
  const CycleChoice({
    Key key,
    @required this.baseSizeIncrease,
  }) : super(key: key);

  final double baseSizeIncrease;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(2 * baseSizeIncrease),
              child: CycleInfoTitle(
                  titleString: 'Choose:', baseSizeIncrease: baseSizeIncrease),
            ),
            CycleChoiceRow(
              baseSizeIncrease: baseSizeIncrease,
            ),
          ],
        ),
      ),
    );
  }
}

class CycleInfoRow extends StatelessWidget {
  const CycleInfoRow({
    Key key,
    @required this.currentCycle,
    @required this.baseSizeIncrease,
  }) : super(key: key);

  final bool currentCycle;
  final double baseSizeIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(2.0 * baseSizeIncrease),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0 * baseSizeIncrease,
          color: Colors.black38,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children:
            List<int>.generate(context.watch<ConfigMod>().numPlayers, (i) => i)
                .map((x) => CycleDataCell(
                      playerX: x,
                      currentCycle: currentCycle,
                      baseSizeIncrease: baseSizeIncrease,
                    ))
                .toList(),
      ),
    );
  }
}

class CycleChoiceRow extends StatelessWidget {
  const CycleChoiceRow({
    Key key,
    @required this.baseSizeIncrease,
  }) : super(key: key);

  final double baseSizeIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(2.0 * baseSizeIncrease),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0 * baseSizeIncrease,
          color: Colors.black38,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children:
            List<int>.generate(context.watch<ConfigMod>().numShapes, (i) => i)
                .map((x) => CycleChoiceCell(
                      choiceX: x + 1,
                      baseSizeIncrease: baseSizeIncrease,
                    ))
                .toList(),
      ),
    );
  }
}

class CycleInfoTitle extends StatelessWidget {
  const CycleInfoTitle({
    Key key,
    @required this.titleString,
    @required this.baseSizeIncrease,
  }) : super(key: key);

  final String titleString;
  final double baseSizeIncrease;

  @override
  Widget build(BuildContext context) {
    return Text(
      titleString,
      textScaleFactor: baseSizeIncrease,
    );
    // return Container(
    //   padding: EdgeInsets.all(5.0 * baseSizeIncrease),
    //   decoration: BoxDecoration(
    //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //       border: Border.all(
    //         width: 2.0 * baseSizeIncrease,
    //         color: Colors.black,
    //       )),
    //   child: Text(
    //     titleString,
    //     textScaleFactor: baseSizeIncrease,
    //   ),
    // );
  }
}

class CycleDataCell extends StatelessWidget {
  CycleDataCell({
    this.playerX,
    this.currentCycle,
    this.baseSizeIncrease,
  });
  final int playerX;
  final bool currentCycle;
  final double baseSizeIncrease;

  @override
  Widget build(BuildContext context) {
    final baseShapeSize = 30 * baseSizeIncrease;
    final String playerXString = playerX.toString();
    final currentChoice =
        context.watch<ClientMod>().currentChoices[playerX].toString();
    final previousChoice =
        context.watch<ClientMod>().previousChoices[playerX].toString();
    final Map<String, dynamic> shapes = context.watch<ConfigMod>().shapes;
    final List shapeColors =
        context.watch<ConfigMod>().shapeColors[playerXString];
    final String currentShape = shapeOrBlank(shapes, currentChoice);
    final String previousShape = shapeOrBlank(shapes, previousChoice);

    return Container(
      padding: EdgeInsets.all(2.0 * baseSizeIncrease),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0 * baseSizeIncrease,
          color: Colors.black38,
        ),
      ),
      child: Column(
        children: [
          Text(
            'P${1 + playerX}',
            style: TextStyle(
                color: Color.fromRGBO(
                    (shapeColors[0] / 2).round(),
                    (shapeColors[1] / 2).round(),
                    (shapeColors[2] / 2).round(),
                    1.0),
                fontSize: Theme.of(context).textTheme.bodyText1.fontSize),
            textScaleFactor: baseSizeIncrease,
          ),
          SizedBox(
            height: 2 * baseSizeIncrease,
          ),
          currentCycle
              ? SvgPicture.asset(
                  'assets/images/$currentShape.svg',
                  width: baseShapeSize,
                  height: baseShapeSize,
                  color: Color.fromRGBO(
                      shapeColors[0], shapeColors[1], shapeColors[2], 1.0),
                )
              : SvgPicture.asset(
                  'assets/images/$previousShape.svg',
                  width: baseShapeSize,
                  height: baseShapeSize,
                  color: Color.fromRGBO(
                      shapeColors[0], shapeColors[1], shapeColors[2], 1.0),
                ),
        ],
      ),
    );
  }
}

class CycleChoiceCell extends StatelessWidget {
  CycleChoiceCell({
    this.choiceX,
    this.baseSizeIncrease,
  });
  final int choiceX;
  final double baseSizeIncrease;

  @override
  Widget build(BuildContext context) {
    final baseShapeSize = 30 * baseSizeIncrease;
    final currentChoice = choiceX.toString();
    final Map<String, dynamic> shapes = context.watch<ConfigMod>().shapes;
    final String currentShape = shapeOrBlank(shapes, currentChoice);
    Color myColor = Colors.black38;

    return Container(
      padding: EdgeInsets.all(2.0 * baseSizeIncrease),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0 * baseSizeIncrease,
          color: myColor,
        ),
      ),
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              context.read<ClientMod>().chooseShape(choiceX);
            },
            child: SvgPicture.asset(
              'assets/images/$currentShape.svg',
              width: baseShapeSize,
              height: baseShapeSize,
              color: context.watch<ClientMod>().choiceShape == choiceX
                  ? Colors.blue
                  : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

String shapeOrBlank(Map<String, dynamic> shapes, String someChoice) {
  String someShape;
  if (shapes.containsKey(someChoice)) {
    someShape = shapes[someChoice];
  } else {
    someShape = 'blank';
  }
  return someShape;
}
