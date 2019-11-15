require 'sinatra'
require 'pg'
require 'pry'
require "./Message.rb"
require "./Comment.rb"

get '/messages' do
  @messages = Message.all
   erb :index, layout: :MesInput
  
end

get "/messages/:id" do
  id = params[:id]
  Message.delete(id)
  redirect to("/messages")
end

get '/comments' do
  @comments = Comment.all
  erb :index, layout: :ComInput
  
end

get "/comments/:id" do
  id = params[:id]
  Comment.delete(id)
  redirect to("/comments")
end

post "/messages" do
  Message.new(params)
 redirect to("/messages")
end

post "/comments" do
  Comment.new(params)
  redirect to("/comments")
end