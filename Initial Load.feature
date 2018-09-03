Feature:Initial Load
	In order to load organisation from Experian file
	As an Organisation added to Master
	I want to see organisation is added to Master

@Experian file
Scenario: Trading status is dead on Experian file

    Given the record from Experian is an Organisation record
    When the Trading Status  equals ‘Dead’
    Then do not write a record to SVOO

@Experian file
Scenario: New Organisation added to master
    Given the record from Experian is an Organisation record
    When record is not present in Master 
    Then the Organisation is added to the Master 


@Experian file
Scenario: New Organisation added to master
    Given the record from Experian is an Organisation record
    When record is found in Master and SVOO has a verified identifier 
    Then the Organisation on SVOO is not updated


@Experian file
Scenario: New Organisation added to master
    Given the record from Experian is an Organisation record
    When is found and SVOO has no verified identifier
    Then the Organisation on SVOO is updated with the data from the Experian file