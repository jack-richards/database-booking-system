/* !IMPORTANT! Due to all the test methods that use SELECT queries to provide a visual indicator that an action has done something 
   mySQL workbench will in-fact crash, no matter what type of PC you have, when running this file in it's enirety. Instead of running it
   all at once each 'section' will have to be run independently. This is sadly unavoidable as far as I'm aware. I've designed this SQL file
   in a way where you have to (to ensure the tests work as expected) run the queries from top to bottom, though this type of behaviour
   is expected to be seen regardless since the run command would just run the entire file from top to bottom anyways under normal conditions.
   I've gone through this section-by-section running process myself and everything works as expected. */

/* Drops (deletes) the database if it already exists. */
DROP DATABASE IF EXISTS `co_working_spaces`;

/* Creates the database `co_working_spaces`. */
CREATE SCHEMA `co_working_spaces` DEFAULT CHARACTER SET utf8;
USE `co_working_spaces`; /* Should allow us to refer to the schema we just created
by default in this file, unless sepecified otherwise. */

/* Creates a table called users. This will store the information 
   relating to each user. */
CREATE TABLE `users` (
  `userID` INT AUTO_INCREMENT NOT NULL, -- We want the userID to auto-increment, whenever a new user is added
  -- they will get assigned the next increment of userID. This ensures uniqueness.
  `typeOfUser` VARCHAR(14) NOT NULL, -- Type of user should only ever be 14 letters long since the longest member-type identifier
  -- is 14 letters long.
  `name` VARCHAR(45) NOT NULL, -- Name could include first name, middle name and surname so I made it 45 letters to be safe.
  `moneyOwed` FLOAT NULL DEFAULT 0, -- moneyOwed needs to default to 0 since it would cause issues if I tried to add a number to a NULL value.
  -- Plus all new accounts/users should realistically owe nothing anyway.
  `membershipExpires` DATETIME NULL, -- All users should default to not having a membership on creation, hence why it's logical to have membershipExpires
  -- default to NULL. Also, I thought it best to use the DATETIME datatype since it will allow for the user to get every second worth of their membership
  -- when we check for when it's expired.
  `daysLeft` INT NULL DEFAULT 0, -- Users should not be a part-time member on creation so that's why I thought it best to have this default to 0. By having
  -- the value default to 0 it also allows for calculations to be performed on the number later if needed, while a NULL value would cause issues.
  PRIMARY KEY (`userID`), -- There should only ever be one user related to one userID. We need to be able to uniquely identify the users.
  UNIQUE(`userID`)); -- Ensures that column value is unique, there can only be on row in
  -- the table with the same userID.
  
  /* Creates a table called Locations. This will store the information
   relating to each location. */
CREATE TABLE `Locations` (
  `locationID` INT AUTO_INCREMENT NOT NULL, -- Same principle as what I described for userID, except this time for locationID.
  `name` VARCHAR(45) NOT NULL,
  `address` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`locationID`),
  UNIQUE(`name`), 
  UNIQUE(`locationID`),
  UNIQUE(`address`));

/* Creates a table called Desks. This will store the information
   relating to each desk. */
CREATE TABLE `Desks` (
  `deskID` INT AUTO_INCREMENT NOT NULL, -- Same principle as what I discussed for userID.
  `location` INT NOT NULL, -- A desk should always be in a location, therefore we shouldn't be able to insert a row with this column as NULL.
  PRIMARY KEY (`deskID`),
  CONSTRAINT `fk_Desks_Locations_locationID` -- Foreign key naming scheme is fk_refrencing table_refrenced table_referenced table column.
    FOREIGN KEY (`location`) -- Here we create a relationship between Desks and Locations. Desks is the child table to the parent table Locations in this instance.
    REFERENCES `Locations` (`locationID`)); -- The column id location in Desks has to exist in the Locations table in the locationID column, otherwise it
    -- will cause a foreign key constraint error. As for any deletes, a row in the Locations table with a locationID that is being used by a row in the Desks table
    -- can't be deleted without the row in the child table (Desks) using the value being deleted first. This creates a level of data-integrity at the schema level.
    
/* Creates a table called privateDesks. This will store all the privateDesks
   that exist. */
CREATE TABLE `privateDesks` (
  `privateDeskID` INT NOT NULL,
  `userID` INT NOT NULL,
  PRIMARY KEY (`privateDeskID`, `userID`), -- Composite primary key. Ensures that rows can't be inserted with the same userID and privateDeskID as another row
  -- that already exists in the table. Basically ensures there's only one unique combination of the two columns.
  UNIQUE(`privateDeskID`),
  UNIQUE(`userID`),
  CONSTRAINT `fk_privateDesks_Desks_privateDeskID` -- For data-integrity as discussed before.
    FOREIGN KEY (`privateDeskID`)
    REFERENCES `Desks` (`deskID`)
	ON DELETE CASCADE,
  CONSTRAINT `fk_privateDesks_users_userID`
    FOREIGN KEY (`userID`)
    REFERENCES `users` (`userID`));

/* Creates a table called deskReservation. As the name suggests, it'll
   store all the desk reservations that have been created. */
CREATE TABLE `deskReservations` (
  `deskID` INT NOT NULL,
  `reserverID` INT NOT NULL,
  `reservationDate` DATE NOT NULL,
  PRIMARY KEY (`reservationDate`, `deskID`), -- Composite primary key of the reservationDate and deskID. Will disallow INSERTING any rows that have
  -- the same deskID and reservationDate as another row that already exists in the deskReservations table. This I feel is logical as it allows for
  -- multiple reservations to be made by a user and at the same time, reservations to be made for different desks, multiple users to reserve the same desk
  -- etc. However, it won't allow for a user to reserve a desk for a date that is identical to an already existing reservation, this ensures that a desk
  -- can't be double-booked.
  CONSTRAINT `fk_deskReservations_Desks_deskID` -- Same principle as what's discussed below.
    FOREIGN KEY (`deskID`)
    REFERENCES `Desks` (`deskID`),
  CONSTRAINT `fk_deskReservations_users_userID` -- Should in theory, ensure that a userID that doesn't exist in the Users table can't be inserted into deskReservations.
    FOREIGN KEY (`reserverID`)
    REFERENCES `users` (`userID`));

/* Creates a table called privateMeetingRooms. This will store all
   the private meeting rooms that exist for each location. */
CREATE TABLE `privateMeetingRooms` (
  `privateMeetingRoomID` INT AUTO_INCREMENT NOT NULL,
  `location` INT NOT NULL,
  UNIQUE(`privateMeetingRoomID`), -- Arguably kind of unnessecary given I define it as a primary key just below but I'm doing it to be certain.
  PRIMARY KEY (`privateMeetingRoomID`),
  CONSTRAINT `fk_privateMeetingRooms_Locations_locationID` -- Will create a relationship between this table and the locations table. If a locationID
  -- is attempted to be inserted into this table that doesn't exist in the locations table, a foreign key constraint error will be thrown. Also,
  -- a row in the Locations table with a locationID that's in use cannot be deleted if a child table (privateMeetingRooms) has a row that uses it, 
  -- the child row will first need to be deleted.
    FOREIGN KEY (`location`)
    REFERENCES `Locations` (`locationID`)
	ON DELETE CASCADE); -- When a row with a locationID that is used by row(s) in the privateMeetingRooms table is deleted from the Locations table.
    -- Then all rows from the privateMeetingRooms table that use it will be deleted.

/* Creates a table called privateMeetingRoomReservations. This will store all
   the reservations for any of the private meeting rooms. */
CREATE TABLE `privateMeetingRoomReservations` (
  `privateMeetingRoomID` INT NOT NULL,
  `reserverID` INT NOT NULL,
  `reservationDate` DATE NOT NULL,
  PRIMARY KEY (`privateMeetingRoomID`, `reservationDate`),
  UNIQUE(`privateMeetingRoomID`),
  UNIQUE(`reservationDate`),
  CONSTRAINT `fk_privateMeetingRoomReservations_users_userID`
    FOREIGN KEY (`reserverID`)
    REFERENCES `users` (`userID`),
  CONSTRAINT `fk_privateMeetingRoomR_privateMeetingRooms_privateMeetingRID` -- Constraint name was too long if I spelled out privateMeetingRoom, shortened it to R.
    FOREIGN KEY (`privateMeetingRoomID`)
    REFERENCES `privateMeetingRooms` (`privateMeetingRoomID`)
    ON DELETE CASCADE); -- Same behaviour basically as what I discussed in the above CREATE TABLE query except this time it's between privateMeetingRoomReservations
    -- and privateMeetingRooms.

/* ------------------------------------------------- */

