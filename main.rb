require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'erb'
require 'pry-byebug'
require 'sqlite3'

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"
require 'db_ops'
require 'auth'

def h(password)
  Authenticator::hash_password(password)
end

credzy_db = CredzyDb.new(true)
credzy_db.seed(:h)

get '/' do
  auth = Authenticator.new(cookies, credzy_db)

  if (auth.is_logged_in_admin?)
    redirect to('/admin')
  elsif (auth.is_logged_in_user?)
    redirect to('/user')
  else
    erb :index, :locals => {:db => credzy_db}
  end
end

post '/login' do
  erb :login, :locals => {:db => credzy_db}
end

get '/create' do
  erb :create
end

post '/new' do
  email = params[:email]
  password = params[:password]
  credzy_db.insert_user(email, h(password), 'user')

  auth = Authenticator.new(cookies, credzy_db)
  auth.authenticate_user(email, password)

  redirect to('/')
end

get '/logout' do
  auth = Authenticator.new(cookies, credzy_db)
  auth.logout()
  redirect to('/')
end

get '/admin' do
  auth = Authenticator.new(cookies, credzy_db)
  if (auth.is_logged_in_admin?)
    erb :admin
  else
    redirect to('/')
  end
end

get '/user' do
  auth = Authenticator.new(cookies, credzy_db)
  if (auth.is_logged_in_user?)
    erb :user, :locals => {:db => credzy_db}
  else
    redirect to('/')
  end
end

get '/about' do
  erb :about
end

post '/upload' do
  auth = Authenticator.new(cookies, credzy_db)
  if (auth.is_logged_in_user?)
    tempfile = params[:file][:tempfile]
    ext = File.extname(params[:file][:filename])
    filename = "#{Digest::MD5.hexdigest(rand().to_s)}#{ext}"
    FileUtils.copy(tempfile.path, "./pii/#{filename}")
    
    credzy_db.insert_document(cookies[:user_id], filename)
  end

  redirect to('/user')
end

get '/download' do
  auth = Authenticator.new(cookies, credzy_db)
  if (auth.is_logged_in_user?)
    file = File.join('pii', params[:filename])
    send_file(file, :disposition => 'attachment', :filename => File.basename(file))
  end

  redirect to('/user')
end