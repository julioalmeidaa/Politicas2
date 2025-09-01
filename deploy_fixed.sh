#!/bin/bash

echo "🚀 Fazendo Deploy do Sistema"
echo "============================"

# Verificar se Docker e Docker Compose estão instalados
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado!"
    exit 1
fi

# Verificar se estamos no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Arquivo docker-compose.yml não encontrado!"
    echo "Certifique-se de estar no diretório raiz do projeto."
    exit 1
fi

# Parar containers existentes
echo "🛑 Parando containers existentes..."
docker-compose down

# Construir imagens
echo "🐳 Construindo imagens Docker..."
docker-compose build --no-cache

# Criar diretórios necessários
echo "�� Criando diretórios..."
mkdir -p backend/media/generated_policies
mkdir -p backend/templates/word_templates

# Ajustar permissões
echo "🔐 Ajustando permissões..."
chown -R 1000:1000 backend/media
chmod -R 755 backend/media

# Iniciar serviços
echo "🚀 Iniciando serviços..."
docker-compose up -d

# Aguardar serviços iniciarem
echo "⏳ Aguardando serviços iniciarem..."
sleep 30

# Verificar se containers estão rodando
echo "🔍 Verificando status dos containers..."
docker-compose ps

# Executar migrações
echo "🗄️ Executando migrações do banco..."
docker-compose exec -T backend python manage.py migrate

# Criar superusuário
echo "👤 Criando superusuário..."
docker-compose exec -T backend python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@itonbusiness.com', 'admin123')
    print('Superusuário criado: admin/admin123')
else:
    print('Superusuário já existe')
"

# Carregar dados iniciais (templates de políticas)
echo "📋 Carregando templates de políticas..."
docker-compose exec -T backend python manage.py shell -c "
from policies.models import PolicyTemplate

templates_data = [
    {
        'name': 'Política de Uso Aceitável de Recursos de TI',
        'policy_type': 'uso_aceitavel',
        'description': 'Define as regras para uso adequado dos recursos de TI da empresa',
        'template_file': 'politica_uso_aceitavel.docx',
        'itil_compliance': True,
        'iso27001_compliance': True
    },
    {
        'name': 'Política de Segurança da Informação',
        'policy_type': 'seguranca_informacao',
        'description': 'Estabelece diretrizes para proteção das informações corporativas',
        'template_file': 'politica_seguranca_informacao.docx',
        'iso27001_compliance': True,
        'lgpd_compliance': True
    },
    {
        'name': 'Política de Backup e Recuperação',
        'policy_type': 'backup_recuperacao',
        'description': 'Define procedimentos para backup e recuperação de dados',
        'template_file': 'politica_backup_recuperacao.docx',
        'itil_compliance': True,
        'iso27001_compliance': True
    }
]

for template_data in templates_data:
    template, created = PolicyTemplate.objects.get_or_create(
        policy_type=template_data['policy_type'],
        defaults=template_data
    )
    if created:
        print(f'Template criado: {template.name}')
    else:
        print(f'Template já existe: {template.name}')
"

echo "✅ Deploy concluído com sucesso!"
echo ""
echo "🌐 Acesse o sistema:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000/api"
echo "   Admin: http://localhost:8000/admin"
echo ""
echo "👤 Credenciais do admin:"
echo "   Usuário: admin"
echo "   Senha: admin123"
echo ""
echo "📋 Para verificar logs:"
echo "   docker-compose logs backend"
echo "   docker-compose logs frontend"