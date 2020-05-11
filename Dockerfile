FROM neo4j:latest

# SHELL ["/bin/bash", "-c"]
ENV NEO4J_AUTH=neo4j/test

# copy cypher scripts for grap model import
COPY assets/cypher/* /

# copy dataset 
COPY assets/data/* /var/lib/neo4j/import/

# copy import script 
COPY import_data.sh import_data.sh

# RUN apk add --no-cache --quiet procps
# RUN chmod 777 /import_data.sh

ENTRYPOINT ["./import_data.sh"]