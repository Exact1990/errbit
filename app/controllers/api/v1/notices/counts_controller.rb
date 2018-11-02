class Api::V1::Notices::CountsController < ApplicationController
  respond_to :json, :xml

  def show
    query = {}

    if params.key?(:age_at_most)
      query = query.merge(
        created_at: { '$gte': Time.now.to_i - params[:age_at_most].to_i }
      )
    end

    if params.key?(:api_key)
      app = App.find_by(api_key: params[:api_key])
      query = query.merge(app_id: app.id)
    end

    count = benchmark("[api/v1/notices/count_controller] query time") do
      Notice.where(query).with(consistency: :strong).count
    end

    respond_to do |format|
      format.any(:html, :json) { render json: { count: count} }
      format.xml { render xml: count }
    end
  end
end
