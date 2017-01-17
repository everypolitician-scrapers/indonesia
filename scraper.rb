# frozen_string_literal: true
# #!/bin/env ruby
# encoding: utf-8

require 'scraped'
require 'scraperwiki'
require 'nokogiri'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :members do
    noko.css('#data-anggota tbody tr').map do |tr|
      fragment tr => MemberRow
    end
  end
end

class MemberRow < Scraped::HTML
  field :id do
    tds[1].css('a/@href').to_s.split('/').last
  end

  field :name do
    tds[2].css('a').text
  end

  field :faction do
    details[1]
  end

  field :area do
    details[2]
  end

  field :image do
    tds[1].css('img/@src').text
  end

  field :term do
    18
  end

  field :source do
    url
  end

  private

  def tds
    noko.css('td')
  end

  def details
    tds[2].inner_html.split('<br>')
  end
end

url = 'http://dpr.go.id/en/anggota'
data = MembersPage.new(response: Scraped::Request.new(url: url).response).members.map(&:to_h)
# puts data

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
ScraperWiki.save_sqlite([:id], data)
