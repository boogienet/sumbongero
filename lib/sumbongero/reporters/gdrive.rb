require "sumbongero/reporters/reporter"
require "google_drive"

# TODO: if the row already exist, then just overwrite

module Sumbongero
  module Reporters
    class GDriveConst
      DATA_SPREADSHEET = "GMAIL_DATA"
      WS_BASE_DATA = "Base Data"
      WS_FOLDERS_DATA = "Folders"
    end

    class GDrive < Reporter
      attr_accessor :session, :spreadsheet

      def initialize(client, username, password)
        super(client)
        @session = GoogleDrive.login(username, password)
        @spreadsheet = @session.spreadsheets("title"=>GDriveConst::DATA_SPREADSHEET, "title-exact" => "true")
        if @spreadsheet.empty?
          initial_setup()
        else
          @spreadsheet = @spreadsheet[0]
        end

        # Make sure that the columns exist for each folder passed
        folders_sync()

      end

      def folders_sync()
        to_add = []
        folders = @client.data[:folders]
        @folders_ws = @spreadsheet.worksheet_by_title(GDriveConst::WS_FOLDERS_DATA)
        folders.each_key do |folder|
          # puts "#{folder}: #{@folders_ws.list.keys.include? folder.to_s}"
          if @folders_ws.list.keys.include?(folder.to_s) == false
            to_add << folder
          end
        end

        # calculate where to start adding columns
        start_add = @folders_ws.list.keys.size + 1
        to_add.each do |folder|
          @folders_ws[1, start_add] = folder
          start_add = start_add + 1
        end
        @folders_ws.save
      end

      def initial_setup()
        @spreadsheet = @session.create_spreadsheet(GDriveConst::DATA_SPREADSHEET)
        @base_ws = @spreadsheet.add_worksheet(GDriveConst::WS_BASE_DATA)
        @base_ws[1,1] = "Date"
        @base_ws[1,2] = "Inbox"
        @base_ws[1,3] = "Deleted"
        @base_ws[1,4] = "Sent"
        @base_ws.save()

        @folders_ws = @spreadsheet.add_worksheet(GDriveConst::WS_FOLDERS_DATA)
        @folders_ws[1,1] = "Date"
        @folders_ws.save()
      end

      def report
        @base_ws = @spreadsheet.worksheet_by_title(GDriveConst::WS_BASE_DATA)

        @base_ws.list.push({
          :Date => @client.data[:query_date],
          :Inbox => @client.data[:inbox],
          :Deleted => @client.data[:deleted],
          :Sent => @client.data[:sent]
        })

        @folders_ws = @spreadsheet.worksheet_by_title(GDriveConst::WS_FOLDERS_DATA)
        folder_data = {}
        @client.data[:folders].each_key do |folder|
          folder_data[:Date] = @client.data[:query_date]
          folder_data[folder] = @client.data[:folders][folder]
        end

        @folders_ws.list.push(folder_data)
        @folders_ws.save()
        @base_ws.save()
      end
    end
  end
end
