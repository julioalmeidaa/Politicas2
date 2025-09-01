#!/bin/bash

echo "Instalando Sistema de Geracao de Politicas de TI - IT ON BUSINESS"
echo "================================================================"

# Verificar se esta rodando como root
if [ "$EUID" -ne 0 ]; then
  echo "Execute este script como root (sudo)"
  exit 1
fi

# Atualizar sistema
echo "Atualizando sistema..."
apt update && apt upgrade -y

# Instalar dependencias basicas
echo "Instalando dependencias basicas..."
apt install -y curl wget git software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Remover versoes antigas do Docker
echo "Removendo versoes antigas do Docker..."
apt remove -y docker docker-engine docker.io containerd runc

# Adicionar repositorio oficial do Docker
echo "Adicionando repositorio do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
echo "Instalando Docker..."
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Habilitar e iniciar Docker
systemctl enable docker
systemctl start docker

# Instalar Docker Compose standalone
echo "Instalando Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Instalar Node.js
echo "Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Instalar Python
echo "Instalando Python..."
apt install -y python3 python3-pip python3-venv python3-dev

# Instalar PostgreSQL
echo "Instalando PostgreSQL..."
apt install -y postgresql postgresql-contrib

# Instalar Nginx
echo "Instalando Nginx..."
apt install -y nginx

# Criar usuario da aplicacao
echo "Criando usuario da aplicacao..."
if ! id "itpolicy" &>/dev/null; then
    useradd -m -s /bin/bash itpolicy
    usermod -aG docker itpolicy
fi

# Verificar instalacoes
echo "Verificando instalacoes..."
docker --version
docker-compose --version
node --version
python3 --version

echo "Instalacao concluida com sucesso!"
echo "Proximos passos:"
echo "1. Execute: sudo ./scripts/setup_database.sh"
echo "2. Execute: sudo ./scripts/deploy_fixed.sh"
