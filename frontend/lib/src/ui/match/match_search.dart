import 'package:agh_soccer/src/bloc/match_bloc/match_event.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';
import 'package:agh_soccer/src/models/match_filter.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class SearchMatches extends StatefulWidget {
  final MatchBloc bloc;
  final MatchFilter initialFilter;
  SearchMatches({this.bloc, @required MatchFilter filter}) : initialFilter = filter;

  State<SearchMatches> createState() => _SearchMatchesState();
}

enum SearchMatchTime { from, to }

class _SearchMatchesState extends State<SearchMatches> {
  final _nameController = new TextEditingController();
  DateTime _dateFrom;
  DateTime _dateTo;
  TimeOfDay _timeFrom;
  TimeOfDay _timeTo;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.initialFilter.timeFrom;
    _dateTo = widget.initialFilter.timeTo;
    final timeNow = TimeOfDay.now();
    _timeFrom = timeNow.replacing(hour: _dateFrom.hour, minute: _dateFrom.minute);
    _timeTo = timeNow.replacing(hour: _dateTo.hour, minute: _dateTo.minute);
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

  Future<void> selectDate(BuildContext context, SearchMatchTime type) async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000, 1, 1),
        lastDate: DateTime(2022, 12, 31),
        initialDatePickerMode: DatePickerMode.day,
    );
    setState(() {
      if (date != null) {
        if (type == SearchMatchTime.from) {
          _dateFrom = date;
        } else {
          _dateTo = date;
        }
      }
    });
  }

  DateTime timeToDate(DateTime date, TimeOfDay time) {
    if (date == null) {
      date = DateTime.now();
    }
    return DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
  }

  String timeToString(TimeOfDay t) {
    if (t == null) return "";
    return DateFormat.Hm().format(DateTime(1, 1, 1, t.hour, t.minute));
  }


  void _search(context) => widget.bloc.add(
      MatchFetchByFilter(
          name: _nameController.text,
          filter: MatchFilter(
            timeFrom: timeToDate(_dateFrom, _timeFrom),
            timeTo: timeToDate(_dateTo, _timeTo),
            showPrivate: true
          )
      )
  );


  void _clear() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day, 0,0,0);
    setState(() {
      _dateFrom = midnight;
      _dateTo = midnight.add(Duration(days: 14));
      _timeFrom = TimeOfDay(hour: 8, minute: 0);
      _timeTo = TimeOfDay(hour: 23, minute: 0);
    });
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
            _chooseDate(context, SearchMatchTime.from),
            Divider(),
            _chooseDate(context, SearchMatchTime.to),
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
          onPressed: () {
            _search(context);
            Navigator.of(context).pop();
          },
          child: Text(
              "Szukaj",
              style: topBarTextStyle
          ),
        )
      ],
    );
  }

  Widget _chooseDate(BuildContext context, SearchMatchTime type) {
    initializeDateFormatting();

    final title = type == SearchMatchTime.from ? "Od dnia: " : "Do dnia: ";
    final date = type == SearchMatchTime.from ? _dateFrom : _dateTo;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title),
            SizedBox(width: 20.0),
            Icon(
              Icons.date_range,
              size: 18.0,
            ),
            Text(DateFormat.yMMMMd("pl_PL").format(date))

          ],
        ),
        FlatButton(
          child: Text("Zmień"),
          onPressed: () async {
            await selectDate(context, type);
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
