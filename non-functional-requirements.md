## Non-functional Requirements in Descending Order of Importance For Project.

## Data-integrity
The database application will need to have data-integrity. The data will need
to be accurate at any given moment as to ensure that all processes are using the
most up-to-date, valid data. Otherwise, there comes the risk of logical errors
occuring. Invalid data should not be allowed in tables, for instance, in the users table there shouldn't be a letter/string in the moneyOwed field, it should instead be a FLOAT. The use of database constraints can be useful in achieving this.

## Acceptance Crtieria
- [ ] Data is kept logically consistent throughout the application. E.g., if a desk is deleted then all reservations for said desk should be deleted and the people who had reservations for the desk should be reimbursed.
- [ ] Data-types should be kept consist and valid in the application, e.g., moneyOwed will always be a FLOAT can't have strings inserted.

## Reliability
The database application will need to be reliable; it should return an expected result from a given input, from known conditions as much as possible. For instance, if I elect to remove a desk from a location, the desk should be removed alongside all the reservations for said desk. The customers who had reservations for this desk should also be refunded if applicable. An additional example, is if a user decides to cancel a reservation for a desk then, given they've provided valid values, the reservation should be deleted and they should be reimbursed, this should happen every time.

## Acceptance Crtieria
- [ ] The database application under normal expected conditions always returns the same expected results.

## Robustness
The system should be reasonably robust. Take for example, if a user wants to reserve a desk but they try to book a desk that doesn't exist, the system should be able to account for this invalid, unexpected input and recover from any errors it may pose. Possibly via error handling.

## Acceptance Criteria
- [ ] Any unexpected actions that cause errors should be handled, ensuring the application doesn't crash or break.

## Usability
The database application should be easily usable for users, there should be a easily understandable method for each piece of functionality. The applications more complicated inner workings should be abstracted. The co-working spaces would lose business if users found the reservation system too difficult to use.

## Acceptance Crtieria
- [ ] Database application has highly usable methods that abstract any inner-workings, e.g, the user should only need to provide their userID, the desk ID for the desk they want to reserve and the date to reserve it for into a method to reserve the desk, the application should handle all the logic to make this happen.

## Analytics
The system should have the ability to provide analytics on what actions users are taking. This would prove useful to certain stakeholders of the system. For instance, if a location manager has data/analytics of a location underperforming in terms of desk usage, they could elect to remove it from the system based on this data. It essentially allows for more data-driven decision making and the ability to get feedback on changes that have been made.

## Acceptance Criteria
- [ ] Ability to generate/fetch aggregrated data for analytical purposes.

## Performance
The database application will need to perform somewhat well. Actions performed in the application will need to be able to execute and complete in a sane amount of time.

## Acceptance Crtieria
- [ ] Actions should complete in 5 seconds or under.

## Accessibility
The database application should be as accessible as possible. It is challenging in this scenario to make the application very accessible since interacting with it is done purely via SQL. However, I have believe if I make the SQL use stored procedures with highly readable names it should make the application more accessible.

## Acceptance Crtieria
- [ ] Stored procedures names are highly readable.

## Security
The database application should be secure. This application will contain individuals names and what they owe, it may prove useful to privacy reasons too to have the system on a secure server.

## Acceptance Criteria
- [ ] Have the ability to run the system from a secure server.

## Operability
Having the ability to actively observe the behaviour of the application while it's running would prove quite useful for the database application. Since, for example, if we were to observe that the application was using a lot of disk space on the host system, this could then lead to the decision to add more disk space to prevent any issues or maybe even a tweak to how long we keep records around for.

## Acceptance Crtieria
- [ ] Have the ability to view the resource usage of the application.

## Scalability
The database application could benefit from being scalable. While arguably not being a massive priority at the moment, it would still be beneficial to allow for it to be scaled in the future. For example, if more co-working spaces were opened in the future we'd probably want the database application to scale to still match the performance requirement of actions taking 5 or less seconds.

## Acceptance Crtieria
- [ ] Have the ability able to move the SQL codebase and database in general to a more powerful host system in the future.

## Reversibility
The database application could benefit from the ability to revert any changes made to the system quickly without impacting users too much.

## Acceptance Crtieria
- [ ] Ability to make backups of the database so that it can be reverted to if needed, should be achievable via a tool like mysql workbench, phpmyadmin etc.
- [ ] Ability to have code-base on a version control system like Git, Gitlab etc.
- [ ] Ability to implement a active back-up system, database replication.
