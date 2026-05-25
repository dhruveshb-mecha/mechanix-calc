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

    test('ClearPressed should NOT clear history', () async {
      final expectedStates = [
        const CalculatorState(expression: '5', result: '0', history: []),
        const CalculatorState(expression: '5+', result: '0', history: []),
        const CalculatorState(expression: '5+3', result: '0', history: []),
        isA<CalculatorState>()
            .having((s) => s.expression, 'expression', '')
            .having((s) => s.result, 'result', '8')
            .having((s) => s.history.length, 'history length', 1),
        isA<CalculatorState>()
            .having((s) => s.expression, 'expression', '')
            .having((s) => s.result, 'result', '0')
            .having((s) => s.history.length, 'history length', 1),
      ];

      expectLater(calculatorBloc.stream, emitsInOrder(expectedStates));

      // 1. Calculate something to add to history
      calculatorBloc.add(const NumberPressed('5'));
      calculatorBloc.add(const OperatorPressed('+'));
      calculatorBloc.add(const NumberPressed('3'));
      calculatorBloc.add(CalculateResult());

      // 2. Clear current calculation
      calculatorBloc.add(const ClearPressed());
    });

    test('Multiple calculations should be added to history', () {
      final expectedStates = [
        const CalculatorState(expression: '5', result: '0', history: []),
        const CalculatorState(expression: '5+', result: '0', history: []),
        const CalculatorState(expression: '5+3', result: '0', history: []),
        isA<CalculatorState>()
            .having((s) => s.expression, 'expression', '')
            .having((s) => s.result, 'result', '8')
            .having((s) => s.history.length, 'history length', 1),
        isA<CalculatorState>()
            .having((s) => s.expression, 'expression', '1')
            .having((s) => s.history.length, 'history length', 1),
        isA<CalculatorState>()
            .having((s) => s.expression, 'expression', '15')
            .having((s) => s.history.length, 'history length', 1),
        isA<CalculatorState>()
            .having((s) => s.expression, 'expression', '15+')
            .having((s) => s.history.length, 'history length', 1),
        isA<CalculatorState>()
            .having((s) => s.expression, 'expression', '15+1')
            .having((s) => s.history.length, 'history length', 1),
        isA<CalculatorState>()
            .having((s) => s.expression, 'expression', '15+10')
            .having((s) => s.history.length, 'history length', 1),
        isA<CalculatorState>()
            .having((s) => s.expression, 'expression', '')
            .having((s) => s.result, 'result', '25')
            .having((s) => s.history.length, 'history length', 2),
      ];

      expectLater(calculatorBloc.stream, emitsInOrder(expectedStates));

      // 1. First calculation
      calculatorBloc.add(const NumberPressed('5'));
      calculatorBloc.add(const OperatorPressed('+'));
      calculatorBloc.add(const NumberPressed('3'));
      calculatorBloc.add(CalculateResult());

      // 2. Second calculation
      calculatorBloc.add(const NumberPressed('1'));
      calculatorBloc.add(const NumberPressed('5'));
      calculatorBloc.add(const OperatorPressed('+'));
      calculatorBloc.add(const NumberPressed('1'));
      calculatorBloc.add(const NumberPressed('0'));
      calculatorBloc.add(CalculateResult());
    });

    test('Division by zero should show error message', () {
      final expectedStates = [
        const CalculatorState(expression: '5', result: '0', history: []),
        const CalculatorState(expression: '5÷', result: '0', history: []),
        const CalculatorState(expression: '5÷0', result: '0', history: []),
        const CalculatorState(
          expression: '5÷0',
          result: '',
          errorMessage: 'Invalid mathematical operation',
          history: [],
        ),
        const CalculatorState(
          expression: '',
          result: '0',
          errorMessage: '',
          history: [],
        ),
        const CalculatorState(
          expression: '1',
          result: '0',
          errorMessage: '',
          history: [],
        ),
      ];

      expectLater(calculatorBloc.stream, emitsInOrder(expectedStates));

      calculatorBloc.add(const NumberPressed('5'));
      calculatorBloc.add(const OperatorPressed('÷'));
      calculatorBloc.add(const NumberPressed('0'));
      calculatorBloc.add(CalculateResult());

      // Clear the error and state before pressing a new number to match expected state exactly
      calculatorBloc.add(const ClearPressed());
      calculatorBloc.add(const NumberPressed('1'));
    });

    test('Malformed expression should show error message', () {
      final expectedStates = [
        const CalculatorState(expression: '5', result: '0', history: []),
        const CalculatorState(expression: '5+', result: '0', history: []),
        const CalculatorState(
          expression: '5+',
          result: '',
          errorMessage: 'Malformed expressions',
          history: [],
        ),
        const CalculatorState(
          expression: '',
          result: '0',
          errorMessage: '',
          history: [],
        ),
      ];

      expectLater(calculatorBloc.stream, emitsInOrder(expectedStates));

      calculatorBloc.add(const NumberPressed('5'));
      calculatorBloc.add(const OperatorPressed('+'));
      calculatorBloc.add(CalculateResult());

      // Pressing AC should clear error message
      calculatorBloc.add(const ClearPressed());
    });
  });
}
