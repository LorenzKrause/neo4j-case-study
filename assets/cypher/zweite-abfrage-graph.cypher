// Zweite Abfrage - Graph
MATCH (r:Ranking {rank: '1'})-[placed:PLACED_IN]->(t:Track)-[c:CREATED_by]->(a:Artist)
MATCH (r)-[listed:LISTED_IN]->(region:Region {region: 'de'})
WHERE date(placed.date) >= date('2020-01-01')
MATCH (r2:Ranking)-[placed2:PLACED_IN {date: placed.date}]->(t2:Track)-[c2:CREATED_by]->(a)
MATCH (r2)-[listed2:LISTED_IN]->(region2:Region {region: 'de'})
WHERE r <> r2 AND t <> t2
RETURN r, placed, t, r2, placed2, t2, c, a, c2, region, listed2, region2, listed