# frozen_string_literal: true

module USGeo
  # Core based statistical area with a population greater then 10,000 but less than 50,000.
  class MicropolitanArea < CoreBasedStatisticalArea
    def metropolitan?
      false
    end

    def micropolitan?
      true
    end
  end
end
