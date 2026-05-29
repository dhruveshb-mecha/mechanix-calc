import 'package:flutter/material.dart';
import '../../bloc/calculator_state.dart';

class DisplayPanel extends StatelessWidget {
  final String expression;
  final String result;
  final String errorMessage;
  final List<HistoryItem> history;
  final ValueChanged<String>? onHistoryItemTap;

  const DisplayPanel({
    super.key,
    required this.expression,
    required this.result,
    required this.errorMessage,
    this.history = const [],
    this.onHistoryItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: RepaintBoundary(
              // ← isolates list repaints
              child: _HistoryList(
                history: history,
                onHistoryItemTap: onHistoryItemTap,
              ),
            ),
          ),
          if (errorMessage.isNotEmpty) ...[
            // Show expression on top when there is an error
            Text(
              expression,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Show error message below in red and smaller font
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ] else
            // Default behavior: show expression or result
            Text(
              expression.isNotEmpty ? expression : result,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

// Extract this as a separate widget
class _HistoryList extends StatelessWidget {
  final List<HistoryItem> history;
  final ValueChanged<String>? onHistoryItemTap;

  const _HistoryList({required this.history, this.onHistoryItemTap});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: history.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        final item = history[index];
        return _HistoryTile(item: item, onTap: onHistoryItemTap);
      },
    );
  }
}

// Also extract the tile
class _HistoryTile extends StatelessWidget {
  final HistoryItem item;
  final ValueChanged<String>? onTap;

  const _HistoryTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w400);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onTap?.call(item.expression),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // 1. Expression side (Left-aligned)
            Expanded(
              flex: 3,
              child: Text(
                item.expression,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle,
              ),
            ),

            // 2. The Equals sign (Fixed width/centered)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '=',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            ),

            // 3. Result side (Right-aligned)
            Expanded(
              flex: 2,
              child: Text(
                item.result,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: textStyle.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
