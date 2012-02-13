#config.ru
require 'rubygems'
begin
  require 'bundler'
  Bundler.require
  require './app'
  run Sinatra::Application
rescue LoadError => err
  warn "Where's bunder? #{err}"
end