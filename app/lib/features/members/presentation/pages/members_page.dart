import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role_labels.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/members_api_service.dart';
import '../../domain/entities/member.dart';
import '../bloc/members_cubit.dart';
import 'add_member_page.dart';
import 'member_detail_page.dart';

/// RF-017b: diretório de membros da igreja, acessível ao Pastor/Líder.
class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MembersCubit(injector<MembersApiService>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Membros')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou e-mail',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: BlocBuilder<MembersCubit, List<Member>>(
                builder: (context, members) {
                  final filtered = _query.isEmpty
                      ? members
                      : members
                          .where((member) =>
                              member.name.toLowerCase().contains(_query) ||
                              member.email.toLowerCase().contains(_query))
                          .toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Nenhum membro encontrado.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.gold,
                            child: Icon(Icons.person, color: AppColors.navy),
                          ),
                          title: Text(member.name),
                          subtitle: Text('${member.email} · ${roleLabel(member.role)}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDetail(context, member),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => _openAddMember(context),
            tooltip: 'Cadastrar membro',
            child: const Icon(Icons.person_add_alt_1),
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Member member) {
    final cubit = context.read<MembersCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: MemberDetailPage(member: member),
        ),
      ),
    );
  }

  void _openAddMember(BuildContext context) {
    final cubit = context.read<MembersCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const AddMemberPage(),
        ),
      ),
    );
  }
}
