import 'package:calculator/features/calculator/presentation/widgets/button_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/calculator_bloc.dart';
import '../../bloc/calculator_event.dart';
import '../../bloc/calculator_state.dart';
import '../widgets/display_panel.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final bloc = context.read<CalculatorBloc>();
    final key = event.logicalKey;

    // Special case: Shift + '=' => '+'
    if (key == LogicalKeyboardKey.equal &&
        HardwareKeyboard.instance.isShiftPressed) {
      bloc.add(const OperatorPressed('+'));
      return;
    }

    final action = _keyMap[key];
    if (action != null) {
      bloc.add(action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<CalculatorBloc, CalculatorState>(
                  builder: (context, state) {
                    return DisplayPanel(
                      expression: state.expression,
                      result: state.result,
                      history: state.history,
                      onHistoryItemTap: (expression) {
                        context.read<CalculatorBloc>().add(
                          ExpressionChanged(expression),
                        );
                      },
                    );
                  },
                ),
              ),
              const Expanded(child: ButtonGrid()),
            ],
          ),
        ),
      ),
    );
  }
}

final Map<LogicalKeyboardKey, CalculatorEvent> _keyMap = {
  LogicalKeyboardKey.digit0: const NumberPressed('0'),
  LogicalKeyboardKey.numpad0: const NumberPressed('0'),
  LogicalKeyboardKey.digit1: const NumberPressed('1'),
  LogicalKeyboardKey.numpad1: const NumberPressed('1'),
  LogicalKeyboardKey.digit2: const NumberPressed('2'),
  LogicalKeyboardKey.numpad2: const NumberPressed('2'),
  LogicalKeyboardKey.digit3: const NumberPressed('3'),
  LogicalKeyboardKey.numpad3: const NumberPressed('3'),
  LogicalKeyboardKey.digit4: const NumberPressed('4'),
  LogicalKeyboardKey.numpad4: const NumberPressed('4'),
  LogicalKeyboardKey.digit5: const NumberPressed('5'),
  LogicalKeyboardKey.numpad5: const NumberPressed('5'),
  LogicalKeyboardKey.digit6: const NumberPressed('6'),
  LogicalKeyboardKey.numpad6: const NumberPressed('6'),
  LogicalKeyboardKey.digit7: const NumberPressed('7'),
  LogicalKeyboardKey.numpad7: const NumberPressed('7'),
  LogicalKeyboardKey.digit8: const NumberPressed('8'),
  LogicalKeyboardKey.numpad8: const NumberPressed('8'),
  LogicalKeyboardKey.digit9: const NumberPressed('9'),
  LogicalKeyboardKey.numpad9: const NumberPressed('9'),

  LogicalKeyboardKey.period: const NumberPressed('.'),
  LogicalKeyboardKey.numpadDecimal: const NumberPressed('.'),

  LogicalKeyboardKey.add: const OperatorPressed('+'),
  LogicalKeyboardKey.numpadAdd: const OperatorPressed('+'),

  LogicalKeyboardKey.minus: const OperatorPressed('-'),
  LogicalKeyboardKey.numpadSubtract: const OperatorPressed('-'),

  LogicalKeyboardKey.asterisk: const OperatorPressed('×'),
  LogicalKeyboardKey.numpadMultiply: const OperatorPressed('×'),

  LogicalKeyboardKey.slash: const OperatorPressed('÷'),
  LogicalKeyboardKey.numpadDivide: const OperatorPressed('÷'),

  LogicalKeyboardKey.percent: PercentagePressed(),

  LogicalKeyboardKey.enter: CalculateResult(),
  LogicalKeyboardKey.numpadEnter: CalculateResult(),

  LogicalKeyboardKey.backspace: DeletePressed(),
  LogicalKeyboardKey.escape: const ClearPressed(),
};
