module ApplicationHelper
  def formatted_number(number, round: nil)
    if number
      number = (round ? number.round(round) : auto_round(number))
      number_with_delimiter(number)
    else
      "-"
    end
  end

  def google_maps_link(location)
    if location.lat && location.lng
      url = "https://www.google.com/maps/place/#{location.lat},#{location.lng}"
      link_to("#{location.lat}, #{location.lng}", url, target: "_blank")
    else
      "n/a"
    end
  end

  def demographics_headers
    render "shared/demographics_headers"
  end

  def demographics_cells(entity, round_area: nil)
    render "shared/demographics_cells", entity: entity, round_area: round_area
  end

  def population_density(entity)
    density = entity.population_density
    return nil unless density

    round = if density < 1
      3
    elsif density < 10
      2
    elsif density < 100
      1
    else
      0
    end

    "#{formatted_number(density, round: round)} / mi²"
  end

  def auto_round(number)
    return number unless number.is_a?(Float)

    decimals = if number < 1
      3
    elsif number < 10
      2
    elsif number < 100
      1
    else
      0
    end

    number.round(decimals)
  end

  def breadcrumb_params(additional_params = {})
    if @breadcrumbs
      @breadcrumbs.merge(additional_params)
    else
      additional_params
    end
  end

  def breadcrumbs(active_label, active: nil)
    render "shared/breadcrumbs", links: breadcrumb_links(active), active_label: active_label
  end

  def breadcrumb_links(active = nil)
    return {} if @breadcrumbs.blank?

    objects = @breadcrumbs.values
    region = objects.detect { |b| b.is_a?(USGeo::Region) }
    division = objects.detect { |b| b.is_a?(USGeo::Division) }
    state = objects.detect { |b| b.is_a?(USGeo::State) }
    combined_statistical_area = objects.detect { |b| b.is_a?(USGeo::CombinedStatisticalArea) }
    core_based_statistical_area = objects.detect { |b| b.is_a?(USGeo::CoreBasedStatisticalArea) }
    metropolitan_division = objects.detect { |b| b.is_a?(USGeo::MetropolitanDivision) }
    designated_market_area = objects.detect { |b| b.is_a?(USGeo::DesignatedMarketArea) }
    county = objects.detect { |b| b.is_a?(USGeo::County) }
    county_subdivision = objects.detect { |b| b.is_a?(USGeo::CountySubdivision) }
    place = objects.detect { |b| b.is_a?(USGeo::Place) }
    zcta = objects.detect { |b| b.is_a?(USGeo::Zcta) }

    links = {}

    if region
      links["Regions"] = regions_path
    elsif division&.persisted?
      links["Divisions"] = divisions_path
    elsif state
      links["States"] = states_path
    elsif combined_statistical_area
      links["Combined Statistical Areas"] = combined_statistical_areas_path
    elsif core_based_statistical_area
      links["Core Based Statistical Areas"] = core_based_statistical_areas_path
    elsif designated_market_area
      links["Designated Market Areas"] = designated_market_areas_path
    end

    links[region.name] = region_path(region) if breadcrumb_link?(region, active)
    links[division.name] = division_path(division) if breadcrumb_link?(division, active)
    links[state.name] = state_path(state) if breadcrumb_link?(state, active)
    links[combined_statistical_area.name] = combined_statistical_area_path(combined_statistical_area) if breadcrumb_link?(combined_statistical_area, active)
    links[core_based_statistical_area.name] = core_based_statistical_area_path(core_based_statistical_area) if breadcrumb_link?(core_based_statistical_area, active)
    links[metropolitan_division.name] = metropolitan_division_path(metropolitan_division) if breadcrumb_link?(metropolitan_division, active)
    links[designated_market_area.name] = designated_market_area_path(designated_market_area) if breadcrumb_link?(designated_market_area, active)

    links[county.name] = county_path(county) if breadcrumb_link?(county, active)
    links[county_subdivision.name] = county_subdivision_path(county_subdivision) if breadcrumb_link?(county_subdivision, active)
    links[place.name] = place_path(place) if breadcrumb_link?(place, active)
    links[zcta.name] = zcta_path(zcta) if breadcrumb_link?(zcta, active)

    links
  end

  private

  def breadcrumb_link?(object, active)
    object&.persisted? && object != active
  end
end