/* Triggers */
/* This will trigger BEFORE a row is inserted into the deskReservations table. It will
   check to see if the deskID for the reservation entered actually exists in the Desks table or not.
   It will also check to see if the userID in the row to INSERT actually exists in the users table or not.
   If either of the two IDs don't exist, then the INSERT will fail and return an error message. */
DELIMITER $$
USE `co_working_spaces`;
$$
CREATE DEFINER = CURRENT_USER TRIGGER `Before_Inserting_a_Desk_Reservation` 
	BEFORE INSERT ON `deskReservations` FOR EACH ROW
BEGIN
	DECLARE idCount INT;
    DECLARE userIDCount INT;
    /* We count the amount of rows in the desks table that have the same deskID as what is being reserved. */
    SELECT COUNT(*) FROM co_working_spaces.desks WHERE deskID = NEW.deskID INTO idCount;
	/* We count the amount of rows in the users table with a userID that equals the reserverID provided for the reservation. */
    SELECT COUNT(*) FROM co_working_spaces.users WHERE userID = NEW.reserverID INTO userIDCount;
    /* If there're no matching IDs then we know that this reservation shouldn't be allowed since the desk being booked
       doesn't exist. We then cancel the insert operation via signalling an error code. This also has the added effect of
       causing the transaction to fail in reserveDesk(), causing a rollback of any changes. The same goes for the reserver/userID. */
    IF idCount < 1 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT="Cannot create a reservation for a desk that doesn't exist. Please enter a valid desk ID.";
	ELSEIF userIDCount < 1 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT="Cannot create a reservation for a user that doesn't exist. Please enter a valid user ID.";
	END IF;
END$$

/* This will trigger only AFTER a desk reservation has been deleted from the deskReservations table. It will
   in summary check what type of user the now deleted reservation belonged to and, if applicable, reimburse them.*/
DELIMITER $$
USE `co_working_spaces`;
$$
CREATE DEFINER = CURRENT_USER TRIGGER `After_Deleting_a_Desk_Reservation`
	AFTER DELETE ON `deskReservations` FOR EACH ROW
BEGIN
    DECLARE theTypeOfUser VARCHAR(14);
    DECLARE theMoneyOwed FLOAT;
    DECLARE theDaysLeft INT;
    
	SELECT typeOfUser FROM co_working_spaces.users WHERE users.userID = OLD.reserverID INTO theTypeOfUser;
    SELECT moneyOwed FROM co_working_spaces.users WHERE users.userID = OLD.reserverID INTO theMoneyOwed;
    SELECT daysLeft FROM co_working_spaces.users WHERE users.userID = OLD.reserverID INTO theDaysLeft;
	/* The goal of this script is to essentially refund the user if needed for the deleted reservation. */
    IF theTypeOfUser = 'partTimeMember' THEN
    /* We can't assume that they are below the amount of reservations they get with their membership in a month (8). */
		IF theDaysLeft < 9 THEN
        /* We add the extra reservation/day they're owed due to us effectively cancelling their reservation for them. */
			UPDATE co_working_spaces.users
			SET daysLeft = daysLeft + 1
			WHERE users.userID = OLD.reserverID;
		END IF;
	ELSEIF theTypeOfUser = 'dailyRatePayer' THEN
    /* We can't assume that they owe money so to be safe we check. */
		IF theMoneyOwed > 0 THEN
        /* We subtract £20 from the amount of money they owe us. Since, afterall we've effectively cancelled their reservation. */
			UPDATE co_working_spaces.users
			SET moneyOwed = moneyOwed - 20
			WHERE users.userID = OLD.reserverID;
		END IF;
	END IF;
END$$
DELIMITER ;
/* -------- */

/* INSERTING sample data. */
USE `co_working_spaces`; -- Making sure that we're still using the correct schema.

/* TEST */
/* Before running inserts. Users table should be empty. */
SELECT * FROM co_working_spaces.users;
/* ---- */

/* Inserts users with varying membership types. */
INSERT INTO users
(name, typeOfUser, membershipExpires, daysLeft, moneyOwed)
VALUES
("Jack Richards", "partTimeMember", DATE_ADD(NOW(), INTERVAL 30 DAY), 8, 120), -- To ensure the users membership is in date at the time the examiner runs this script I've made the code
-- set the users membership expiry date to 30 days after the date the code has been run. HOWEVER, if this doesn't work (it should though) please uncomment the alternative section below
-- and comment this section out.
("Jack Bradley", "partTimeMember", DATE_SUB(NOW(), INTERVAL 5 DAY), 5, 120),
("Andrew Jones", "dailyRatePayer", NULL, 0, 0),
("Usashi Chatterjee", "dailyRatePayer", NULL, 0, 0),
("Cai Connaughton", "dailyRatePayer", NULL, 0, 0),
("Oliver Healey", "fullTimeMember", DATE_SUB(NOW(), INTERVAL 30 DAY), 0, 250), -- Should have an expired membership, so we can test for that condition.
("Carl Jones", "fullTimeMember", DATE_ADD(NOW(), INTERVAL 26 DAY), 0, 250), -- Should be in-date.
("Soumya Barathi", "fullTimeMember", DATE_ADD(NOW(), INTERVAL 34 DAY), 0, 250); -- Should be in-date.

/* ALTERNATIVE SECTION */
-- ("Jack Richards", "partTimeMember", "2022-09-20 12:09:28", 8, 120),
-- ("Jack Bradley", "partTimeMember", "2022-02-16 13:01:25", 5, 120),
-- ("Andrew Jones", "dailyRatePayer", NULL, 0, 0),
-- ("Usashi Chatterjee", "dailyRatePayer", NULL, 0, 0),
-- ("Cai Connaughton", "dailyRatePayer", NULL, 0, 0),
-- ("Oliver Healey", "fullTimeMember", "2022-02-25 17:00:12", 0, 250), -- Should have an expired membership, so we can test for that condition.
-- ("Carl Jones", "fullTimeMember", "2022-08-25 18:30:42", 0, 250), -- Should be in-date.
-- ("Soumya Barathi", "fullTimeMember", "2022-08-28 21:20:10", 0, 250); -- Should be in-date.
/* ------------------ */

/* TEST */
/* After running insert. Users table should be populated with the values seen in the INSERTS above. */
SELECT * FROM co_working_spaces.users;
/* ---- */

/* TEST */
/* Before running INSERT. Locations table should be unpopulated. */
SELECT * FROM co_working_spaces.locations;
/* ---- */


/* Inserts the two locations specified in the brief. The North-West Cardiff and North Cardiff locations. */
INSERT INTO locations
(name, address)
VALUES
("North West Cardiff", "10 North West Cardiff Street, CF20 9AF"),
("North Cardiff", "88 North Cardiff Street, CF19 1CF");

/* TEST */
/* After running INSERT. Locations table should be populated with the values seen in the INSERT above. */
SELECT * FROM co_working_spaces.locations;
/* ---- */

/* TEST */
/* Before running INSERT. Desks should be unpopulated. */
SELECT * FROM co_working_spaces.desks;
/* ---- */

/* Inserts 45 desks for the North-West Cardiff Location. */
INSERT INTO desks
(location)
VALUES
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1),
(1);

/* Inserts 30 desks for the North Cardiff Location. */
INSERT INTO desks
(location)
VALUES
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2),
(2);

/* TEST */
/* After running INSERTs. Desks should be populated with a total of 75 desks. There should be 30 desks in the Cardiff location and 45 desks labelled for the
   North-West Cardiff location. */
/* Gets number of desks in table. Should be 75. */
SELECT COUNT(*) FROM co_working_spaces.desks;

/* Gets number of desks tagged for the North-West Cardiff Location. */
SELECT COUNT(*) FROM co_working_spaces.desks WHERE location = 1;
   
/* Gets number of desks tagged for the North Cardiff Location. */
SELECT COUNT(*) FROM co_working_spaces.desks WHERE location = 2;
/* --- */

/* TEST */
/* Before INSERT. privateMeetingRooms table should be unpopulated. */
SELECT * FROM co_working_spaces.privateMeetingRooms;
/* ---- */

/* Inserts two locations for both the North-West Cardiff location and the North Cardiff Location. */
INSERT INTO privatemeetingrooms
(location)
VALUES
(1),
(1),
(2),
(2);

/* TEST */
/* After INSERT. privateMeetingRooms table should be populated. Two desks should be tagged for North Cardiff and two for North-West Cardiff. */
/* Gets total number of private meeting rooms in table. */
SELECT COUNT(*) FROM co_working_spaces.privateMeetingRooms;

/* Gets number of private meeting rooms in the North-West Cardiff Location. */
SELECT COUNT(*) FROM co_working_spaces.privateMeetingRooms WHERE location = 1;

