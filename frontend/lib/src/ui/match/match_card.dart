import 'package:agh_soccer/src/models/match.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class MatchCard extends StatelessWidget {
  final Match match;

  final timeFormat = DateFormat.Hm();

  MatchCard({this.match});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    return Container(
      decoration: BoxDecoration(color: Color.fromRGBO(40, 40, 40, 0.7)),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: new BorderRadius.circular(8.0),
              child: Image.asset("assets/reservation_pitch.jpg", width: 80, height: 80)
            ),
          ),
          SizedBox(
            width: 10
          ),
          Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                          match.isPrivate
                              ? Icons.lock_outline
                              : Icons.lock_open,
                          color: match.isPrivate ? Colors.amber : Colors.grey),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(match.name),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      Text("Dzień: "),
                      Icon(Icons.date_range),
                      Text(DateFormat.yMMMMd("pl_PL").format(match.startTime))
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text("Godzina: "),
                      Icon(Icons.access_time),
                      Text(timeFormat.format(match.startTime) +
                          " - " +
                          timeFormat.format(match.endTime))
                    ],
                  )
                ],
              ))
        ],
      ),
    );
  }
}
