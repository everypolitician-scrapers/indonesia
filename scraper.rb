# #!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'scraped_page_archive/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('#data-anggota tbody tr').each do |tr|
    tds = tr.css('td')
    details = tds[2].inner_html.split('<br>')
    img = URI.join(url, tds[1].css('img/@src').to_s).to_s
    id = tds[1].css('a/@href').to_s.split('/').last
    data = {
      id: id,
      name: tds[2].css('a').text,
      faction: details[1],
      area: details[2],
      image: img,
      term: 18,
      source: url
    }
    ScraperWiki.save_sqlite([:id], data)
  end
end

scrape_list('http://dpr.go.id/en/anggota')

terms = [
  {
    id: 18,
    start_date: '2014-10-01',
    name: 'The Indonesian House - 11th General Election',
    source: 'http://dpr.go.id/en/tentang/sejarah-dpr'
  }
]

ScraperWiki.save_sqlite([:id], terms, 'terms')
