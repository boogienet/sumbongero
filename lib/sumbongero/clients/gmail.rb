require 'sumbongero/clients/client'
require 'gmail'

module Sumbongero
  module Clients
    class GMail < Client 
      attr_accessor :username, :password
      attr_accessor :gmail

      def initialize(username, password)
        super()
        @username = username
        @password = password

        @gmail = Gmail.new(@username, @password)
        ObjectSpace.define_finalizer(self, proc {
          @gmail.logout
        })
      end
      def query
        if @whichday == Date.today
          @stats[:inbox] = @gmail.inbox.count
        end

        @stats[:sent] = @gmail.mailbox('[Gmail]/Sent Mail').count(:on => @whichday)
        puts @stats
      end
    end
  end
end
