require 'securerandom'

module Ocm
  module Idable

    def id
      @id
    end

    def id=(id)
      @id = id
    end

    def self.generate_id
      SecureRandom.uuid()
    end

  end
end
