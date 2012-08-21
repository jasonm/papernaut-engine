class StatsController < ApplicationController
  def index
    render json: {
       discussions_indexed: Discussion.count,
       discussions_identified: Discussion.joins(pages: :identifiers).count(distinct: true),
       article_candidates_indexed: Page.count,
       article_candidates_needing_identification: Page.unidentified.count,
       articles_identified: Page.joins(:identifiers).count(distinct: true),
       distinct_article_identification_tags: Identifier.count
    }
  end
end
