class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: ErrorSerializer.format_errors([e.message], '422' ), status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: ErrorSerializer.format_errors([e.message], '404'), status: :not_found
  end

  rescue_from ActionController::ActionControllerError do |e|
    render json: ErrorSerializer.forbidden_action([e.message], '403'), status: :forbidden
  end

  def render_error
    render json: ErrorSerializer.format_invalid_search_response,
        status: :bad_request
  end
end
