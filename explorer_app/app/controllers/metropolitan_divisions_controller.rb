# frozen_string_literal: true

class MetropolitanDivisionsController < ApplicationController
  before_action :set_breadcrumbs

  def index
    @metropolitan_divisions = if @combined_statistical_area
      @combined_statistical_area.metropolitan_divisions.order(:name)
    elsif @core_based_statistical_area
      @core_based_statistical_area.metropolitan_divisions.order(:name)
    else
      USGeo::MetropolitanDivision.not_removed.order(:name)
    end
  end

  def show
    @metropolitan_division = USGeo::MetropolitanDivision.find(params[:id])
    add_breadcrumb(metropolitan_division_id: @metropolitan_division)
  end

  private

  def set_breadcrumbs
    add_combined_statistical_area_breadcrumb
    add_core_based_statistical_area_breadcrumb
  end
end
