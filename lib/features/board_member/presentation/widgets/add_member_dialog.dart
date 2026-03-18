import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  final String boardId;
  const AddMemberDialog({super.key, required this.boardId});

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Member to Board"),
      content: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: "User Email",
          hintText: "example@email.com",
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const CircularProgressIndicator() : const Text("Add"),
        ),
      ],
    );
  }

  void _submit() async {
    setState(() => _isLoading = true);
    // Here you would need a search engine for users by email in Supabase
    // For simplicity, we will assume that we insert the member
    // Note: You should get the user's UUID through their email first.
    Navigator.pop(context);
  }
}