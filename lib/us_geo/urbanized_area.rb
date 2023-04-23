# frozen_string_literal: true

module USGeo
  # Urban area with population >= 50,000.
  class UrbanizedArea < UrbanArea
    def urbanized?
      true
    end

    def cluster?
      false
    end
  end
end
