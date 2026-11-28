import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Small reusable building blocks shared by every feature (forms, lists, status, bottom bars).

enum StatusTone {
  success(AppColors.success, AppColors.successTint),
  warning(AppColors.warning, AppColors.warningTint),
  info(AppColors.info, AppColors.infoTint),
  neutral(AppColors.muted, AppColors.neutralTint),
  danger(AppColors.danger, Color(0xFFF8E4E2));

  const StatusTone(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.tone});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: tone.background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: tone.foreground, fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing, this.padding = const EdgeInsets.fromLTRB(0, 22, 0, 10)});

  final String text;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Square icon holder used in lists and headers.
class IconBox extends StatelessWidget {
  const IconBox(this.icon, {super.key, this.size = 40, this.filled = false, this.color = AppColors.navy});

  final IconData icon;
  final double size;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? color : Colors.white,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: filled ? null : Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: size * 0.55, color: filled ? Colors.white : color),
    );
  }
}

/// A form field with its label above it; [required] adds a red asterisk.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child, this.required = false});

  final String label;
  final Widget child;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              children: [
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.danger),
                  ),
              ],
            ),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

/// White rounded group whose children are separated by hairlines.
class ListGroup extends StatelessWidget {
  const ListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const Divider(), children[i]],
        ],
      ),
    );
  }
}

/// Row inside a [ListGroup]: icon, title (+ subtitle), optional value and chevron.
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.onTap,
    this.destructive = false,
    this.valueLtr = false,
    this.valueColor = AppColors.muted,
    this.roundIcon = false,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;
  final bool valueLtr;
  final Color valueColor;

  /// Shows the icon inside a soft grey circle (account / settings lists).
  final bool roundIcon;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              if (roundIcon)
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.neutralTint, shape: BoxShape.circle),
                  child: Icon(icon, size: 21, color: destructive ? AppColors.danger : AppColors.ink),
                )
              else
                Icon(icon, size: 22, color: destructive ? AppColors.danger : AppColors.navy),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, color: color)),
                  if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
            if (value != null)
              Text(
                value!,
                textDirection: valueLtr ? TextDirection.ltr : null,
                style: TextStyle(fontSize: 14, color: valueColor, fontWeight: FontWeight.w500),
              ),
            if (onTap != null && !destructive) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.subtle),
            ],
          ],
        ),
      ),
    );
  }
}

/// Selectable card with a radio ring (single choice lists).
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.footer,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? footer;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? AppColors.navy : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _RadioRing(selected: selected),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      if (subtitle != null)
                        Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      ?footer,
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioRing extends StatelessWidget {
  const _RadioRing({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? AppColors.navy : const Color(0xFFB9B7AD), width: 2),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
            )
          : null,
    );
  }
}

/// Row with a square check box (multi-choice lists).
class CheckRow extends StatelessWidget {
  const CheckRow({super.key, required this.title, required this.checked, required this.onChanged, this.trailing});

  final String title;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: checked ? AppColors.navy : const Color(0xFFB9B7AD), width: 2),
              ),
              child: checked ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Single-choice chips. [expand] gives every chip the same width (short option lists).
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.expand = false,
  });

  final List<(T, String)> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final (value, label) in options)
        _Chip(label: label, selected: value == selected, onTap: () => onSelected(value)),
    ];

    if (expand) {
      return Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[if (i > 0) const SizedBox(width: 8), Expanded(child: chips[i])],
        ],
      );
    }
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? AppColors.navy : AppColors.fieldBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          // widthFactor 1: as wide as the label inside a Wrap, centred when expanded.
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Step 1 of 3 · Vehicle" with a segmented progress line.
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.step, required this.total, required this.label});

  final int step;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 1; i <= total; i++) ...[
                if (i > 1) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step ? AppColors.navy : const Color(0xFFDCDAD0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

/// White bar pinned to the bottom of a flow: optional total on the start side, main button on the end.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.button, this.caption, this.amount});

  final Widget button;
  final String? caption;
  final String? amount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: amount == null
              ? button
              : Row(
                  children: [
                    // The total keeps its natural width; the button takes the rest.
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (caption != null)
                          Text(caption!, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        Text(
                          amount!,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: button),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Libyan plate drawn as a small bordered badge.
class PlateBadge extends StatelessWidget {
  const PlateBadge(this.plate, {super.key, this.onDark = false});

  final String plate;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: onDark ? null : Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Text(
        plate,
        textDirection: TextDirection.ltr,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.ink),
      ),
    );
  }
}

/// Tinted message box (warnings, reminders, staff replies).
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.action,
    this.tone = StatusTone.warning,
  });

  final String? title;
  final String message;
  final IconData? icon;
  final Widget? action;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final background = tone == StatusTone.warning ? AppColors.notice : tone.background;
    final borderColor = tone == StatusTone.warning ? AppColors.noticeBorder : tone.background;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, color: tone.foreground, size: 24), const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) Text(title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF4A4E60), height: 1.6)),
                if (action != null) ...[const SizedBox(height: 10), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only labelled value shaped like a form field (dates, fixed values).
class FieldBox extends StatelessWidget {
  const FieldBox({super.key, required this.label, required this.value, this.icon, this.onTap});

  final String label;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 18, color: AppColors.navy)],
            ],
          ),
        ),
      ),
    );
  }
}

/// Big price with its breakdown (price calculators).
class PriceCard extends StatelessWidget {
  const PriceCard({super.key, required this.title, required this.total, this.rows = const []});

  final String title;
  final String total;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            Text(
              total,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            for (final (label, value) in rows) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                    ),
                    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
