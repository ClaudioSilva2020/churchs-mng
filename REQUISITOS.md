# Documento de Requisitos — ChurchsMng

**Cliente:** (IBBE) | **Data:** 2026-06-13 | **Versão:** 1.0
**Responsável:** Claudio Silva | **Status:** Rascunho

---

## 1. Visão Geral

Aplicativo voltado para igrejas, funcionando como **rede social interna da
congregação**. Permite que membros e visitantes acompanhem banners de
eventos, cultos e palavras (sermões) dos pastores, e que membros engajados em
ministérios tenham espaços dedicados de organização: chat, agendamento de
reuniões e conteúdos específicos do ministério (ex.: repertório de louvor com
tons, vocalistas e versões das músicas, escalas de culto).

Adicionalmente, o app oferece um módulo restrito de **automação e
monitoramento da igreja** (câmeras e automação de lâmpadas/tomadas), acessível
apenas pelo Pastor e por usuários por ele autorizados.

O projeto inicial é para a **IBBE**, mas a solução deve ser construída
pensando em uma futura oferta white-label para outras igrejas (nome,
logo e cores customizáveis por instância) — este item de multi-tenant fica
registrado como **requisito futuro**, fora do escopo do MVP.

O app resolve três problemas centrais:

- Falta de um canal único e organizado de comunicação entre liderança e
  congregação (eventos, palavras, programação).
- Falta de ferramentas de organização interna para ministérios (escalas,
  repertório, agendas, comunicação do time).
- Falta de controle remoto/visibilidade sobre a estrutura física da igreja
  (câmeras e automação), centralizado e com controle de acesso granular.

---

## 2. Stakeholders

| Papel | Nome/Área | Responsabilidade |
|-------|----------|-------------------|
| Cliente / Patrocinador | IBBE | Define escopo, aprova entregas |
| Pastor (Admin Geral) | Usuário final | Acesso total: cria ministérios, gerencia permissões, acessa câmeras/automação, publica conteúdo institucional |
| Líder de Ministério | Usuário final | Cria/administra seu ministério, adiciona membros, gerencia agenda, escalas e conteúdo do ministério |
| Servo (membro de ministério) | Usuário final | Participa do chat, agenda e conteúdos do(s) ministério(s) em que serve; vê escalas em que está designado |
| Membro da igreja | Usuário final | Acesso à rede social interna: banners, eventos, palavras, programação; pode integrar ministérios |
| Mídia (Comunicação) | Usuário final | Publica e gerencia banners de eventos/cultos/palavras (feed institucional), no app e no painel web |
| Não-membro / Visitante | Usuário final | Acesso restrito à tela inicial pública (app ou web): banners de eventos, princípios da igreja e programação |
| Usuário com permissão de automação | Usuário final | Acesso à aba de câmeras/automação, concedido individualmente pelo Pastor |

---

## 3. Requisitos Funcionais

### 3.1 Acesso e Perfis

| ID | Descrição | Prioridade | Critério de Aceite |
|----|-----------|-----------|---------------------|
| RF-001 | Cadastro/login com perfis distintos (Não-membro, Membro, Servo, Líder de Ministério, Mídia, Pastor) | 🔴 Must | Usuário se cadastra/loga e o app/painel exibe apenas as abas/conteúdos permitidos ao seu papel |
| RF-002 | Não-membro acessa apenas a tela inicial pública, via app ou web (banners de eventos passados/futuros, princípios da igreja, programação) | 🔴 Must | Usuário não autenticado (ou autenticado como não-membro) não vê abas de ministérios, automação ou área restrita, em nenhuma das plataformas |
| RF-003 | Promoção de cadastro: visitante pode solicitar/ser promovido a Membro (aprovação por staff/Pastor) | 🟡 Should | Pastor/staff aprova solicitação e o perfil do usuário é atualizado para Membro |
| RF-004 | Pastor concede/revoga, individualmente, a permissão de acesso ao módulo de Automação/Câmeras para qualquer usuário | 🔴 Must | Usuário sem permissão não vê a aba de automação; ao receber permissão, a aba aparece sem necessidade de reinstalar o app |
| RF-004b | Pastor concede o perfil "Mídia" a usuários responsáveis por publicar banners/conteúdo institucional | 🔴 Must | Usuário com perfil Mídia acessa a área de publicação de banners no app e/ou painel web; demais perfis não veem essa área |

