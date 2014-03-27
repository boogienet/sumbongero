
module Sumbongero
  module Clients
    class Client 
      attr_accessor :stats, :whichday
      def initialize
        @stats = {}
        @stats[:inbox] = nil
        @whichday = Date.today
      end
      def query
        puts "Please override this"
      end
    end
  end
end