/* Gets number of private meeting rooms in the North Cardiff Location. */
SELECT COUNT(*) FROM co_working_spaces.privateMeetingRooms WHERE location = 2;
/* ---- */

/* --------------------- */

/* Stored procedures */

/* Takes a name. Will create/insert a new user record with the provided name. Creates a daily-rate payer. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `createUser` (
IN name VARCHAR(45)
)
BEGIN
    START TRANSACTION;
		INSERT INTO users
		(name, typeOfUser, membershipExpires, daysLeft, moneyOwed)
		VALUES
        (name, "dailyRatePayer", NULL, 0, 0);
	COMMIT;
END$$
DELIMITER ;

/* I won't have a test SQL for the above createUser() stored procedure as it could break all the tests below this
   via making the userIDs be autoincremented by one more than they should be. This method is pretty simple and I
   know it works through my own testing anyways. */

/* Takes userID as an argument. Will find out what type of user that person is via a select query then it will,
   if they're a daily rate payer, set them to a partTimeMember and add £120 to the amount they owe (moneyOwed).
   Will also update the dateMembershipExpires field to be the current date plus 30 days from now.
   Alternatively, if they're a full-time member, this means that we are essentially downgrading their membership. 
   We check if their membership has expired, if it has we can proceed with the down-grade. We add £120 to their money owed
   and update the field dateMembershipExpires to be 30 days from the current date. In both, daysLeft is set to 8. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `becomePartTimeMember` (
IN inputUserID INT
)
BEGIN
	DECLARE theTypeOfUser VARCHAR(14);
    DECLARE dateMembershipExpires DATETIME;
    START TRANSACTION;
		SELECT typeOfUser FROM co_working_spaces.users WHERE users.userID = inputUserID INTO theTypeOfUser;
        SELECT membershipExpires FROM co_working_spaces.users WHERE users.userID = inputUserID INTO dateMembershipExpires;
		IF theTypeOfUser = 'dailyRatePayer' THEN
			UPDATE users
			SET typeOfUser = 'partTimeMember', moneyOwed = moneyOwed + 120, membershipExpires = DATE_ADD(NOW(), INTERVAL 30 DAY), daysLeft = 8
			WHERE users.userID = inputUserID;
		/* Logic below is essentially the downgrade scenario. From full-time to part-time. */
        ELSEIF theTypeOfUser = 'fullTimeMember' THEN
        /* We then determine if they should be allowed to downgrade, if they're in the middle of their current subscription we don't 
           allow them to downgrade. */
			IF NOW() > dateMembershipExpires THEN
				UPDATE users
				SET typeOfUser = 'partTimeMember', moneyOwed = moneyOwed + 120, membershipExpires = DATE_ADD(NOW(), INTERVAL 30 DAY), daysLeft = 8
				WHERE users.userID = inputUserID;
            ELSE
				SELECT "You're still in the middle of your subscription. Please wait until the day after your subscription for this month ends to downgrade.";
            END IF;
        END IF;
	COMMIT;
END$$
DELIMITER ;

/* TEST */
/* Tests:
   Andrew Jones should become a part-time member from daily-rate payer after I run the stored procedure
   becomePartTimeMember, providing his userID. 
   Additonally, the following changes should be made: their membershipExpires datetime
   should be set to 30 days from the current datetime, £120 should be added to their moneyOwed,
   their daysOwed should be set to 8 days. */
   
   USE co_working_spaces; -- This should be executed alongside any of the queries you want to test.
   
/* View if Andrew Jones is a daily-rate payer with all the default values to start off with. */
SELECT * FROM co_working_spaces.users WHERE userID = 3; -- Should show Andrew Jones's record, which will show he's a daily-rate payer
-- to start with.

/* Andrew Jones should now have all the values set appropriately as discussed before. */
CALL becomePartTimeMember(3); -- Stored procedure that makes the intended changes.
SELECT * FROM co_working_spaces.users WHERE userID = 3; -- Should show Andrew Jone's record, he should now be seen to be a 
-- part-time member with the appropriate values.

/* 
	Oliver Healey should become a part-time member, downgraded from a full-time member, since he has an expired
	membership this should be succesful. The details of this user will need to be updated in the same way as
	what I discussed in the above comments.
*/
/* View if Oliver Healey is a part-time member. */
SELECT * FROM co_working_spaces.users WHERE userID = 6; -- Show Oliver's record in the users table, he should start
-- as a full-time member.

/* Oliver Healey should now have all the values set appropriately as discussed before. */
CALL becomePartTimeMember(6); -- Will update Oliver to be a part-time member as his membership has expired. Will add £120 to his money
-- owed column and update membershipExpires to be 30 days from the current date.
SELECT * FROM co_working_spaces.users WHERE userID = 6; -- Should show Oliver's record allowing you to see the changes discussed.

/* 
	Carl Jones should not become a full-time member as there membership is still in-date at this time.
    Their record should remain unaffected.
*/
/* View if Carl Jones is a full-time member with a membership that isn't expired. */
SELECT * FROM co_working_spaces.users WHERE userID = 7;

CALL becomePartTimeMember(7); /* No changes should be made and a error/warning message should be returned when the procedure is called. */
SELECT * FROM co_working_spaces.users WHERE userID = 7; -- Should show Carl's record with no changes from what was seen previous as there
-- membership is still active/not expired.
/* ------ */
/* ---- */

/* Takes userID as an argument. Will find out what type of user that person is via a select query then it will, if they're
	a daily rate payer, set them to a fullTimeMember and add £250 to the amount they owe (moneyOwed). It will also update the
    field dateMembershipExpires to be 30 days from the current date. Alternatively, if the person is a partTimeMember it will
	check if their membership has expired, if it has it will update their membership status to being fullTimeMember and it will
    add £250 to their current moneyOwed. It will also again update the field dateMembershipExpires to be 30 days from the current
    date. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `becomeFullTimeMember` (
IN inputUserID INT
)
BEGIN
    DECLARE theTypeOfUser VARCHAR(14);
	DECLARE dateMembershipExpires DATETIME;
    START TRANSACTION;
        SELECT typeOfUser FROM co_working_spaces.users WHERE users.userID = inputUserID INTO theTypeOfUser;
        SELECT membershipExpires FROM co_working_spaces.users WHERE users.userID = inputUserID INTO dateMembershipExpires;
        IF theTypeOfUser = 'dailyRatePayer' THEN
            UPDATE users
            SET typeOfUser = 'fullTimeMember', moneyOwed = moneyOwed + 250, membershipExpires = DATE_ADD(NOW(), INTERVAL 30 DAY), daysLeft = 0
            WHERE users.userID = inputUserID;
        ELSEIF theTypeOfUser = 'partTimeMember' THEN
			IF NOW() > dateMembershipExpires THEN
				UPDATE co_working_spaces.users
				SET typeOfUser = 'fullTimeMember', moneyOwed = moneyOwed + 250, membershipExpires = DATE_ADD(NOW(), INTERVAL 30 DAY), daysLeft = 0
				WHERE users.userID = inputUserID;
            ELSE
				SELECT "You're still in the middle of your subscription. Please wait until the day after your subscription for this month ends to upgrade.";
            END IF;
        END IF;
    COMMIT;
END$$
DELIMITER ;

/* TEST */
/* Tests for stored procedure: 
	Usashi Chatterjee should become a full-time member and be charged £250 for their new
    membership, their membershipExpires column should also be set to 30 days from the current date
    and their daysLeft column should be set to 0. */
/* View that Usashi is actually a daily-rate payer as expected */
USE co_working_spaces; -- This should be executed alongside any of the queries you want to test.
SELECT * FROM co_working_spaces.users WHERE userID = 4;

/* Usashi should have the new details specified above. */
CALL becomeFullTimeMember(4); -- Attempts to make them a full-time member, if all goes well this happens, if not it doesn't.
SELECT * FROM co_working_spaces.users WHERE userID = 4; -- Returns Usashi's row, should now be a full-time member.

/* Jack Bradley should become a full-time member from being a part-time member. Since, their membership
	is expired. The values should be updated to the same as what was discussed above. */
/* View that Jack Bradley is actually orignally a part-time member. */
SELECT * FROM co_working_spaces.users WHERE userID = 2; -- Shows Jack Bradley's row, he should be a part-time member.

/* Jack Bradley should now have the data specified above. Should be a full-time member. */
CALL becomeFullTimeMember(2); -- Attempts to upgrade Jack Bradley to a full-time member. Should be successful as their membership has expired. Will update
-- data to what was described previous.
SELECT * FROM co_working_spaces.users WHERE userID = 2; -- Shows Jack Bradley's record and that he is now a full-time member.

