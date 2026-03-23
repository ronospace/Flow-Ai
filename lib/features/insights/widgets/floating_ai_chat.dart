import 'package:flutter/material.dart';

class FloatingAIChat extends StatefulWidget {
  const FloatingAIChat({super.key});

  @override
  State<FloatingAIChat> createState() => _FloatingAIChatState();
}

class _FloatingAIChatState extends State<FloatingAIChat> {
  bool _open = false;

  @override
  
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Positioned(
      bottom: 90,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_open)
            Container(
              width: screen.width * 0.75,
              constraints: BoxConstraints(
                maxWidth: 300,
                maxHeight: screen.height * 0.45,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              padding: EdgeInsets.all(16),
              child: SafeArea(
                child: Center(
                  child: Text(
                    "AI Assistant",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => setState(() => _open = !_open),
            child: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
    );
  }

}
