import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../core/constants/user_role_labels.dart';
import '../bloc/members_cubit.dart';

/// RF-017c/RF-017d: cadastro de novo membro, restrito a Pastor/Líder
/// administrador. Não há autocadastro público.
///
/// TODO(backend): enviar para POST /api/members/ (cria conta + envia
/// convite por e-mail).
class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserRole _role = UserRole.member;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar membro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            Text('Papel inicial', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: UserRole.values
                  .map((role) => DropdownMenuItem(value: role, child: Text(roleLabel(role))))
                  .toList(),
              onChanged: (role) => setState(() => _role = role ?? _role),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _submit(context),
                child: const Text('Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe nome e e-mail do membro.')),
      );
      return;
    }

    context.read<MembersCubit>().addMember(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          role: _role,
        );
    Navigator.of(context).pop();
  }
}
