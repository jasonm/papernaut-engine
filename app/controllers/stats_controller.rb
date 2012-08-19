class StatsController < ApplicationController
  def index
    render json: {
       identified_discussions: Discussion.joins(pages: :identifiers).count(distinct: true),
       identified_pages: Page.joins(:identifiers).count(distinct: true)
    }
  end
end
