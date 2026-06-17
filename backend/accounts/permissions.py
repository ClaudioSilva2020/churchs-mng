from rest_framework.permissions import SAFE_METHODS, BasePermission


class IsPastor(BasePermission):
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.role == "pastor")


class CanPublishContentOrReadOnly(BasePermission):
    """RF-005/RF-006/RF-007/RF-008c: leitura pública, escrita só Mídia/Pastor."""

    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.can_publish_content
        )


class CanManageMinistriesOrReadOnly(BasePermission):
    """RF-009: leitura para membros autenticados, escrita só Líder/Pastor."""

    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        if request.method in SAFE_METHODS:
            return True
        return request.user.can_manage_ministries


class CanManageMembers(BasePermission):
    """RF-017b/c/d: apenas o Pastor administra membros."""

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.can_manage_members
        )


class CanCreateUsers(BasePermission):
    """RF-017c: apenas Pastor e Líder criam contas de usuário."""

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role in ("leader", "pastor")
        )
