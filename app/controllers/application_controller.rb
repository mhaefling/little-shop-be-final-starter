class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record
  rescue_from ActiveRecord::RecordNotFound, with: :no_valid_record
  rescue_from ActionController::ActionControllerError, with: :forbidden_actions


  def render_error
    render json: ErrorSerializer.format_invalid_search_response,
        status: :bad_request
  end

  private

  def no_valid_record(exception)
    render json: ErrorSerializer.format_errors([exception.message], '404'), status: :not_found
  end

  def invalid_record(exception)
    render json: ErrorSerializer.format_errors([exception.message], '422' ), status: :unprocessable_entity
  end

  def forbidden_actions(exception)
    render json: ErrorSerializer.forbidden_action([exception.message], '403'), status: :forbidden
  end
end
