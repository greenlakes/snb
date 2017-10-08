require 'dm-core'
require 'dm-migrations'

configure do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

class Page
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true 
  property :content, Text, :required => true 
end

DataMapper.finalize