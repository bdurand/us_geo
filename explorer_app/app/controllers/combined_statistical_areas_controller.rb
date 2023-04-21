# frozen_string_literal: true

class CombinedStatisticalAreasController < ApplicationController
  def index
    @combined_statistical_areas = USGeo::CombinedStatisticalArea.not_removed.order(:name)
  end

  def show
    @combined_statistical_area = USGeo::CombinedStatisticalArea.find(params[:id])
    add_breadcrumb(combined_statistical_area_id: @combined_statistical_area)
  end
end
