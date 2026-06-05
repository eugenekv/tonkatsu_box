import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class CreateCollectionDialog extends StatefulWidget {
  const CreateCollectionDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => const CreateCollectionDialog(),
    );
  }

  @override
  State<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return AlertDialog(
      title: Text(l.createCollectionTitle),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          focusNode: _nameFocus,
          decoration: InputDecoration(
            labelText: l.createCollectionNameLabel,
            hintText: l.createCollectionNameHint,
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return l.createCollectionEnterName;
            }
            if (value.trim().length < 2) {
              return l.createCollectionNameTooShort;
            }
            return null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l.create),
        ),
      ],
    );
  }
}

class RenameCollectionDialog extends StatefulWidget {
  const RenameCollectionDialog({
    required this.currentName,
    super.key,
  });

  final String currentName;

  static Future<String?> show(BuildContext context, String currentName) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => RenameCollectionDialog(
        currentName: currentName,
      ),
    );
  }

  @override
  State<RenameCollectionDialog> createState() => _RenameCollectionDialogState();
}

class _RenameCollectionDialogState extends State<RenameCollectionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return AlertDialog(
      title: Text(l.renameCollectionTitle),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: l.createCollectionNameLabel,
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return l.createCollectionEnterName;
            }
            if (value.trim().length < 2) {
              return l.createCollectionNameTooShort;
            }
            return null;
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l.rename),
        ),
      ],
    );
  }
}
