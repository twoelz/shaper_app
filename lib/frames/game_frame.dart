import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart' show Platform;
import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:shaper_app/data/streams.dart';
import 'package:shaper_app/widgets/layout.dart';

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
    return Center(
      child: Container(
        color: Colors.lightBlueAccent[100],
        child: Column(
          children: [
            MyVerticalFlexConstrainBox(
              maxHeight: 50,
            ),
            context.watch<ConfigMod>().debug ? Text('DEBUG') : Container(),
            Container(
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  border: Border.all(
                    width: 2.0,
                    color: Colors.black,
                  )),
              child: Text('Previous Cycle'),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [Text('Previous Cycle')],
            // ),
            FittedBox(
              child: Row(
                // PREVIOUS CYCLE
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<int>.generate(
                        context.watch<ConfigMod>().numPlayers, (i) => i)
                    .map((x) => CycleDataCell(
                          playerX: x,
                          currentCycle: false,
                          reduce: true,
                        ))
                    .toList(),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  border: Border.all(
                    width: 2.0,
                    color: Colors.black,
                  )),
              child: Text('Current Cycle'),
            ),
            Row(
              // CURRENT CYCLE
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<int>.generate(
                      context.watch<ConfigMod>().numPlayers, (i) => i)
                  .map((x) => CycleDataCell(
                        playerX: x,
                        currentCycle: true,
                      ))
                  .toList(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.airline_seat_legroom_extra),
                Icon(Icons.ac_unit_outlined),
                Icon(Icons.add_alarm_sharp)
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CycleDataCell extends StatelessWidget {
  CycleDataCell({
    this.playerX,
    this.currentCycle,
    this.reduce,
  });
  final int playerX;
  final bool currentCycle;
  final bool reduce;
  // initialize configured game data

  @override
  Widget build(BuildContext context) {
    // return Text('P${x + 1}');
    return Column(
      children: [
        Text('P${1 + playerX}',
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyText1.fontSize)),
        //TODO: change choice icons to actual choice corresponding
        currentCycle
            // ? Icon(Icons.airline_seat_legroom_extra)
            // : Icon(Icons.ac_unit_outlined),
            ? choiceSymbols[context.watch<ClientMod>().currentChoices[playerX]]
            : choiceSymbols[
                context.watch<ClientMod>().previousChoices[playerX]],
      ],
    );
  }
}
