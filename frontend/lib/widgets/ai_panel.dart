import 'package:flutter/material.dart';
import '../services/task_service.dart';

class AiPanel extends StatefulWidget {
  const AiPanel({super.key});

  @override
  State<AiPanel> createState() => _AiPanelState();
}

class _AiPanelState extends State<AiPanel> {
  final TextEditingController _controller = TextEditingController();
  Task? _attachedTask;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAccept: (data) => data != null,
      onAccept: (task) {
        setState(() {
          _attachedTask = task;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: candidateData.isNotEmpty 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildAiMessage(context, "Hello! How can I help you reorganize your day?"),
                    const SizedBox(height: 16),
                    _buildUserMessage(context, "I need to plan my studying schedule."),
                    const SizedBox(height: 16),
                    _buildAiMessage(context, "Sure. What subjects are you focusing on besides Flutter?"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_attachedTask != null) _buildAttachedTask(context),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask anything .......',
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.arrow_forward, size: 20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachedTask(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.attachment, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Attached Task",
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _attachedTask!.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.white54),
            onPressed: () => setState(() => _attachedTask = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessage(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 48),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color?.withOpacity(0.5),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(4),
            bottomLeft: Radius.circular(20),
          ),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
