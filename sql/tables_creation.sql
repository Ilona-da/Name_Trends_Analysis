-- Table structure for table 'names'

USE baby_names_db;

DROP TABLE IF EXISTS names;

CREATE TABLE names (
  State CHAR(2),
  Gender CHAR(1),
  Year INT,
  Name VARCHAR(45),
  Births INT);

-- Table structure for table 'regions'

CREATE TABLE regions (
  State CHAR(2),
  Region VARCHAR(45));

-- Insert data into table 'names'

BULK INSERT names
FROM 'C:\temp\names_data.csv'
WITH (
  FIELDTERMINATOR = ',',
  ROWTERMINATOR = '\n'
);

-- Insert data into table 'regions'

INSERT INTO regions VALUES 
('AL', 'South'),
('AK', 'Pacific'),
('AZ', 'Mountain'),
('AR', 'South'),
('CA', 'Pacific'),
('CO', 'Mountain'),
('CT', 'New_England'),
('DC', 'Mid_Atlantic'),
('DE', 'South'),
('FL', 'South'),
('GA', 'South'),
('HI', 'Pacific'),
('ID', 'Mountain'),
('IL', 'Midwest'),
('IN', 'Midwest'),
('IA', 'Midwest'),
('KS', 'Midwest'),
('KY', 'South'),
('LA', 'South'),
('ME', 'New_England'),
('MD', 'South'),
('MA', 'New_England'),
('MN', 'Midwest'),
('MS', 'South'),
('MO', 'Midwest'),
('MT', 'Mountain'),
('NE', 'Midwest'),
('NV', 'Mountain'),
('NH', 'New England'),
('NJ', 'Mid_Atlantic'),
('NM', 'Mountain'),
('NY', 'Mid_Atlantic'),
('NC', 'South'),
('ND', 'Midwest'),
('OH', 'Midwest'),
('OK', 'South'),
('OR', 'Pacific'),
('PA', 'Mid_Atlantic'),
('RI', 'New_England'),
('SC', 'South'),
('SD', 'Midwest'),
('TN', 'South'),
('TX', 'South'),
('UT', 'Mountain'),
('VT', 'New_England'),
('VA', 'South'),
('WA', 'Pacific'),
('WV', 'South'),
('WI', 'Midwest'),
('WY', 'Mountain');


