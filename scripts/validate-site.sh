#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ruby -rjson -rpathname <<'RUBY'
html_files = Dir['docs/**/*.html'].sort
raise "expected 12 HTML pages, found #{html_files.length}" unless html_files.length == 12

failures = []

html_files.each do |file|
  content = File.read(file, encoding: 'UTF-8')

  %w[<!doctype\ html> <html\ lang="zh-CN"> <title> </main> </html>].each do |needle|
    failures << "#{file}: missing #{needle}" unless content.include?(needle)
  end
  failures << "#{file}: missing main landmark" unless content.match?(/<main\b[^>]*\bid="main"/)

  unless file.end_with?('404.html')
    %w[meta\ name="description" link\ rel="canonical"].each do |needle|
      failures << "#{file}: missing #{needle}" unless content.include?(needle)
    end
  end

  content.scan(/<(?:a|link|img)[^>]+(?:href|src)="([^"]+)"/i).flatten.each do |ref|
    next if ref.match?(%r{\A(?:https?:|mailto:|tel:|data:|#|//)})
    path = ref.split(/[?#]/, 2).first
    target = Pathname.new(File.join(File.dirname(file), path)).cleanpath
    target = target.join('index.html') if target.directory?
    failures << "#{file}: missing local target #{ref}" unless target.exist?
  end

  content.scan(/<script\s+type="application\/ld\+json">(.*?)<\/script>/m).flatten.each do |json|
    begin
      JSON.parse(json)
    rescue JSON::ParserError => error
      failures << "#{file}: invalid JSON-LD (#{error.message})"
    end
  end
end

abort failures.join("\n") unless failures.empty?
puts "HTML, metadata, local links, and JSON-LD are valid for #{html_files.length} pages."
RUBY

xmllint --noout docs/sitemap.xml
printf 'sitemap.xml is valid XML.\n'
