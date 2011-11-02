-- This script populates the repository with sample data related 
-- information including users and data sources

USE hibernate;

--  Create HSQLDB Sample Data Source

INSERT INTO DATASOURCE VALUES('SampleData',20,'com.mysql.jdbc.Driver',5,'pentaho_user','password','jdbc:mysql://localhost/sampledata','select 1',1000);

commit;
