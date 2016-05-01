$: << './lib'
require 'web_app'

use Rack::Reloader, 0
use Rack::Static, urls: ['/css', '/js'], root: 'lib/public'
run GambleMarket::WebApp
