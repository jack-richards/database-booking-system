## Non-functional Requirements in Descending Order of Importance For Project.

## Data-integrity
The database application will need to have data-integrity. The data will need
to be accurate at any given moment as to ensure that all processes are using the
most up-to-date, valid data. Otherwise, there comes the risk of logical errors
occuring. Invalid data should not be allowed in tables, for instance, in the users table there shouldn't be a letter/string in the moneyOwed field, it should instead be a FLOAT. The use of database constraints can be useful in achieving this.

## Scenarios
- [ ] Given the desk is avaliable to reserve, when Jack initaties reserving that desk and  during this process John attempts to reserve the same desk. Then it should wait until Jacks reservation attempt either succeeds or fails until handling Johns request to create his reservation as the result of Jacks request could alter the data used to determine whether Johns reservation creation request should be successful or not.
- [ ] Given the data-type FLOAT is defined for the moneyOwed column in the users table, when a row is attempted to be inserted into users with moneyOwed as "a", then the INSERT should fail as it isn't a FLOAT.
- [ ] Given the desks table has a foreign key relating it's column 'location' to the column 'locationID' in the locations table. When a desk is attempted to be INSERTED into the desks table with a non-existing location (ID) then the INSERT will fail via a foreign key constraint error since the locationID doesn't exist in the locations table.

## Acceptance Crtieria
- [ ] Data is kept logically consistent throughout the application. E.g., if a desk is deleted then all reservations for said desk should be deleted and the people who had reservations for the desk should be reimbursed.
- [ ] Data-types should be kept consist and valid in the application, e.g., moneyOwed will always be a FLOAT can't have strings inserted.

## Reliability
The database application will need to be reliable; it should return an expected result from a given input, from known conditions as much as possible. For instance, if I elect to remove a desk from a location, the desk should be removed alongside all the reservations for said desk. The customers who had reservations for this desk should also be refunded if applicable. An additional example, is if a user decides to cancel a reservation for a desk then, given they've provided valid values, the reservation should be deleted and they should be reimbursed, this should happen every time.

## Scenarios
- [ ] Given a desk exists with two reservations for it. When a site manager provides valid details for the desk in question to delete then the two reservations made for this desk should be deleted and the people who made these reservations should be reimbursed (where applicable) and then the desk itself should be deleted.
- [ ] Given a daily-rate payer has a valid, existing reservation for a date in the future. When they go to cancel this reservation, under normal, expected conditions then this reservation should be cancelled and they should be reimbursed +£20.
- [ ] Given a part-time member has a valid, existing reservation. When the part-time member goes to cancel the reservation and it is the day of the reservation then under this known condition they shouldn't be able to cancel it.

## Acceptance Crtieria
- [ ] The database application under normal expected conditions always returns the same expected results.
