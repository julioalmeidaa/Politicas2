#!/bin/bash

echo "🚀 Fazendo Deploy do Sistema"
echo "============================"

# Navegar para o diretório do projeto
cd /home/itpolicy/it-policy-generator

# Construir e iniciar containers
echo "🐳 Construindo containers Docker..."
docker-compose build

echo "🐳 Iniciando serviços..."
docker-compose up -d

# Aguardar serviços iniciarem
echo "⏳ Aguardando serviços iniciarem..."
sleep 30

# Executar migrações
echo "🗄️ Executando migrações do banco..."
docker-compose exec backend python manage.py migrate

# Criar superusuário
echo "👤 Criando superusuário..."
docker-compose exec backend python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'julioalmeida@itonbusiness.com', 'admin123')
    print('Superusuário criado: admin/admin123')
"

# Carregar dados iniciais
echo "📋 Carregando templates de políticas..."
docker-compose exec backend python manage.py shell -c "
from policies.models import PolicyTemplate

templates = [
    {
        'name': 'Política de Uso Aceitável de Recursos de TI',
        'policy_type': 'uso_aceitavel',
        'description': 'Define as regras para uso adequado dos recursos de TI da empresa',
        'template_file': 'politica_uso_aceitavel.docx',
        'itil_compliance': True,
        'iso27001_compliance': True
    },
    {
        'name