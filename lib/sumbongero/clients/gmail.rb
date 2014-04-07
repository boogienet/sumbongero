require 'sumbongero/clients/client'
require 'gmail'

module Sumbongero
  module Clients
    class GMail < Client 
      attr_accessor :username, :password
      attr_accessor :gmail

      def initialize(username, password, folders = {})
        super()
        unless folders.nil?
          @folders = folders
        end

        @username = username
        @password = password

        @gmail = Gmail.new(@username, @password)
        ObjectSpace.define_finalizer(self, proc {
          @gmail.logout
        })
      end
      def query
        @stats[:query_date] = @whichday.to_s
        if @whichday == Date.today
          @stats[:inbox] = @gmail.inbox.count
        end

        @stats[:deleted] = @gmail.mailbox('[Gmail]/Trash').count(:on => @whichday)
        @stats[:sent] = @gmail.mailbox('[Gmail]/Sent Mail').count(:on => @whichday)

        @folders_stats = {}
        @folders.each do |folder|
          @folders_stats[folder.to_sym] = @gmail.mailbox(folder).count(:on => @whichday)
        end

        @stats[:folders] = @folders_stats
        @data = @stats
      end
    end
  end
end
