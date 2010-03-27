require 'rubygems'
require 'sinatra'
require 'json'

set :port, 3333

class Symbol
  def to_proc
    lambda { |o| o.send(self) }
  end
end

# MemoryStore is an in memory approximation of a datastore.
# It takes O(n) for any find, so don't use it for major stuff.
class MemoryStore
  def initialize(primary_key, attributes = {})
    @primary_key = primary_key
    @attributes = attributes
    @data_store = []
  end

  def method_missing(meth, *args, &block)
    case meth.to_s
    when /^find_by_(.*)$/
      find_by($1, *args, &block)
    else 
      super
    end
  end

  def find_by(attribute, value)
    @data_store.detect { |item| item[attribute.to_sym] == value }
  end

  def create(attrs={})
    return unless valid?(attrs)
    existing = send("find_by_#@primary_key", attrs[@primary_key])
    @data_store.delete(existing) if existing
    @data_store << sanitize(attrs)
  end

  def sanitize(attrs)
    arr = attrs.map do |k, v|
      val = case @attributes[k.to_sym]
            when :string
              v
            when :array
              v.split(/ *, */)
            else
              raise "Cannot sanitize #{k} of type #{@attributes[k]} and value #{v}"
            end
      [k.to_sym, val]
    end
    Hash[*arr.flatten(1)]
  end

  def valid?(attrs)
    (attrs.keys.map(&:to_sym) - @attributes.keys.map(&:to_sym)).empty?
  end
end

User = MemoryStore.new(:name, :name => :string, :roles => :array)
Authorization = MemoryStore.new(:resource, :resource => :string, :roles => :array)

post '/users' do
  user = User.create(params)
  user ? 'Created' : 'Failed'
end

post '/authorizations' do
  auth = Authorization.create(params)
  auth ? 'Created' : 'Failed'
end

get '/users/:name/authorizations' do |name|
  user_roles = (User.find_by_name(name) || {})[:roles] || []
  auth_roles = (Authorization.find_by_resource(params[:resource]) || {})[:roles] || []
  authorized = (user_roles - auth_roles).length != user_roles.length
  {:authorized => authorized}.to_json
end

get '/status' do
  'running'
end
