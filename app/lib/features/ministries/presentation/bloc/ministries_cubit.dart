import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ministry.dart';

/// Lista de ministérios da igreja (RF-009).
///
/// TODO(backend): substituir `_initialMinistries` por GET /api/ministries/ e
/// enviar criação para POST /api/ministries/.
class MinistriesCubit extends Cubit<List<Ministry>> {
  MinistriesCubit() : super(_initialMinistries);

  void createMinistry({
    required String name,
    required String description,
    bool hasSchedule = false,
  }) {
    final ministry = Ministry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      description: description,
      hasSchedule: hasSchedule,
    );
    emit([...state, ministry]);
  }
}

/// Cadastro inicial confirmado em REQUISITOS.md (seção 9.1).
/// Escala (RF-014) disponível apenas em Louvor, Mulheres, Libras, PGs e Missões.
final _initialMinistries = [
  const Ministry(
    id: '1',
    name: 'Louvor',
    description: 'Repertório, tons e escalas de culto',
    hasSchedule: true,
    hasRepertoire: true,
  ),
  const Ministry(id: '2', name: 'Homens', description: 'Encontros e discipulado'),
  const Ministry(
    id: '3',
    name: 'Mulheres',
    description: 'Encontros e discipulado',
    hasSchedule: true,
  ),
  const Ministry(
    id: '4',
    name: 'Libras',
    description: 'Acessibilidade em Libras',
    hasSchedule: true,
  ),
  const Ministry(id: '5', name: 'Pastoral', description: 'Cuidado pastoral'),
  const Ministry(
    id: '6',
    name: 'PGs',
    description: 'Pequenos Grupos',
    hasSchedule: true,
  ),
  const Ministry(id: '7', name: 'Aconselhamento', description: 'Apoio e aconselhamento'),
  const Ministry(
    id: '8',
    name: 'Missões',
    description: 'Ação missionária',
    hasSchedule: true,
  ),
];
