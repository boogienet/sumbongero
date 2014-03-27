require "win32ole"
require "time"

require "reporter"

module Sumbongero
  module Clients
    class OutlookConst
    end

    class Outlook < Reporter
      attr_accessor :client, :mapi
      def initialize
        @client = WIN32OLE.new('Outlook.Application')
        WIN32OLE.const_load(@client, OutlookConst)
        @mapi = @client.GetNameSpace("MAPI")
      end

      def query
      end

      def inbox_item_count
        items = get_inbox_items(Date.today)
        items.Count
      end

      def sent_item_count_yesterday
        items = get_sent_items(Date.today.prev_day)
        items.Count
      end

      def deleted_item_count_yesterday
        items = get_deleted_items(Date.today.prev_day)
        items.Count
      end

      private

      def build_date_filtering(column, whichday)
        "#{column} >= \"#{whichday.strftime("%m/%d/%Y 12:01 AM")}\" AND #{column} <= \"#{whichday.strftime("%m/%d/%Y 11:59 PM")}\""
      end

      def get_items_by_folder(folder)
        folder = @mapi.GetDefaultFolder(folder)
        puts "#{folder.FolderPath}"
        folder.Items
      end

      def get_inbox_items(whichday = Date.today)
        get_items_by_folder(OutlookConst::OlFolderInbox)
      end

      def get_deleted_items(whichday = Date.today)
        items = get_items_by_folder(OutlookConst::OlFolderDeletedItems)
        filter = build_date_filtering("[LastModificationTime]", Date.today.prev_day)
        items.Restrict(filter)
      end
      def get_sent_items(whichday = Date.today)
        items = get_items_by_folder(OutlookConst::OlFolderSentMail)
        filter = build_date_filtering("[SentOn]", Date.today.prev_day)
        items.Restrict(filter)
      end
    end
  end
end
