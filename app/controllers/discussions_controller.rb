class DiscussionsController < ApplicationController
  def create
    DiscussionLinkJob.work(params['url'])
    head :created
  end
end
