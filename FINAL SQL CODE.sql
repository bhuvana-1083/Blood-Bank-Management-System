FINAL SQL CODE

CREATE SCHEMA bloodbank;

CREATE TABLE bloodbank.persons( pid char(8) not null unique, name text not null,  age integer not null, 
gender char(1) not null, weight integer not null, Blood_group char(3) not null, DP char(1) not null, 
CONSTRAINT check_gender CHECK(gender='M' OR gender='F'),CONSTRAINT check_dp CHECK(DP='D' OR DP='P'), primary key (pid));


CREATE TABLE bloodbank.donors( pid char(8) not null, Blood_group char(3) not null, 
primary key(pid), CONSTRAINT dpidfk FOREIGN KEY(pid) REFERENCES persons(pid) ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE bloodbank.patients( pid char(8) not null, Blood_group char(3) not null,
primary key(pid), CONSTRAINT ppidfk FOREIGN KEY(pid) REFERENCES persons(pid) ON DELETE CASCADE ON UPDATE CASCADE);


CREATE TABLE bloodbank.Donation_Records( did char(8) not null unique, pid char(8) not null unique DEFAULT('deleted_person'), 
Blood_group char(3) not null, quantity integer not null, date DATE not null, primary key(did),
CONSTRAINT drpidfk FOREIGN KEY(pid) REFERENCES persons(pid) ON DELETE SET DEFAULT ON UPDATE CASCADE );


CREATE TABLE bloodbank.Transfusion_Records( tid char(8) not null unique, pid char(8) not null unique DEFAULT('deleted_person'), 
Blood_group char(3) not null, quantity integer not null, date DATE not null, primary key(tid),
CONSTRAINT trpidfk FOREIGN KEY(pid) REFERENCES persons(pid) ON DELETE SET DEFAULT ON UPDATE CASCADE);

CREATE TABLE bloodbank.Inventory(Blood_group char(3) not null unique, Stock_quantity integer not null, primary key(Blood_group));


INSERT INTO bloodbank.persons values ('p1', 'John', '21', 'M', '65', 'AB-', 'D');
INSERT INTO bloodbank.persons values ('p2', 'Ross', '30', 'M', '72', 'O+', 'D');
INSERT INTO bloodbank.persons values ('p3', 'Rachel', '34', 'F', '67', 'A+', 'D');
INSERT INTO bloodbank.persons values ('p4', 'Andy', '27', 'M', '58', 'O+', 'D');
INSERT INTO bloodbank.persons values ('p5', 'Justin', '16', 'M', '51', 'A-', 'D');
INSERT INTO bloodbank.persons values ('p6', 'Mary', '22', 'F', '43', 'B+', 'D');
INSERT INTO bloodbank.persons values ('p7', 'Monica', '52', 'F', '70', 'B-', 'P');
INSERT INTO bloodbank.persons values ('p8', 'Joey', '47', 'M', '79', 'O-', 'P');
INSERT INTO bloodbank.persons values ('p9', 'Robert', '55', 'M', '82', 'AB+', 'P');
INSERT INTO bloodbank.persons values ('p10', 'Erica', '38', 'F', '64', 'O+', 'P');


INSERT INTO bloodbank.donors SELECT pid, Blood_group FROM bloodbank.persons WHERE persons.weight>45 AND persons.age>18 AND persons.dp='D';


INSERT INTO bloodbank.patients SELECT pid, Blood_group FROM bloodbank.persons WHERE persons.dp='P';



INSERT INTO bloodbank.Donation_Records values ('d1', 'p2', 'O+', '470', '2020-05-20');
INSERT INTO bloodbank.Donation_Records values ('d2', 'p3', 'A+', '470', '2020-05-20');
INSERT INTO bloodbank.Donation_Records values ('d3', 'p4', 'O+', '350', '2020-05-20');



INSERT INTO bloodbank.Transfusion_Records values ('t1', 'p7', 'B-', '200', '2020-05-20');
INSERT INTO bloodbank.Transfusion_Records values ('t2', 'p8', 'O-', '300', '2020-05-20');
INSERT INTO bloodbank.Transfusion_Records values ('t3', 'p10', 'O+', '100', '2020-05-20');



INSERT INTO bloodbank.Inventory values ('A+','300');
INSERT INTO bloodbank.Inventory values ('A-','200');
INSERT INTO bloodbank.Inventory values ('B+','150');
INSERT INTO bloodbank.Inventory values ('B-','250');
INSERT INTO bloodbank.Inventory values ('AB+','200');
INSERT INTO bloodbank.Inventory values ('AB-','450');
INSERT INTO bloodbank.Inventory values ('O+','700');
INSERT INTO bloodbank.Inventory values ('O-','600');



//triggers

DELIMITER $$
CREATE TRIGGER bloodbank.Inventory_Decrease
BEFORE UPDATE ON Transfusion_Records
FOR EACH ROW
BEGIN
IF NEW.Quantity is NOT NULL THEN
UPDATE Inventory
SET Stock_quantity = Stock_quantity - NEW.Quantity
WHERE NEW.Blood_Group = Inventory.Blood_group;
END IF;
END$$
DELIMITER;

DELIMITER $$
CREATE TRIGGER bloodbank.Inventory_Decrease1
BEFORE INSERT ON Transfusion_Records
FOR EACH ROW
BEGIN
IF NEW.Quantity is NOT NULL THEN
UPDATE Inventory
SET Stock_quantity = Stock_quantity - NEW.Quantity
WHERE NEW.Blood_Group = Inventory.Blood_group;
END IF;
END$$
DELIMITER;




DELIMITER $$
CREATE TRIGGER bloodbank.Inventory_Increase
AFTER UPDATE ON Donation_Records
FOR EACH ROW
BEGIN
IF NEW.Quantity is NOT NULL THEN
UPDATE Inventory
SET Stock_quantity = Stock_quantity + NEW.Quantity
WHERE NEW.Blood_Group = Inventory.Blood_group;
END IF;
END$$
DELIMITER;

DELIMITER $$
CREATE TRIGGER bloodbank.Inventory_Increase1
AFTER INSERT ON Donation_Records
FOR EACH ROW
BEGIN
IF NEW.Quantity is NOT NULL THEN
UPDATE Inventory
SET Stock_quantity = Stock_quantity + NEW.Quantity
WHERE NEW.Blood_Group = Inventory.Blood_group;
END IF;
END$$
DELIMITER;


//after executing the triggers , open another sql commandline client & execute the given code below , 
this is to show maam during the presentation.


use bloodbank;

SELECT *FROM bloodbank.Inventory;

INSERT INTO bloodbank.persons values ('p11', 'Sid', '30', 'M', '68', 'O+', 'D');

INSERT INTO bloodbank.Donation_Records values ('d4', 'p11', 'O+', '300', '2020-05-20');

SELECT *FROM bloodbank.Inventory;

INSERT INTO bloodbank.persons values ('p12', 'Pete', '42', 'M', '74', 'A+', 'P');

INSERT INTO bloodbank.Transfusion_Records values ('t4', 'p12', 'A+', '100', '2020-05-20');

SELECT *FROM bloodbank.Inventory;






//some complex SQL queries


Select* FROM bloodbank.Transfusion_records WHERE quantity>100;

Select* FROM bloodbank.persons WHERE persons.weight<45 OR persons.age<18;


SELECT I.Blood_group, I.Stock_quantity
FROM bloodbank.Inventory as I
WHERE EXISTS (SELECT *
				FROM Donation_Records as P
				WHERE  P.Blood_group = I.Blood_group);


SELECT I.Blood_group, I.Stock_quantity
FROM bloodbank.Inventory as I
WHERE EXISTS (SELECT *
				FROM Transfusion_Records as Q
				WHERE  Q.Blood_group = I.Blood_group);

SELECT I.Blood_group
FROM bloodbank.Inventory as I
WHERE NOT EXISTS (SELECT *
				FROM Donation_Records as P
				WHERE  P.Blood_group = I.Blood_group);


SELECT I.Blood_group
FROM bloodbank.Inventory as I
WHERE NOT EXISTS (SELECT *
				FROM Transfusion_Records as Q
				WHERE  Q.Blood_group = I.Blood_group);






SELECT SUM(Stock_quantity), MAX(Stock_quantity), MIN(Stock_quantity), AVG(Stock_quantity)
FROM bloodbank.Inventory;

SELECT COUNT(Blood_group)
FROM bloodbank.Inventory;






SELECT p.pid,
p.name,
p.gender,
COUNT(d.pid) AS TimesDonated,
SUM(d.quantity) AS TotalAmount
FROM persons p INNER JOIN donation_records d ON p.pid = d.pid
GROUP BY p.pid
ORDER by TotalAmount asc;


SELECT p.pid,
p.name,
p.gender,
COUNT(t.pid) AS TimesRecieved,
SUM(t.quantity) AS TotalAmount
FROM persons p INNER JOIN Transfusion_records t ON p.pid = t.pid
GROUP BY p.pid
ORDER by TotalAmount asc;




SELECT persons.pid, persons.name, Donation_records.blood_group, Donation_records.quantity
FROM persons
LEFT JOIN Donation_records
ON persons.pid = Donation_records.pid;



SELECT Transfusion_records.pid, Transfusion_records.blood_group, Transfusion_records.quantity, persons.name, persons.age, persons.gender, persons.weight
FROM persons
RIGHT JOIN Transfusion_records
ON persons.pid = Transfusion_records.pid;






