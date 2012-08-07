require 'json'
require 'curb'

class ZoteroXulrunnerIdentifierService
  def initialize(endpoint_url)
    @endpoint_url = endpoint_url
  end

  def identifiers(page_url)
    ZoteroXulrunnerIdentificationRequest.new(@endpoint_url, page_url).identifiers
  end
end

class ZoteroXulrunnerIdentificationRequest
  def initialize(endpoint_url, page_url)
    @endpoint_url = endpoint_url
    @page_url = page_url
  end

  def identifiers
    if success?
      [
        identifier_for('DOI'),
        identifier_for('ISSN'),
        identifier_for('url'),
        extra_identifier_for('PMID'),
        extra_identifier_for('PMCID')
      ].compact
    else
      # TODO: Handle HTTP 300 Multiple Choices:
      #
      # http://ehp03.niehs.nih.gov/article/info%3Adoi%2F10.1289%2Fehp.120-a305
      #
      # gives response from translation server
      #
      # zotero(5)(+0000001): HTTP/1.0 300 Multiple Choices
      # Content-Type: application/json
      # {"10.1289/ehp.120-a305":"Purifying Drinking Water with Sun, Salt, and Limes","10.2166/washdev.2012.043":"Optimizing the solar water disinfection (SODIS) method by decreasing turbidity with NaCl"}


      # TODO: Fixup 501 Method Not Implemented ones like
      # http://www.reddit.com/r/science/comments/xsmc0/alzheimers_protein_could_be_used_to_reverse_the/
      # which links to
      # http://www.sciencenews.org/view/generic/id/342721/title/Alzheimer%E2%80%99s_protein_could_help_in_MS
      # which is identifiable in browser, but not in server :(

      []
    end
  end

  private

  def response
    @response ||= begin
      Curl::Easy.http_post(url, body) do |curl|
        curl.headers["Content-Type"] = "application/json"
      end
    end
  end

  def url
    "#{@endpoint_url}/web"
  end

  def body
    { url: @page_url, sessionid: @page_url }.to_json
  end

  def success?
    (200..299).include?(response.response_code)
  end

  def match
    @match ||= JSON.parse(response.body_str)[0] || {}
  end

  #TODO: canonicalize URL (trailing slash, url params, hash, etc.)
  #TODO: some pages have multiple ISSN (e.g. print vs online http://www.sciencemag.org/content/336/6079/348) -- handle here or in translators lib?
  def identifier_for(kind)
    if match.has_key?(kind)
      Identifier.new(body: "#{kind.upcase}:#{match[kind]}")
    end
  end

  def extra_identifier_for(kind)
    if match.has_key?("extra")
      match["extra"].split("\n").each do |line|
        if line =~ /^#{kind}: (.*)$/
          return Identifier.new(body: "#{kind}:#{$1}")
        end
      end

      nil
    end
  end
end
