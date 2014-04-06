require "win32ole"
require "time"

require "sumbongero/clients/client"

module Sumbongero
  module Clients
    class OutlookConst
    end

    class Outlook < Client
      attr_accessor :client, :mapi
      attr_accessor :data

      def initialize(folder = nil)
        super()
        unless folder.nil?
          @folders = folder
        end

        @client = WIN32OLE.new('Outlook.Application')
        WIN32OLE.const_load(@client, OutlookConst)
        @mapi = @client.GetNameSpace("MAPI")
      end

      def query
        @whichday = Date.today

        @stats[:inbox] = inbox_item_count
        @stats[:sent] = sent_item_count
        @stats[:deleted] = deleted_item_count

        @folders_stats = {}
        @folders.each do |folder|
          @folders_stats[folder.to_sym] = folder_item_count(folder)
        end

        @stats[:folders] = @folders_stats
        @data = @stats
      end

      def folder_item_count(folder)
        folder = get_folder(OutlookConst::OlFolderInbox, folder)
        items = get_items(folder, {:column=>"[LastModificationTime]", :date=>@whichday})
        items.count
      end

      def inbox_item_count
        folder = get_folder(OutlookConst::OlFolderInbox)
        items = get_items(folder, {:column=>"[ReceivedTime]", :date=>@whichday})
        items.count
      end

      def sent_item_count
        folder = get_folder(OutlookConst::OlFolderSentMail)
        items = get_items(folder, {:column=>"[SentOn]", :date=>@whichday})
        items.count
      end

      def deleted_item_count
        folder = get_folder(OutlookConst::OlFolderDeletedItems)
        items = get_items(folder, {:column=>"[LastModificationTime]", :date=>@whichday})
        items.count
      end

      private

      def build_date_filtering(column, whichday)
        "#{column} >= \"#{whichday.strftime("%m/%d/%Y 12:01 AM")}\" AND #{column} <= \"#{whichday.strftime("%m/%d/%Y 11:59 PM")}\""
      end

      def get_folder(default_folder, subfolder = nil)
        folder = @mapi.GetDefaultFolder(default_folder)
        unless subfolder.nil?
          subfolders = subfolder.split('\\').count
          if subfolders == 1
            folder = folder.Folders(subfolder)
          else
            cmd = ""
            subfolder.split('\\').each do |f| 
              cmd += ".Folders(\'#{f}\')"
            end
            folder = eval("folder#{cmd}")
          end
        end
        folder
      end

      def get_items(folder, filter = nil)
        items = folder.Items
        filter_column = filter[:column]
        filter_date = filter[:date]
        unless filter_column.nil?
          filter = build_date_filtering(filter_column, filter_date)
          items = items.Restrict(filter)
        end
        items
      end

    end
  end
end
