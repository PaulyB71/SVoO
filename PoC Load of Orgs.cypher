CREATE CONSTRAINT ON(c:Limited_Company) ASSERT c.AV_ID IS UNIQUE;
CREATE CONSTRAINT ON (en:Experian_Number) ASSERT en.Number IS UNIQUE;
CREATE CONSTRAINT ON (cn:Company_Registration_Number) ASSERT cn.Number IS UNIQUE;
CREATE CONSTRAINT ON (j:Jusrisdiction) ASSERT j.Name IS UNIQUE;
CREATE CONSTRAINT ON (cl:Classification) ASSERT cl.Code IS UNIQUE;


//Load Organisations

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///Megafile.csv' AS line
WITH line

CREATE (org:Limited_Company {AV_ID:line.AV_ID, Trading_Name:line.NAME, Legal_Status:line.LEGSTAT, Trading_Status:"Active", Is_Employer:CASE UPPER(line.EMPLOYER) WHEN 'Y' THEN true ELSE false END, Is_Marketable:CASE UPPER(line.MAILABLE) WHEN 'Y' THEN true ELSE false END, Website:line.URL})

MERGE (exn:Experian_Number {Number:line.PH_CO})

MERGE (crn:Company_Registration_Number {Number:line.CRN, Date_of_Incorporation:line.CO_BORNYR})

MERGE (jur:Jusrisdiction {Name:line.DTIREGION})

CREATE (org)-[:IS_IDENTIFIED_BY {Validated:true}]->(exn)
CREATE (org)-[:IS_IDENTIFIED_BY {Validated:false}]->(crn)
CREATE (org)-[:OPERATES_TO_THE_LAWS_OF]->(jur)
;

//Load Classifications

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///SIC07_CH_condensed_list_en.csv' AS line
WITH line

MERGE (class:Classification {Code:line.`SIC Code`, Name:line.Description, Classification:"SIC"})
;

//Assign Classifications

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///Megafile.csv' AS line
WITH line

MATCH (class:Classification {Code:line.UKSIC07_1})
MATCH (org:Limited_Company {AV_ID:line.AV_ID})
MERGE (org)-[:IS_CLASSIFIED_AS]->(class)
;

//Add Addresses

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///Megafile.csv' AS line
WITH line

MATCH (org:Limited_Company {AV_ID:line.AV_ID})
CREATE (add:UK_Structured_Address {Address_Line_1:line.AD1, Address_Line_2:line.AD2, Address_Line_3:line.AD3, Address_line_4:line.AD4, Address_Line_5:line.AD5, Post_Town:line.TOWN, Postcode:line.POSTCODE})
MERGE (org)-[:HAS_CORRESPONDANCE_ADDRESS_OF]->(add)
;

//Add Phone Numbers

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM
'file:///Megafile.csv' AS line

WITH line
WHERE NOT line.PHONE IS NULL
MERGE (pn:Phone_Number {Standardised_Phone_Number:line.PHONE})

WITH pn, line
MATCH (org:Limited_Company {AV_ID:line.AV_ID})
CREATE (org)-[:IS_CONTACTABLE_BY]->(pn)
