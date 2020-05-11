// Erste Abfrage - Graph
MATCH (r:Ranking {rank: '1'})-[placed:PLACED_IN]->(t:Track)-[c:CREATED_by]->(a:Artist)
MATCH (r)-[listed:LISTED_IN]->(reg:Region {region: 'de'})
WHERE date(placed.date) >= date('2020-01-01')
RETURN r, placed, t, c, a, reg, listed