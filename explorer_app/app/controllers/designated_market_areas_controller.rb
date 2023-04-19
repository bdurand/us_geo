# frozen_string_literal: true

class DesignatedMarketAreasController < ApplicationController
  def index
    @designated_market_areas = USGeo::DesignatedMarketArea.not_removed.order(:name)
  end

  def show
    @designated_market_area = USGeo::DesignatedMarketArea.find(params[:id])
    add_breadcrumb(designated_market_area_id: @designated_market_area)
  end
end
