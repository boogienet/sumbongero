require 'sumbongero/clients/client'

module Sumbongero
  module Reporters
    class Reporter
      attr_accessor :client
      def initialize(c)
        @client = c
        @client.query
      end
    end
  end
end