/* Jack Richards shouldn't become a full-time member as they have a membership that isn't expired. Instead
   a error/warning message should be returned. */
/* View that Jack Richards is actually a part-time member originally. */
SELECT * FROM co_working_spaces.users WHERE userID = 1;

/* Jack Richards should not become a full-time member instead an error/warning message should be returned. */
CALL becomeFullTimeMember(1); -- Attempts to make Jack Richards a full-time member but will detect that his membership hasn't expired and will
-- return a warning to the user.
SELECT * FROM co_working_spaces.users WHERE userID = 1; -- Will return Jack Richards row, should still be a part-time member.

/* ------ */
/* ---- */

/* Takes userID as an argument. Will find out what type of user that person is via a select query. Given they
   are either a full-time member or a part-time member and their membership has expired it will set them to be
   a dailyRatePayer, which is essentially a user without a membership. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `cancelMembership` (
IN inputUserID INT
)
BEGIN
    DECLARE theTypeOfUser VARCHAR(14);
    DECLARE dateMembershipExpires DATETIME;
    START TRANSACTION;
        SELECT typeOfUser FROM co_working_spaces.users WHERE users.userID = inputUserID INTO theTypeOfUser;
		SELECT membershipExpires FROM co_working_spaces.users WHERE users.userID = inputUserID INTO dateMembershipExpires;
        IF theTypeOfUser = 'fullTimeMember' OR theTypeOfUser = 'partTimeMember' THEN
			IF NOW() > dateMembershipExpires THEN
				UPDATE users
				SET typeOfUser = 'dailyRatePayer', membershipExpires = NULL, daysLeft = 0
				WHERE users.userID = inputUserID;
			ELSE
				SELECT "You're still in the middle of your subscription. Please wait until the day after your subscription for this month ends to cancel.";
			END IF;
        ELSEIF theTypeOfUser = 'dailyRatePayer' THEN
			SELECT "You're a daily-rate payer and therefore have no membership to cancel.";
		END IF;
    COMMIT;
END$$
DELIMITER ;

/* TEST */
/* Tests for stored procedure: 
    /* INSERTs for needed data to test the scenarios for this stored procedure. */
    USE co_working_spaces; -- This should be executed alongside any of the queries you want to test.
    SELECT * FROM co_working_spaces.users; -- Shows all the users before the INSERT query.
	INSERT INTO users
		(name, typeOfUser, membershipExpires, daysLeft, moneyOwed)
	VALUES
        ("Kamil Kusy", "fullTimeMember", DATE_SUB(NOW(), INTERVAL 5 DAY), 0, 250),
		("James Mewett", "fullTimeMember", DATE_ADD(NOW(), INTERVAL 30 DAY), 0, 250),
        ("Charlotte Richards", "partTimeMember", DATE_SUB(NOW(), INTERVAL 8 DAY), 5, 120),
        ("Jasper Tecklenberg", "partTimeMember", DATE_ADD(NOW(), INTERVAL 30 DAY), 3, 120),
        ("Robert Knoxx", "dailyRatePayer", NULL, 0, 0);
	SELECT * FROM co_working_spaces.users; -- Should show all the users rows included the newly added ones
    -- from the INSERT query.
    /* ----------------------------------------------------------------------- */

 /* ------ */
   SELECT * FROM co_working_spaces.users WHERE userID = 9; -- Shows their user record, will have the details shown in the INSERT, at this time.
   CALL cancelMembership(9); /* As Kamils membership has expired it should set him to a dailyRatePayer and change their daysOwed to 0, their moneyOwed
   should be left the same and their membershipExpires date should be set to NULL. */
   SELECT * FROM co_working_spaces.users WHERE userID = 9; -- This query should show Kamil's row which should reflect the changes mentioned ^.
/* ------ */

/* ------- */
	SELECT * FROM co_working_spaces.users WHERE userID = 10; -- Shows their user record, will have the details shown in the INSERT, at this time.
    CALL cancelMembership(10); /* James should not be allowed to cancel their subscription, their rows should remain unedited.
    Also, a warning/error message should be displayed. */
    SELECT * FROM co_working_spaces.users WHERE userID = 10; -- This query should show James's row which should reflect the lack of change in data ^.
/* ------ */

/* ------ */
	SELECT * FROM co_working_spaces.users WHERE userID = 11; -- Shows their user record, will have the details shown in the INSERT, at this time.
    CALL cancelMembership(11); /* Charlotte should be set to a dailyRatePayer and have their daysOwed set to 0, their moneyOwed left the same
	and their membershipExpires date set to NULL */
    SELECT * FROM co_working_spaces.users WHERE userID = 11; -- This query should show Charlotte's row which should reflect the changes in data mentioned ^.
/* ----- */

/* ------ */
   	SELECT * FROM co_working_spaces.users WHERE userID = 12; -- Shows their user record, will have the details shown in the INSERT, at this time.
    CALL cancelMembership(12); /* Jasper should not be allowed to cancel their subscription, their rows should remain unedited.
    Also, a warning/error message should be displayed. */
    SELECT * FROM co_working_spaces.users WHERE userID = 12; -- This query should show Jasper's row which should highlight the lack of change in data.
/* ----- */

/* ----- */
	SELECT * FROM co_working_spaces.users WHERE userID = 13; -- Shows their user record, will have the details shown in the INSERT, at this time.
    CALL cancelMembership(13); /* Shouldn't cancel Robert's membership as they don't even have one. Will effectively do nothing apart
    from display a warning message. */
    SELECT * FROM co_working_spaces.users WHERE userID = 13; -- This query should show Robert's row which should highlight the lack of a change in data.
/* ----- */
    
/* -------- */
/* ---- */

/* Desks Reservation-Related Methods */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `reserveDesk` (
IN inputUserID INT, inputDeskID INT, reservationDateTime DATE
)
BEGIN
    DECLARE theTypeOfUser VARCHAR(14);
    DECLARE dateMembershipExpires DATETIME;
    DECLARE theDaysLeft INT;
    
    /* Error Handlers. */
    /* Catches exception that happens when you try to enter a row with the same deskID and reservationDate. */ 
	DECLARE EXIT HANDLER FOR 1062
    BEGIN
		SELECT "Can't reserve this desk for this date and time as a reservation already exists.";
        ROLLBACK;
    END;
    /* --------------- */
    /* Catches the exception that occurs when you try to enter a userID that 
       doesn't exist in the users table. */
    DECLARE EXIT HANDLER FOR 1452
    BEGIN
		SELECT "The deskID or userID you have entered does not exist.";
        ROLLBACK;
    END;
    /* -------------- */
    START TRANSACTION;
        SELECT typeOfUser FROM co_working_spaces.users WHERE users.userID = inputUserID INTO theTypeOfUser;
		SELECT membershipExpires FROM co_working_spaces.users WHERE users.userID = inputUserID INTO dateMembershipExpires;
        SELECT daysLeft FROM co_working_spaces.users WHERE users.userID = inputUserID INTO theDaysLeft;
        /* Can only book weekdays. Can only book for a time greater than the present day - don't want them to be able to book a desk in the past. */
        IF DAYNAME(reservationDateTime) != 'Saturday' AND DAYNAME(reservationDateTime) != 'Sunday' AND reservationDateTime > NOW() THEN
        /* If daily rate payer, we just insert their reservation into the deskReservations table, if there is no reservation for that desk
           that exists for the given time it will succeed else it will fail due to the composite primary key. We then update their moneyOwed, 
           adding +£20 to the amount. */
			IF theTypeOfUser = 'dailyRatePayer' THEN
				INSERT INTO deskReservations SET deskID = inputDeskID, reserverID = inputUserID, reservationDate = reservationDateTime;
				UPDATE co_working_spaces.users
				SET moneyOwed = moneyOwed + 20
				WHERE users.userID = inputUserID;
			/* If full-time member, we check if the time now is less than when their membership is meant to expire. If it is we know they have the
			   ability to book a reservation for free any weekday within their month. */
			ELSEIF theTypeOfUser = 'fullTimeMember' THEN
				IF NOW() < dateMembershipExpires THEN
					IF reservationDateTime < dateMembershipExpires THEN
						INSERT INTO deskReservations SET deskID = inputDeskID, reserverID = inputUserID, reservationDate = reservationDateTime;
					ELSE
						SELECT "Can't book this date + time. Please only book a desk within your membership period.";
					END IF;
				ELSE
					/* In the instance the user is no longer a full-time member when this method runs we need to remove their membership status.
					   We do this by calling the method previously defined called cancelMembership, passing in the users id. */
					SELECT "Your membership has expired, you'll now be set to a daily rate payer. You can either remain a daily-rate payer or you can always renew your membership.
							Please re-run this procedure when you've made your decision.";
					CALL cancelMembership(inputUserID);
				END IF;
			/* If part-time member, we check if the time now is less than when their membership is meant to expire. If it is we know they have the
			   ability to book a reservation. We then check if they have any daysLeft that they can use (a part-time member can make up to 8 reservations
               in the month of their subscription). If they do we then insert their reservation and update their user record, removing one from daysLeft. */
			ELSEIF theTypeOfUser = 'partTimeMember' THEN
				IF NOW() < dateMembershipExpires THEN
					IF reservationDateTime < dateMembershipExpires THEN
						IF theDaysLeft > 0 THEN
							INSERT INTO deskReservations SET deskID = inputDeskID, reserverID = inputUserID, reservationDate = reservationDateTime;
							UPDATE co_working_spaces.users
							SET daysLeft = daysLeft - 1
							WHERE users.userID = inputUserID;
						ELSE
							SELECT "Can't reserve desk as you don't have any spare reservations provided by your part-time membership.";
						END IF;
					ELSE
						SELECT "Can't book this date + time. Please only book a desk within your membership period.";
					END IF;
				ELSE
					/* In the instance the user is no longer a part-time member when this method runs we need to remove their membership status.
					   We do this by calling the method previously defined called cancelMembership, passing in the users id. */
					SELECT "Your membership has expired, you'll now be set to a daily rate payer. You can either remain a daily-rate payer or you can always renew your membership.
							Please re-run this procedure when you've made your decision.";
					CALL cancelMembership(inputUserID);
				END IF;
			END IF;
		ELSE
			SELECT "Can't book on a weekend, a date in the past or for the same day. Please enter a valid reservation date.";
		END IF;
  COMMIT;
