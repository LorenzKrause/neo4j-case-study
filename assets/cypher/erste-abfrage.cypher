// erste abfrage
Match (r:Ranking {rank: '1'})-[placed:PLACED_IN]->(t:Track)-[c:CREATED_by]->(a:Artist)
where date(placed.date) >= date('2020-01-01') and r.region = 'de'
return r, placed, t