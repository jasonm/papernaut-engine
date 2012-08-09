class DiscussionsController < ApplicationController
  respond_to :json

  def index
    respond_with Discussion.identified_by(params['query'])
  end
end
