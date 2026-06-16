# Arquitetura Backend — ChurchsMng

**Responsável:** Backend Architect (Python) | **Data:** 2026-06-13 | **Status:** Proposta v1

Referência: [REQUISITOS.md](REQUISITOS.md)

---

## Framework e Banco de Dados

**Framework:** Django 5.x + Django REST Framework (DRF)
**DB:** PostgreSQL 16

**Justificativa:**
- RBAC granular (RF-001 a RF-004b) com 6 papéis (Não-membro, Membro, Servo,
  Líder, Mídia, Pastor) se beneficia do sistema de permissões/grupos do Django
  e de `permission_classes` do DRF.
- O **Django Admin** serve, a custo zero, como CMS inicial para o perfil
  Mídia/Pastor publicarem banners/programação/princípios (RF-005 a RF-007)
  enquanto o painel web (Frontend) é desenvolvido — reduz risco de atraso da
  Fase 1 e mantém custo baixo (RNF/Restrições — orçamento contido).
- Monólito modular (apps Django por domínio) é suficiente para ~200 usuários
  e 8-10 ministérios; evita custo/complexidade de microsserviços.

---

## Diagrama de Componentes

```
[App Flutter] ─┐
               ├─→ [API REST (DRF) + JWT] ─→ [PostgreSQL]
[Web React]  ──┘            │
                             ├─→ [Channels / WebSocket] ─→ [Redis] (chat realtime)
                             └─→ [FCM] (push notifications)
```

- App mobile consome: institucional (banners/programação/princípios),
  ministérios (chat, agenda, escalas, conteúdo de Louvor), automação (Fase 2/3).
- Web consome: **apenas** endpoints institucionais (RF-005 a RF-008b),
  conforme escopo definido em REQUISITOS.md seção 5.
- Único backend, única fonte de verdade para ambas as plataformas.

---

## Apps Django (módulos)

```
churchs_mng/
├── config/                # settings, urls, asgi/wsgi
├── accounts/               # User customizado, papéis (roles), permissões de automação
├── institutional/          # Banners, Princípios, Programação
├── ministries/             # Ministério, Membership, Eventos/Agenda, Escalas
├── praise/                  # Conteúdo específico do Ministério de Louvor (Song, SongSchedule)
├── chat/                    # Mensagens de chat por ministério (Channels)
└── automation/             # Stub para Fase 2/3 (dispositivos, câmeras)
```

---

## Modelo de Dados (principais entidades)

```python
# accounts/models.py
class Role(models.TextChoices):
    NON_MEMBER = "non_member", "Não-membro"
    MEMBER = "member", "Membro"
    SERVANT = "servant", "Servo"
    LEADER = "leader", "Líder de Ministério"
    MEDIA = "media", "Mídia"
    PASTOR = "pastor", "Pastor"


class User(AbstractUser):
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.NON_MEMBER)
    has_automation_access = models.BooleanField(default=False)  # RF-004, concedido individualmente pelo Pastor
    phone = models.CharField(max_length=20, blank=True)


# institutional/models.py
class Banner(models.Model):
    class Kind(models.TextChoices):
        EVENT = "event", "Evento"
        SERVICE = "service", "Culto"
        WORD = "word", "Palavra"

    title = models.CharField(max_length=120)
    description = models.TextField(blank=True)
    image = models.ImageField(upload_to="banners/")
    kind = models.CharField(max_length=20, choices=Kind.choices)
    starts_at = models.DateTimeField()
    published_by = models.ForeignKey(User, on_delete=models.PROTECT)  # role=media ou pastor
    created_at = models.DateTimeField(auto_now_add=True)


class ChurchPrinciple(models.Model):
    """Conteúdo estático editável (RF-006) — singleton via Solo pattern."""
    title = models.CharField(max_length=120)
    content = models.TextField()
    updated_at = models.DateTimeField(auto_now=True)


class ServiceSchedule(models.Model):
    """Programação institucional de cultos/eventos (RF-007)."""
    title = models.CharField(max_length=120)
    description = models.TextField(blank=True)
    starts_at = models.DateTimeField()
    location = models.CharField(max_length=120, blank=True)


# ministries/models.py
class Ministry(models.Model):
    name = models.CharField(max_length=80)
    slug = models.SlugField(unique=True)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=40, blank=True)
    color = models.CharField(max_length=7, blank=True)  # hex
    created_by = models.ForeignKey(User, on_delete=models.PROTECT)


class MinistryMembership(models.Model):
    class MemberRole(models.TextChoices):
        LEADER = "leader", "Líder"
        SERVANT = "servant", "Servo"

    ministry = models.ForeignKey(Ministry, related_name="memberships", on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=20, choices=MemberRole.choices, default=MemberRole.SERVANT)

    class Meta:
        unique_together = ("ministry", "user")


class MinistryEvent(models.Model):
    """Agendamento de reuniões/eventos do ministério (RF-013)."""
    ministry = models.ForeignKey(Ministry, related_name="events", on_delete=models.CASCADE)
    title = models.CharField(max_length=120)
    description = models.TextField(blank=True)
    location = models.CharField(max_length=120, blank=True)
    starts_at = models.DateTimeField()


class ServiceSlot(models.Model):
    """Escala de serviço: quem está designado para qual culto/data (RF-014)."""
    ministry = models.ForeignKey(Ministry, related_name="service_slots", on_delete=models.CASCADE)
    event = models.ForeignKey(MinistryEvent, null=True, blank=True, on_delete=models.SET_NULL)
    date = models.DateField()
    member = models.ForeignKey(User, on_delete=models.CASCADE)
    function = models.CharField(max_length=80)  # ex: "Vocal", "Guitarra", "Recepção"


# praise/models.py — conteúdo específico do Ministério de Louvor (RF-016)
class Song(models.Model):
    title = models.CharField(max_length=120)
    key = models.CharField(max_length=10)  # tom, ex: "G", "D#m"
    reference_url = models.URLField(blank=True)  # versão/link de referência
    ministry = models.ForeignKey(Ministry, related_name="songs", on_delete=models.CASCADE)


class SongAssignment(models.Model):
    """Associa música a um ServiceSlot/evento, indicando vocalista designado."""
    song = models.ForeignKey(Song, related_name="assignments", on_delete=models.CASCADE)
    service_slot = models.ForeignKey(ServiceSlot, related_name="songs", on_delete=models.CASCADE)


# chat/models.py
class ChatMessage(models.Model):
    ministry = models.ForeignKey(Ministry, related_name="messages", on_delete=models.CASCADE)
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
```

