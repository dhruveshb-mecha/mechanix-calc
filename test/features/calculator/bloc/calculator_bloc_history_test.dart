import 'package:flutter_test/flutter_test.dart';
import 'package:calculator/features/calculator/bloc/calculator_bloc.dart';
import 'package:calculator/features/calculator/bloc/calculator_event.dart';
import 'package:calculator/features/calculator/bloc/calculator_state.dart';

void main() {
  group('CalculatorBloc', () {
    late CalculatorBloc calculatorBloc;

    setUp(() {
      calculatorBloc = CalculatorBloc();
    });

    tearDown(() {
      calculatorBloc.close();
    });

    test('initial state should be empty expression and result 0', () {
      expect(
        calculatorBloc.state,
        const CalculatorState(expression: '', result: '0', history: []),
      );
    });

    test('ClearPressed should NOT clear history', () {
      // 1. Calculate something to add to history
      calculatorBloc.add(const NumberPressed('5'));
      calculatorBloc.add(const OperatorPressed('+'));
      calculatorBloc.add(const NumberPressed('3'));
      calculatorBloc.add(CalculateResult());

      // 2. Clear current calculation
      calculatorBloc.add(const ClearPressed());

      expectLater(
        calculatorBloc.stream,
        emitsInOrder([
          const CalculatorState(expression: '5', result: '0', history: []),
          const CalculatorState(expression: '5+', result: '0', history: []),
          const CalculatorState(expression: '5+3', result: '0', history: []),
          CalculatorState(
            expression: '',
            result: '8',
            history: [HistoryItem(expression: '5+3', result: '8')],
          ),
        ]),
      );
    });
    test('Error for invalid expression', () {
      // 1. Calculate something to add to history
      calculatorBloc.add(const NumberPressed('5'));
      calculatorBloc.add(const OperatorPressed('+'));
      calculatorBloc.add(const NumberPressed('3'));
      calculatorBloc.add(CalculateResult());

      calculatorBloc.add(const NumberPressed('15'));
      calculatorBloc.add(const OperatorPressed('+'));
      calculatorBloc.add(const NumberPressed('10'));
      calculatorBloc.add(CalculateResult());

      expectLater(
        calculatorBloc.stream,
        emitsInOrder([
          const CalculatorState(expression: '5', result: '0', history: []),
          const CalculatorState(expression: '5+', result: '0', history: []),
          const CalculatorState(expression: '5+3', result: '0', history: []),
          CalculatorState(
            expression: '',
            result: '8',
            history: [HistoryItem(expression: '5+3', result: '8')],
          ),
          CalculatorState(
            expression: '15',
            result: '8',
            history: [HistoryItem(expression: '5+3', result: '8')],
          ),
          CalculatorState(
            expression: '15+',
            result: '8',
            history: [HistoryItem(expression: '5+3', result: '8')],
          ),
          CalculatorState(
            expression: '15+10',
            result: '8',
            history: [HistoryItem(expression: '5+3', result: '8')],
          ),
          CalculatorState(
            expression: '',
            result: '25',
            history: [
              HistoryItem(expression: '5+3', result: '8'),
              HistoryItem(expression: '15+10', result: '25'),
            ],
          ),
        ]),
      );
    });
  });
}