### 3.2 Tela Inicial / Conteúdo Institucional

| ID | Descrição | Prioridade | Critério de Aceite |
|----|-----------|-----------|---------------------|
| RF-005 | Feed de banners de eventos, cultos e palavras (sermões) dos pastores | 🔴 Must | Usuário com perfil Mídia ou Pastor publica um banner (imagem + texto + data) e ele aparece no feed para todos os públicos, no app e na web |
| RF-006 | Página de princípios/valores da igreja (conteúdo estático editável) | 🔴 Must | Pastor/Mídia edita o texto e a mudança reflete para todos os usuários, no app e na web |
| RF-007 | Programação semanal/mensal de cultos e eventos (agenda institucional) | 🔴 Must | Usuário visualiza calendário/lista com horários e descrição dos próximos cultos/eventos, no app e na web |
| RF-008 | Notificações push para novos banners/eventos/avisos institucionais (app mobile) | 🟡 Should | Usuário recebe notificação ao ser publicado um novo banner/evento |
| RF-008b | Painel web público com tela inicial (banners, princípios, programação), espelhando o conteúdo do app | 🔴 Must | Visitante acessa a página web sem login e visualiza o mesmo conteúdo institucional disponível no app para não-membros |
| RF-008c | Mídia/Pastor cria uma publicação (post) diretamente do app — foto ou vídeo, título, descrição, tipo (evento/culto/palavra) — que passa a aparecer no carrossel de Avisos e Eventos | 🔴 Must | Usuário com perfil Mídia ou Pastor toca em "Nova publicação", preenche os campos e o post aparece imediatamente no feed; demais perfis não veem essa opção |

### 3.3 Ministérios

| ID | Descrição | Prioridade | Critério de Aceite |
|----|-----------|-----------|---------------------|
| RF-009 | Pastor ou Líder cria um ministério (nome, descrição, ícone/cor) | 🔴 Must | Ministério criado aparece na lista de ministérios da igreja |
| RF-010 | Líder/Pastor adiciona ou remove membros do ministério | 🔴 Must | Membro adicionado passa a ver o ministério na sua lista e ganha acesso ao chat/agenda/conteúdo dele |
| RF-011 | Definição de papel dentro do ministério (Líder, Servo) | 🔴 Must | Apenas Líderes (e Pastor) podem editar conteúdo/escalas/membros do ministério |
| RF-012 | Chat em grupo por ministério | 🔴 Must | Membros do ministério enviam/recebem mensagens em tempo real, restritas aos integrantes daquele ministério |
| RF-013 | Agendamento de reuniões/eventos do ministério (data, hora, local, descrição) | 🔴 Must | Líder cria um evento de ministério; membros visualizam na agenda do ministério e recebem notificação |
| RF-014 | Escala de serviço (quem está designado para qual culto/data) — aplicável apenas aos ministérios de **Louvor, PGs, Missões, Libras e Mulheres** (ministérios com atuação direta em cultos/encontros recorrentes); demais ministérios (Homens, Pastoral, Aconselhamento) não exibem aba de escala | 🔴 Must | Líder monta escala associando membros a datas/funções; membro visualiza sua própria escala; ministérios sem escala não exibem essa aba |
| RF-015 | Espaço de conteúdo específico por ministério (estrutura configurável) | 🔴 Must | Cada ministério pode ter seções de conteúdo próprias, conforme seu tipo (ver RF-016) |
| RF-016 | Conteúdo específico do Ministério de Louvor: repertório de músicas com título, tom, versão/link de referência e vocalista(s) designado(s) por culto | 🔴 Must | Líder de louvor cadastra música (título, tom, versão/link) e associa à escala de um culto, indicando quem canta cada música |
| RF-017 | Notificações push de novas mensagens no chat e novos agendamentos/escalas do ministério | 🟡 Should | Membro recebe notificação ao ser escalado ou ao receber nova mensagem |
| RF-017b | Pastor possui um diretório de membros da igreja, com acesso ao perfil de cada um (dados, papel, ministérios) | 🔴 Must | Pastor acessa a lista de membros, busca por nome e abre o perfil de qualquer membro |
| RF-017c | Pastor (e Líder com permissão administrativa) adiciona ou remove membros da igreja | 🔴 Must | Pastor cria um novo cadastro de membro (nome, e-mail, papel inicial) ou remove um membro existente, refletindo imediatamente no diretório |
| RF-017d | Cadastro de novo usuário/membro é restrito ao Pastor e a Líderes com permissão administrativa — não há autocadastro público de membros | 🔴 Must | Tela de "novo membro" só é acessível a Pastor/Líder administrador; demais perfis não veem essa opção |

