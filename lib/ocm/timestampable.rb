module Ocm
  module Timestampable

    def created_at
      @created_at
    end

    def created_at=(t)
      @created_at = t
    end

    def updated_at
      @updated_at
    end

    def updated_at=(t)
      @updated_at = t
    end

    def set_timestamps
      time = Time.now.utc
      if !created_at
        self.created_at = time
      end
      self.updated_at = time
    end

  end
end

