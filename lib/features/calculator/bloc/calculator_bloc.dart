import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';
import 'calculator_event.dart';
import 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  CalculatorBloc() : super(const CalculatorState()) {
    on<NumberPressed>(_onNumberPressed);
    on<OperatorPressed>(_onOperatorPressed);
    on<ClearPressed>(_onClearPressed);
    on<DeletePressed>(_onDeletePressed);
    on<CalculateResult>(_onCalculateResult);
    on<ToggleSignPressed>(_onToggleSignPressed);
    on<PercentagePressed>(_onPercentagePressed);
    on<ExpressionChanged>(_onExpressionChanged);
  }

  void _onNumberPressed(NumberPressed event, Emitter<CalculatorState> emit) {
    String newExpression = state.expression;
    if (newExpression == '0' && event.number != '.') {
      newExpression = event.number;
    } else {
      newExpression += event.number;
    }
    emit(state.copyWith(expression: newExpression));
  }

  void _onOperatorPressed(
    OperatorPressed event,
    Emitter<CalculatorState> emit,
  ) {
    const operators = ['+', '-', '×', '÷', '%'];

    // 1. Handle the case where the expression is empty
    if (state.expression.isEmpty) {
      // If we have a result from a previous calculation, start the new expression with it.
      // Example: result is "30". Pressing '+' makes expression "30+"
      if (state.result.isNotEmpty) {
        emit(
          state.copyWith(
            expression: state.result + event.operator,
            result:
                '', // Optional: clear the result so it doesn't linger awkwardly
          ),
        );
      }
      return;
    }

    // 2. Handle the case where the expression is NOT empty
    String lastChar = state.expression.substring(state.expression.length - 1);

    // If the last character is already an operator, replace it
    if (operators.contains(lastChar)) {
      emit(
        state.copyWith(
          expression:
              state.expression.substring(0, state.expression.length - 1) +
              event.operator,
        ),
      );
    } else {
      // Otherwise, just append the operator
      emit(state.copyWith(expression: state.expression + event.operator));
    }
  }

  void _onClearPressed(ClearPressed event, Emitter<CalculatorState> emit) {
    emit(state.copyWith(expression: '', result: '0'));
  }

  void _onDeletePressed(DeletePressed event, Emitter<CalculatorState> emit) {
    if (state.expression.isNotEmpty) {
      emit(
        state.copyWith(
          expression: state.expression.substring(
            0,
            state.expression.length - 1,
          ),
        ),
      );
    }
  }

  void _onCalculateResult(
    CalculateResult event,
    Emitter<CalculatorState> emit,
  ) {
    if (state.expression.isEmpty) return;

    try {
      String finalExpression = state.expression
          .replaceAll(',', '')
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      GrammarParser p = GrammarParser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      String result = eval.toString();
      if (result.endsWith('.0')) {
        result = result.substring(0, result.length - 2);
      }

      // Formatting like in original image (comma for thousands)
      // Basic formatting for demonstration
      if (result.length > 3 && !result.contains('.')) {
        // simple comma injector for whole numbers
        RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
        result = result.replaceAllMapped(reg, (Match m) => '${m[1]},');
      }

      final updatedHistory = List<HistoryItem>.from(state.history)
        ..insert(0, HistoryItem(expression: state.expression, result: result));

      emit(
        state.copyWith(expression: "", result: result, history: updatedHistory),
      );
    } catch (e) {
      emit(state.copyWith(result: 'Error'));
    }
  }

  void _onToggleSignPressed(
    ToggleSignPressed event,
    Emitter<CalculatorState> emit,
  ) {
    if (state.expression.isEmpty) return;

    String expression = state.expression;
    if (expression.startsWith('-')) {
      emit(state.copyWith(expression: expression.substring(1)));
    } else {
      emit(state.copyWith(expression: '-$expression'));
    }
  }

  void _onPercentagePressed(
    PercentagePressed event,
    Emitter<CalculatorState> emit,
  ) {
    if (state.expression.isEmpty) return;
    emit(state.copyWith(expression: '${state.expression}%'));
    // Usually percentage divides by 100, but often in calculators it acts as an operator or immediate transform.
    // For simplicity here, we add the symbol and the parser might need to handle it or we handle it during evaluation.
    // math_expressions might not handle % natively as "divide by 100" in all contexts without custom setup.
  }

  void _onExpressionChanged(
    ExpressionChanged event,
    Emitter<CalculatorState> emit,
  ) {
    emit(state.copyWith(expression: event.expression, result: ''));
  }
}
