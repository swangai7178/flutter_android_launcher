import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';

class TimeState {
  final String time;
  final String date;
  const TimeState(this.time, this.date);
}

class TimeBloc extends HydratedCubit<TimeState> {
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
  TimeState? fromJson(Map<String, dynamic> json) {
    return TimeState(json['time'], json['date']);
  }

  @override
  Map<String, dynamic>? toJson(TimeState state) {
    return {'time': state.time, 'date': state.date};
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}