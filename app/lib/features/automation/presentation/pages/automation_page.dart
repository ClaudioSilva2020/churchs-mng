import 'package:flutter/material.dart';

/// RF-018 a RF-021: módulo restrito de automação e câmeras.
/// Visível apenas para usuários com `hasAutomationAccess == true` (RF-004),
/// concedido individualmente pelo Pastor.
///
/// Fase 2/3 do projeto (ver REQUISITOS.md) — placeholder até a definição
/// do hardware de automação (TechIndev) e do protocolo das câmeras existentes.
class AutomationPage extends StatelessWidget {
  const AutomationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automação e Câmeras')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Módulo em desenvolvimento (Fase 2/3).\n'
            'Aguardando definição do hardware de automação e do '
            'protocolo das câmeras existentes.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