---

## Endpoints Principais

| Método | Endpoint | Descrição | Auth |
|--------|---------|-----------|------|
| POST | `/api/auth/register/` | Cadastro (perfil inicial: não-membro) | Público |
| POST | `/api/auth/login/` | Login, retorna par de tokens JWT | Público |
| POST | `/api/auth/token/refresh/` | Refresh do access token | Refresh token |
| GET | `/api/me/` | Dados do usuário autenticado (role, ministérios, permissões) | JWT |
| GET | `/api/banners/` | Lista de banners (RF-005) | Público |
| POST | `/api/banners/` | Cria banner | JWT (role=media/pastor) |
| GET | `/api/principles/` | Princípios da igreja (RF-006) | Público |
| PUT | `/api/principles/` | Edita princípios | JWT (role=media/pastor) |
| GET | `/api/schedule/` | Programação institucional (RF-007) | Público |
| POST | `/api/schedule/` | Cria item de programação | JWT (role=media/pastor) |
| GET | `/api/ministries/` | Lista ministérios do usuário (ou todos, se pastor) | JWT |
| POST | `/api/ministries/` | Cria ministério (RF-009) | JWT (role=pastor/leader) |
| POST | `/api/ministries/{id}/members/` | Adiciona/remove membro (RF-010) | JWT (role=leader do ministério/pastor) |
| GET | `/api/ministries/{id}/events/` | Agenda do ministério (RF-013) | JWT (membro do ministério) |
| POST | `/api/ministries/{id}/events/` | Cria evento/reunião | JWT (leader) |
| GET | `/api/ministries/{id}/schedule-slots/` | Escala de serviço (RF-014) | JWT (membro do ministério) |
| POST | `/api/ministries/{id}/schedule-slots/` | Cria/edita escala | JWT (leader) |
| GET/POST | `/api/ministries/{id}/songs/` | Repertório do Louvor (RF-016) | JWT (membro do ministério, leader p/ escrita) |
| WS | `/ws/ministries/{id}/chat/` | Chat em tempo real do ministério (RF-012) | JWT (membro do ministério) |
| POST | `/api/users/{id}/automation-access/` | Concede/revoga acesso à automação (RF-004) | JWT (role=pastor) |

---

## Decisões de Design

| Decisão | Escolha | Justificativa |
|---------|---------|--------------|
| Framework | Django + DRF | Admin embutido cobre RF-005/006/007 no MVP; RBAC maduro; baixo custo |
| Banco | PostgreSQL | Padrão da empresa, suporta JSONField para extensões futuras de conteúdo de ministério |
| Auth | JWT (`djangorestframework-simplejwt`) | Stateless, simples de usar no Flutter (Dio interceptor) |
| RBAC | Campo `role` no User + `permission_classes` customizadas por papel | Modelo simples, suficiente para 6 papéis; evita overengineering com grupos/permissões dinâmicas no MVP |
| Chat em tempo real | Django Channels + Redis | Único serviço adicional (Redis) cobre WebSocket e pode futuramente servir de cache/broker Celery |
| Notificações push | Firebase Cloud Messaging (FCM) | Gratuito, já previsto no stack Flutter da empresa |
| Tasks assíncronas | Celery + Redis — **opcional no MVP** | Push notifications podem ser disparadas de forma síncrona no início (volume baixo, ~200 usuários); introduzir Celery somente se necessário |
| Deploy | Docker Compose em VPS único (Django+Gunicorn, Channels/Daphne, PostgreSQL, Redis, Nginx) | Atende restrição de orçamento contido sem abrir mão de segurança (HTTPS via Nginx+Let's Encrypt) |
| Conteúdo de ministério (RF-015) | Estrutura genérica (chat + agenda + escala) para todos; `praise` app dedicado apenas para Louvor | Evita generalização prematura (ver Risco em REQUISITOS.md) |

---

## Riscos

- 🟡 Django Channels exige servidor ASGI (Daphne/Uvicorn) além do WSGI — incluir desde o setup inicial do Docker Compose para não retrabalhar a infra depois.
- 🟡 Upload de imagens de banners (RF-005): definir storage (local + backup, ou S3-compatible barato) antes da Fase 1 terminar.
- 🟢 RBAC simples por campo `role` é suficiente para o MVP, mas se a Fase 3 (multi-tenant) avançar, reavaliar para um modelo de permissões por igreja (tenant).

---

## Próximos Passos

1. **Backend Senior:** inicializar projeto Django (`config`, apps `accounts`, `institutional`, `ministries`, `praise`, `chat`), configurar `simplejwt`, Channels e Docker Compose (Postgres + Redis).
2. Popular fixtures iniciais com os 8 ministérios definidos (Louvor, Homens, Mulheres, Libras, Pastoral, PGs, Aconselhamento, Missões).
3. Gerar OpenAPI/Swagger (drf-spectacular) para consumo pelo Mobile e Frontend.
