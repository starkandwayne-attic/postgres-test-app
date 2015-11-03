# postgres-test-app

##Endpoints:

###GET '/'  
Displays the current timestamp if connecting to the database and creating a key-value table was successful. Otherwise, displays an error message beginning with "FAILED:"

###GET '/services'  
Displays the VCAP_SERVICES environment variable of the application instance.

###POST '/exec'
Takes, as the body, an parameter named "sql" which is equal to the SQL query to be executed on the app's database. An example format from `curl` is as follows:

	curl -X POST <applicationurl>/exec -d "sql=INSERT INTO test VALUES ('foo', 'bar');"
Note that double-quotes are used to delimit the -d argument of curl so that single-quotes can be freely used in the SQL query.
