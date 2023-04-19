# frozen_string_literal: true

class StatesController < ApplicationController
  before_action :set_breadcrumbs

  def index
    @states = if @division
      @division.states.order(:name)
    else
      USGeo::State.not_removed.order(:name)
    end
  end

  def show
    @state = USGeo::State.find(params[:id])
    add_breadcrumb(state_id: @state)
  end

  private

  def set_breadcrumbs
    add_region_breadcrumb
    add_division_breadcrumb
  end
end
