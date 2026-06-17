#!/bin/bash
# Script de deploy para o VPS.
# Execute: bash deploy.sh
set -e

COMPOSE="docker compose --env-file .env.prod -f docker-compose.prod.yml"

echo "🚀 Iniciando deploy IBBE ..."
echo ""

# Verificar pré-requisitos
if [ ! -f .env.prod ]; then
  echo "❌ Arquivo .env.prod não encontrado."
  echo "   Copie .env.prod.example, preencha os valores e tente novamente."
  exit 1
fi

# Puxar últimas alterações do repositório (se usar git)
if [ -d .git ]; then
  echo "📥 Atualizando código..."
  git pull origin main
fi

# Build da imagem do backend
echo "🔨 Construindo imagem do backend..."
$COMPOSE build backend

# Subir banco e redis
echo "🗄️  Iniciando banco de dados e Redis..."
$COMPOSE up -d db redis

# Aguardar health checks
echo "⏳ Aguardando serviços ficarem prontos..."
$COMPOSE run --rm backend sh -c "
  until python manage.py check --database default > /dev/null 2>&1; do
    echo '  aguardando banco...'; sleep 2
  done
  echo '  banco pronto.'"

# Migrações
echo "📦 Rodando migrações..."
$COMPOSE run --rm backend python manage.py migrate --noinput

# Arquivos estáticos
echo "📁 Coletando arquivos estáticos..."
$COMPOSE run --rm backend python manage.py collectstatic --noinput --clear

# Subir todos os serviços
echo "🚀 Iniciando todos os serviços..."
$COMPOSE up -d

echo ""
echo "✅ Deploy concluído!"
echo ""
echo "📊 Status dos serviços:"
$COMPOSE ps
echo ""
echo "📋 Logs recentes do backend:"
$COMPOSE logs --tail=20 backend
