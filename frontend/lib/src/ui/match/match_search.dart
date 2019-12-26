import 'package:agh_soccer/src/bloc/match_bloc/match_event.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class SearchMatches extends StatefulWidget {
  final MatchBloc bloc;

  SearchMatches({this.bloc});

  State<SearchMatches> createState() => _SearchMatchesState();
}

enum SearchMatchTime { from, to }

class _SearchMatchesState extends State<SearchMatches> {
  final _nameController = new TextEditingController();
  DateTime _date;
  TimeOfDay _timeFrom;
  TimeOfDay _timeTo;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    final timeNow = TimeOfDay.now();
    _timeFrom = timeNow.replacing(hour: timeNow.hour, minute: 0);
    _timeTo = timeNow.replacing(hour: 23, minute: 0);
    setState(() {

    });
  }

  Future<void> selectTime(BuildContext context, SearchMatchTime type) async {
    final time = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (time == null) return;
    if (type == SearchMatchTime.from) {
      setState(() {
        _timeFrom = time;
      });
    } else {
      setState(() {
        _timeTo = time;
      });
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000, 1, 1),
        lastDate: DateTime(2022, 12, 31),
        initialDatePickerMode: DatePickerMode.day,
    );
    setState(() {
      if (date != null) {
        _date = date;
      }
    });
  }

  DateTime timeToDate(TimeOfDay time) {
    if (_date == null) {
      _date = DateTime.now();
    }
    return DateTime(
        _date.year, _date.month, _date.day, time.hour, time.minute);
  }

  String timeToString(TimeOfDay t) {
    if (t == null) return "";
    return DateFormat.Hm().format(DateTime(1, 1, 1, t.hour, t.minute));
  }


  void _search(context) => widget.bloc.add(
      MatchFetchByFilter(
          name: _nameController.text,
          timeFrom: timeToDate(_timeFrom),
          timeTo: timeToDate(_timeTo),
          showPrivate: true)
  );

  void _clear() {

  }

  final topBarTextStyle = TextStyle(
      color: Colors.white.withOpacity(0.7)
  );

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          children: <Widget>[
            _filterHeader(context),
            Divider(),
            _chooseDate(context),
            Divider(),
            _chooseTime(context, "Od godziny: ", SearchMatchTime.from),
            Divider(),
            _chooseTime(context, "Do godziny: ", SearchMatchTime.to),
          ],
      ),
    );
  }

  Widget _filterHeader(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FlatButton(
            onPressed: _clear,
            child: Text(
              "Wyczyść",
              style: topBarTextStyle,
            )
        ),
        Text(
          "Filter",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white
          ),
        ),
        FlatButton(
          onPressed: () => _search(context),
          child: Text(
              "Szukaj",
              style: topBarTextStyle
          ),
        )
      ],
    );
  }

  Widget _chooseDate(context) {
    initializeDateFormatting();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text("Dzień: "),
            SizedBox(width: 20.0),
            Icon(
              Icons.date_range,
              size: 18.0,
            ),
            Text(DateFormat.yMMMMd("pl_PL").format(_date))

          ],
        ),
        FlatButton(
          child: Text("Zmień"),
          onPressed: () async {
            await selectDate(context);
          },
        ),
      ],
    );
  }

  Widget _chooseTime(BuildContext context, String title, SearchMatchTime type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title),
            SizedBox(width: 20.0),
            Icon(
              Icons.access_time,
              size: 18.0,
            ),
            Text(timeToString(type == SearchMatchTime.from ? _timeFrom : _timeTo))
          ],
        ),
        FlatButton(
          child: Text("Zmień"),
          onPressed: () async {
            await selectTime(context, type);
          },
        ),
      ],
    );
  }
}
