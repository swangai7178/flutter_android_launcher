import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TimeState {
  final String time;
  final String date;
  const TimeState(this.time, this.date);
}

class TimeBloc extends Cubit<TimeState> {
  late Timer _timer;

  TimeBloc() : super(_getTime()) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(_getTime());
    });
  }

  static TimeState _getTime() {
    final now = DateTime.now();
    return TimeState(
      DateFormat('HH:mm:ss').format(now),
      DateFormat('EEEE, MMMM d, yyyy').format(now),
    );
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