### 3.4 Automação e Câmeras (módulo restrito)

| ID | Descrição | Prioridade | Critério de Aceite |
|----|-----------|-----------|---------------------|
| RF-018 | Visualização de câmeras da igreja (streaming de vídeo) | 🔴 Must | Usuário autorizado acessa a aba de câmeras e visualiza stream em tempo real de cada câmera cadastrada |
| RF-019 | Controle de automação (lâmpadas e tomadas): ligar/desligar/status | 🔴 Must | Usuário autorizado liga/desliga um dispositivo e o app reflete o status atualizado |
| RF-020 | Cadastro de dispositivos de automação/câmeras (Pastor/Admin) | 🔴 Must | Pastor cadastra novo dispositivo (nome, local, tipo, identificador de integração) e ele passa a aparecer na aba |
| RF-021 | Log de acessos e ações no módulo de automação/câmeras | 🟡 Should | Sistema registra quem acessou câmeras ou acionou dispositivos, com data/hora |

---

## 4. Requisitos Não-Funcionais

| ID | Categoria | Requisito | Métrica |
|----|-----------|-----------|---------|
| RNF-001 | Plataforma | Mobile nativo via Flutter | iOS + Android a partir de um único código |
| RNF-002 | Segurança | Controle de acesso por papel (RBAC) em todas as telas e endpoints | Usuário sem permissão não consegue acessar dado/endpoint via API direta (não só ocultar na UI) |
| RNF-003 | Segurança | Acesso a câmeras/automação protegido por autenticação forte e autorização individual | MFA recomendado para perfis com acesso à automação; toda ação registrada em log (RF-021) |
| RNF-004 | Privacidade (LGPD) | Dados pessoais de membros (nome, contato, fotos) tratados conforme LGPD | Política de privacidade + consentimento no cadastro |
| RNF-005 | Performance | Chat em tempo real com baixa latência | Mensagens entregues em < 2s em condições normais de rede |
| RNF-006 | Disponibilidade | Streaming de câmeras não pode comprometer demais funcionalidades do app | Falha de conexão com câmera não impacta feed, chat ou agendas |
| RNF-007 | Escalabilidade | Arquitetura deve suportar múltiplos ministérios e crescimento da congregação sem retrabalho estrutural | Adição de novo ministério/usuário não exige alteração de código |
| RNF-008 | Usabilidade | Navegação por abas conforme perfil, sem sobrecarga visual para o usuário comum | Não-membro/Membro não veem abas de automação/câmeras |

---

## 5. Restrições

- **Plataforma:** Mobile (Flutter — Android e iOS) **+ Web**. Escopo da web definido: **apenas conteúdo institucional e publicações** (tela pública para não-membros + área de publicação para Mídia/Pastor — RF-005 a RF-008b). Funcionalidades de ministério (chat, agenda, escalas, automação) são **exclusivas do app mobile**.
- **Backend:** necessário backend dedicado (não apenas BaaS), dado o volume de regras de negócio (RBAC granular, chat em tempo real, integração IoT/streaming, e atendimento simultâneo a app mobile e web).
- **Automação:** não há instalação prévia — o sistema de automação (lâmpadas/tomadas) será especificado e implementado pela própria TechIndev (hardware novo). Envolve o time de **Firmware/Embedded** na Fase 2/3. Fica para depois do MVP.
- **Câmeras:** a igreja já possui câmeras instaladas; protocolo/modelo ainda a definir tecnicamente, mas o cliente confirmou que este item é de **prioridade baixa**, tratado apenas em fase final.
- **Regulatório:** LGPD aplicável (dados pessoais de ~200 membros, imagens de câmeras de áreas internas).
- **Volume:** dimensionar para ~200 membros e 10 ministérios no lançamento, com crescimento esperado (RNF-007).
- **Prazo:** sem data-limite definida.
- **Orçamento:** sem valor fixo, mas a diretriz do cliente é **custo-efetivo e seguro** — priorizar stack com bom custo/benefício (evitar serviços caros desde o início, sem abrir mão de segurança/RBAC).
- **Identidade visual:** definida — logo em [logo.png](logo.png). Paleta: azul-marinho escuro, dourado/amarelo e branco (livro aberto + cruz).
- **Conteúdo institucional:** alimentado por usuários com perfil **Mídia** (RF-004b/RF-005).
- **Moderação de chat:** não é necessária (confirmado pelo cliente).

