# Deploy — IBBE Connect

Guia completo de provisionamento e deploy do backend Django + Flutter Web em um VPS.

---

## Sumário

1. [Infraestrutura necessária](#1-infraestrutura-necessária)
2. [Preparar o servidor](#2-preparar-o-servidor)
3. [Configurar o ambiente](#3-configurar-o-ambiente)
4. [Configurar o DNS](#4-configurar-o-dns)
5. [Executar o deploy](#5-executar-o-deploy)
6. [Primeiro acesso](#6-primeiro-acesso)
7. [Build e deploy do Flutter Web](#7-build-e-deploy-do-flutter-web)
8. [Ambiente de staging no mesmo servidor](#8-ambiente-de-staging-no-mesmo-servidor)
9. [Manutenção](#9-manutenção)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Infraestrutura necessária

### VPS recomendado — Hetzner Cloud

| Plano | vCPU | RAM   | SSD   | Preço       | Indicado para       |
|-------|------|-------|-------|-------------|---------------------|
| CX22  | 2    | 4 GB  | 40 GB | ~€ 4/mês    | Até ~500 membros    |
| CX32  | 4    | 8 GB  | 80 GB | ~€ 9/mês    | Até ~2000 membros   |

> Acesse [hetzner.com/cloud](https://www.hetzner.com/cloud) → crie uma conta → **Add Server** → Ubuntu 22.04 LTS → CX22.

### Domínio

- `.com.br` → [registro.br](https://registro.br) (~R$ 40/ano)
- `.com` → [namecheap.com](https://namecheap.com) (~US$ 10/ano)

### Estrutura de subdomínios

```
seudominio.com.br       →  Flutter Web (app)
api.seudominio.com.br   →  API Django (backend)
```

> SSL é gerado automaticamente pelo Caddy via Let's Encrypt — sem configuração extra.

---

## 2. Preparar o servidor

Conecte via SSH e execute os comandos abaixo:

```bash
ssh root@IP_DO_VPS
```

### 2.1 Instalar Docker

```bash
# Atualizar pacotes
apt-get update && apt-get upgrade -y

# Instalar Docker (script oficial)
curl -fsSL https://get.docker.com | sh

# Adicionar usuário ao grupo docker (opcional, se não for root)
usermod -aG docker $USER
newgrp docker

# Verificar instalação
docker --version
docker compose version
```

### 2.2 Clonar o repositório

```bash
# Criar diretório de produção
mkdir -p /opt/ibbe
cd /opt/ibbe

# Clonar o repositório
git clone SEU_REPOSITORIO_GIT .

# Ou transferir os arquivos via scp da sua máquina local:
# scp -r /mnt/workspace/techindev/projects/churchs-mng/backend/* root@IP_VPS:/opt/ibbe/backend/
```

---

## 3. Configurar o ambiente

```bash
cd /opt/ibbe/backend

# Criar o arquivo de ambiente a partir do exemplo
cp .env.prod.example .env.prod

# Editar com seus valores reais
nano .env.prod
```

### Campos obrigatórios do `.env.prod`

```env
DOMINIO=seudominio.com.br
DJANGO_SECRET_KEY=GERAR_ABAIXO
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=api.seudominio.com.br
CORS_ALLOWED_ORIGINS=https://seudominio.com.br
DB_PASSWORD=GERAR_ABAIXO
```

### Gerar valores seguros

```bash
# SECRET_KEY
python3 -c "import secrets; print(secrets.token_urlsafe(50))"

# DB_PASSWORD
openssl rand -base64 24
```

---

## 4. Configurar o DNS

No painel do seu registrador de domínio, adicionar dois registros **tipo A**:

| Tipo | Host  | Valor (IP do VPS)  | TTL  |
|------|-------|--------------------|------|
| A    | `@`   | `123.45.67.89`     | 3600 |
| A    | `api` | `123.45.67.89`     | 3600 |

> Aguarde a propagação do DNS (5 minutos a 1 hora).  
> Verificar: `nslookup api.seudominio.com.br`

---

## 5. Executar o deploy

```bash
cd /opt/ibbe/backend

# Permissão de execução (apenas na primeira vez)
chmod +x deploy.sh

# Executar deploy
bash deploy.sh
```

O script automaticamente:
1. Builda a imagem Docker do backend
2. Sobe banco de dados e Redis
3. Executa as migrations
4. Coleta os arquivos estáticos
5. Sobe todos os serviços (backend + Caddy)
6. O Caddy obtém o certificado SSL automaticamente

### Verificar que está funcionando

```bash
# Serviços rodando
docker compose --env-file .env.prod -f docker-compose.prod.yml ps

# Testar a API
curl https://api.seudominio.com.br/api/ministries/
```

---

## 6. Primeiro acesso

### Criar usuários de demonstração / dados iniciais

```bash
docker compose --env-file .env.prod -f docker-compose.prod.yml \
  exec backend python manage.py seed_demo
```

Isso cria os 4 usuários padrão (senha `ibbe@2026`):

| Usuário         | Papel   |
|-----------------|---------|
| `pastor.ronie`  | Pastor  |
| `lider.louvor`  | Líder   |
| `midia.ibbe`    | Mídia   |
| `membro.maria`  | Membro  |

> **Importante:** troque as senhas após o primeiro acesso em produção.

### Criar superusuário para o Django Admin

```bash
docker compose --env-file .env.prod -f docker-compose.prod.yml \
  exec backend python manage.py createsuperuser
```

Acesse o admin em: `https://api.seudominio.com.br/admin/`

---

## 7. Build e deploy do Flutter Web

Execute na sua **máquina local**:

```bash
cd /caminho/para/churchs-mng/app

# Build de produção com a URL da API
flutter build web \
  --dart-define=API_BASE_URL=https://api.seudominio.com.br/api \
  --release

# Transferir para o VPS
scp -r build/web/* root@IP_VPS:/opt/ibbe-flutter/
```

No VPS, montar o volume do Flutter no Caddy:

```bash
# Criar diretório se não existir
mkdir -p /opt/ibbe-flutter

# Recriar o serviço Caddy para reconhecer os novos arquivos
docker compose --env-file .env.prod -f docker-compose.prod.yml restart caddy
```

> **Nota:** para updates futuros do app, basta repetir o `flutter build web` + `scp` + `restart caddy`.

---

## 8. Ambiente de staging no mesmo servidor

É possível rodar **produção e desenvolvimento no mesmo VPS** usando portas diferentes.  
O staging serve para testar novas funcionalidades antes de subir para produção.

```
Produção  →  porta 80/443  (via Caddy, domínio real)
Staging   →  porta 8001    (acesso direto por IP, sem SSL)
```

### 8.1 Criar o stack de staging

```bash
# Diretório separado para o staging
mkdir -p /opt/ibbe-staging
cd /opt/ibbe-staging
git clone SEU_REPOSITORIO .
cp backend/.env.example backend/.env.staging
```

Edite `backend/.env.staging` com configurações de staging:

```env
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=*
DATABASE_URL=postgres://churchsmng:staging123@db:5432/churchsmng_staging
REDIS_URL=redis://redis:6379/1
```

### 8.2 Subir staging na porta 8001

```bash
cd /opt/ibbe-staging/backend

# Arquivo de compose para staging (apenas db + redis + backend)
docker compose -f docker-compose.yml --env-file .env.staging \
  -p ibbe-staging up -d db redis

docker compose -f docker-compose.yml --env-file .env.staging \
  -p ibbe-staging run --rm backend python manage.py migrate

docker compose -f docker-compose.yml --env-file .env.staging \
  -p ibbe-staging up -d
```

Acesso: `http://IP_VPS:8001/api/`

### 8.3 Resumo das URLs

| Ambiente  | URL                                  | Banco                  |
|-----------|--------------------------------------|------------------------|
| Produção  | `https://api.seudominio.com.br/api/` | `churchsmng`           |
| Staging   | `http://IP_VPS:8001/api/`            | `churchsmng_staging`   |
| Dev local | `http://192.168.0.6:8001/api/`       | `churchsmng` (Docker)  |

---

## 9. Manutenção

### Atualizar o backend

```bash
cd /opt/ibbe/backend
bash deploy.sh
```

### Visualizar logs

```bash
# Todos os serviços
docker compose --env-file .env.prod -f docker-compose.prod.yml logs -f

# Só o backend
docker compose --env-file .env.prod -f docker-compose.prod.yml logs -f backend

# Só o Caddy (inclui logs de SSL)
docker compose --env-file .env.prod -f docker-compose.prod.yml logs -f caddy
```

### Reiniciar um serviço

```bash
docker compose --env-file .env.prod -f docker-compose.prod.yml restart backend
```

### Backup do banco de dados

```bash
docker compose --env-file .env.prod -f docker-compose.prod.yml \
  exec db pg_dump -U churchsmng churchsmng > backup_$(date +%Y%m%d).sql
```

### Restaurar backup

```bash
cat backup_20260101.sql | docker compose --env-file .env.prod \
  -f docker-compose.prod.yml exec -T db psql -U churchsmng churchsmng
```

---

## 10. Troubleshooting

### SSL não está sendo gerado

```bash
# Verificar logs do Caddy
docker compose --env-file .env.prod -f docker-compose.prod.yml logs caddy

# Causas comuns:
# - DNS ainda não propagou (aguarde até 1h)
# - Portas 80/443 bloqueadas no firewall do VPS
```

### Liberar portas no firewall (Ubuntu UFW)

```bash
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw allow 443   # HTTPS
ufw allow 8001  # Staging (opcional)
ufw enable
```

### Backend não conecta ao banco

```bash
# Ver logs de erro
docker compose --env-file .env.prod -f docker-compose.prod.yml logs backend

# Entrar no container e testar
docker compose --env-file .env.prod -f docker-compose.prod.yml \
  exec backend python manage.py check --database default
```

### Limpar tudo e recomeçar (cuidado: apaga dados)

```bash
docker compose --env-file .env.prod -f docker-compose.prod.yml down -v
bash deploy.sh
```
