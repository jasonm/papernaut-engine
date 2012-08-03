class DiscussionsController < ApplicationController
  respond_to :json

  def index
    respond_with Discussion.identified_by(params['query'])
  end

  def create
    DiscussionLinkJob.work(params['url'])
    head :created
  end
end
