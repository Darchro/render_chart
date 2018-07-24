require File.join(File.dirname(__FILE__), "app")

use Rack::Cors do
  allow do
    origins "*"
    resource "/public/*", headers: :any, methods: :get
    resource "*",
      methods: [:get, :post, :put, :patch, :delete, :options],
      headers: :any,
      max_age: 600
  end
end

use Rack::Auth::Basic do |username, password|
  username == 'admin' && password == 'admin.password'
end

run ChartsApp
