require_relative './config/environment.rb'

Adapters::MovieClient.new.seed
