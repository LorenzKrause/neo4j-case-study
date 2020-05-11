// Erste Abfrage - Tabelle
MATCH (r:Ranking {rank: '1'})-[placed:PLACED_IN]->(t:Track)-[c:CREATED_by]->(a:Artist)
MATCH (r)-[listed:LISTED_IN]->(reg:Region {region: 'de'})
WHERE date(placed.date) >= date('2020-01-01')
RETURN placed.date AS stream_date, 
	a.name AS artist, 
    t.name AS track_name,
    r.rank AS rank,
    placed.no_streams AS no_streams
ORDER BY placed.date ASC