#!/bin/bash
set -e
###
# Инициализируем сервис конфигурации
###
echo "Инициализируем сервис конфигурации"
docker exec -i configSrv mongosh --port 27017 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
exit();
EOF
echo "Сервис конфигурации инициализировался"
sleep 3

# Инициализируем шарды
echo "Инициализируем шарды"
docker exec -i shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27018" },
       // { _id : 1, host : "shard2:27019" }
      ]
    }
);
exit();
EOF
echo "Шард 1 инициализировался"
sleep 3

docker exec -i shard2 mongosh --port 27019 --quiet <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
       // { _id : 0, host : "shard1:27018" },
        { _id : 1, host : "shard2:27019" }
      ]
    }
  );
exit();
EOF
echo "Шард 2 инициализировался"
sleep 3

# Инициализируем роутер
echo "Инициализируем роутер"
docker exec -i mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
exit();
EOF

echo "Роутер инициализировался, все готово!"
