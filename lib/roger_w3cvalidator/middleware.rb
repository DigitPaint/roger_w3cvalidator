require 'rack/request'
require 'rack/response'
require File.dirname(__FILE__) + "/w3c_validator"

module RogerW3cvalidator
  class Middleware
    def initialize(app)
      @app = app
    end
    
    def call(env)
      resp = @app.call(env)
      if resp[1]["Content-Type"].to_s.include?("html")
        str = ""
        resp[2].each{|c| str << c}
        validator = W3CValidator.new(str)
        validator.validate!
        if !validator.valid
          env["rack.errors"].puts "Validation failed on #{env["PATH_INFO"]}: (errors: #{validator.errors}, warnings: #{validator.warnings})"
        end
      end
      resp
    end    
  end
end