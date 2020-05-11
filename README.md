# Neo4j case study
This project aims to give a practical introduction in modeling graph data. importing CSV data into a graph model and cypher query's. This is the result of a
case study carried out with neo4j. The dataset used in this case study consists of Spotify rankings of each day from January 2019 to February 2020 in the region Global and Germany. 


## Requirements
The case study was carried out .It is possible to use the dockerfile provided in this project to create a container for an automatic data import. alternatively, the data import can be done manually. For this purpose the data set has to be copied to the host and the cypher queries can be executed via the browser. 
- Docker installed on host system [Download & Install](https://docs.docker.com/desktop/)

## Building the container
Builint the container can be initiated with:
`docker built -t neo4j_case_study` .

During the container create the dataset, cypher scripts and import script will be copied to the container. In addition a password for the neo4j user is set.
```bash
User: neo4j
Password: test
```

## Installation
The installation can be carried out with one command: `docker run -d --name neo4j_case_study -p 7474:7474 -p 7687:7687 neo4j_case_study`

This command maps port 7474 and 7687 to the localhost. The neo4j browser will be accessible at http://localhost:7474. Further configuration can be found at the [Neo4j documentation](https://neo4j.com/developer/docker-run-neo4j/). For example the database data can be 
persisted with volumes. Other installation methods can be found at the 
[Neo4j documentation](httos://neo4j.com/docs/operations-manual/current/installation/). 

## Import of data

After the database is running, a cypher script is executed which contains the process of importing the data into the graph model. Afterwards the database is now ready to execute some query's on the graph model. This is the graph model created during the case study  for the dataset:
![Graph Model](assets/graph_model.png)

### Import process
At first indexes for the nodes will be created. This will increase the 
performance within further query's on these properties of the nodes.
```bash
CREATE INDEX ON :Artist(artist_id);
CREATE INDEX ON :Track(track_id);
CREATE INDEX ON :Region(region);
CREATE INDEX ON :Ranking(rank);
```

Now follows the creation of the track and artist nodes with their relationship.
The track node will also be added the property of the url
```bash
// create artist nodes
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///artist.csv" AS row
CREATE (:Artist {artist_id: row.id, name: row.artist});

// Create track
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///track.csv" AS row
CREATE (:Track {track_id: row.id, name: row.track_name});

// add url information to track
LOAD CSV WITH HEADERS FROM "file:///ranking.csv" AS row
MATCH (t:Track {track_id: row.track_id})
SET t.url = row.url;

// create artist / track
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///ranking.csv" AS r_row
MATCH(a:Artist {artist_id: r_row.artist_id})
MATCH(t:Track {track_id: r_row.track_id})
MERGE (t)-[:CREATED_by]->(a);
```
Now follows the creation of the ranking nodes with their division into a region.
```bash
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///ranking.csv" AS row
MERGE (region:Region {region: row.region})
MERGE (:Ranking {rank: row.rank})-[:LISTED_IN]->(region);
```

Finally, the Ranking nodes and Tracks nodes are now connected. 
```bash
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///ranking.csv" AS row
MATCH (r:Ranking {rank: row.rank})-[:LISTED_IN]->(:Region {region: row.region})
MATCH (t:Track {track_id: row.track_id})
CREATE (r)-[:PLACED_IN {date: row.stream_date, no_streams: row.no_streams}]->(t);
```

### Important import data
The repository consists of two import directory's and one bash script for the data import:
```
.
+-- assets/
    +-- data/
    +-- cypher/
+-- import_data.sh
```
These files can be exchanged to extend the dataset or use another data model.

## Example querys
The following sample queries are based on queries that are executed with SQL on the given data set. In the first query all tracks which are ranked 1st in the region 'de' from 01.01.2020 should be found. 
```bash
MATCH (r:Ranking {rank: '1'})-[placed:PLACED_IN]->(t:Track)-[c:CREATED_by]->(a:Artist)
MATCH (r)-[listed:LISTED_IN]->(reg:Region {region: 'de'})
WHERE date(placed.date) >= date('2020-01-01')
RETURN r, placed, t, c, a, reg, listed
```
The result of this query can be seen in the following:
![Graph Model](assets/query1.png)


In the second query, the first is to be extended. Now all further tracks of an artist, who has a place 1 placement from 01.01.2020, should be found.
```bash
MATCH (r:Ranking {rank: '1'})-[placed:PLACED_IN]->(t:Track)-[c:CREATED_by]->(a:Artist)
MATCH (r)-[listed:LISTED_IN]->(region:Region {region: 'de'})
WHERE date(placed.date) >= date('2020-01-01')
MATCH (r2:Ranking)-[placed2:PLACED_IN {date: placed.date}]->(t2:Track)-[c2:CREATED_by]->(a)
MATCH (r2)-[listed2:LISTED_IN]->(region2:Region {region: 'de'})
WHERE r <> r2 AND t <> t2
RETURN r, placed, t, r2, placed2, t2, c, a, c2, region, listed2, region2, listed
```
The result of this query can be seen in the following:
![Graph Model](assets/query2.png)