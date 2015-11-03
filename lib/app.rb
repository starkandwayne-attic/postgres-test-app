require 'sinatra'
require 'pg'
require 'cf-app-utils'

DATA ||= {}
SUCCESS_MESSAGE = "SUCCESS"
FAILURE_MESSAGE = "FAILURE"

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

#gets a fresh connection to the database
def get_conn
  begin
    return PG::Connection.new(postgres_uri)
  rescue PG::Error
    return nil
  end
end

#This should display the timestamp if a connection to the database was established.
get '/' do
  conn = get_conn
  if conn == nil
    body FAILURE_MESSAGE
    status 409
  else 
    begin
      res = conn.exec("SELECT CURRENT_TIMESTAMP;")
      status 200
      output = "#{SUCCESS_MESSAGE}\n#{res.getvalue(0,0)}"
      body output
    rescue PG::Error
      status 409
      body FAILURE_MESSAGE
    end
  end
  conn.close()
end

get '/services' do
  body "#{ENV['VCAP_SERVICES']}\n"
  status 200
end

#execute an arbitrary, user-supplied query on the database
post '/exec' do
  conn = get_conn
  begin
    unless params['sql']
      halt 500, 'NO-SQL-QUERY'
    end
    res = conn.exec(params['sql'])
    if res.num_tuples > 0
      output = "#{SUCCESS_MESSAGE}\n"
      res.each_row do |row|
        row.map do |column|
          #this technically won't play well if an entry actually has a quote in it...
          output = "#{output}\"#{column}\" "
        end
        output = output.strip
        output = "#{output}\n"
      end
      status 200
      body output
    else
      body SUCCESS_MESSAGE
      status 200
    end
  rescue PG::Error
    body FAILURE_MESSAGE
    status 409
  end
  conn.close()
end

error do
  halt 500, "ERR:#{env['sinatra.error']}"
end

