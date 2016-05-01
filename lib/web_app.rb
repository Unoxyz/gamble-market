require 'erb'
require 'json'
require 'main'

class BasicApp
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def request
    @request
  end

  def res(body=[], status=200, header={})
    Rack::Response.new(body, status, header)
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def response
  end
end

module GambleMarket
  class WebApp < BasicApp
    def response
      case request.path
      when '/'
        Rack::Response.new { |response| response.redirect '/chart' }
      when '/chart'
        Rack::Response.new 'hello world'
        data_type = request.params["data"] || A
        @data = Factory.accumulated_goods[data_type]
        res(render("index.html.erb"))
      else
        # [ 200, {'Content-Type' => 'text/plain'}, ["Hello World!"] ]
        res("Hello World!")
      end
    end

    def data1
      {
        wtp: {
          x: [1, 2, 3, 5, 7, 9, 10, 11, 12, 13],
          y: [49990, 39999, 33000, 30000, 25000, 20000, 12000, 8000, 5000, 100]
        },
        wta: {
          x: [2, 4, 5, 6, 9, 10, 11, 12, 13],
          y: [10000, 20000, 21000, 24000, 30000, 35000, 37500, 39999, 40000]
        }
      }
    end

  end
end
