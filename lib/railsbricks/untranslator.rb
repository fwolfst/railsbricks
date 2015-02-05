# It seems like an odd idea, but probably easiest way to opt out
# i18n (also odd idea ;) ).

class Untranslator
  attr_accessor :translations
  def initialize translations={}
    @translations = translations
    STDERR.puts @translations.inspect
  end

  # In-place editing of files lets you run into problems when out of
  # disk space.  We hope that never happens
  # TODO work with temporary files
  def process_in_place file
    file_content = File.read file
    # TODO also capture linkt_to t('...') style translations
    new_file_content = file_content.gsub(/<%= t\('([a-zA-Z0-9.-_]*)'\) %>/) do |match|
      translate Regexp.last_match[1]
    end
    File.open file, 'w' do |f|
      f.puts new_file_content
    end
  end

  private

  # Find translation by recursing into tree
  def translate token, translations = @translations
    head, tail = token.split(".")
    return "TRANSLATTION NOT FOUND (empty tree)" if translations.nil?
    match = translations[head]
    return match if(match.instance_of? String || match.nil?)
    return "TRANSLATION MISSING" if tail.nil?
    return translate tail, match
  end
end
