# frozen_string_literal: true

module USGeo

  # Urban area with population < 50,000.
  class UrbanCluster < UrbanArea
    
    def urbanized?
      false
    end
    
    def cluster?
      true
    end
    
  end

end
