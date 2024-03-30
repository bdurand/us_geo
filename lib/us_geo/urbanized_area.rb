# frozen_string_literal: true

module USGeo
  # Urban area with population >= 50,000.
  #
  # @deprecated This class will be removed in version 3.0 and only UrbanArea will be used.
  class UrbanizedArea < UrbanArea
    def urbanized?
      true
    end

    def cluster?
      false
    end
  end
end
