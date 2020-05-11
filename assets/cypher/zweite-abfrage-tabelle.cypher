// Zweite Abfrage - Tabelle
MATCH (r:Ranking {rank: '1'})-[placed:PLACED_IN]->(t:Track)-[c:CREATED_by]->(a:Artist)
MATCH (r)-[listed:LISTED_IN]->(region:Region {region: 'de'})
WHERE date(placed.date) >= date('2020-01-01')
MATCH (r2:Ranking)-[placed2:PLACED_IN {date: placed.date}]->(t2:Track)-[c2:CREATED_by]->(a)
MATCH (r2)-[listed2:LISTED_IN]->(region2:Region {region: 'de'})
WHERE r <> r2 and t <> t2
RETURN placed.date AS stream_date, a.name AS artist,
       t.name AS track_name, r.rank AS rank, 
       placed.no_streams AS no_streams, 
       t2.name AS track_name_2, placed2.no_streams AS no_stream_2, r2.rank AS rank_2
ORDER BY placed.date ASC