Papernaut Engine
================

This is the matching engine for <http://www.papernautapp.com>.

Overview
--------

This engine consists of two main parts: the Loaders, and the query API.

The loaders may be invoked while the query API is down, and the query API may
be running without invoking the loaders.

The loaders load webpages via feeds and archives, extract references to
academic papers, and store those webpage-to-paper citations in the database.
When parsing a page, a loader determines which outbound links point to academic
papers by issuing calls to a Zotero translation-server.

The query API is an HTTP API for querying these citations by identifier (such
as DOI, PubMed ID, or arXiv ID), so that someone who reads papers can query to
find online discussions of those papers.  The primary consumer of the API is
the papernaut-frontend web application.

The loaders depend on a running instance of the Zotero translation-server, a
third-party open-source project.  It must be available when running the
loaders, but is not necessary for running the query API.

Getting Started
---------------

1.  Get the translator-server project built and running: <https://github.com/zotero/translation-server>

2.  Install gems:

        bundle install

3.  Create and migrate the databases.  PostgreSQL is used by default.

        rake db:create db:migrate db:test:prepare

4.  If the translation-server is running somewhere other than
    <http://localhost:1969>, configure `ENV['ZOTERO_TRANSLATION_SERVER_URL']`
    with the base URL.

5. Run the test suite to ensure things work on your system:

        rake

6. Start the application with [foreman](https://rubygems.org/gems/foreman).
   By default, the papernaut-frontend application expects papernaut-engine
   to be running on <http://localhost:3001>, so set your `PORT` in `.env`:

        echo "PORT=3001" > .env
        foreman start


Loading content
---------------

Content is loaded into the database in two steps: discussion loading and page
identification.

In the first step, a `Loader` in run to scrape a content feed, such as a blog
archive or an RSS feed.  For each element in the feed, a `Discussion` is
created, corresponding to the original piece of content in the feed.  Each
`Discussion` links to one or more `Page` object, corresponding to the outgoing
links from the discussion page.  These are typically a subset of the webpage
links; for example, on a social news feed like Reddit, there will be a single
linked `Page`, the subject of discussion.  Other feed types (like blog
articles) will have a corresponding `Page` for each outbound link in the
content area, eschewing sidebar and navigation links.

See `lib/loaders/**/*.rb` for the loader code.  Each file should contain
an example of how to run it.  For example, to load the first 5 pages
of <http://reddit.com/r/science> with 20 items per page:

```ruby
Loaders::RedditRssLoader.new('science', 5, 20).load
```

In the second step, the collected pages are identified.  Here they are
submitted to the zotero-translator instance which must be running at the time
of identification.

This can be executed from the console as:

```ruby
Page.unidentified.last.identify
```

or may be run in parallel (see `lib/parallel_identifier.rb`) or as a background
job.

Deploying to production
-----------------------

See `DEPLOY.md` for information about deploying.
