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

# Instalar dependências
echo "🔧 Instalando dependências..."
apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    postgresql \
    postgresql-contrib \
    nginx \
    git \
    curl \
    software-properties-common

# Instalar Node.js
echo "📦 Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Instalar Docker
echo "🐳 Instalando Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl start docker

# Instalar Docker Compose
echo "🐳 Instalando Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Criar usuário para a aplicação
echo "👤 Criando usuário da aplicação..."
useradd -m -s /bin/bash itpolicy
usermod -aG docker itpolicy

echo "✅ Instalação das dependências concluída!"
echo "📋 Próximos passos:"
echo "1. Execute: sudo -u itpolicy ./setup_database.sh"
echo "2. Execute: sudo -u itpolicy ./deploy.sh"