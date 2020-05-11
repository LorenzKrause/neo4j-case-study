// Create Nodes and Relationship for Spotify example

// Create indexs for performance boost 
CREATE INDEX ON :Artist(artist_id);
CREATE INDEX ON :Track(track_id);
CREATE INDEX ON :Region(region);
CREATE INDEX ON :Ranking(rank);


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
 
// create ranking and region nodes with relationship
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///ranking.csv" AS row
MERGE (region:Region {region: row.region})
MERGE (:Ranking {rank: row.rank})-[:LISTED_IN]->(region);

// create ranking track relationship
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///ranking.csv" AS row
MATCH (r:Ranking {rank: row.rank})-[:LISTED_IN]->(:Region {region: row.region})
MATCH (t:Track {track_id: row.track_id})
CREATE (r)-[:PLACED_IN {date: row.stream_date, no_streams: row.no_streams}]->(t);

// remove unused information
MATCH (a:Artist)
REMOVE a.artist_id;

MATCH (t:Track)
REMOVE t.track_id;