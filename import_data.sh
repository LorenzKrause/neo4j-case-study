#!/bin/bash
set -m 
/docker-entrypoint.sh neo4j &

sleep 2m
# echo "clear database"
# cat /clear-database.cypher | bin/cypher-shell -u neo4j -p test --format plain
echo "start data import"
if [ -f "/import_finished" ]; then
    echo "Data was already imported into Neo4j."
else
    echo "Starting import of data ..."
    cat /create-nodes-and-relationship-for-spotify-example.cypher | bin/cypher-shell -u neo4j -p test --format plain
    touch /import_finished
    echo "Import finished!"
fi

fg %1