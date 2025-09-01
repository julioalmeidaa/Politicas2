#!/bin/bash

echo "Fazendo Deploy do Sistema"
echo "========================="

# Verificar se Docker esta instalado
if ! command -v docker &> /dev/null; then
    echo "Docker nao esta instalado!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose nao esta instalado!"
    exit 1
fi

# Verificar se estamos no diretorio correto
if [ ! -f "docker-compose.yml" ]; then
    echo "Arquivo docker-compose.yml nao encontrado!"
    echo "Certifique-se de estar no diretorio raiz do projeto."
    exit 1
fi

# Parar containers existentes
echo "Parando containers existentes..."
docker-compose down

# Construir imagens
echo "Construindo imagens Docker..."
docker-compose build --no-cache

# Criar diretorios necessarios
echo "Criando diretorios..."
mkdir -p backend/media/generated_policies
mkdir -p backend/templates/word_templates

# Ajustar permissoes
echo "Ajustando permissoes..."
chown -R 1000:1000 backend/media
chmod -R 755 backend/media

# Iniciar servicos
echo "Iniciando servicos..."
docker-compose up -d

# Aguardar servicos iniciarem
echo "Aguardando servicos iniciarem..."
sleep 30

# Verificar se containers estao rodando
echo "Verificando status dos containers..."
docker-compose ps

# Executar migracoes
echo "Executando migracoes do banco..."
docker-compose exec -T backend python manage.py migrate

# Criar superusuario
echo "Criando superusuario..."
docker-compose exec -T backend python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@itonbusiness.com', 'admin123')
    print('Superusuario criado: admin/admin123')
else:
    print('Superusuario ja existe')
"

echo "Deploy concluido com sucesso!"
echo ""
echo "Acesse o sistema:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000/api"
echo "   Admin: http://localhost:8000/admin"
echo ""
echo "Credenciais do admin:"
echo "   Usuario: admin"
echo "   Senha: admin123"