END$$
DELIMITER ;

/* TESTs */ 
    /* INSERTs for needed data to test this stored procedure. */
    USE co_working_spaces; -- This should be executed alongside any of the queries you want to test.
    SELECT * FROM co_working_spaces.users; -- Should display list of users, John shouldn't be present.
	INSERT INTO users
		(name, typeOfUser, membershipExpires, daysLeft, moneyOwed)
	VALUES
        ("John", "dailyRatePayer", NULL, 0, 0);
	SELECT * FROM co_working_spaces.users; -- Should display list of users, John should now be present.
    /* ----------------------------------------------------------------------- */
	SELECT * FROM co_working_spaces.users WHERE userID = 14; -- Should show John with moneyOwed of £0.
    SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 3 AND reserverID = 14; -- Should return no rows.
    CALL reserveDesk(14, 3,  DATE_ADD(NOW(), INTERVAL 3 DAY)); -- Should successfully create a reservation in
    -- the table deskReservations for userID 14/John for desk/deskID 3 for a date 3 days past
    -- the present date. IMPORTANT, if the date 3 days from the current date is a week-end could you please manually enter a date in the
    -- future that isn't a weekend, this can be done in the format "YYYY-MM-DD". It's impossible for me to know when this will be marked
    -- so this is the only real alternative I can think of. (*).
	SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 3 AND reserverID = 14; -- Should now show the created reservation.
    SELECT * FROM co_working_spaces.users WHERE userID = 14; -- Should now show that John owes £20.
    
    --------------
    
    SELECT * FROM co_working_spaces.users WHERE userID = 14; -- Should show John with moneyOwed of £20.
	SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 4 AND reserverID = 14; -- Should return 0 rows.
    CALL reserveDesk(14, 4, NOW()); -- Should attempt to create a reservation for userID 14/John for deskID/desk 4 for the current date.
    -- This attempt should fail and return a error message to the user.
	SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 4 AND reserverID = 14; -- Shouldn't show a reservation as you can't reserve a desk
	-- for the present day.
	SELECT * FROM co_working_spaces.users WHERE userID = 14; -- Should show the unchanged moneyOwed amount of £20.
    
    -------------
    
	SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 3 AND reserverID = 14; -- Should show one row, the reservation created earlier.
    CALL reserveDesk(14, 3, DATE_ADD(NOW(), INTERVAL 3 DAY)); -- Should attempt to create a reservation for userID 14/John for deskID/desk 4
    -- for the same date as the one used in the first call marked with a (*)/3 days past the current date. This attempt should fail
    -- as it'll trigger a foreign key constraint error, this exception should be handled by the method and return a error/warning message
    -- to the user.
	SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 3 AND reserverID = 14; -- Should only show the originally created reservation.
    SELECT * FROM co_working_spaces.users WHERE userID = 14; -- Should show the unchanged moneyOwed amount of £20.
/* ---- */

/* Cancel desk reservation method */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `cancelReservation` (
IN inputUserID INT, inputDeskID INT, reservationDate DATE
)
BEGIN
    DECLARE theTypeOfUser VARCHAR(14);
    DECLARE numberOfReservations INT;
    START TRANSACTION;
    SELECT typeOfUser FROM co_working_spaces.users WHERE users.userID = inputUserID INTO theTypeOfUser;
    /* We get a count of the amount of rows that match the reservation information entered. */
    SELECT COUNT(*) FROM co_working_spaces.deskReservations WHERE deskReservations.reserverID = inputUserID AND
	deskReservations.deskID = inputDeskID AND deskReservations.reservationDate = reservationDate INTO numberOfReservations;
    /* Check if there were any rows that matched the details entered. Also, check to make sure that the person is 
       trying to cancel a reservation scheduled to take place in the future. Since, if they were able to 'cancel' old 
       reservations it would allow them to make a reservations, attend it, and then the day later get a refund. */
	  IF numberOfReservations > 0 && reservationDate > NOW() THEN
		/* Delete the specified row/reservation from the database.
		   This will in turn trigger a trigger (AFTER DELETE) in the deskReservations
		   table, this trigger will refund the user for the cancelled reservations in a way
           that's appropriate for their membership type. If anything in the trigger were to
           fail with an exception, this would cause the transaction seen in this procedure to
           rollback, reversing the DELETE query seen below. */
			DELETE FROM co_working_spaces.deskReservations WHERE deskReservations.reserverID = inputUserID AND
			deskReservations.deskID = inputDeskID AND deskReservations.reservationDate = reservationDate;
            
	/* Reservation based on information entered doesn't exist. */
	  ELSE
			SELECT "Couldn't find the reservation entered in the database. Please enter a valid existing reservation for a date past the present date.";
	  END IF;
    COMMIT;
END$$
DELIMITER ;
/* ------------- */

/* TESTs */ 
    /* CALLs needed to test this stored procedure. */
    USE co_working_spaces; -- This should be executed alongside any of the queries you want to test.
	SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 8 AND reserverID = 1; -- Shouldn't show a reservation
    -- since it hasn't been made yet.
    SELECT * FROM co_working_spaces.users WHERE userID = 1; -- Should show Jack has 8 days left/reservation owed at this moment.
    CALL reserveDesk(1, 8, DATE_ADD(NOW(), INTERVAL 3 DAY)); -- Should successfully create a reservation in
    -- the table deskReservations for userID 1/Jack Richards for desk/deskID 8 for a date 5 days past
    -- the present date. If the date 5 days from the present date is a week-end please adjust the date to
    -- a valid date in the future as discussed in the other TEST section, the test for reserveDesk.
	SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 8 AND reserverID = 1; -- Should show the newly
    -- created reservation.
	SELECT * FROM co_working_spaces.users WHERE userID = 1; -- Should show Jack now has 7 days left as they just used a reservation
    -- successfully.
    /* ------------------------------------------- */
    
    SELECT * FROM co_working_spaces.users WHERE userID = 1; -- Shows Jack's/userID 1's row, should have 7 daysLeft.
    SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 8 AND reserverID = 1; -- Should return 1 row/reservation.
    CALL cancelReservation(1, 8, DATE_ADD(NOW(), INTERVAL 3 DAY)); -- Should successfully cancel the reservation by userID 1 for desk 8
    -- for the date showed in the reserveDesk query just above this one. Jack/userID 1 should be reimbursed 1 days owed, totalling 8 daysLeft/owed.
    SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 8 AND reserverID = 1; -- Should now return 0 rows/reservations as it's been cancelled.
	SELECT * FROM co_working_spaces.users WHERE userID = 1; -- Shows Jack's/userID 1's row, should now have 8 daysLeft as they've been reimbursed for cancelling
    -- their reservation.
    
    -- Can't delete a non-existing or old reservation.
    SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 8 AND reserverID = 1 AND reservationDate = DATE_SUB(NOW(), INTERVAL 2 DAY); -- Should return 0 rows.
    CALL cancelReservation(1, 8, DATE_SUB(NOW(), INTERVAL 2 DAY)); -- Should not cancel a reservation as firstly it doesn't exist, but secondly
    -- it's also in the past, so even if it did exist it still wouldn't allow for it to be cancelled.
    SELECT * FROM co_working_spaces.deskReservations WHERE deskID = 8 AND reserverID = 1 AND reservationDate = DATE_SUB(NOW(), INTERVAL 2 DAY); -- Should return 0 rows.
    SELECT * FROM co_working_spaces.users WHERE userID = 1; -- Jack should still only have 8 daysLeft/reservations owed as no reservation was cancelled.
    
