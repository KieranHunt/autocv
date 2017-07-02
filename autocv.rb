#! /usr/bin/env ruby
require 'uri'
require 'json'
require 'net/http'
require 'erb'
require 'fileutils'

QUERIES = {
    name: 'my name is',
    address: 'i live',
    phone: 'my phone',
    email: 'my email is',
    date_of_birth: 'i was born',
    marital_status: 'i am married to',
    nationality: 'my country is',
    languages: 'my language is',
    sex: 'i identify as',
    profile_1: 'i am good at',
    profile_2: 'but i can',
    core_competencies: 'i believe that',
    professional_experience_1: 'i once',
    professional_experience_2: 'but i am',
    professional_qualifications_1: 'i am trained',
    professional_qualifications_2: 'and i can',
    please_hire_1: 'i need',
    please_hire_2: 'so i can purchase',
    thanks: 'thank you for your'
}

SEARCH_PREFIX = 'http://suggestqueries.google.com/complete/search?client=firefox&q='

TEMPLATE_FILE = 'cv.html.erb'
OUTPUT_FILE = 'build/cv.html'

def pick_suggestion(query, suggestions)
    loop do
        suggestion = suggestions.sample
        next if suggestion.eql? query
        return suggestion
    end
end

cv = QUERIES.map do |key, query|
    uri = URI.parse(SEARCH_PREFIX + URI.escape(query))
    suggestions = JSON.load(Net::HTTP.get_response(uri).body)[1]
    { key => pick_suggestion(query, suggestions) }
end.reduce Hash.new, :merge


FileUtils.mkdir_p File.dirname(OUTPUT_FILE)
File.open(OUTPUT_FILE, 'w') do |file|
    file.write(ERB.new(File.read(TEMPLATE_FILE)).result(binding))
end
