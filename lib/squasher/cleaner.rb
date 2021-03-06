require 'fileutils'

module Squasher
  class Cleaner
    MIGRATION_NAME = 'squasher_clean'

    def self.process(*args)
      new(*args).process
    end

    def process
      Squasher.error(:migration_folder_missing) unless config.migrations_folder?

      migration_file = config.migration_file(now_timestamp, MIGRATION_NAME)
      if prev_migration
        FileUtils.mv(prev_migration, migration_file)
      else
        File.open(migration_file, 'wb') do |stream|
          stream << ::Squasher::Render.render(MIGRATION_NAME, config)
        end
      end
      Squasher.rake("db:migrate", :db_cleaning)
    end

    private

    def config
      @config ||= Squasher::Config.new
    end

    def prev_migration
      return @prev_migration if defined?(@prev_migration)

      @prev_migration = config.migration_files.detect do |file|
        File.basename(file).include?(MIGRATION_NAME)
      end
    end

    def now_timestamp
      Time.now.strftime("%Y%m%d%H%M%S")
    end
  end
end
