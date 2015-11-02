# postgres-test-app

Endpoints:

/
Displays the current timestamp if connecting to the database and creating a key-value table was successful. Otherwise, displays an error message beginning with "FAILED:"

/services
Displays the VCAP_SERVICES environment variable of the application instance.

/query/{key}
Returns a list of the [key, value] pairs returned by querying the key-value postgres table from all rows where key={key}

/insert/{key}/{value}
Inserts a row into the key-value table where the key={key} and value={value}
