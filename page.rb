require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")


class Page
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :required => true 
  property :content, Text, :required => true 
  

end

# Tell DataMapper the models are done being defined
DataMapper.finalize

# Update the database to match the properties of User.
DataMapper.auto_upgrade!

