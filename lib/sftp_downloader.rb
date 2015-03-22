require "sftp_downloader/version"
require 'fileutils'
require 'net/sftp'

module SftpDownloader

  class Client
    def initialize(credentials:, download_path: './', remote_path: '/', file_pattern: /.*\..*/, remove_after_download: false, logger: nil)
      @credentials = credentials
      @download_path = download_path
      @remote_path = remote_path
      @logger = logger
      @file_pattern = file_pattern
      @remove_after_download = remove_after_download
    end

    def perform(&block)
      check_download_directory_and_create_if_necessary
      Net::SFTP.start(@credentials[:host], @credentials[:username], password: @credentials[:password]) do |sftp|
        log "Connected to: #{@credentials[:host]}"
        files = get_files(sftp: sftp)
        downloads = get_downloads(sftp: sftp, files: files)
        removal_tasks = wait_downloads_completion_yield_and_start_removal_if_necessary(sftp: sftp, downloads: downloads, block: block)
        wait_removal_tasks_if_any(removal_tasks: removal_tasks)
      end
    end

    private

      def check_download_directory_and_create_if_necessary
        if File.exists?(@download_path)
          unless File.directory?(@download_path)
            raise "#{@download_path} already exists but isn't a directory"
          end
        else
          FileUtils.mkdir_p(@download_path)
        end
      end

      def get_files(sftp:)
        sftp.
          dir.
          entries(@remote_path).
          select(&:file?).
          map(&:name).
          grep(@file_pattern).
          sort
      end

      def get_downloads(sftp:, files:)
        files.map do |file|
          log "Starting download: #{file}"
          sftp.download(File.join(@remote_path, file), File.join(@download_path, file))
        end
      end

      def wait_downloads_completion_yield_and_start_removal_if_necessary(sftp:, downloads:, block:)
        downloads.map do |download|
          log "Waiting for download: #{download.remote}"
          download.wait
          log "Completed download: #{download.remote}"

          block.call(download.local)

          if @remove_after_download
            perform_remove(sftp: sftp, download: download)
          end
        end
      end

      def perform_remove(sftp:, download:)
        log "Starting removal: #{download.remote}"
        {
          remote: download.remote,
          request: sftp.remove(download.remote)
        }
      end

      def wait_removal_tasks_if_any(removal_tasks:)
        removal_tasks.compact.each do |removal_task|
          log "Waiting for removal: #{removal_task[:remote]}"
          removal_task[:request].wait
          log "Completed removal: #{removal_task[:remote]}"
        end
      end

      def log(message)
        if @logger
          @logger.debug(message)
        end
      end

  end

end
