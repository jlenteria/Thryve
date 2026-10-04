import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    this.onSubmit,
    this.onChanged,
    this.onTap,
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextNode,
    this.validator,
    this.isPassword = false,
    this.showClear = false,
    this.onClear,
    this.suffix,
    this.prefix,
    this.capitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.minLines = 1,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.maxLength,
    this.textStyle,
    this.error,
    this.labelText,
    this.contentPadding,
    this.autofocus = false,
    this.borderWidth = 1,
    this.enableSuffixIcon = true,
    this.hasSuffixConstraints = true,
    this.enabledFocus = true,
    super.key,
  });

  final String? hint;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextNode;
  final FormFieldValidator<String?>? validator;
  final bool isPassword;
  final bool showClear;
  final Widget? suffix;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final VoidCallback? onSubmit;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onFieldSubmitted;
  final int minLines;
  final int maxLines;
  final TextAlign textAlign;
  final bool enabled;
  final int? maxLength;
  final TextStyle? textStyle;
  final Widget? error;
  final String? labelText;
  final EdgeInsets? contentPadding;
  final bool autofocus;
  final double borderWidth;
  final bool enableSuffixIcon;
  final bool hasSuffixConstraints;
  final bool enabledFocus;
  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      onChanged: (String s) {
        if (widget.showClear) {
          setState(() {});
        }
        widget.onChanged?.call(s);
      },
      obscuringCharacter: '*',
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onTap: widget.onTap,
      controller: widget.controller,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.capitalization,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      obscureText: widget.isPassword && !_showPassword,
      cursorColor: ThryvColors.onSurface,
      textAlign: widget.textAlign,
      style: widget.textStyle ??
          GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
        counterText: '',
        contentPadding:
            widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        filled: true,
        prefixIcon: widget.prefix,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 12,
        ),
        suffixIcon:
            widget.enableSuffixIcon
                ? widget.suffix ??
                    (widget.isPassword
                        ? _buildEyeSuffixIcon()
                        : widget.showClear && widget.controller.text.isNotEmpty
                        ? _buildClearIcon()
                        : null)
                : null,
        suffixIconConstraints:
            widget.hasSuffixConstraints
                ? const BoxConstraints(minWidth: 24, minHeight: 12)
                : null,
        hintText: widget.hint,
        errorMaxLines: 3,
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: ThryvColors.error,
        ),
        fillColor: widget.enabled
            ? ThryvColors.surfaceContainerLow
            : ThryvColors.surfaceContainerHigh,
        focusedBorder:
            widget.enabledFocus
                ? const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: ThryvColors.onSurface),
                )
                : null,
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: ThryvColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: ThryvColors.outlineVariant,
            width: widget.borderWidth,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: ThryvColors.onSurface,
            width: widget.borderWidth,
          ),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ThryvColors.onSurface.withValues(alpha: .3),
        ),
      ),
      onEditingComplete: () {
        switch (widget.textInputAction) {
          case TextInputAction.next:
            FocusScope.of(context).requestFocus(widget.nextNode);
            break;
          case TextInputAction.done:
            FocusManager.instance.primaryFocus?.unfocus();
            widget.onSubmit?.call();
            break;
          case TextInputAction.none:
          case TextInputAction.go:
          case TextInputAction.search:
          case TextInputAction.send:
          case TextInputAction.previous:
          case TextInputAction.continueAction:
          case TextInputAction.join:
          case TextInputAction.route:
          case TextInputAction.unspecified:
          case TextInputAction.emergencyCall:
          case TextInputAction.newline:
            break;
        }
      },
      onFieldSubmitted: widget.onFieldSubmitted,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
    );
  }

  /// Build show password suffix icon.
  Widget _buildEyeSuffixIcon() => CupertinoButton(
    padding: const EdgeInsets.only(right: 12),
    onPressed: () => setState(() => _showPassword = !_showPassword),
    minimumSize: Size.zero,
    child: Icon(
      _showPassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash_fill,
      size: 24,
      color: ThryvColors.onSurface,
    ),
  );

  /// Build show clear suffix icon.
  Widget _buildClearIcon() => CupertinoButton(
    padding: const EdgeInsets.only(right: 12),
    onPressed: () {
      setState(widget.controller.clear);
      widget.onClear?.call();
    },
    minimumSize: Size.zero,
    child: const Icon(
      CupertinoIcons.clear_circled_solid,
      size: 22,
      color: ThryvColors.onSurface,
    ),
  );
}
