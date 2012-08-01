class Discussion < ActiveRecord::Base
  belongs_to :content_page, class_name: "Page"
  # Eventually, Discussion has kind (blog/hn/reddit/nyt/etc), #/comments, author, activity, etc.

  def link
    spider
    identify_linked_pages
  end

  def identifier_strings
    content_page.identifiers.map(&:body)
  end

  def content_url
    content_page.url
  end

  private

  def spider
    #TODO: depth=1
    Spider.new(content_page, 0).spider
  end

  def identify_linked_pages
    content_page.page_tree.each(&:identify)
  end
end

#TODO: test
class Spider
  def initialize(page, depth = 1)
    @page = page
    @depth = depth
  end

  def spider
    if @depth > 0
      hyperlinks.each do |hyperlink|
        child = Page.create(url: hyperlink)
        link = Link.create(parent_page: @page, child_page: child)
        Spider.new(child, depth-1).spider
      end
    end
  end

  #TODO: refactor, this seems like it belongs inside Page.  Maybe the whole Spider logic does.
  def hyperlinks
    html = open(@page.url).read
    doc = Nokogiri::HTML.new(html)
    doc.css('a').map { |node| node['href'] }.compact
  end
end
