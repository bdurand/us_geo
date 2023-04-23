# frozen_string_literal: true

class DivisionsController < ApplicationController
  before_action :set_breadcrumbs

  def index
    @divisions = if @region
      @region.divisions.order(:id)
    else
      USGeo::Division.not_removed.order(:id)
    end
  end

  def show
    @division = USGeo::Division.find(params[:id])
    add_breadcrumb(division_id: @division)
  end

  private

  def set_breadcrumbs
    if params[:region_id]
      @region = USGeo::Region.find(params[:region_id])
      add_breadcrumb(region_id: @region)
    end
  end
end
