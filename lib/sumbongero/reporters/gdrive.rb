require "sumbongero/reporters/reporter"
require "google_drive"

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
        @folders_ws = @spreadsheet.worksheet_by_title(GDriveConst::WS_FOLDERS_DATA)

        _base_data = {
          :Date => @client.data[:query_date],
          :Inbox => @client.data[:inbox],
          :Deleted => @client.data[:deleted],
          :Sent => @client.data[:sent]
        }
        _folder_data = {}
        @client.data[:folders].each_key do |folder|
          _folder_data[:Date] = @client.data[:query_date]
          _folder_data[folder] = @client.data[:folders][folder]
        end

        in_spreadsheet = row_exist?(@client.data[:query_date])
        if in_spreadsheet == nil
          @base_ws.list.push(_base_data)
          @folders_ws.list.push(_folder_data)
        else
          @base_ws.list[in_spreadsheet] = _base_data
          @folders_ws.list[in_spreadsheet] = _folder_data
        end
        @folders_ws.save()
        @base_ws.save()
      end

      def row_exist?(qd)
        # build an array of the dates (of rows) saved in ths spreadsheet
        # to compare the passed in date with
        _row_exist = nil
        dates = []
        if @base_ws.list.size != 0
          (0..@base_ws.list.size-1).each do |index|
            dates << @base_ws.list[index]["Date"]
          end
          qd_formatted = Date.parse(qd).strftime("%-m/%d/%Y")
          _row_exist = dates.rindex qd_formatted
          # puts " _row_exist: #{_row_exist} \n qd_formatted #{qd_formatted} \n\n dates array #{dates}"
        end
        _row_exist
      end
    end
  end
end
