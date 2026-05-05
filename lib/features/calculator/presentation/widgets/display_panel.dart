import 'package:flutter/material.dart';
import '../../bloc/calculator_state.dart';

class DisplayPanel extends StatelessWidget {
  final String expression;
  final String result;
  final List<HistoryItem> history;

  const DisplayPanel({
    super.key,
    required this.expression,
    required this.result,
    this.history = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Determines what is shown in the main box.
    // If an expression is actively being typed, it shows that.
    // If the expression is empty (e.g., after pressing '='), it shows the result.
    final String displayText = expression.isNotEmpty ? expression : result;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.separated(
              reverse: true,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: history.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final item = history[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.expression,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '= ${item.result}',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // const SizedBox(height: 10),
          // Single main display box
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              displayText,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
