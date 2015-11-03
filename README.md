# postgres-test-app

##Endpoints:
All calls respond with "SUCCESS" as their first line if the call performs the behavior as expected, and will return "FAILURE" as their first line otherwise.

###GET '/'  
Displays the current timestamp if connecting to the database and creating a key-value table was successful. Otherwise, displays an error message beginning with "FAILED:"

###GET '/services'  
Displays the VCAP\_SERVICES environment variable of the
application instance. It is considered to be a failure if the
VCAP\_SERVICES environment variable does not exist in the
application's environment.

###POST '/exec'
Takes, as the body, an parameter named "sql" which is equal to the SQL query to be executed on the app's database. An example format from `curl` is as follows:

	curl -X POST <appurl>/exec -d "sql=INSERT INTO test VALUES ('foo', 'bar');"
Note that double-quotes are used to delimit the -d argument of curl so that single-quotes can be freely used in the SQL query.

The response to this endpoint will be the expected SUCCESS/FAILURE message, and following that, starting on a new line, returned rows (if any) will be given the following format:
Rows will each be represented on their own line. Columns within rows will be enclosed in double-quotes and separated by a space character from adjacent columns.

Note that, due to limitations of the underlying pg api, if the input "query" is actually multiple queries concatenated with semicolons, while all of them will be executed, only the rows of the last query (if any) will be returned.
