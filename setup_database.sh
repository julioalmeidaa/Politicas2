#!/bin/bash

echo "🗄️ Configurando Banco de Dados PostgreSQL"
echo "=========================================="

# Configurar PostgreSQL
sudo -u postgres psql -c "CREATE DATABASE it_policy_generator;"
sudo -u postgres psql -c "CREATE USER itpolicy WITH PASSWORD 'itpolicy123';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE it_policy_generator TO itpolicy;"

echo "✅ Banco de dados configurado com sucesso!"