class StatsController < ApplicationController
  def index
    render json: {
       indexed_discussions: Discussion.count,
       indexed_pages: Page.count,
       identified_discussions: Discussion.joins(pages: :identifiers).count(distinct: true),
       identified_pages: Page.joins(:identifiers).count(distinct: true),
       distinct_identification_tags: Identifier.count
    }
  end
end
