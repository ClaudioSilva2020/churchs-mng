import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../core/constants/user_role_labels.dart';
import '../bloc/members_cubit.dart';

/// RF-017c/RF-017d: cadastro de novo membro, restrito a Pastor/Líder.
class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.member;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar membro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuário (login)'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Sobrenome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha temporária',
                helperText: 'Mínimo 8 caracteres',
              ),
            ),
            const SizedBox(height: 16),
            Text('Papel inicial', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: UserRole.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(roleLabel(r))))
                  .toList(),
              onChanged: (r) => setState(() => _role = r ?? _role),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : () => _submit(context),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final username = _usernameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || firstName.isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha usuário, nome e e-mail.')),
      );
      return;
    }
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha deve ter pelo menos 8 caracteres.')),
      );
      return;
    }

    final cubit = context.read<MembersCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() => _loading = true);
    final ok = await cubit.addMember(
      username: username,
      firstName: firstName,
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: password,
      role: _role,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      nav.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Membro cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Erro ao cadastrar. Verifique os dados ou se o usuário já existe.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
