# frozen_string_literal: true

class UrbanAreasController < ApplicationController
  def index
    urban_areas = USGeo::UrbanArea.not_removed

    @tab = params[:tab]
    if @tab == "urbanized"
      urban_areas = urban_areas.where(population: 50_000..)
    elsif @tab == "cluster"
      urban_areas = urban_areas.where(population: ...50_000)
    end

    @urban_areas = urban_areas.order(:name)
  end

  def show
    @urban_area = USGeo::UrbanArea.find(params[:id])
    add_breadcrumb(urban_area_id: @urban_area)
  end
end
