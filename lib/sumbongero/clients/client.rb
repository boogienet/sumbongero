
module Sumbongero
  module Clients
    class Client 
      attr_accessor :stats, :whichday
      attr_accessor :folders
      def initialize
        @folders = {}
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
