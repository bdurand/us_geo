# frozen_string_literal: true

module USGeo

  # Core based statistical area with a population greater then 50,000.
  class MetropolitanArea < CoreBasedStatisticalArea
    
    def metropolitan?
      true
    end
    
    def micropolitan?
      false
    end
    
  end
  
end