/* ----- */

/* Add/Remove Desk from Location */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `addDesk` (
IN locationID INT
)
BEGIN
    /* Error Handler. */
    /* Catches the exception that occurs when you try to enter a location (column) that 
       doesn't exist in the locations table. */
    DECLARE EXIT HANDLER FOR 1452
    BEGIN
		SELECT "The location ID you have entered does not exist.";
        ROLLBACK;
    END;
    /* -------------- */
    START TRANSACTION;
		/* Adds a desk, a row specified by the inputted value into the desks table. */
		INSERT INTO co_working_spaces.desks SET location = locationID;
    COMMIT;
END$$
DELIMITER ;

/* TESTs */
SELECT COUNT(*) FROM co_working_spaces.desks WHERE location = 2; -- Should return a count of 30. Counts the amount of desks in the table
-- with a location id of 2.
CALL addDesk(2); -- Should INSERT a desk into the table desks with a location id of 2. The deskID is the next autoincremement.
SELECT COUNT(*) FROM co_working_spaces.desks WHERE location = 2; -- Should show a count of 31.
SELECT * FROM co_working_spaces.desks WHERE deskID = 76; -- Should show the newly added desk at location 2.

SELECT COUNT(*) FROM co_working_spaces.desks; -- Should return a count of 76. Counts the amount of desks in the table.
CALL addDesk(5); -- Should fail with the error code 1452, foreign key constraint error. This exception should be handled and return
-- an error message. This error will occur because the locationID provided does not exist in the locations table.
SELECT COUNT(*) FROM co_working_spaces.desks; -- Should return a count of 76. Counts the amount of desks in the table. Shouldn't
-- increase by 1 as the desk shouldn't have been added.
/* ----- */

DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `removeDesk` (
IN inputDeskID INT
)
BEGIN
    DECLARE deskCount INT;
    START TRANSACTION;
		/* Gets the number of rows in desks that have the same deskID and stores them in deskCount. */
		SELECT COUNT(*) FROM co_working_spaces.desks WHERE deskID = inputDeskID INTO deskCount;
        /* Checks if one row/desk was returned. */
        IF deskCount = 1 THEN
        /* The order is crucial here since if the desk is deleted from desks first, it will cause an error
           (foreign key constraint), so by deleting the child row before deleting the parent row we avoid this
           issue entirely. */
		/* When this is called, a trigger is activated, AFTER DELETE. */
            DELETE FROM co_working_spaces.deskReservations WHERE deskID = inputDeskID;
		/* This will just delete any rows in privateDesks where the deskID is the same as the desk we're deleting.
		   For now just doing this is fine as I haven't developed any logic for a user claiming a private desk.
           In the future I'll probably use a trigger like I have for the delete above. */
			DELETE FROM co_working_spaces.privateDesks WHERE privateDeskID = inputDeskID;
		/* Delete row specified using inputted value from desks table. */
			DELETE FROM co_working_spaces.desks WHERE deskID = inputDeskID;
		ELSE
			SELECT deskCount;
			SELECT "No desks, or more than one were retrieved based on the information entered. Couldn't delete the desk.";
		END IF;
    COMMIT;
END$$
DELIMITER ;

/* TESTs */
SELECT * FROM co_working_spaces.desks WHERE deskID = 3; -- Should return the row of desk 3.
SELECT COUNT(*) FROM co_working_spaces.desks; -- Should show a count of 76.
SELECT moneyOwed FROM co_working_spaces.users WHERE userID = 14; -- Shows the amount of money John owes, should be £20 as they have one
-- existing reservation as a dailyRatePayer.
CALL removeDesk(3); -- Should delete desk 3, which in turn should delete Johns/userID 14s desk reservation for the table this in
-- turn will activate a trigger which'll reimburse him by removing £20 from his moneyOwed column (in this case as he's a dailyRatePayer).
SELECT COUNT(*) FROM co_working_spaces.desks; -- Counts the amount of desks in the table. Should return a count of 75 since one desk has 
-- been removed.
SELECT moneyOwed FROM co_working_spaces.users WHERE userID = 14; -- Shows the amount of money John owes, should now be £0 as their one 
-- existing reservation was cancelled as an effect of the desk deletion.
/* ----- */

SELECT * FROM co_working_spaces.desks WHERE deskID = 2000; -- Shouldn't return a row as it doesn't exist.
SELECT COUNT(*) FROM co_working_spaces.desks; -- Should show a count of 75.
CALL removeDesk(2000); -- Attempts to remove desk 2000, but since it doesn't exist, instead a warning message
-- is returned.
SELECT COUNT(*) FROM co_working_spaces.desks; -- Should still show a count of 75.

/* ---- */

/* ----------------------------- */

/* Location Management */
/* Takes the locationID as the parameter and will fetch the name of the location if it exists. This
   is useful because it allows the location manager to double-check that they know the ID is related
   to a particular location. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `getNameOfLocationFromID` (
IN inputtedLocationID INT
)
BEGIN
	SELECT name AS locationName FROM co_working_spaces.locations WHERE locationID = inputtedLocationID;
END$$
DELIMITER ;

/* TESTs */
SELECT * FROM co_working_spaces.locations WHERE locationID = 2; -- Should return location with the ID of 2.
CALL getNameOfLocationFromID(2); -- Should output North Cardiff under a column with the alias locationName.

SELECT * FROM co_working_spaces.locations WHERE locationID = 2000; -- Shouldn't return a row since a location
-- doesn't exist with that ID.
CALL getNameOfLocationFromID(2000); -- Should return no rows as the location doesn't exist.
/* ----- */

/* Takes the name and address for the new location as parameters. Will use this to insert a new row/location with
	these column values given it doesn't already exist. If it does exist, the error will be handled and a error
    message will be outputted via a SELECT. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `addALocation` (
IN inputtedName VARCHAR(45), inputtedAddress VARCHAR(45)
)
BEGIN
    /* Error Handler. */
    /* Catches exception that happens when you try to INSERT a row into the table locations with a column
	   value that's already in the table. */ 
	DECLARE EXIT HANDLER FOR 1062
    BEGIN
		SELECT "Can't add the location as it already exists.";
        ROLLBACK;
    END;
    /* --------------- */
    START TRANSACTION;
		INSERT INTO co_working_spaces.locations SET name = inputtedName, address = inputtedAddress;
    COMMIT;
END$$
DELIMITER ;

/* TESTs */
SELECT * FROM co_working_spaces.locations; -- Should return 2 location rows.
CALL addALocation("Llangollen", "552 Llangollen Avenue"); -- Should INSERT a location with these details
-- into the table locations. ID will be generated automatically, next increment.
SELECT * FROM co_working_spaces.locations WHERE locationID = 3; -- Should show the Llangollen location with
-- the details specified in the INSERT.

SELECT * FROM co_working_spaces.locations; -- Should return 3 location rows.
CALL addALocation("Llangollen", "552 Llangollen Avenue"); -- Should fail to INSERT the location as it already exists.
-- Should instead return a warning message to the user.
SELECT * FROM co_working_spaces.locations WHERE name = "Llangollen"; -- Should show one row for Llangollen.

/* ----- */

