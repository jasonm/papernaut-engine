class DiscussionsController < ApplicationController
  respond_to :json

  def index
    discussions = Discussion.identified_by(params['query'])
    respond_with(present(discussions))
  end

  private

  def present(discussions)
    discussions.map { |discussion|
      discussion.as_json(methods: %w(identifier_strings))
    }
  end
end
