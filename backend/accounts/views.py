from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import User
from .permissions import CanCreateUsers
from .serializers import RegisterSerializer, UserSerializer


class RegisterView(generics.CreateAPIView):
    """RF-001: auto-cadastro público — cria conta com papel nonMember."""

    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class MeView(APIView):
    """GET /api/me/ — dados do usuário autenticado (role, permissões).
    PATCH /api/me/ — RF-003: edição de perfil (nome, sobrenome, e-mail).
    """

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def patch(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class MembersView(generics.ListAPIView):
    """GET /api/members/ — diretório de membros (Pastor/Líder)."""

    queryset = User.objects.all().order_by("first_name", "last_name", "username")
    serializer_class = UserSerializer
    permission_classes = [CanCreateUsers]


class MemberDetailView(APIView):
    """PATCH /api/members/{id}/ — atualiza papel do usuário (Pastor/Líder)."""

    permission_classes = [CanCreateUsers]

    def patch(self, request, pk):
        try:
            user = User.objects.get(pk=pk)
        except User.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        role = request.data.get("role")
        if role and role in [c[0] for c in User._meta.get_field("role").choices]:
            user.role = role
            user.save(update_fields=["role"])

        return Response(UserSerializer(user).data)
