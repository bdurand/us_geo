# frozen_string_literal: true

class UrbanAreasController < ApplicationController
  def index
    urban_areas = USGeo::UrbanArea.not_removed

    @tab = params[:tab]
    if @tab.present?
      type = if @tab == "urbanized"
        "UrbanizedArea"
      elsif @tab == "cluster"
        "UrbanCluster"
      end
      urban_areas = urban_areas.where(type: type)
    end

    @urban_areas = urban_areas.order(:name)
  end

  def show
    @urban_area = USGeo::UrbanArea.find(params[:id])
    add_breadcrumb(urban_area_id: @urban_area)
  end
end
