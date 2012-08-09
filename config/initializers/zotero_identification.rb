zotero_url = ENV['ZOTERO_TRANSLATION_SERVER_URL'] || 'localhost:1969'
Page.identifier_service = ZoteroXulrunnerIdentifierService.new(zotero_url, Rails.logger)
