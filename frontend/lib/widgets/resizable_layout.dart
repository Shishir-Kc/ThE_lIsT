import 'package:flutter/material.dart';

class ResizableLayout extends StatefulWidget {
  final List<Widget> children;
  final List<double> initialFlex;

  const ResizableLayout({
    super.key,
    required this.children,
    this.initialFlex = const [3, 4, 3], // Default flex values matching our design
  }) : assert(children.length == initialFlex.length);

  @override
  State<ResizableLayout> createState() => _ResizableLayoutState();
}

class _ResizableLayoutState extends State<ResizableLayout> {
  late List<double> _flexValues;

  @override
  void initState() {
    super.initState();
    _flexValues = List.from(widget.initialFlex);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // Total flex units
        final totalFlex = _flexValues.reduce((a, b) => a + b);

        List<Widget> rowChildren = [];

        for (int i = 0; i < widget.children.length; i++) {
          // Add the child panel
          rowChildren.add(
            Expanded(
              flex: (_flexValues[i] * 100).toInt(), // Flex needs int
              child: widget.children[i],
            ),
          );

          // Add a divider if it's not the last child
          if (i < widget.children.length - 1) {
            rowChildren.add(
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    final delta = details.primaryDelta ?? 0;
                    // Calculate flex change based on pixel delta
                    // proportion = delta / totalWidth
                    // flexChange = proportion * totalFlex
                    final flexChange = (delta / totalWidth) * totalFlex;

                    // Apply change: increase current, decrease next
                    // Ensure we don't go below a minimum size to keep content readable
                    const double minFlex = 2.0; 
                    if (_flexValues[i] + flexChange >= minFlex && _flexValues[i+1] - flexChange >= minFlex) {
                        _flexValues[i] += flexChange;
                        _flexValues[i + 1] -= flexChange;
                    }
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: Container(
                    width: 16, // Width of the handle area
                    color: Colors.transparent, // Invisible but clickable
                    alignment: Alignment.center,
                    child: Container(
                      width: 4,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rowChildren,
        );
      },
    );
  }
}
