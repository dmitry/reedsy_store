module Api
  class BaseController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
    rescue_from ActiveRecord::RecordInvalid, ActiveModel::ValidationError, with: :unprocessable_entity_response

    private

    def not_found_response(exception)
      render json: { error: exception.message },
             status: :not_found
    end

    def unprocessable_entity_response(exception)
      record = exception.is_a?(ActiveRecord::RecordInvalid) ? exception.record : exception.model
      render json: { errors: record.errors.as_json },
             status: :unprocessable_entity
    end
  end
end