/* Takes the location ID as a parameter and will remove the location in question, all rows that relied or had a relationship
   with the removed location will also be deleted. */    
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `removeALocation` (
IN inputtedLocationID INT
)
BEGIN
   DECLARE desksLeft INT; /* Holds the amount of desks that're left to delete. Used to determine when the loop should end. */
   DECLARE deskIDToDelete INT; /* Stores the deskID for the currently iterated onto row. */
   DECLARE resultsCursor CURSOR FOR -- Creates a cursor that will hold and then allow us to iterate over the results
     SELECT deskID -- returned by this select query.
     FROM co_working_spaces.desks
     WHERE location = inputtedLocationID;
   
    START TRANSACTION;
	   SELECT COUNT(*) FROM co_working_spaces.desks WHERE location = inputtedLocationID INTO desksLeft;
       IF desksLeft > 0 THEN -- If there're desks related to the location to remove.
		   OPEN resultsCursor; -- We open the cursor.
				removeDesksLoop: LOOP
				FETCH resultsCursor INTO deskIDToDelete; -- Fetches the next row to look at in the cursor.
				CALL removeDesk(deskIDToDelete); -- This method will delete the desk along with any child rows, refunding the
				-- user where applicable.
				SET desksLeft = desksLeft - 1;
				IF desksLeft = 0 THEN
					CLOSE resultsCursor;
					LEAVE removeDesksLoop;
				END IF;
			END LOOP removeDesksLoop;
            
			DELETE FROM co_working_spaces.locations WHERE locationID = inputtedLocationID; /* We can now safely delete the parent row/location.
			   Rows in other tables like privateDesks and privateMeetingRooms that have a foreign key relation to the location will for now
			   just be deleted via the ON DELETE CASCADE rule. */ 
		ELSE
		   DELETE FROM co_working_spaces.locations WHERE locationID = inputtedLocationID; /* We can now safely delete the parent row/location.
		   Rows in other tables like privateDesks and privateMeetingRooms that have a foreign key relation to the location will for now
           just be deleted via the ON DELETE CASCADE rule. */ 
		END IF;
    COMMIT;
END$$
DELIMITER ;

/* TESTs */

SELECT * FROM co_working_spaces.locations WHERE locationID = 3; -- Should return the Llangollen location.
CALL removeALocation(3); -- Should delete the location from the locations table.
SELECT * FROM co_working_spaces.locations WHERE locationID = 3; -- Should now return 0 rows as the Llangollen
-- location has been deleted.

SELECT * FROM co_working_spaces.locations; -- Should return all locations in the database, there should only be 2 at this time.
SELECT * FROM co_working_spaces.deskReservations WHERE reserverID = 2 AND deskID = 74 AND reservationDate = DATE_ADD(NOW(), INTERVAL 3 DAY); -- Should return no reservation, not made yet.
CALL reserveDesk(2, 74, DATE_ADD(NOW(), INTERVAL 3 DAY)); -- Should create a valid reservation for Jack Bradley/userID 2 for deskID 74
-- 3 days after the present date. If 3 days after the present date is a week-end, please adjust the date to a future date manually as
-- specified and for the reasons discussed in my previous tests.
-- Should show the newly created reservation for userID 2 for a desk that's in location 2.
SELECT * FROM co_working_spaces.deskReservations WHERE reserverID = 2 AND deskID = 74 AND reservationDate = DATE_ADD(NOW(), INTERVAL 3 DAY);

SELECT * FROM co_working_spaces.privateDesks WHERE privateDeskID = 72 AND userID = 2; -- Should return 0 rows at this time.
INSERT INTO co_working_spaces.privateDesks -- Inserting sample data to demonstrate ON DELETE CASCADE rule for foreign key.
	(privateDeskID, userID)
VALUES
	(72, 2); -- Private desk will be deskID 72 and will belong to Jack Bradley, userID 2.
SELECT * FROM co_working_spaces.privateDesks WHERE privateDeskID = 72 AND userID = 2; -- Should return 1 row which has the
-- details of what we just INSERTED above.

SELECT * FROM co_working_spaces.privateMeetingRoomReservations; -- Should show 0 rows.
INSERT INTO co_working_spaces.privateMeetingRoomReservations -- Should INSERT 1 row/private meeting room reservation for meeting room 3 which
-- is in location 2.
	(privateMeetingRoomID, reserverID, reservationDate)
VALUES
	(3, 2, DATE_ADD(NOW(), INTERVAL 3 DAY)); -- Reservation should be made for date 3 days after the present date.
    
SELECT * FROM co_working_spaces.privateMeetingRoomReservations WHERE privateMeetingRoomID = 3 AND reserverID = 2; -- Should display the newly inserted private room
-- reservation for Jack Bradley.

SELECT * FROM co_working_spaces.privateMeetingRooms; -- Should show 4 private meeting rooms.
-- We know that a reservation exists for a desk (74) in this location. What should happen when we run removeALocation() 
-- is all the desks should be deleted that're related to location 2 via multiple calls to the removeDesk method, this in
-- turn will cause a trigger to activate reimbursing any users who had reservations for the deleted desk, in this case that
-- would be Jack Bradley, but since he's a full-time memmber there's nothing to really reimburse him with so we don't. Additionally,
-- the ON CASCADE DELETE foreign key action will trigger when a desk in the privateDesks table has it's parent
-- row deleted (in the desks table). Which in this case means that the private desk with the privateDeskID of 72 gets deleted
-- from running this procedure. 
-- Once this process has completed all the desks related to location 2 should be gone and all the users should be 
-- reimbursed (if applicable) then the location itself is finally deleted which will then trigger any ON CASCADE DELETEs for other child tables
-- like privateMeetingRooms to also trigger.

SELECT COUNT(*) FROM co_working_spaces.desks WHERE location = 2; -- Should return a count of 31, 31 desks (we added one extra to the 30 in an earlier test).
CALL removeALocation(2); -- ^
SELECT COUNT(*) FROM co_working_spaces.desks WHERE location = 2; -- Should return a count of 0, 0 desks as they've now all been deleted.
SELECT * FROM co_working_spaces.privateMeetingRooms; -- Should show 2 private meeting rooms. Private meeting room 2 and 3 should be gone now due to the ON CASCADE DELETE rule for
-- the foreign key.
SELECT * FROM co_working_spaces.privateMeetingRoomReservations; -- The reservation made by Jack Bradley, userID 2 should now be deleted.

-- Now if a location that doesn't exist is attempted to be deleted.
SELECT * FROM co_working_spaces.locations WHERE locationID = 252; -- Should return 0 rows.
CALL removeALocation(252); -- Should affect 0 or 1 rows but does nothing essentially.
SELECT * FROM co_working_spaces.locations WHERE locationID = 252; -- Should return 0 rows.

/* ----- */
/* ------------------- */

/* Analytics for desks. */
/* Displays the most reserved desk overall. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `getMostReservedDesk` ()
BEGIN
	DECLARE mostReservedDeskID INT;
    DECLARE deskLocationID INT;
    DECLARE locationName VARCHAR(45);
    DECLARE locationAddress VARCHAR(45);
    
	SELECT deskID FROM co_working_spaces.deskReservations
	WHERE reservationDate < NOW()
	GROUP BY deskID ORDER BY COUNT(*) DESC
    LIMIT 1 INTO mostReservedDeskID;
    
    SELECT location FROM co_working_spaces.desks WHERE deskID = mostReservedDeskID INTO deskLocationID;
    SELECT name FROM co_working_spaces.locations WHERE locationID = deskLocationID INTO locationName;
    SELECT address FROM co_working_spaces.locations WHERE locationID = deskLocationID INTO locationAddress;
    
    SELECT mostReservedDeskID, deskLocationID, locationName, locationAddress;
END$$
DELIMITER ;

/* TESTs */
-- Re-adding North-Cardiff Location alongside adding 30 desks related to the location in the desks table.
SELECT * FROM co_working_spaces.locations WHERE name = "North Cardiff"; -- Should return no rows as the location does not exist
-- in the table currently (we deleted it in a previous test).
/* Inserts the North Cardiff location. */
INSERT INTO locations
(name, address)
VALUES
("North Cardiff", "88 North Cardiff Street, CF19 1CF");

SELECT * FROM co_working_spaces.locations WHERE name = "North Cardiff"; -- Should return the North Cardiff location row as it's
-- just been INSERTED.

SELECT COUNT(*) FROM co_working_spaces.desks WHERE location = 5; -- Should equal 0 as we haven't added the desks yet.
/* Inserts 30 desks for the North Cardiff Location. */
INSERT INTO desks
(location)
VALUES
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5),
(5);

SELECT COUNT(*) FROM co_working_spaces.desks WHERE location = 5; -- Should equal 30 as we've just INSERTED the desks relating to this location.

SELECT * FROM co_working_spaces.deskReservations WHERE reservationDate < NOW(); -- Should return a list of all the old reservations. Shouldn't return any
-- rows/results.

-- Will INSERT 7 old reservations that the analytic-related queries will all look at, since the analytical stored procedures all build
-- results based off previous reservations/old data as it's certain, (e.g., reservations that have already passed can't be cancelled).
INSERT INTO co_working_spaces.deskReservations
(deskID, reserverID, reservationDate)
VALUES
(78, 4, DATE_SUB(NOW(), INTERVAL 20 DAY)),
(78, 4, DATE_SUB(NOW(), INTERVAL 19 DAY)),
(78, 5, DATE_SUB(NOW(), INTERVAL 18 DAY)),
(79, 4, DATE_SUB(NOW(), INTERVAL 22 DAY)),
(5, 7, DATE_SUB(NOW(), INTERVAL 17 DAY)),
(5, 2, DATE_SUB(NOW(), INTERVAL 12 DAY)),
(4, 3, DATE_SUB(NOW(), INTERVAL 16 DAY));

