# Sometimes loaders incorrectly loaded page titles.
require 'curb'
require 'nokogiri'
require 'benchmark'

module Util
  class Titler
    def self.process_in_batches(batch_size = 20)
      loop do
        urls = nil
        mappings = nil

        b = Benchmark.measure do
          urls = self.untitled_discussion_urls(batch_size)
          mappings = self.titles_for(urls)
          self.update_titles(mappings)
        end

        return if urls.empty?
        puts "Updated #{mappings.count}/#{urls.count} in #{b.real} seconds"
      end
    end

    def self.untitled_discussion_urls(limit = nil)
      Discussion.where('url = title').order('random()').limit(limit).select(:url).map(&:url)
    end

    def self.titles_for(urls)
      results = {}

      easy_options = {
        :follow_location => true,
        :max_redirects => 3,
        :connect_timeout => 5,
        :timeout => 5
      }

      multi_options = {
        :pipeline => true
      }

      begin
        Curl::Multi.get(urls, easy_options, multi_options) do |c|
          begin
            title = Nokogiri::HTML.parse(c.body_str).css('title')[0].text
            results[c.url] = title
          rescue
            puts "No <title> for #{url}"
          end
        end
      rescue Curl::Err::TimeoutError => e
        puts "Timed out on #{url}"
      end

      results
    end

    def self.update_titles(mappings)
      mappings.each do |url, title|
        Discussion.find_by_url(url).update_attribute(:title, title)
      end
    end
  end
end
