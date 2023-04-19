# frozen_string_literal: true

class CountySubdivisionsController < ApplicationController
  before_action :set_breadcrumbs

  def show
    @county_subdivision = USGeo::CountySubdivision.find(params[:id])
    add_breadcrumb(county_subdivision_id: @county_subdivision)
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
    add_designated_market_area_breadcrumb
  end
end
