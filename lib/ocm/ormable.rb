require 'jsonable'
require 'ostruct'
require_relative 'idable'

module Ocm
  module Ormable

    def self.included(by)
      puts "included by #{by}"
      by.class_eval do
        include Idable
        include Jsonable
      end
      by.extend(ClassMethods)
    end

    module ClassMethods
      # put class methods here
    end

    def initialize(options={})
      options.each_pair do |key,value|
        var_name = "@#{key}"
    #    self.class.__send__(:attr_accessor, var_name)
    #    self.__send__("")
        instance_variable_set var_name, value
    #    send(:define_method, var_name)
      end
    #  @struct = OpenStruct.new(options)
    end

    #def method_missing(method, *args, &block)
    #  @source.send(method, *args, &block)
    #end

  end
end
