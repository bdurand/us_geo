# frozen_string_literal: true

class PlacesController < ApplicationController
  before_action :set_breadcrumbs

  def show
    @place = USGeo::Place.find(params[:id])
    add_breadcrumb(place_id: @place)
  end

  private

  def set_breadcrumbs
    add_region_breadcrumb
    add_division_breadcrumb
    add_state_breadcrumb
    add_county_breadcrumb
    add_combined_statistical_area_breadcrumb
    add_core_based_statistical_area_breadcrumb
    add_metropolitan_division_breadcrumb
  end
end
