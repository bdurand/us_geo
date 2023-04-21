# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"

  controller :regions do
    get "regions", action: :index, as: :regions
    get "regions/:id", action: :show, as: :region
  end

  controller :divisions do
    get "divisions", action: :index, as: :divisions
    get "divisions/:id", action: :show, as: :division
  end

  controller :states do
    get "states", action: :index, as: :states
    get "states/:id", action: :show, as: :state
  end

  controller :combined_statistical_areas do
    get "csas", action: :index, as: :combined_statistical_areas
    get "csas/:id", action: :show, as: :combined_statistical_area
  end

  controller :core_based_statistical_areas do
    get "core_based_statistical_areas", action: :index, as: :core_based_statistical_areas
    get "core_based_statistical_areas/:id", action: :show, as: :core_based_statistical_area
  end

  controller :metropolitan_divisions do
    get "metropolitan_divisions", action: :index, as: :metropolitan_divisions
    get "metropolitan_divisions/:id", action: :show, as: :metropolitan_division
  end

  controller :urban_areas do
    get "urban_areas", action: :index, as: :urban_areas
    get "urban_areas/:id", action: :show, as: :urban_area
  end

  controller :counties do
    get "counties/:id", action: :show, as: :county
  end

  controller :county_subdivisions do
    get "county_subdivisions/:id", action: :show, as: :county_subdivision
  end

  controller :places do
    get "places/:id", action: :show, as: :place
  end

  controller :zctas do
    get "zctas/:id", action: :show, as: :zcta
  end
end
