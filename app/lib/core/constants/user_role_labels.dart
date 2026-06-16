import 'user_role.dart';

/// Rótulos amigáveis para [UserRole], usados no Perfil e no diretório de
/// membros (RF-017b).
String roleLabel(UserRole role) {
  switch (role) {
    case UserRole.nonMember:
      return 'Não-membro';
    case UserRole.member:
      return 'Membro';
    case UserRole.servant:
      return 'Servo';
    case UserRole.leader:
      return 'Líder de Ministério';
    case UserRole.media:
      return 'Mídia';
    case UserRole.pastor:
      return 'Pastor';
  }
}
