import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomWidget extends StatefulWidget {
  final Widget? topWidget;
  final List<FilterButton> filterButtons;
  final List<SortOption> sortOptions;
  final VoidCallback? onClearSortOptionsSelected;

  final Widget Function(BuildContext, int) tileBuilder;
  final int itemCount;
  final String title;
  final Widget? leadingIcon;
  final NewButton? newButton;
  final Function(int)? onTileEdit;
  final Function(int)? onTileDelete;
  final Function(int)? onTileTap;
  final Function(int)? onTileLongPress;
  final Color? secondaryHeaderColor;
  final Color? primaryColor;
  final Color? primaryColorLight;

  const CustomWidget({
    super.key,
    required this.filterButtons,
    required this.sortOptions,
    required this.tileBuilder,
    required this.itemCount,
    this.onClearSortOptionsSelected,
    this.topWidget,
    this.newButton,
    this.title = 'Events',
    this.leadingIcon,
    this.onTileEdit,
    this.onTileDelete,
    this.onTileTap,
    this.onTileLongPress,
    this.secondaryHeaderColor,
    this.primaryColor,
    this.primaryColorLight,
  });

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = false;
  int? selectedButtonIndex;
  List<bool> _statusSelections = [];
  List<bool> _filterSelections = [];

  @override
  void initState() {
    super.initState();
    _statusSelections =
        List.generate(widget.filterButtons.length, (idx) => idx == 0);
    _filterSelections = List.generate(widget.sortOptions.length, (_) => false);

    _scrollController.addListener(() {
      if (_scrollController.offset > 300) {
        setState(() => _isVisible = true);
      } else {
        setState(() => _isVisible = false);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            widget.secondaryHeaderColor ?? theme.secondaryHeaderColor,
        leading: widget.leadingIcon ??
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                context.go('/profile');
              },
            ),
        title: Text(
          widget.title,
          style: TextStyle(color: widget.primaryColor ?? theme.primaryColor),
        ),
        actions: [
          if (!widget.sortOptions.isEmpty)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _filterSelections.any((element) => element == true)
                    ? widget.primaryColorLight ?? theme.primaryColorLight
                    : null,
              ),
              child: IconButton(
                onPressed: () => _showSortDialog(context),
                icon: Icon(Icons.sort),
              ),
            ),
          if (widget.newButton != null)
            ElevatedButton.icon(
              onPressed: widget.newButton!.onPressed,
              label: Text(widget.newButton!.label),
              icon: const Icon(Icons.add),
            )
        ],
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          if (widget.topWidget != null) widget.topWidget!,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0; i < widget.filterButtons.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8.0),
                  OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: _statusSelections[i]
                          ? WidgetStatePropertyAll(widget.primaryColorLight ??
                              theme.primaryColorLight)
                          : null,
                    ),
                    onPressed: () {
                      setState(() {
                        for (int j = 0; j < _statusSelections.length; j++) {
                          _statusSelections[j] = j == i;
                        }
                        widget.filterButtons[i].onPressed?.call();
                      });
                    },
                    child: Text(widget.filterButtons[i].label),
                  ),
                ],
              ],
            ),
          ),
          for (int i = 0; i < widget.itemCount; i++)
            widget.tileBuilder(context, i),
        ],
      ),
      floatingActionButton: _isVisible
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomSortDialog(
        sortOptions: widget.sortOptions,
        initialSelection: selectedButtonIndex,
      ),
    ).then((selectedOption) {
      if (selectedOption != null) {
        setState(() {
          _filterSelections.fillRange(0, _filterSelections.length, false);
          if (selectedOption >= 0) {
            selectedButtonIndex = selectedOption;
            _filterSelections[selectedOption] = true;
            widget.sortOptions[selectedOption].onSelected?.call();
          } else {
            selectedButtonIndex = null;
            widget.onClearSortOptionsSelected?.call();
          }
        });
      }
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

// Supporting classes
class FilterButton {
  final String label;
  final VoidCallback? onPressed;

  FilterButton({required this.label, this.onPressed});
}

class SortOption {
  final String label;
  final VoidCallback? onSelected;

  SortOption({required this.label, this.onSelected});
}

class NewButton {
  final String label;
  final VoidCallback? onPressed;

  NewButton({required this.label, required this.onPressed});
}

// Sort Dialog remains the same
class CustomSortDialog extends StatefulWidget {
  final List<SortOption> sortOptions;
  final int? initialSelection;
  final VoidCallback? onClearSortOptionsSelected;

  const CustomSortDialog({
    super.key,
    required this.sortOptions,
    this.initialSelection,
    this.onClearSortOptionsSelected,
  });

  @override
  State<CustomSortDialog> createState() => _CustomSortDialogState();
}

class _CustomSortDialogState extends State<CustomSortDialog> {
  int? selectedButtonIndex;

  @override
  void initState() {
    super.initState();
    selectedButtonIndex = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sort By'),
      content:
          const Text('Please choose one of the following options to sort by:'),
      actions: [
        Wrap(
          spacing: 8.0,
          children: List.generate(widget.sortOptions.length, (index) {
            return TextButton(
              onPressed: () {
                setState(() {
                  selectedButtonIndex =
                      selectedButtonIndex == index ? null : index;
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  selectedButtonIndex == index
                      ? Theme.of(context).primaryColorLight
                      : Colors.transparent,
                ),
                overlayColor: WidgetStateProperty.all(
                  Colors.blue.withOpacity(0.1),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: selectedButtonIndex == index
                          ? Colors.blue
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              child: Text(
                widget.sortOptions[index].label,
                style: TextStyle(
                  color: selectedButtonIndex == index
                      ? Colors.blue
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: selectedButtonIndex != null ? clearSelection : null,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear'),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey;
                    }
                    return Colors.red;
                  },
                ),
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(selectedButtonIndex),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void clearSelection() {
    setState(() {
      selectedButtonIndex = -1;
    });
  }
}
