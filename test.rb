require 'ap'

module USDA
  require 'uri'
  require 'net/http'
  require 'json'

  class API
    attr_accessor :base_uri

    API_KEY = { api_key: "DEMO_KEY" }

    def initialize(base_uri = "http://api.data.gov/USDA/ERS/data/")
      @base_uri = base_uri
    end

    def response(endpoint, params = {})
      uri = build_uri(endpoint, params)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end

    def build_uri(endpoint, params)
      params.merge!(API_KEY)
      uri = URI(@base_uri + endpoint)
      uri.query = URI.encode_www_form(params)
      uri
    end
  end

  class ARMS
    def self.surveys
      api = API.new
      api.response("Arms/Surveys")
    end

    def self.reports(survey)
      api = API.new
      api.response("Arms/Reports", survey: survey)
    end

    def self.subjects(survey, report)
      api = API.new
      api.response("Arms/Subjects", survey: survey, report: report)
    end

    def self.series(survey, report)
      api = API.new
      api.response("Arms/Series", survey: survey, report: report)
    end

    def self.crops(report, series, options = {})
      options_hash = { report: report, series1: series }.merge options
      api = API.new
      api.response("Arms/Crop", options_hash)
    end
  end

  class Selector
    def self.select_from_results(selectors = {}, results)
      selected = results["dataTable"]
      selectors.each do |selector, value|
        selected = selected.select { |e| e[selector] == value }
      end
      selected
    end
  end

  class DataSeries
    def self.data_by_year(topic_seq, subject_num, element2_name, results)
      selected = Selector.select_from_results({ "topic_seq" => topic_seq, "subject_num" => subject_num, "element2_name" => element2_name }, results)
      selected.map { |n| { n["stat_year"] => n["estimate"] } }
    end
  end
end
  
results = USDA::ARMS.crops(1, "FARM", { fipsStateCode: "27" })
selected = USDA::Selector.select_from_results({ "topic_header" => "Planted acres"}, results)
ap selected.map { |e| e["estimate"] }
# ap USDA::ARMS.crops(1, "FARM", { fipsStateCode: "27" })
# ap USDA::ARMS.reports("CROP")
# ap USDA::ARMS.subjects("CROP", 10)



# base_uri = "http://api.data.gov/USDA/ERS/data/Arms/"
# params = {  report:         1,
#             subject:        1,
#             series1:        'AGE',
#             series2:        'FARM',
#             size:           2,
#             start:          0 }

# api = USDA::API.new("Finance", params)
# 
# ap USDA::Reports.get_reports("CROP")
# ap USDA::Reports.reports(1)
# puts api.parsed_response