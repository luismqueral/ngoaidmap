module Api
  module V1
    class SectorsController < ApiController
      def index
        if params[:include].present? && params[:include] == 'projects_count'
          @sectors = Sector.counting_projects(sector_params)
          #@sectors_hash = normalize_projects @sectors
          render json: @sectors, root: 'data',
          meta: { total: @sectors.size },
          each_serializer: SectorWithProjectsCountSerializer
        else
          @sectors = Sector.fetch_all(sector_params).order(:name)
          render json: @sectors, root: 'data',
          meta: { total: @sectors.size },
          each_serializer: SectorPreviewSerializer
        end
      end
      def show
        @caller = "sectors"
        if params[:only].present? && params[:only] == 'donors'
          sector = Sector.find(params[:id])
          donors_array = sector.donors
          @donors = normalize_donors donors_array
          render json: @donors, root: 'data',
          meta: { total: @donors.size },
          each_serializer: DonorFromSectorSerializer
        else
        @sector = Sector.eager_load([:projects]).find(params[:id])
          render json: @sector, root: 'data'
        end
      end
      def sector_params
        params.permit(:status)
      end

      private
      def normalize_projects(h)
        normalized = []
        h.each do |k,v|
          normalized.push(({id: k[0], name: k[1], projects_count: v}))
        end
        normalized
      end
      def normalize_donors(a)
        normalized = []
        a.each do |d|
          normalized.push({id: d[0], name: d[1]})
        end
        normalized
      end
    end
  end
end