SELECT * FROM co_working_spaces.deskReservations WHERE reservationDate < NOW(); -- Should return 7 rows/old reservations, the rows we INSERTED just now.

-- Now everything is ready for the test queries as we now have the sample data etc.

CALL getMostReservedDesk(); -- Should return deskID 78 as it's the most previously reserved. Alongside this the locationID of where it is should be shown and
-- the name of the location it's at alongside the locations address.

/* ----- */

/* Displays the most reserved desks in descending order. Enter True as a parameter for the results to be displayed in
   descending order or False to have them returned in ascending order. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `getMostReservedDesks` (
descendingOrder BOOLEAN
)
BEGIN
	/* The deskID, locationID that desk is in, name of the desks location, address of the desks location, the number of reservations
	   that had been made for that desk prior to todays date. Displayed in descending order. */
	/* Descending order in terms of reservation quantity for a desk. */
	IF descendingOrder THEN
		SELECT deskReservations.deskID, locations.locationID, locations.name AS locationName, locations.address AS locationAddress, COUNT(*) AS amountOfPreviousReservations
		FROM locations
		INNER JOIN desks ON locations.locationID=desks.location
		INNER JOIN deskReservations ON desks.deskID = deskReservations.deskID
		WHERE deskReservations.reservationDate < NOW()
		GROUP BY deskID
        ORDER BY amountOfPreviousReservations DESC;
    ELSE
    /* Ascending order in terms of reservation quantity for a desk. */
		SELECT deskReservations.deskID, locations.locationID, locations.name AS locationName, locations.address AS locationAddress, COUNT(*) AS amountOfPreviousReservations
		FROM locations
		INNER JOIN desks ON locations.locationID=desks.location
		INNER JOIN deskReservations ON desks.deskID = deskReservations.deskID
		WHERE deskReservations.reservationDate < NOW()
		GROUP BY deskID
        ORDER BY amountOfPreviousReservations ASC;
	END IF;
END$$
DELIMITER ;

/* TESTs */
CALL getMostReservedDesks(True); -- Should return a list of desks with at least one previous reservation (older than the current date)
-- in descending order of how much they've been previously booked. deskID 78 should be at the top of this descending list and deskID 79
-- or 4 (4 and 79 share the same amount of reservations) should be at the bottom in this case.

CALL getMostReservedDesks(False); -- Should return a list of desks with at least one previous reservation (older than the current date)
-- in ascending order of how much they've been previously booked. deskID 78 should be at the bottom of the list and deskID 79 or 4 should be
-- at the top in this case (they both share the same amount of reservations).
/* ----- */

/* Displays the most reserved desk for the provided location/locationID. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `getMostReservedDeskInALocation` (
IN locationID INT
)
BEGIN
	/* The deskID, locationID that desk is in, name of the desks location, address of the desks location, the number of reservations
	   that had been made for that desk prior to todays date. */
	SELECT deskReservations.deskID, locations.locationID, locations.name AS locationName, locations.address AS locationAddress, COUNT(*) AS amountOfPreviousReservations
	FROM locations
	INNER JOIN desks ON locations.locationID=desks.location
	INNER JOIN deskReservations ON desks.deskID = deskReservations.deskID
	WHERE deskReservations.reservationDate < NOW() AND desks.location = locationID
	GROUP BY deskID
    ORDER BY amountOfPreviousReservations DESC
    LIMIT 1;
END$$
DELIMITER ;

/* TESTs */
CALL getMostReservedDeskInALocation(5); -- Should return all the information regarding the desk with an ID of 78 as it's the most reserved desk in location 5 (locationID 5).
-- the amount of reservations made for the desk should also be shown (3).
CALL getMostReservedDeskInALocation(1); -- Should return all the information regarding the desk with an ID of 5 as it's the most reserved desk in location 1 (locationID 1).
-- the amount of reservations made for the desk should also be shown (2).
CALL getMostReservedDeskInALocation(200); -- Should return nothing as there is no location with an ID of 200.
/* ----- */

/* Displays the most reserved desks for the provided location/locationID. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `getMostReservedDesksInALocation` (
IN locationID INT, descendingOrder BOOLEAN
)
BEGIN
	/* The deskID, locationID that desk is in, name of the desks location, address of the desks location, the number of reservations
	   that had been made for that desk prior to todays date. Displayed in descending order. */
	/* Descending order in terms of reservation quantity for a desk. */
	IF descendingOrder THEN
		SELECT deskReservations.deskID, locations.locationID, locations.name AS locationName, locations.address AS locationAddress, COUNT(*) AS amountOfPreviousReservations
		FROM locations
		INNER JOIN desks ON locations.locationID=desks.location
		INNER JOIN deskReservations ON desks.deskID = deskReservations.deskID
		WHERE deskReservations.reservationDate < NOW() AND desks.location = locationID
		GROUP BY deskID
        ORDER BY amountOfPreviousReservations DESC;
	ELSE
	/* Ascending order in terms of reservation quantity for a desk. */
		SELECT deskReservations.deskID, locations.locationID, locations.name AS locationName, locations.address AS locationAddress, COUNT(*) AS amountOfPreviousReservations
		FROM locations
		INNER JOIN desks ON locations.locationID=desks.location
		INNER JOIN deskReservations ON desks.deskID = deskReservations.deskID
		WHERE deskReservations.reservationDate < NOW() AND desks.location = locationID
		GROUP BY deskID
        ORDER BY amountOfPreviousReservations ASC;
	END IF;
END$$
DELIMITER ;

/* TESTs */
CALL getMostReservedDesksInALocation(5, True); -- Should return the most reserved desks in location 5, in descending order.  All the details regarding
-- these desks should also be shown, e.g., locationName of where the desk is, locationID etc. Desk 78 should be at the top and 79 at the bottom
-- in this case.

CALL getMostReservedDesksInALocation(5, False); -- Should return the most reserved desks in location 5, in ascending order.  All the details regarding
-- these desks should also be shown, e.g., locationName of where the desk is, locationID etc. Desk 79 should be at the top and 78 at the
-- bottom in this case.
/* ----- */
/* --------- */

/* Analytics re members. */
/* When run will return a total of 3 rows, in either descending or ascending order depending on
   the value provided to the procedure. The rows will be dailyRatePayer, fullTimeMember and partTimeMember
   there will be a count next to each showing the amount of users who have said membership type as a total count. */
DELIMITER $$
USE `co_working_spaces`$$
CREATE PROCEDURE `getAmountOfEachTypeOfUser` (
IN descendingOrder BOOLEAN
)
BEGIN
	IF descendingOrder THEN
		SELECT typeOfUser, COUNT(typeOfUser) as amountOfUserType
		FROM co_working_spaces.users
		GROUP BY typeOfUser ORDER BY COUNT(*) DESC;
	ELSE
		SELECT typeOfUser, COUNT(typeOfUser) as amountOfUserType
		FROM co_working_spaces.users
		GROUP BY typeOfUser ORDER BY COUNT(*) ASC;
	END IF;
END$$
DELIMITER ;

/* TESTs */
CALL getAmountOfEachTypeOfUser(True); -- Should return a table with a column called typeOfUser there should be 3 rows
-- one for fullTimeMember, dailyRatePayer and partTimeMember each will have a count of the total amount of users of that
-- type in a column called amountOfUserType. It will be displayed in descending order in this case. At the top of the list
-- should be fullTimeMember with 5 total users with that type and partTimeMember at the bottom with 4.

CALL getAmountOfEachTypeOfUser(False); -- Should return a table with a column called typeOfUser there should be 3 rows
-- one for fullTimeMember, dailyRatePayer and partTimeMember each will have a count of the total amount of users of that
-- type in a column called amountOfUserType. It will be displayed in ascending order in this case. At the top of the list
-- should be partTimeMember with 4 total users with that type and dailyRatePayer (or fullTimeMember) at the bottom with 5.
/* ----- */

/* -------------------- */

/* View(s) */
CREATE VIEW viewUsers AS -- Will create a view called viewUsers.
  SELECT userID, typeOfUser, membershipExpires -- This view will only show non-private information about each user such
  FROM users; -- as their userID, their more private details like how much they owe is left out in this view.
  
/* TESTs */
SELECT * FROM co_working_spaces.viewUsers; -- Should show a view "table" that contains all users in the database but
-- only with the userID, typeOfUser and membershipExpires columns.
/* ----- */
/* ----- */
