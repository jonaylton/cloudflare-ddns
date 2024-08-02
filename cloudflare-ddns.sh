#!/bin/bash

echo "Starting DNS update script..."

# Configurações do Cloudflare
CF_API_KEY="YOUR_API_KEY"
ZONE_ID="YOUR_ZONE_ID"
RECORD_NAME="A_DNS_RECORD"
LAST_IP_FILE="/PATH/TO/cloudflare-ddns/last_ip.txt"
LOG_FILE="/PATH/TO/cloudflare-ddns/logs.txt"

# Função para obter o IP atual
get_current_ip() {
    curl -s http://ipv4.icanhazip.com
}

# Verifica se o arquivo last_ip.txt existe, se não, cria
if [ ! -f "$LAST_IP_FILE" ]; then
    echo "Last IP file not found. Creating it..."
    touch "$LAST_IP_FILE"
    echo "" > "$LAST_IP_FILE"
fi

# Obtendo o IP atual
CURRENT_IP=$(get_current_ip)
echo "Current IP is $CURRENT_IP"

# Lendo o último IP registrado no arquivo
LAST_IP=$(cat "$LAST_IP_FILE")

# Se o IP atual for diferente do último IP registrado, fazer a chamada à API do Cloudflare e registrar logs
if [ "$CURRENT_IP" != "$LAST_IP" ]; then
    {
        echo "Current IP is $CURRENT_IP"
        echo "Last IP was $LAST_IP"
        echo "IPs do not match. Checking Cloudflare IP..."

        # Obtendo o ID do registro DNS no Cloudflare
        RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$RECORD_NAME" \
             -H "Authorization: Bearer $CF_API_KEY" \
             -H "Content-Type: application/json" | jq -r '.result[0].id')
        echo "Record ID is $RECORD_ID"

        # Obtendo o IP atual do Cloudflare
        CF_IP=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
             -H "Authorization: Bearer $CF_API_KEY" \
             -H "Content-Type: application/json" | jq -r '.result.content')
        echo "Cloudflare IP is $CF_IP"

        # Se o IP atual for diferente do IP do Cloudflare, atualizar o registro DNS
        if [ "$CURRENT_IP" != "$CF_IP" ]; then
            echo "IPs do not match. Updating DNS record..."
            RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
               -H "Authorization: Bearer $CF_API_KEY" \
               -H "Content-Type: application/json" \
               --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":1,\"proxied\":true}")

            if [[ $RESPONSE == *"\"success\":false"* ]]; then
                echo "Failed to update DNS record: $RESPONSE"
            else
                echo "DNS record updated successfully."
                echo "$CURRENT_IP" > "$LAST_IP_FILE"
            fi
        else
            echo "No update needed. IP addresses match Cloudflare."
            echo "$CURRENT_IP" > "$LAST_IP_FILE"
        fi
    } 2>&1 | while IFS= read -r line; do
        echo "$(date +'%Y-%m-%d %H:%M:%S') $line" >> "$LOG_FILE"
    done
else
    echo "No update needed. IP addresses match the last recorded IP."
fi
