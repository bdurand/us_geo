# frozen_string_literal: true

class RegionsController < ApplicationController
  def index
    @regions = USGeo::Region.not_removed.order(:id)
    @territories = USGeo::State.not_removed.where(division: nil)
  end

  def show
    @region = USGeo::Region.find(params[:id])
    @divisions = @region.divisions.order(:id)
    add_breadcrumb(region_id: @region)
  end
end
