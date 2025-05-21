import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    Key? key,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return const SizedBox.shrink(); // Don't display if no error
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red[50], // Light red background
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.red[200]!)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'RETRY',
                style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
