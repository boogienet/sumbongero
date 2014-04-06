require 'sumbongero/clients/client'

module Sumbongero
  module Reporters
    class Reporter
      attr_accessor :client
      def initialize(c)
        @client = c
        unless @client.nil?
          @client.query
        end
      end
      def report
        puts @client.data
      end
    end
  end
end
