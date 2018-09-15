CREATE CONSTRAINT ON (p:Person) ASSERT p.AV_PID IS UNIQUE;
CREATE CONSTRAINT ON (i:Government_Identifier) ASSERT (i.Identifier, i.Type) IS NODE KEY
CREATE CONSTRAINT ON (s:Host_ID) ASSERT (s.ID, s.Host) IS NODE KEY


#Load employees

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///Employees.csv' AS line
WITH line

MATCH (org:Limited_Company {AV_ID:line.AV_ID})
MERGE (per:Person {AV_PID:line.AV_PID, Name:line.NAME})
MERGE (name:Name {Title:line.TITLE_P, Given_Name:line.GIVEN_NAME_P, Family_name:line.FAMILY_NAME_P})
CREATE (per)-[:HAS_PREFERED_NAME]->(name)
CREATE (org)-[:EMPLOYS {From:line.OCC_START}]->(per)

#Load Occupations
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///Employees.csv' AS line
WITH line

MATCH (per:Person {AV_PID:line.AV_PID})
CREATE (occ:Main_Occupation {Occupation:line.OCCUPATION})
MERGE (per)-[:HAS_OCCUPATION_OF]->(occ)

#Load legal name
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///Employees.csv' AS line
WITH line

MATCH (per:Person {AV_PID:line.AV_PID})
MERGE (name:Name {Title:line.TITLE, Given_Name:line.GIVEN_NAME, Family_name:line.FAMILY_NAME})
CREATE (per)-[:HAS_LEGAL_NAME]->(name)

#Load NI Numbers
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///Employees.csv' AS line
WITH line

WHERE NOT line.NI_NO IS NULL 
MERGE (ident:Government_Identifier {Identifier:line.NI_NO, Type:"NI_Number"})
WITH line, ident 
MATCH (per:Person {AV_PID:line.AV_PID})
CREATE (per)-[:IS_IDENTIFIED_BY]->(ident)