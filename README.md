# postgres-test-app

##Endpoints:
All calls respond with "SUCCESS" as their first line if the call performs the behavior as expected, and will return "FAILURE" as their first line otherwise.

###GET '/'  
Displays the current timestamp if connecting to the database and creating a key-value table was successful.

###GET '/timestamp'  
Alias for GET '/'

###GET '/ping'  
Returns "SUCCESS" if this endpoint is reachable; i.e. if the app
is running and receiving connections.

###GET '/services'  
Displays the VCAP\_SERVICES environment variable of the
application instance. It is considered to be a failure if the
VCAP\_SERVICES environment variable does not exist in the
application's environment.

###POST '/exec'  
Takes, as the body, an parameter named "sql" which is equal to the SQL query to be executed on the app's database. An example format from `curl` is as follows:

	curl -X POST <appurl>/exec -d "sql=INSERT INTO test VALUES ('foo', 'bar');"
Note that double-quotes are used to delimit the -d argument of curl so that single-quotes can be freely used in the SQL query.

The response to this endpoint will be the expected SUCCESS/FAILURE
message, and following that, starting on a new line, returned rows
(if any) will be given in JSON format, where the output is a JSON
array of rows, and each row is in turn represented as a JSON array
of values. The values are all encoded as strings, seemingly as a
limitation of the pg library.

Note that, due to limitations of the underlying pg api, if the input "query" is actually multiple queries concatenated with semicolons, while all of them will be executed, only the rows of the last query (if any) will be returned.
