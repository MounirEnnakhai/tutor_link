import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final String? initialValue;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              // DYNAMIC: Dynamically color labels depending on Light/Dark mode
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          textInputAction: textInputAction,
          focusNode: focusNode,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: theme.colorScheme.onSurfaceVariant)
                : null,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;

  const AppDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            // DYNAMIC: Header labels shift cleanly per background context
            color: theme.colorScheme.onSurfaceVariant,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          // DYNAMIC: Explicitly sets the internal popover container theme color
          dropdownColor: theme.colorScheme.surface,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: theme.colorScheme.onSurfaceVariant)
                : null,
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            // DYNAMIC: Flips options text color seamlessly
            color: theme.colorScheme.onSurface,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}