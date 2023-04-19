# frozen_string_literal: true

class ZctasController < ApplicationController
  before_action :set_breadcrumbs

  def show
    @zcta = USGeo::Zcta.find(params[:id])
    add_breadcrumb(zcta_id: @zcta)
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
