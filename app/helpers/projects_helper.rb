module ProjectsHelper

  String.class_eval do
    def indefinitize
      %w(a e i o u).include?(downcase.first) ? "an #{self}" : "a #{self}"
    end
  end

  def old_subtitle(project, site)
    clusters_sectors = if site.navigate_by_sector?
      sectors_to_sentence(project)
    else
      clusters_to_sentence(project)
    end
    place        = project_regions_and_countries(project)
    organization = "by #{link_to project['organization_name'], organization_path(project['organization_id'])}"

    case controller_name
    when 'sites'
      raw("#{clusters_sectors} #{place} #{organization}")
    when 'organizations'
      raw("#{clusters_sectors} #{place}")
    when 'clusters_sectors'
      raw("#{place} #{organization}")
    when 'georegion'
      raw("#{clusters_sectors} #{organization}")
    when 'donors'
      raw("#{clusters_sectors} #{place} #{organization}")
    end
  end

  def subtitle(project, site)
    clusters_sectors = sectors_to_sentence(project)
    place        = project_regions_and_countries(project)
    organization = "by #{link_to project.primary_organization.name, organization_path(project.primary_organization.id)}"

    case controller_name
    when 'sites'
      raw("#{clusters_sectors} #{place} #{organization}")
    when 'organizations'
      raw("#{clusters_sectors} #{place}")
    when 'clusters_sectors'
      raw("#{place} #{organization}")
    when 'georegion'
      raw("#{clusters_sectors} #{organization}")
    when 'donors'
      raw("#{clusters_sectors} #{place} #{organization}")
    else
      raw("#{clusters_sectors} #{place} #{organization}")
    end
  end

  def subtitle_donors_page(project, site, donor_lnk)
    clusters_sectors = if site.navigate_by_sector?
      sectors_to_sentence(project)
    else
      clusters_to_sentence(project)
    end
    place        = project_regions_and_countries(project)
    #organization = "by #{link_to project['organization_name'], organization_path(project['organization_id'])}"
    organization = "by #{ link_to project['organization_name'],  donor_lnk.html_safe}"

    case controller_name
    when 'sites'
      raw("#{clusters_sectors} #{place} #{organization}")
    when 'organizations'
      raw("#{clusters_sectors} #{place}")
    when 'clusters_sectors'
      raw("#{place} #{organization}")
    when 'georegion'
      raw("#{clusters_sectors} #{organization}")
    when 'donors'
      raw("#{clusters_sectors} #{place} #{organization}")
    end
  end

  def clusters_to_sentence(project)
    return "" if project['clusters'].nil? || project['cluster_ids'].nil?
    clusters = project['clusters'].split('|').reject{|c| c.blank?}
    clusters_ids = project['cluster_ids'].delete('{}').split(',')
    if clusters.size == 1
      "A #{link_to clusters.first.indefinitize.capitalize, cluster_path(clusters_ids.first), :title => clusters.first} project"
    else
      "A project from #{pluralize(clusters.size, 'different clusters')}"
    end
  end

  def sectors_to_sentence(project)
    return "" if project.sectors.nil?
    sectors = project.sectors.uniq.map{|s| s.name}
    sectors_ids = project.sectors.uniq.map{|s| s.id}
    if sectors.size == 1
      " #{if project.geographical_scope == 'global' then  'global' end}  #{link_to sectors.first.indefinitize.capitalize, sector_path(sectors_ids.first), :title => sectors.first} project"
    else
      "A #{if project.geographical_scope == 'global' then  'global' end} project from #{pluralize(sectors.size, 'different sectors')}"
    end
  end

  def metainformation(project, site)
    result = ""
    clusters_sectors = []
    if site.navigate_by_sector? && project['sectors'].present?
      project['sectors'].split('|').delete_if{ |e| e.blank? }.each_with_index do |sector_name, i|
        next if sector_name.blank?
        clusters_sectors << link_to(sector_name, sector_path(project['sector_ids'].delete('{}').split(',')[i]))
      end
    elsif site.navigate_by_cluster? && project['clusters'].present?
      project['clusters'].split('|').delete_if{ |e| e.blank? }.each_with_index do |cluster_name, i|
        next if sector_name.blank?
        clusters_sectors << link_to(cluster_name, cluster_path(project['cluster_ids'].delete('{}').split(',')[i]))
      end
    end
    unless clusters_sectors.empty?
      result << " on #{clusters_sectors.to_sentence}"
    end
    result << " by #{link_to(project['organization_name'], organization_path(project['organization_id']))}"
    raw(result)
  end

  def project_regions_and_countries(project)
    if @site.navigate_by_country?
      return if project.countries.nil?
      countries     = project.countries.map{|c| c.name}
      countries_ids =  project.countries.map{|c| c.uid}
      if project.geographical_scope == 'global'
        ""
      elsif countries.size == 1
        "in #{link_to(countries.first, location_path(:ids => [countries_ids.first]), :title => countries.first)}"
      else
        "in #{pluralize(countries.size, 'country', 'countries')}"
      end
    else
      return if project.geolocations.where('adm_level > 0').size == 0
      regions     = project.geolocations.pluck(:name).split('|').reject{|r| r.blank?}.flatten
      regions_ids = project.geolocations.pluck(:uid).split(',').flatten

      if regions.size == 1
        "in #{link_to(regions.first, "/location/#{regions_ids.first}", :title => regions.first)}"
      else
        "in #{pluralize(regions.size, 'place')}"
      end
    end
  end

  def region_breadcrumb(region)
    if region.is_a?(Country)
      return region.name
    end
    result = [region.country.name]
    if region.level == 1
    elsif region.level == 2
      result << Region.find(region.parent_region_id, :select => "id, name, parent_region_id").name
    elsif region.level == 3
      parent = Region.find(region.parent_region_id, :select => "id, name, parent_region_id")
      result << Region.find(parent.parent_region_id, :select => "id, name, parent_region_id").name
      result << parent.name
    end
    result = (result + [region.name]).join(' > ')
    if result.size > 30
      list = result.split(' > ')
      return ([list.first] + ['...'] + [list[-2..-1]]).join(' > ')
    else
      return result
    end
  end

end
