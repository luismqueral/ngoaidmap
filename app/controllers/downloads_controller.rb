class DownloadsController < ApplicationController
  before_action :set_format
  def index
    name = params[:name]
    respond_to do |format|
      format.csv {
        if params[:v] && params[:v] == 'full'
          send_data Project.fetch_all(projects_params).includes(:geolocations, :donors, :sectors).to_comma,
            :type        => 'application/vnd.ms-excel',
            :disposition => "attachment; filename=#{name}.csv"
        else
          send_data Project.fetch_all(projects_params).includes(:geolocations, :donors, :sectors).to_comma(:style => :brief),
            :type        => 'application/vnd.ms-excel',
            :disposition => "attachment; filename=#{name}.csv"
        end
      }
      format.xls {
        send_data Project.fetch_all(projects_params).to_xls,
          :type        => 'application/vnd.ms-excel',
          :disposition => "attachment; filename=#{name}.xls"
      }
      format.kml {
        @locations = Project.fetch_all(projects_params).pluck('geolocations.name', 'geolocations.longitude', 'geolocations.latitude')
        stream = render_to_string(:template => "downloads/index" )
        send_data stream,
          :type        => 'application/vnd.google-earth.kml+xml',
          :disposition => "attachment; filename=#{name}.kml"
      }
    end
  end
  def set_format
     request.format = 'csv' if params[:doc]=='csv'
     request.format = 'xls' if params[:doc]=='xls'
     request.format = 'kml' if params[:doc]=='kml'
  end
  private
  def projects_params
    params.permit(:level, :ids, :id, :geolocation, :status, :q, :starting_after, :ending_before, :site, organizations:[], countries:[], donors:[], sectors:[], projects:[])
  end
end
