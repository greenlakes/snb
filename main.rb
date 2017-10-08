require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require './page'

configure do
 enable :sessions
 set :username, 'admin'
 set :password, 'password'
end

get '/' do
  slim :home
end

get '/about' do
  slim :about
end

get '/contact' do
  slim :contact
end

get '/pages' do
  @pages = Page.all
  slim :pages
end

get '/pages/new' do
  redirect '/login' unless session[:admin]
  @page = Page.new
  slim :new_page
end

get '/pages/:id' do
  @page = Page.get(params[:id])
  slim :show_page
end

post '/pages' do
  redirect '/login' unless session[:admin]
  @page = Page.create(params[:page])
  redirect ("/pages/#{@page.id}")
end


get '/pages/:id/edit' do
  redirect '/login' unless session[:admin]
  @page = Page.get(params[:id])
  slim :edit_page
end

put '/pages/:id' do
  redirect '/login' unless session[:admin]
  @page = Page.get(params[:id])
  @page.update(params[:page])
  redirect ("/pages/#{@page.id}")
end

delete '/pages/:id' do
  redirect '/login' unless session[:admin]
  @page = Page.get(params[:id])
  @page.destroy
  redirect "/pages"
end

get '/login' do
  slim :login
end

post '/login' do
    if params[:username] == settings.username && params[:password]== settings.password
      session[:admin] = true
      redirect '/pages'
    else
      slim :login
    end
end

get '/logout' do
  session.clear
  redirect '/login'
end

not_found do
  slim :not_found
end