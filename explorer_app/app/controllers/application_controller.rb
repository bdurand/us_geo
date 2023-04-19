# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def add_breadcrumb(breadcrumbs)
    @breadcrumbs ||= HashWithIndifferentAccess.new
    @breadcrumbs.merge!(breadcrumbs)
  end

  def add_region_breadcrumb
    if params[:region_id]
      @region = USGeo::Region.find(params[:region_id])
      add_breadcrumb(region_id: @region)
    end
  end

  def add_division_breadcrumb
    if params[:division_id]
      @division = USGeo::Division.find(params[:division_id])
      add_breadcrumb(division_id: @division)
    end
  end

  def add_state_breadcrumb
    if params[:state_id]
      @state = USGeo::State.find(params[:state_id])
      add_breadcrumb(state_id: @state)
    end
  end

  def add_county_breadcrumb
    if params[:county_id]
      @county = USGeo::County.find(params[:county_id])
      add_breadcrumb(county_id: @county)
    end
  end

  def add_core_based_statistical_area_breadcrumb
    if params[:core_based_statistical_area_id]
      @core_based_statistical_area = USGeo::CoreBasedStatisticalArea.find(params[:core_based_statistical_area_id])
      add_breadcrumb(core_based_statistical_area_id: @core_based_statistical_area)
    end
  end

  def add_combined_statistical_area_breadcrumb
    if params[:combined_statistical_area_id]
      @combined_statistical_area = USGeo::CombinedStatisticalArea.find(params[:combined_statistical_area_id])
      add_breadcrumb(combined_statistical_area_id: @combined_statistical_area)
    end
  end

  def add_metropolitan_division_breadcrumb
    if params[:metropolitan_division_id]
      @metropolitan_division = USGeo::MetropolitanDivision.find(params[:metropolitan_division_id])
      add_breadcrumb(metropolitan_division_id: @metropolitan_division)
    end
  end

  def add_designated_market_area_breadcrumb
    if params[:designated_market_area_id]
      @designated_market_area = USGeo::DesignatedMarketArea.find(params[:designated_market_area_id])
      add_breadcrumb(designated_market_area_id: @designated_market_area)
    end
  end
end
