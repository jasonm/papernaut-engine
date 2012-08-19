require 'threadpool'

class ParallelIdentifier
  def initialize(pages = Page.unidentified)
    @pages = pages
  end

  def run
    @pages.each do |page|
      in_thread do
        page.identify
      end
    end
  end

  private

  def in_thread(&blk)
    thread_pool.process(&blk)
  end

  def thread_pool
    @thread_pool ||= ThreadPool.new(db_pool_size)
  end

  def db_pool_size
    ActiveRecord::Base.configurations[Rails.env]["pool"]
  end
end
