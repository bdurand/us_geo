# frozen_string_literal: true

require "sqlite3"

module USGeoData
  # This is used to determine which ZCTA contains a given latitude and longitude
  # from Tiger files.
  class ZCTAShape
    def initialize(path)
      @db = SQLite3::Database.new(path)
      @db.results_as_hash = true

      # Load SpatiaLite extension to enable spatial functions
      @db.enable_load_extension(true)

      begin
        # Try full path to mod_spatialite
        @db.load_extension("/opt/homebrew/lib/mod_spatialite")
      rescue SQLite3::SQLException
        # Fallback to other possible locations
        begin
          @db.load_extension("/usr/local/lib/mod_spatialite")
        rescue SQLite3::SQLException
          # Last resort - try without full path
          @db.load_extension("mod_spatialite")
        end
      end
      @db.enable_load_extension(false)

      # Performance optimizations
      optimize_database
    end

    def including(lat, lng)
      lng_f = lng.to_f
      lat_f = lat.to_f

      # Use MbrContains for faster bounding box check, then ST_Contains for precision
      sql = <<~SQL
        SELECT zcta5ce20
        FROM zctas
        WHERE MbrContains(geometry, ST_Point(#{lng_f}, #{lat_f}))
          AND ST_Contains(geometry, ST_Point(#{lng_f}, #{lat_f}))
        LIMIT 1
      SQL

      results = @db.execute(sql)
      results.first&.fetch("zcta5ce20", nil)
    end

    private

    def optimize_database
      # Increase cache size for better performance (default is 2MB, set to 64MB)
      @db.execute("PRAGMA cache_size = -65536")

      # Use WAL mode for better concurrent access
      @db.execute("PRAGMA journal_mode = WAL") rescue nil

      # Optimize for read-heavy workloads
      @db.execute("PRAGMA temp_store = MEMORY")
      @db.execute("PRAGMA mmap_size = 268435456") # 256MB memory mapping

      # Ensure spatial cache is enabled for better spatial index performance
      @db.execute("SELECT EnableSpatialIndex('geographies', 'geometry')") rescue nil
    end
  end
end