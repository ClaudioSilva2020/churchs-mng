/// Papéis de acesso definidos em REQUISITOS.md (RF-001).
enum UserRole {
  nonMember,
  member,
  servant,
  leader,
  media,
  pastor;

  static UserRole fromApi(String value) {
    switch (value) {
      case 'member':
        return UserRole.member;
      case 'servant':
        return UserRole.servant;
      case 'leader':
        return UserRole.leader;
      case 'media':
        return UserRole.media;
      case 'pastor':
        return UserRole.pastor;
      case 'non_member':
      default:
        return UserRole.nonMember;
    }
  }

  /// RF-002: não-membro só acessa a tela inicial pública.
  bool get isMember => this != UserRole.nonMember;

  /// RF-009/RF-010: pode criar ministério e gerenciar membros.
  bool get canManageMinistries => this == UserRole.leader || this == UserRole.pastor;

  /// RF-004b: pode publicar banners/conteúdo institucional.
  bool get canPublishContent => this == UserRole.media || this == UserRole.pastor;

  /// RF-017b/RF-017c: pode acessar o diretório de membros e
  /// adicionar/remover/cadastrar membros.
  bool get canManageMembers => this == UserRole.pastor;
}
