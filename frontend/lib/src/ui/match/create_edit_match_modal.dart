import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_event.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';


enum PickTime { from, to }

class CreateEditMatchModal extends StatefulWidget {
  State<CreateEditMatchModal> createState() => _CreateEditMatchModalState();
}

class _CreateEditMatchModalState extends State<CreateEditMatchModal> {
  MatchBloc bloc;
  final _formKey = GlobalKey<FormState>();
  final validator = CreateEditMatchValidator();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  bool _showPassword = false;
  DateTime _date = DateTime.now().add(Duration(hours: 1));
  DateTime _startTime;
  DateTime _endTime;

  @override
  void initState() {
    bloc = BlocProvider.of<MatchBloc>(context);
    bloc.add(MatchResetAdding());
    super.initState();
  }

  _combineDateWithTime(DateTime date, DateTime time) {
    return DateTime(
        date.year, date.month, date.day, time.hour, time.minute, time.second);
  }

  void _onCreateButtonPresses() {
    if (_formKey.currentState.validate()) {
      bloc.add(MatchCreate(
          name: _nameController.text,
          description: _descriptionController.text,
          password: _showPassword ? _passwordController.text : null,
          startTime: _combineDateWithTime(_date, _startTime),
          endTime: _combineDateWithTime(_date, _endTime)));
    }
  }

  Future<void> selectDate(BuildContext context) async {
    initializeDateFormatting();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      initialDatePickerMode: DatePickerMode.day,
    );
    if (date == null) return;

    setState(() {
      if (date != null) {
      _dateController.text = DateFormat.yMMMMd("pl_PL").format(date);
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

  Future<void> selectTime(BuildContext context, PickTime type) async {
    final time = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (time == null) return;

    final timeDate = timeToDate(time);

    if (type == PickTime.from) {
      setState(() {
      _startTimeController.text = DateFormat.Hm().format(timeDate);
        _startTime = timeDate;
      });
    } else {
      _endTimeController.text = DateFormat.Hm().format(timeDate);
      setState(() {
        _endTime = timeDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MatchBloc, MatchState>(
      listener: (context, state) {
        if (state is MatchFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is MatchCreated) {
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<MatchBloc, MatchState>(builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: "Nazwa"),
                controller: _nameController,
                validator: validator.validateName,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Opis"),
                controller: _descriptionController,
                validator: validator.validateDescription,
                keyboardType: TextInputType.multiline,
                maxLines: 4
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "Hasło"),
                      controller: _passwordController,
                      validator: (value) => validator.validatePassword(value, _showPassword),
                      readOnly: !_showPassword,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Checkbox(
                      value: _showPassword,
                      onChanged: (value) {
                        setState(() {
                          _showPassword = value;
                        });
                      },
                    ),
                  )
                ],
              ),
              _dateField(),
              _startTimeField(),
              _endTimeField(),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                    onPressed: state is! MatchCreateLoading
                        ? _onCreateButtonPresses
                        : null,
                    child: Text('Stwórz mecz'),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0))),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _dateField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: "Kiedy: ",
              prefixIcon: Icon(Icons.date_range),
              hintText: 'Kiedy ma rozgrywać się mecz?',
              errorText: validator.validateDate(_date),
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            ),
            readOnly: true,
            validator: (value) {
              if (value == null || value == "") {
                return "Podaj datę";
              }
              return validator.validateDate(_date);
            }
          ),
        ),
        FlatButton(
          child: Text("Zmień"),
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            await selectDate(context);
          },
        ),
      ],
    );
  }

  Widget _startTimeField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _startTimeController,
            decoration: InputDecoration(
              labelText: "Od której: ",
              prefixIcon: Icon(Icons.access_time),
              hintText: 'O której ma się zacząć?',
              errorText: null,
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            ),
            readOnly: true,
            validator: (value) {
              if (value == null || value == "") {
                return "Podaj godzinę";
              }
              return validator.validateStartTime(_startTime);
            },
          ),
        ),
        FlatButton(
          child: Text("Zmień"),
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            await selectTime(context, PickTime.from);
          },
        ),
      ],
    );
  }

  Widget _endTimeField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: _endTimeController,
            decoration: InputDecoration(
              labelText: "Do której: ",
              prefixIcon: Icon(Icons.access_time),
              hintText: 'O której ma się zacząć?',
              errorText: validator.validateEndTime(_startTime, _endTime),
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            ),
            readOnly: true,
            validator: (value) {
              if (value == null || value == "") {
                return "Podaj godzinę";
              }
              return validator.validateEndTime(_startTime, _endTime);
            }
          ),
        ),
        FlatButton(
          child: Text("Zmień"),
          onPressed: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            await selectTime(context, PickTime.to);
          },
        ),
      ],
    );
  }
}

class CreateEditMatchValidator {
  String validateName(String name) {

    if (name.length < 4 || name.length > 20) {
      return "Nazwa powinna mieć od 4 do 20 znaków";
    }
    return null;
  }

  String validateDescription(String description) {
    if (description == null) {
      return "Podaj opis";
    }
    if (description.length > 200) {
      return "Opis powinien mieć do 200 znaków";
    }
    return null;
  }

  String validatePassword(String password, bool showPassword) {
    if (showPassword) {
      if (password == null) {
        return "Podaj hasło albo je odznacz";
      }
      if (password.length < 4 || password.length > 32) {
        return "Hasło powinno mieć od 4 do 32 znaków";
      }
    }
    return null;
  }

  String validateDate(DateTime date) {

    var now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);
    if (date.isBefore(now)) {
      return "Date nie może być w przeszłości";
    }
    return null;
  }

  String validateStartTime(DateTime start) {
    if (start == null) {
      return "Podaj godzinę";
    }
    return null;
  }

  String validateEndTime(DateTime start, DateTime end) {
    if (end == null) {
      return null;
    }
    if (!end.isAfter(start)) {
      return "Czas 'Do' musi być przed 'Od'";
    }
    return null;
  }
}
