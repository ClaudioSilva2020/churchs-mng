# Arquitetura Mobile — ChurchsMng (IBBE Connect)

**Responsável:** Mobile Architect (Flutter) | **Data:** 2026-06-13 | **Status:** Template inicial criado

Referência: [REQUISITOS.md](REQUISITOS.md) | [ARQUITETURA-BACKEND.md](ARQUITETURA-BACKEND.md)

**Framework:** Flutter | **Dart SDK:** 3.11+ | **Projeto:** `app/` (package `churchs_mng`)

---

## Arquitetura

Clean Architecture (data/domain/presentation por feature) + **BLoC/Cubit**
(`flutter_bloc`), conforme padrão da empresa para times grandes. Navegação
com **GoRouter**, com guards de redirecionamento baseados no estado do
`AuthBloc` (RF-001/RF-002/RF-004).

### Estrutura de Pacotes (implementada)

```
app/lib/
├── core/
│   ├── constants/      # AppConstants (API URL, chaves de storage), UserRole (RF-001)
│   ├── di/              # injector.dart (get_it)
│   ├── network/         # DioClient (JWT interceptor)
│   ├── router/           # app_router.dart (GoRouter + redirects por papel)
│   ├── storage/          # SecureStorage (flutter_secure_storage)
│   └── theme/            # AppColors, AppTheme (paleta extraída de logo.png)
├── features/
│   ├── auth/             # login, registro (RF-001/RF-003)
│   │   ├── data/          # AuthRemoteDataSource, AuthRepositoryImpl, AppUserModel
│   │   ├── domain/        # AppUser, AuthRepository
│   │   └── presentation/  # AuthBloc, LoginPage, RegisterPage
│   ├── home/              # tela inicial pública (RF-002, RF-005 a RF-008b)
│   ├── ministries/        # lista de ministérios (RF-009 a RF-011) — chat/agenda/escala: próxima etapa
│   ├── praise/            # conteúdo do Louvor (RF-016) — esqueleto, a implementar
│   ├── automation/        # módulo restrito (RF-018 a RF-021) — placeholder Fase 2/3
│   └── profile/           # perfil do usuário, login/logout
├── shared/
│   └── widgets/           # AppShell (bottom nav condicional por papel)
└── main.dart
```

---

## Decisões de Design

| Decisão | Escolha | Justificativa |
|---------|---------|--------------|
| Gerenciamento de estado | `flutter_bloc` (Cubit/Bloc) | Padrão preferido da empresa para times grandes; `AuthBloc` já controla todo o fluxo de sessão |
| Navegação | `go_router` com `ShellRoute` + `redirect` | Bottom nav único (`AppShell`) adaptado por papel; guards centralizados no `redirect` evitam checagem espalhada nas telas |
| Injeção de dependência | `get_it` (service locator simples) | Suficiente para o tamanho do projeto; evita boilerplate de providers aninhados |
| Rede | `dio` com interceptor JWT | Compatível com auth JWT do backend (ARQUITETURA-BACKEND.md) |
| Armazenamento de tokens | `flutter_secure_storage` | RNF-002/RNF-003 — nunca tokens em `SharedPreferences` |
| Tema visual | `AppColors`/`AppTheme` a partir de `logo.png` (azul-marinho `#1B2347`, dourado `#D4AF37`) | Identidade visual definida em REQUISITOS.md seção 5; cores extraídas diretamente do asset fornecido |
| RBAC no app | `UserRole` enum + getters (`isMember`, `canManageMinistries`, `canPublishContent`) + `hasAutomationAccess` no `AppUser` | Espelha o `role` do backend; usado pelo `AppShell`/`router` para mostrar/ocultar abas (RF-002/RF-004) |
| Escopo da Fase 1 | Ministérios/chat/agenda/escala **somente no app** (web cobre só institucional) | Conforme decisão registrada em REQUISITOS.md seção 9.1 |

---

## Navegação e Guards (implementado em `app_router.dart`)

| Rota | Acesso | Observação |
|------|--------|-----------|
| `/login`, `/register` | Público | Fora do shell; redireciona para `/home` se já autenticado |
| `/home` | Público (RF-002) | Tela inicial — banners + acesso rápido condicional por papel |
| `/ministries` | Autenticado, `role.isMember` | Redireciona para `/login` se não autenticado |
| `/automation` | `hasAutomationAccess == true` (RF-004) | Redireciona para `/home` caso contrário |
| `/profile` | Todos | Visitante vê CTA de login/cadastro; autenticado vê dados + logout |

`AppShell` monta a bottom navigation dinamicamente: "Início" sempre,
"Ministérios" se `role.isMember`, "Automação" se `hasAutomationAccess`.

---

## Estado do Template

✅ Projeto Flutter criado (`flutter create`), `flutter analyze` e `flutter
test` passando.
✅ Tema com a identidade visual da IBBE.
✅ Fluxo de autenticação (login/registro/logout) com `AuthBloc`, integrado a
`Dio` + `flutter_secure_storage` — **aponta para API ainda não implementada**
(`AppConstants.apiBaseUrl` é placeholder).
✅ Tela inicial pública com banners mockados e grid de acesso rápido
condicional por papel.
✅ Lista de Ministérios com os 8 ministérios iniciais (mockada).
✅ Placeholder de Automação/Câmeras (Fase 2/3).

### Pendências para a Fase 1 (próximos passos do Flutter Senior)

1. Conectar `home`/`ministries` aos endpoints reais quando o Backend Senior
   disponibilizar a API (`/api/banners/`, `/api/principles/`, `/api/schedule/`,
   `/api/ministries/`).
2. Implementar detalhe do ministério: chat (RF-012, via WebSocket/Channels),
   agenda (RF-013) e escala de serviço (RF-014).
3. Implementar `praise` (RF-016): repertório de músicas, tom, link de
   referência e atribuição de vocalistas por escala.
4. Telas de Princípios (RF-006) e Programação (RF-007) — atualmente apenas
   placeholders na grid da Home.
5. Configurar Firebase (FCM) quando push notifications (RF-008/RF-017) entrarem
   em escopo — não incluído no template para não exigir credenciais antecipadamente.
6. Configurar flavors (dev/staging/prod) e `AppConstants.apiBaseUrl` por flavor.
