#!/bin/bash

echo "🚀 Instalando Sistema de Geração de Políticas de TI - IT ON BUSINESS"
echo "=================================================================="

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Execute este script como root (sudo)"
  exit 1
fi

# Atualizar sistema
echo "📦 Atualizando sistema..."
apt update && apt upgrade -y

# Instalar dependências básicas
echo "🔧 Instalando dependências básicas..."
apt install -y \
    curl \
    wget \
    git \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Instalar Docker
echo "🐳 Instalando Docker..."
# Remover versões antigas
apt remove -y docker docker-engine docker.io containerd runc

# Adicionar repositório oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualizar e instalar Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Habilitar e iniciar Docker
systemctl enable docker
systemctl start docker

# Instalar Docker Compose standalone (compatibilidade)
echo "🐳 Instalando Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d" -f4)
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Criar link simbólico
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Instalar Node.js
echo "📦 Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Instalar Python e dependências
echo "🐍 Instalando Python..."
apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev

# Instalar PostgreSQL
echo "🗄️ Instalando PostgreSQL..."
apt install -y postgresql postgresql-contrib

# Instalar Nginx
echo "🌐 Instalando Nginx..."
apt install -y nginx

# Criar usuário para a aplicação
echo "👤 Criando usuário da aplicação..."
if ! id "itpolicy" &>/dev/null; then
    useradd -m -s /bin/bash itpolicy
    usermod -aG docker itpolicy
fi

# Verificar instalações
echo "✅ Verificando instalações..."
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "Node.js: $(node --version)"
echo "Python: $(python3 --version)"
echo "PostgreSQL: $(psql --version)"

echo "✅ Instalação concluída com sucesso!"
echo "📋 Próximos passos:"
echo "1. Execute: sudo ./scripts/setup_database.sh"
echo "2. Execute: sudo ./scripts/deploy_fixed.sh"