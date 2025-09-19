#!/bin/bash

set -euo pipefail  # Строгий режим: выход при ошибках

IG_ID="$1"
if [[ -z "$IG_ID" ]]; then
    echo "Error: please provide id of Instance Group as the first argument" >&2
    echo "Usage: $0 <instance_group_id>" >&2
    exit 1
fi

echo "Getting instances from Instance Group: $IG_ID"

# Получаем IP addresses инстансов с проверкой ошибок
if ! ADDRESSES_JSON=$(yc compute instance-group list-instances "$IG_ID" --format json 2>/dev/null); then
    echo "Error: Failed to get instances from group $IG_ID" >&2
    echo "Please check if the Instance Group ID is correct and you have proper permissions" >&2
    exit 1
fi

# Парсим IP адреса
mapfile -t ADDRESSES < <(echo "$ADDRESSES_JSON" | jq -r ".[].network_interfaces[0].primary_v4_address.one_to_one_nat.address // empty" | grep -v '^$')

# Проверяем, что есть хотя бы один адрес
if [[ ${#ADDRESSES[@]} -eq 0 ]]; then
    echo "Error: No instances with public IP addresses found in Instance Group $IG_ID" >&2
    exit 1
fi

echo "Found ${#ADDRESSES[@]} instances with public IPs"

# Инициализируем генератор случайных чисел более надежным способом
RANDOM=$(date +%s)$$

# Выбираем случайный адрес
selected=${ADDRESSES[$RANDOM % ${#ADDRESSES[@]}]}

# Проверяем валидность IP адреса
if [[ ! $selected =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Error: Invalid IP address selected: $selected" >&2
    exit 1
fi

echo "Selected instance: $selected"

# Определяем протокол и порт (можно сделать настраиваемым)
PROTOCOL="http"
PORT="80"
ENDPOINT="switch_healthy"

# Составляем полный URL
URL="${PROTOCOL}://${selected}:${PORT}/${ENDPOINT}"

echo "Attempting to break instance: $URL"

# Выполняем запрос с таймаутом и лучшей обработкой ошибок
if curl -s -X POST --connect-timeout 10 --max-time 30 "$URL" >/dev/null 2>&1; then
    echo "✓ $selected is now broken"
else
    exit_code=$?
    echo "✗ Failed to break $selected (curl exit code: $exit_code)" >&2
    
    # Дополнительная диагностика
    echo "Troubleshooting steps:" >&2
    echo "1. Check if the instance is running: yc compute instance get <instance_id>" >&2
    echo "2. Verify the application is listening on port $PORT" >&2
    echo "3. Check security groups and firewall rules" >&2
    echo "4. Test connectivity: curl -I $URL" >&2
    
    exit 1
fi