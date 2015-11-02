require 'sinatra'
require 'pg'
require 'cf-app-utils'

DATA ||= {}
TABLE_NAME = 'user_sample_table_1234567890'

def create_sample_table
  #bdr doesn't support IF NOT EXISTS... so, gotta hack around it.
  sql = "SELECT 1 FROM pg_tables WHERE tablename = '#{TABLE_NAME}';"
  res = $client.exec(sql)
  if res.num_tuples > 0
    sql = "DROP TABLE #{TABLE_NAME};"
    $client.exec(sql)
  end
  sql = "CREATE TABLE #{TABLE_NAME}(key varchar(255), value varchar(255));"
  $client.exec(sql)
  nil
end

def postgres_uri
  return nil unless ENV['VCAP_SERVICES']

  JSON.parse(ENV['VCAP_SERVICES'], :symbolize_names => true).values.map do |services|
    services.each do |s|
      #check if this is actually an RDPG service. Ugly, but should work.
      if s.has_key?(:credentials)
        c = s[:credentials]
        if c.has_key?(:ID) and c.has_key?(:binding_id) and c.has_key?(:instance_id) and
          c.has_key?(:uri) and c.has_key?(:dsn) and c.has_key?(:jdbc_uri) and
          c.has_key?(:host) and c.has_key?(:port) and c.has_key?(:username) and
          c.has_key?(:password) and c.has_key?(:database)
          return s[:credentials][:uri]
        end
      end
    end
  end
  nil
end

before do
  unless postgres_uri
    $default_message = 'FAILED: You must bind a Postgres service instance to this application'
  end
end

begin
  $client = PG::Connection.new(postgres_uri)
  res = $client.exec("SELECT CURRENT_TIMESTAMP;")
  timestamp = res.getvalue(0,0)
  create_sample_table
  $default_message = timestamp
rescue PG::Error
  $default_message = 'FAILED: Error during connection/initialization'
end

#This should display the timestamp if a connection to the database was established.
get '/' do
  body $default_message << '\n'
  status 200
end

get '/services' do
  body "#{ENV['VCAP_SERVICES']}\n"
  status 200
end

get '/insert/:key/:value' do
  begin
    sql = "INSERT INTO #{TABLE_NAME} VALUES ('#{params['key']}', '#{params['value']}');"
    $client.exec(sql)
    status 200
    body "Successfully inserted: key: '#{params['key']}', value: '#{params['value']}'"
  rescue PG::Error
    status 409
    body "Unable to insert key: '#{params['key']}', value: '#{params['value']}'"
  end
end

get '/query/:key' do
  begin
    if params['key'].to_s == '*'
      sql = "SELECT * FROM #{TABLE_NAME};"
    else
      sql = "SELECT * FROM #{TABLE_NAME} WHERE key = '#{params['key']}';"
    end
    res = $client.exec(sql)
    if res.num_tuples == 0
      body "No tuples were returned"
    else
      output = ""
      res.each_row do |row|
        output = "#{output} key: '#{row[0]}', value: '#{row[1]}'\n"
      end
      status 200
      body output
    end
  rescue PG::Error
    status 409
    body "FAILED: Error when returning tuples"
  end
end

error do
  halt 500, "ERR:#{env['sinatra.error']}"
end

