import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_event.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_state.dart';
import 'package:agh_soccer/src/bloc/match_details_bloc/match_details_bloc.dart';
import 'package:agh_soccer/src/models/match.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

enum PickTime { from, to }

enum CreateEditMatchMode { create, edit }

class CreateEditMatchModal extends StatefulWidget {
  Match _match;
  CreateEditMatchMode _mode;

  CreateEditMatchModal({
    Match match,
    CreateEditMatchMode mode = CreateEditMatchMode.create
  }) {
    _mode = mode;
    if (mode == CreateEditMatchMode.edit) {
      assert(match != null);
      _match = match;
    }
  }
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
  bool _changePassword = false;
  DateTime _date = DateTime.now().add(Duration(hours: 1));
  DateTime _startTime;
  DateTime _endTime;

  bool _isCreateMode() {
    return widget._mode == CreateEditMatchMode.create;
  }

  @override
  void initState() {
    initializeDateFormatting();

    if (!_isCreateMode()) {
      _nameController.text = widget._match.name;
      _descriptionController.text = widget._match.description;

      _date = widget._match.startTime;
      _startTime = widget._match.startTime;
      _endTime = widget._match.endTime;

      _dateController.text = DateFormat.yMMMMd("pl_PL").format(_date);
      _startTimeController.text = DateFormat.Hm().format(_startTime);
      _endTimeController.text = DateFormat.Hm().format(_endTime);
    }
    bloc = BlocProvider.of<MatchBloc>(context);
    bloc.add(MatchResetAdding());
    super.initState();
  }

  _combineDateWithTime(DateTime date, DateTime time) {
    print(time.toIso8601String());
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

  void _onUpdateButtonPressed() {
    if (_formKey.currentState.validate()) {
      bloc.add(MatchUpdate(
          matchId: widget._match.sId,
          name: _nameController.text,
          description: _descriptionController.text,
          changePassword: _changePassword,
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
    return DateTime(_date.year, _date.month, _date.day, time.hour, time.minute);
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
        if (state is MatchCreated || state is MatchUpdated) {
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
              _passwordField(),
              _dateField(),
              _startTimeField(),
              _endTimeField(),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                    onPressed: () {
                      if (_isCreateMode() && state is! MatchCreateLoading) {
                        _onCreateButtonPresses();
                      }
                      if (!_isCreateMode() && state is! MatchUpdateLoading) {
                        _onUpdateButtonPressed();
                      }
                      return null;
                    },
                    child:
                        Text(_isCreateMode() ? 'Stwórz mecz' : 'Zapisz mecz'),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0))),
              ),
              SizedBox(height: 20)
            ],
          ),
        );
      }),
    );
  }


  // if it is create mode simply return password field
  // if we are in edit mode, ask whether to change password, if yes then display password field
  Widget _passwordField() {
    return Column(
      children: <Widget>[
        !_isCreateMode() ? Row(
          children: <Widget>[
            Text("Zmień hasło", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Switch(
              value: _changePassword,
              onChanged: (value) => setState(() { _changePassword = value; }),
            )
          ],
        ) : Container(),
        (!_isCreateMode() && _changePassword) || _isCreateMode() ? Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: TextFormField(
                decoration: InputDecoration(
                    labelText: _isCreateMode() ? "Hasło" : "Nowe hasło"),
                controller: _passwordController,
                validator: (value) =>
                    validator.validatePassword(value, _showPassword),
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
        ) : Container()
      ],
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
              }),
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
              }),
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
