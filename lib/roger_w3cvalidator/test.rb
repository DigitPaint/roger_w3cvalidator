require 'roger/test'
require File.dirname(__FILE__) + "/w3c_validator"

module RogerW3cvalidator
  class Test

    def initialize(options={})
      @options = {
        :match => ["html/**/*.html"],
        :skip => []
      }
      @options.update(options) if options            
    end

    def call(test, options={})
      options = {}.update(@options).update(options)

      test.log(self, "Validating all files matching #{options[:match].inspect}")

      success = true
      test.get_files(options[:match], options[:skip]).each do |file_path|
        validator = W3CValidator.new(File.read(file_path))
        validator.validate!
        if !validator.valid
          test.log(self, "#{file_path} is invalid (errors: #{validator.errors}, warnings: #{validator.warnings})") do
            validator.response["messages"].each do |message|
              test.debug(self, message["message"])
            end
          end
          success = false
        else
          test.debug(self, "#{file_path} is valid")
        end
      end

      success
    end

  end
end

Roger::Test.register :w3cvalidator, RogerW3cvalidator::Test