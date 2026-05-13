import 'package:equatable/equatable.dart';

class HistoryItem {
  final String expression;
  final String result;
  final String displayResult; // pre-built, zero alloc during build()

  HistoryItem({required this.expression, required this.result})
    : displayResult = '= $result';
}

class CalculatorState extends Equatable {
  final String expression;
  final String result;
  final List<HistoryItem> history;

  const CalculatorState({
    this.expression = '',
    this.result = '0',
    this.history = const [],
  });

  CalculatorState copyWith({
    String? expression,
    String? result,
    List<HistoryItem>? history,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      history: history ?? this.history,
    );
  }

  @override
  List<Object> get props => [expression, result, history];
}
