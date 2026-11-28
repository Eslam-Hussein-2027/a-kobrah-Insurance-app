import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';

/// A form field that looks like a dropdown and opens a bottom sheet list.
/// Long lists get a search box; with [allowCustom] the typed text can be used as the value.
class ChoiceField extends FormField<String> {
  ChoiceField({
    super.key,
    required List<({String value, String label})> options,
    required String title,
    required ValueChanged<String> onChanged,
    String? value,
    String? hint,
    String? errorText,
    bool allowCustom = false,
    bool ltrLabels = false,
    super.validator,
  }) : super(
         initialValue: value,
         builder: (state) {
           final context = state.context;
           final current = state.value;
           final label = current == null
               ? null
               : options.where((o) => o.value == current).firstOrNull?.label ?? current;

           Future<void> open() async {
             final picked = await showModalBottomSheet<String>(
               context: context,
               isScrollControlled: true,
               showDragHandle: true,
               builder: (_) => _ChoiceSheet(
                 title: title,
                 options: options,
                 selected: current,
                 allowCustom: allowCustom,
                 ltrLabels: ltrLabels,
               ),
             );
             if (picked == null) return;
             state.didChange(picked);
             onChanged(picked);
           }

           return InkWell(
             borderRadius: BorderRadius.circular(14),
             onTap: open,
             child: InputDecorator(
               isEmpty: label == null,
               decoration: InputDecoration(
                 hintText: hint ?? context.l10n.tapToChoose,
                 errorText: errorText ?? state.errorText,
                 suffixIcon: const Icon(Icons.keyboard_arrow_down, color: AppColors.subtle),
               ),
               child: label == null
                   ? null
                   : Text(
                       label,
                       textDirection: ltrLabels ? TextDirection.ltr : null,
                       style: const TextStyle(fontSize: 15),
                     ),
             ),
           );
         },
       );
}

class _ChoiceSheet extends StatefulWidget {
  const _ChoiceSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.allowCustom,
    required this.ltrLabels,
  });

  final String title;
  final List<({String value, String label})> options;
  final String? selected;
  final bool allowCustom;
  final bool ltrLabels;

  @override
  State<_ChoiceSheet> createState() => _ChoiceSheetState();
}

class _ChoiceSheetState extends State<_ChoiceSheet> {
  static const _searchFrom = 10;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _query.trim().toLowerCase();
    final shown = query.isEmpty
        ? widget.options
        : widget.options
              .where((o) => o.label.toLowerCase().contains(query) || o.value.toLowerCase().contains(query))
              .toList();
    final exactMatch = widget.options.any((o) => o.label.toLowerCase() == query || o.value.toLowerCase() == query);
    final offerCustom = widget.allowCustom && query.isNotEmpty && !exactMatch;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              if (widget.allowCustom || widget.options.length >= _searchFrom)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    autofocus: widget.allowCustom,
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.search),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (offerCustom)
                      ListTile(
                        leading: const Icon(Icons.edit_outlined, color: AppColors.navy),
                        title: Text(l10n.useTypedValue(_query.trim())),
                        onTap: () => Navigator.of(context).pop(_query.trim()),
                      ),
                    for (final option in shown)
                      ListTile(
                        title: Text(
                          option.label,
                          textDirection: widget.ltrLabels ? TextDirection.ltr : null,
                          textAlign: TextAlign.start,
                        ),
                        trailing: option.value == widget.selected
                            ? const Icon(Icons.check_circle, color: AppColors.navy)
                            : null,
                        onTap: () => Navigator.of(context).pop(option.value),
                      ),
                    if (shown.isEmpty && !offerCustom)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.noResults,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
