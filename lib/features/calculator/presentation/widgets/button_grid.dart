import 'package:calculator/features/calculator/bloc/calculator_bloc.dart';
import 'package:calculator/features/calculator/bloc/calculator_event.dart';
import 'package:calculator/features/calculator/presentation/widgets/calculator_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({super.key});

  // Keep the data static so it doesn't re-allocate
  static const List<List<String>> _layout = [
    ['AC', '+/-', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['⌫', '0', '.', '='],
  ];

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CalculatorBloc>();

    return Container(
      color: Colors.black,
      child: Column(
        children: _layout.map((row) {
          return Expanded(
            // Using Expanded instead of hardcoded height
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              child: Row(
                children: row.map((text) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: CalcButton(
                        text: text,
                        onTap: () => _handleTap(bloc, text),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleTap(CalculatorBloc bloc, String text) {
    if (text == 'AC')
      bloc.add(ClearPressed());
    else if (text == '⌫')
      bloc.add(DeletePressed());
    else if (text == '=')
      bloc.add(CalculateResult());
    else if (text == '+/-')
      bloc.add(ToggleSignPressed());
    else if (text == '%')
      bloc.add(PercentagePressed());
    else if (['÷', '×', '-', '+'].contains(text))
      bloc.add(OperatorPressed(text));
    else
      bloc.add(NumberPressed(text));
  }
}

class CalcButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const CalcButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Business logic for styling stays inside the widget
    final isOperator = ['÷', '×', '-', '+', '='].contains(text);
    final isAction = ['AC', '+/-', '%'].contains(text);
    final color = (isOperator || isAction)
        ? const Color(0xFF2C2C2C)
        : const Color(0xFF1A1A1A);

    return CalculatorButton(
      text: text,
      icon: text == '⌫' ? Icons.backspace_outlined : icon,
      color: color,
      onTap: onTap,
    );
  }
}
