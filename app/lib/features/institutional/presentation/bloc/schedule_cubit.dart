import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/service_schedule_item.dart';

/// RF-007: programação semanal de cultos e eventos da igreja.
///
/// TODO(backend): substituir `_mockSchedule` por GET /api/schedule/.
class ScheduleCubit extends Cubit<List<ServiceScheduleItem>> {
  ScheduleCubit() : super(_mockSchedule);
}

final _mockSchedule = [
  const ServiceScheduleItem(
    id: '1',
    dayOfWeek: 'Domingo',
    time: '08h30',
    title: 'Escola Bíblica Dominical',
    subtitle: 'Tema: Evangelismo',
  ),
  const ServiceScheduleItem(
    id: '2',
    dayOfWeek: 'Domingo',
    time: '10h00',
    title: 'Culto de Adoração',
    subtitle: 'Palavra: Filipenses 1 — Pastor Ronie',
  ),
  const ServiceScheduleItem(
    id: '3',
    dayOfWeek: 'Quarta-feira',
    time: '19h30',
    title: 'Culto de Oração',
    subtitle: 'Palavra: Colossenses 1 — Pastor Ronie',
  ),
  const ServiceScheduleItem(
    id: '4',
    dayOfWeek: 'Sexta-feira',
    time: '19h30',
    title: 'Encontro de Mulheres',
  ),
  const ServiceScheduleItem(
    id: '5',
    dayOfWeek: 'Sábado',
    time: '19h00',
    title: 'Encontro da Mocidade',
  ),
];
