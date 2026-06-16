import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/service_schedule_item.dart';
import '../bloc/schedule_cubit.dart';

/// RF-007: programação semanal/mensal de cultos e eventos.
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Programação')),
        body: BlocBuilder<ScheduleCubit, List<ServiceScheduleItem>>(
          builder: (context, items) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.navy,
                      child: Text(
                        item.time.substring(0, 2),
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: Text(
                      [
                        '${item.dayOfWeek} · ${item.time}',
                        if (item.subtitle != null) item.subtitle!,
                      ].join('\n'),
                    ),
                    isThreeLine: item.subtitle != null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
