# frozen_string_literal: true

module USGeo
  class LoadError < StandardError
  end

  # Base class that all models inherit from.
  class BaseRecord < ::ActiveRecord::Base
    self.abstract_class = true
    self.table_name_prefix = "us_geo_"

    STATUS_IMPORTED = 1
    STATUS_REMOVED = -1
    STATUS_MANUAL = 0

    validates :status, inclusion: [STATUS_IMPORTED, STATUS_REMOVED, STATUS_MANUAL]

    scope :imported, -> { where(status: STATUS_IMPORTED) }
    scope :removed, -> { where(status: STATUS_REMOVED) }
    scope :manual, -> { where(status: STATUS_MANUAL) }
    scope :not_removed, -> { where(status: [STATUS_IMPORTED, STATUS_MANUAL]) }

    class << self
      def load!(location = nil, gzipped: true)
        raise NotImplementedError
      end

      protected

      # Insert or update a record given the unique criteria for finding it.
      def load_record!(criteria, &block)
        record = find_or_initialize_by(criteria)
        record.status = STATUS_IMPORTED
        record.updated_at = Time.now
        yield(record)
        record.save!
      end

      # Mark the status of any records not updated in the block as being no longer imported.
      def import!(&block)
        start_time = Time.at(Time.now.to_i.floor)
        yield
        raise LoadError.new("No data found") unless where("updated_at >= ?", start_time).exists?
        where("updated_at < ?", start_time).imported.update_all(status: STATUS_REMOVED)
      end

      def data_uri(path)
        path = path.to_s if path
        if path.start_with?("/") || path.include?(":")
          path
        elsif USGeo.base_data_uri.include?(":")
          "#{USGeo.base_data_uri}/#{path}"
        else
          File.join(USGeo.base_data_uri, path)
        end
      end

      def load_data_file(location, &block)
        require "open-uri"
        require "csv"

        file = if location.include?(":")
          URI.parse(location).open(read_timeout: 5, open_timeout: 5)
        else
          File.open(location)
        end
        begin
          rows = []
          CSV.new(file, headers: true).each do |row|
            rows << row
            if rows.size >= 50
              transaction { rows.each(&block) }
              rows.clear
            end
          end
          transaction { rows.each(&block) } unless rows.empty?
        ensure
          file.close if file && !file.closed?
        end
      end
    end

    # Return true if the record was imported from the data source distributed with the gem.
    #
    # @return [Boolean]
    def imported?
      status == STATUS_IMPORTED
    end

    # Return true if the record was removed from the data source distributed with the gem.
    #
    # @return [Boolean]
    def removed?
      status == STATUS_REMOVED
    end

    # Return true if the record was manually added to the database.
    #
    # @return [Boolean]
    def manual?
      status == STATUS_MANUAL
    end
  end
end
