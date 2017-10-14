require 'bundler'
Bundler.require
require 'bcrypt'
require 'sinatra'
require './user'
require './page'
require 'sinatra/flash'
require "sinatra/reloader"

def hash_password(password)
  BCrypt::Password.create(password).to_s
end

def test_password(password, hash)
  BCrypt::Password.new(hash) == password
end

class App < Sinatra::Base
 
  enable :sessions
  set :method_override, true
  register Sinatra::Flash
  register Sinatra::Reloader
  


 get '/' do
    slim :home
 end

 get '/about' do
  slim :about
 end

 get '/contact' do
  slim :contact
 end

 get '/login' do
    slim :login
 end
  
 post '/login' do
  user = User.find { |u| u.username == params[:username] }
  if user && test_password(params[:password], user.password) && user.admin
    session.clear
    session[:user_id] = user.id
    flash[:success] = 'You have successfully logged in as admin.'
    redirect "/admin"
  elsif user && test_password(params[:password], user.password) 
    session.clear
    session[:user_id] = user.id
    flash[:success] = 'You have successfully logged in.'
    redirect "/users/#{user.id}"
  else
    flash[:error] = 'Username or password were incorrect.'
    redirect '/login'
  end
 end

 post '/logout' do
  session.clear
  flash[:success] = 'You have successfully logged out.'
  redirect '/login'
 end

get '/users/:id' do
 @user = User.get(params[:id])
 slim :user_profile
end


 get '/new_user' do
  @user = User.new
  slim :new_user
 end
 
  get '/users/:id/edit' do
  @user = User.get(params[:id])
  slim :edit_user
 end

 post '/new_user' do
  if @user = User.create(params[:user])
  flash[:success] = "New user account has been created. You can now log in to proceed."
  redirect '/login'
  end
end

put '/users/:id' do
  user = User.get(params[:id])
  if user.update(params[:user])
  flash[:notice] = "User details have been updated."
  redirect to("/users/#{user.id}")
  end
end

delete '/users/:id' do
  if User.get(params[:id]).destroy
  flash[:notice] = "User account has been deleted"
  redirect to('/')
  end
end
 
 get '/admin' do
  @pages = Page.all
  @users = User.all
  if current_admin
  slim :admin
  else
  flash[:error] = "You need to log in with admin permissions to access admin"
  redirect '/login'
  end
 end
  
 get '/pages' do
  @pages = Page.all
      slim :pages
 end

 get '/pages/new' do
  @page = Page.new
  if current_user
  slim :new_page
 else
  flash[:warning]= "You need to log in to be able to create a page."
  redirect '/login'
 end
 end

 get '/pages/:id' do
  @page = Page.get(params[:id])
  slim :show_page
 end

 post '/pages' do
  if page = Page.create(params[:page])
   page.created_at = Time.now
  page.created_by = current_user.username
  info = "#{params[:page]}"
  time = Time.now.strftime('%Y/%m/%d %H:%M %p')
  @info = time + " " + info + " Created by: " + page.created_by
  file = File.new("logs/#{page.title + page.created_at.to_s}.txt", "w")
  file.puts @info
  file.close
  
  flash[:success] = "Page successfully created."
  redirect to("/pages/#{page.id}")
  end
end

 get '/pages/:id/edit' do
  @page = Page.get(params[:id])
  if current_user
  slim :edit_page
 else 
  flash[:warning]= "You need to log in to be able to edit the page."
  redirect '/login'
 end
end
 
put '/pages/:id' do
  page = Page.get(params[:id])
  if page.update(params[:page])
  page.updated_at = Time.now
  page.updated_by = current_user.username
  info = "#{params[:page]}"
  time = Time.now.strftime('%Y/%m/%d %H:%M %p')
  @info = time + " " + info + " Edit made by: " + page.updated_by
  file = File.new("logs/#{page.title + page.updated_at.to_s}.txt", "w")
  file.puts @info
  file.close
  
  flash[:notice] = "Page successfully updated."
  redirect to("/pages/#{page.id}")
  end
end
 

 delete '/pages/:id' do
  if current_user && Page.get(params[:id]).destroy
  flash[:notice] = "Page successfully deleted"
  redirect to('/pages')
 else
  flash[:warning]= "You need to be logged in to delete this page."
  redirect '/login'
end
end


 helpers do
    def current_user
      if session[:user_id]
         User.find { |u| u.id == session[:user_id] }
      else
        nil
      end
    end
    
    def current_admin
      if session[:user_id]
         User.find { |u| u.id == session[:user_id] && u.admin}
      else
        nil
      end
    end
    
  end
  
 not_found do
  slim :not_found
 end

end