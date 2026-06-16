import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/principles_cubit.dart';

/// RF-006: princípios/valores da igreja. Editável apenas pelo Pastor.
class PrinciplesPage extends StatelessWidget {
  const PrinciplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canEdit = context.watch<AuthBloc>().state.role == UserRole.pastor;

    return BlocProvider(
      create: (_) => PrinciplesCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Princípios da Igreja')),
        body: BlocBuilder<PrinciplesCubit, String>(
          builder: (context, text) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo.png', height: 64),
                  const SizedBox(height: 16),
                  Text(
                    text.trim(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: canEdit
            ? Builder(
                builder: (context) => FloatingActionButton(
                  onPressed: () => _editText(context),
                  tooltip: 'Editar princípios',
                  child: const Icon(Icons.edit),
                ),
              )
            : null,
      ),
    );
  }

  void _editText(BuildContext context) {
    final cubit = context.read<PrinciplesCubit>();
    final controller = TextEditingController(text: cubit.state);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar princípios'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 12,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            onPressed: () {
              cubit.updateText(controller.text);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
