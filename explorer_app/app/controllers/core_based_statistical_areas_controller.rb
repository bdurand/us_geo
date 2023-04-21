# frozen_string_literal: true

class CoreBasedStatisticalAreasController < ApplicationController
  before_action :set_breadcrumbs

  def index
    cbsas = if @combined_statistical_area
      @combined_statistical_area.core_based_statistical_areas.order(:name)
    else
      USGeo::CoreBasedStatisticalArea.not_removed.order(:name)
    end

    @tab = params[:tab]
    if @tab.present?
      type = if @tab == "metropolitan"
        "MetropolitanArea"
      elsif @tab == "micropolitan"
        "MicropolitanArea"
      end
      cbsas = cbsas.where(type: type)
    end

    @core_based_statistical_areas = cbsas.order(:name)
  end

  def show
    @core_based_statistical_area = USGeo::CoreBasedStatisticalArea.find(params[:id])
    add_breadcrumb(core_based_statistical_area_id: @core_based_statistical_area)
  end

  private

  def set_breadcrumbs
    add_combined_statistical_area_breadcrumb
  end
end
