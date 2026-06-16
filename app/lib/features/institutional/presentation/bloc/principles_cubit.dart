import 'package:flutter_bloc/flutter_bloc.dart';

/// RF-006: princípios/valores da igreja (conteúdo estático editável pelo
/// Pastor).
///
/// TODO(backend): substituir texto mockado por GET /api/principles/ e
/// enviar edições para PUT /api/principles/.
class PrinciplesCubit extends Cubit<String> {
  PrinciplesCubit() : super(_defaultText);

  void updateText(String text) => emit(text);
}

const _defaultText = '''
A Igreja Batista Bíblica Esperança (IBBE) fundamenta sua fé e prática na Palavra de Deus, a Bíblia Sagrada, que cremos ser a Palavra inspirada por Deus, infalível e a única regra suprema de fé e conduta (2 Timóteo 3:16-17).

Cremos em um só Deus, eternamente existente em três pessoas: Pai, Filho e Espírito Santo. Cremos que Jesus Cristo é o Filho de Deus, que morreu pelos nossos pecados, ressuscitou ao terceiro dia e é o único caminho de salvação (João 14:6).

Cremos na salvação pela graça, mediante a fé em Jesus Cristo, e não por obras (Efésios 2:8-9). Cremos na importância do batismo por imersão como testemunho público da fé, e na Ceia do Senhor como memorial da Sua obra redentora.

Cremos na igreja local como corpo de Cristo, formada por pessoas regeneradas, reunidas para adoração, comunhão, ensino da Palavra, evangelismo e serviço (Atos 2:42).

Cremos na Grande Comissão: anunciar o evangelho a toda criatura, fazer discípulos e ensiná-los a obedecer aos mandamentos de Cristo (Mateus 28:19-20).

Cremos no chamado à santidade, à vida em família segundo os princípios bíblicos, e ao amor ao próximo como expressão prática da fé (Mateus 22:37-39).

Cremos na volta de Jesus Cristo, na ressurreição dos mortos e no juízo final, vivendo em expectativa e esperança dessa promessa (1 Tessalonicenses 4:16-18).
''';