---

## 6. Áreas Envolvidas

- [x] Firmware (C/C++ bare metal / RTOS) — Fase 2/3: automação (lâmpadas/tomadas) será hardware próprio da TechIndev
- [ ] Embedded Linux / Yocto — não aplicável a princípio
- [x] Backend — necessário (auth, RBAC, chat realtime, conteúdo institucional para app+web, integração IoT/streaming na Fase 2/3)
- [x] Frontend (React / Angular) — painel web público + administrativo (Mídia/Pastor/Líderes)
- [x] Mobile (Flutter)
- [x] DevOps / Infra — infraestrutura para chat realtime, broker IoT (MQTT) e proxy/streaming de câmeras (fases futuras)

---

## 7. Riscos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| Automação é hardware novo, a ser projetado pela TechIndev (sem especificação ainda) | 🔴 Alta | Alto | Tratar como projeto de Firmware/Embedded próprio na Fase 2/3, com especificação detalhada antes de iniciar; não bloqueia o MVP |
| Câmeras existentes com protocolo ainda não levantado | 🟡 Média | Médio | Como o cliente definiu prioridade baixa, fazer o levantamento técnico (modelo/protocolo ONVIF/RTSP) apenas ao iniciar a fase de câmeras |
| Controle de acesso a câmeras/automação é sensível (segurança física da igreja) | 🟡 Média | Alto | RBAC rígido + logs de auditoria (RNF-003, RF-021) desde a Fase 2/3 |
| Escopo amplo (rede social + ministérios + chat + app/web + IoT) pode estourar prazo se tratado como um único MVP | 🔴 Alta | Alto | Dividir em fases: Fase 1 (app + web institucional/ministérios/chat/agenda/escalas), Fase 2 (automação), Fase 3 (câmeras + multi-tenant) |
| Conteúdo configurável por tipo de ministério (RF-015/016) pode virar complexidade excessiva se generalizado demais | 🟡 Média | Médio | Para o MVP, modelar Louvor como caso concreto; demais ministérios usam estrutura genérica (chat + agenda + escala), sem campos especializados |
| Chat em tempo real com múltiplos ministérios + manter custo de infraestrutura baixo | 🟡 Média | Médio | Avaliar WebSocket nativo (Django Channels) vs. serviço gerenciado com bom custo/benefício, dado o requisito de orçamento contido (~200 usuários) |
| Manter app, web e backend sincronizados (mesmo conteúdo institucional em duas plataformas) | 🟡 Média | Médio | Backend único como fonte de verdade (API REST/GraphQL); app e web consomem a mesma API |

---

## 8. Cronograma de Alto Nível (proposta em fases)

| Fase | Duração Estimada | Entregável |
|------|-------------------|-----------|
| Requisitos | Concluído | Este documento, com respostas do cliente |
| Arquitetura | A definir | ADRs: stack backend, modelagem de RBAC, modelagem de ministérios, arquitetura app + web compartilhando API |
| Fase 1 — MVP App + Web Institucional/Ministérios | A definir | App (Flutter) e Web (tela pública para não-membros + painel Mídia/Pastor/Líderes): perfis/RBAC, banners/programação/princípios, ministérios (chat, agenda, escalas), conteúdo de Louvor |
| Fase 2 — Automação | A definir | Especificação e implementação do hardware de automação (TechIndev Firmware), integração no app |
| Fase 3 — Câmeras + Multi-tenant/White-label | A definir | Levantamento técnico das câmeras existentes, módulo de visualização; avaliação de arquitetura multi-igreja (nome/logo/cores configuráveis) |
| QA | A definir | Testes dos fluxos por perfil (Não-membro, Membro, Servo, Líder, Mídia, Pastor) em app e web |
| Deploy | A definir | Publicação nas lojas (Android/iOS) + deploy da web + infraestrutura backend em produção |

---

