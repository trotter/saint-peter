require File.dirname(__FILE__) + '/../rack_adapter/rack_saint_peter'

use Rack::SaintPeter, "localhost" do |env|
  {:user => env["HTTP_X_USER"], :resource => env["REQUEST_PATH"]}
end

run Proc.new { |env| [200, {"Content-Type" => "text/html"}, "St. Peter gave you access\n"] }
