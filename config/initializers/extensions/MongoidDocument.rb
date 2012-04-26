module Mongoid
  module Document
    def logger
      Mongoid.logger
    end

    module ClassMethods
      def logger
        Mongoid.logger
      end
    end

  end
end