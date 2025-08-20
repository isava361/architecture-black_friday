#!/bin/bash
set -e
###
# Инициализируем бд
###
echo "Добавляем документы"
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
EOF

sleep 1

echo "Документы успешно добавились"
echo "Количество документов на Шард 1"
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

sleep 1

echo "Количество документов на Шард 2"
docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF
