CREATE CONSTRAINT ON (p:Person) ASSERT p.AV_PID IS UNIQUE;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///Employees.csv' AS line
WITH line

MATCH (org:Limited_Company {AV_ID:line.AV_ID})
MERGE (per:Person {Name:line.NAME})
MERGE (name:Name {Title:line.TITLE_P, Given_Name:line.GIVEN_NAME_P, Family_name:line.FAMILY_NAME_P})
CREATE (per)-[:HAS_PREFERED_NAME]->(name)
CREATE (org)-[:EMPLOYS {From:line.OCC_START]->(per)