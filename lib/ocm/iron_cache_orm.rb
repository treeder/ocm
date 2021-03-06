require 'iron_cache'
require 'logger'

module Ocm

  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::INFO

  def self.logger
    @@logger
  end

  def self.logger=(l)
    @@logger = l
  end

  class Orm

    # initialize with a cache object from IronCache::Client, eg: iron_cache.cache("my_object_cache")
    def initialize(cache)
      @cache = cache
    end

    def key_for(idable, id=nil)
      if id
        # idable should be a class
        "#{idable.name.downcase}_#{id}"
      else
        "#{idable.class.name.downcase}_#{idable.id}"
      end
    end

    def save(idable)
      unless idable.id
        idable.id = Idable.generate_id
      end
      if defined? idable.set_timestamps
        idable.set_timestamps
      end
      put(key_for(idable), idable)
    end

    def save_list(key, array)
      put(key, array)
    end

    def get_list(key)
      messages = get(key)
      #puts 'got messages: ' + messages.inspect
      if messages.nil?
        messages = []
      end
      messages
    end

    # first item that matches comps is replaced with item.
    def update_in_list(key, item, comps)
      messages = get_list(key)
      Ocm.logger.debug "update_in_list: messages: #{messages.inspect}"
      messages.each_with_index do |m, i|
        match = true
        comps.each_pair do |k, v|
          if m.is_a?(Hash)
            if m[k.to_s] != v
              match = false
              break
            end
          else
            if m.__send__(k.to_sym) != v
              match = false
              break
            end
          end
        end
        if match
          if item
            messages[i] = item
          else
            messages.delete_at(i)
          end
          put(key, messages)
          return
        end
      end
      raise "No matching item found in list for #{comps.inspect}"
    end

    # Warning, this is not a safe operation, be sure it is only being called once at a time
    def prepend_to_list(key, item)
      messages = get_list(key)
      messages.unshift(item)
      put(key, messages)
    end

    # Warning, this is not a safe operation, be sure it is only being called once at a time
    def append_to_list(key, item)
      messages = get_list(key)
      messages.push(item)
      put(key, messages)
    end

    # Warning, this is not a safe operation, be sure it is only being called once at a time
    def remove_from_list(key, comps)
      #id = item.is_a?(String) ? item : item.id
      update_in_list(key, nil, comps)
    end

    def find(clazz, id)
      get(key_for(clazz, id))
    end

    def get(key)
      val = @cache.get(key)
      #puts 'got val: ' + val.inspect
      if val.nil?
        puts "GOT NIL for key #{key}"
        return nil
      end
      val = val.value
      #puts "got from cache #{val}"
      begin
        val = JSON.load(val)
        if val.is_a?(Hash) && val['string']
          val = val['string']
        end
      rescue => ex
        puts "CAUGHT: #{ex.message}"
      end
      val
    end

    def put(key, value, options={})
      if value.is_a?(String)
        # need to wrap it
        value = {string: value}.to_json
      else
        value = value.to_json
      end
      #puts 'value jsoned: ' + value.inspect
      @cache.put(key, value, options)
    end

    def remove(idable, id=nil)
      delete(key_for(idable, id))
    end

    def delete(key)
      @cache.delete(key)
    end

    def increment(key, value=1)
      puts 'INC'
      begin
        ret = @cache.increment(key, value)
        puts 'INC RET ' + ret.inspect
        return ret.value
      rescue Rest::HttpError, IronCore::ResponseError => ex
        p ex
        puts "couldn't increment #{key}"
        puts ex.message
        p ex.backtrace
        if ex.code == 404
          puts "setting value in cache"
          settings.iron_cache.put(key, 1)
        end
        puts "done increment"
        return 1
      end
    end

    # You can add these to allow multiple ways to look up an object, rather than just a single key
    def add_alias(key_from, ob_to)
      put(key_for(ob_to.class, key_from), key_for(ob_to))
    end

    # returns the object found by the key contained in the alias entry
    def get_alias(clz, key_from)
      real_key = get(key_for(clz, key_from))
      return nil unless real_key
      get(real_key)
    end
  end
end