## 9. Perguntas Respondidas pelo Cliente

1. **Escala:** apenas IBBE por enquanto. Multi-tenant/white-label (nome, logo e cores por igreja) é **requisito futuro** (Fase 3), fora do MVP.
2. **Automação:** não há instalação prévia. Será hardware novo, especificado e construído pela própria TechIndev — envolve o time de Firmware/Embedded (Fase 2).
3. **Câmeras:** já existem câmeras instaladas; protocolo a definir tecnicamente. Prioridade baixa — tratado na Fase 3 ("para o final").
4. **Painel Web:** confirmado como requisito — principalmente para servir a tela inicial pública a não-membros, além de painel para Mídia/Pastor/Líderes.
5. **Volume estimado:** ~200 membros e 10 ministérios no lançamento.
6. **Conteúdo institucional:** alimentado por usuários com perfil **Mídia**. Identidade visual definida — logo em [logo.png](logo.png), paleta azul-marinho/dourado/branco.
7. **Moderação:** não é necessária.
8. **Prazo e orçamento:** sem prazo definido. Orçamento sem valor fixo, mas com diretriz de **custo-efetivo e seguro**.

## 9.1 Novas Perguntas Abertas — Resolvidas

1. **Painel Web — alcance:** resolvido. Nesta fase, a web cobre **apenas conteúdo institucional + publicações** (tela pública para não-membros + área de publicação para Mídia/Pastor). Funcionalidades de ministério (chat, agenda, escalas) ficam restritas ao **app mobile**.
2. **Cores exatas:** resolvido. TechIndev extrairá a paleta diretamente de [logo.png](logo.png) (azul-marinho, dourado, branco) para o Design System (tema Flutter / Tailwind).
3. **Ministérios iniciais:** resolvido. Cadastro inicial com 8 ministérios: **Louvor, Homens, Mulheres, Libras, Pastoral, PGs (Pequenos Grupos), Aconselhamento, Missões**.

---

## 10. Recomendação de Equipe e Próximos Passos

**Equipe recomendada (Fase 1 — MVP App + Web Institucional/Ministérios):**
- **Backend Architect (Python)** — define modelagem de RBAC (perfis x ministérios x permissões, incluindo o perfil Mídia), arquitetura de chat em tempo real, estrutura de conteúdo configurável por ministério e API única consumida por app e web.
- **Mobile Architect (Flutter)** — define arquitetura do app, navegação condicional por perfil, tema com a identidade visual (logo.png) e integração com backend/push notifications.
- **Frontend Architect (React)** — define arquitetura da web (tela pública para não-membros + painel Mídia/Pastor/Líderes), consumindo a mesma API do backend, com o mesmo tema visual.
- **Backend Senior + Mobile Senior + Frontend Senior** — implementação das telas/endpoints.
- **DevOps** — infraestrutura de backend, banco de dados, serviço de chat realtime e push notifications, com foco em custo-efetividade (~200 usuários).
- **QA** — validação dos fluxos por perfil de acesso, em app e web.

**Equipe adicional (Fase 2 — Automação), após especificação do hardware:**
- **Firmware/Embedded** — especificação e implementação do hardware de automação (TechIndev), em conjunto com Backend/DevOps para integração com o app.

**Equipe adicional (Fase 3 — Câmeras + Multi-tenant):**
- **Backend/DevOps** — levantamento técnico das câmeras existentes e integração de streaming.
- **Backend Architect** — reavaliação do modelo de dados para suportar multi-tenant/white-label.

**Estimativa:** **GG (Muito Grande)** — projeto com múltiplos perfis de acesso (incluindo Mídia), app + web compartilhando backend, múltiplos ministérios com conteúdo configurável, chat em tempo real, e automação/câmeras/multi-tenant como fases futuras. Fase 1 já é, por si só, um esforço considerável (app + web + backend completo).

**Próximos passos:**
1. Enviar as Novas Perguntas Abertas (seção 9.1) ao cliente.
2. Acionar **Backend Architect**, **Mobile Architect** e **Frontend Architect** para produzir os ADRs de arquitetura da Fase 1 (modelo de dados RBAC/ministérios, API compartilhada, tema visual a partir de [logo.png](logo.png)).
3. Validar com o cliente o escopo detalhado do MVP (Fase 1) antes de iniciar desenvolvimento.