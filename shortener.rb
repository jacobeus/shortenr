%w(rubygems sinatra dm-core dm-validations dm-aggregates uri).each {|f| require f}
DataMapper.setup(:default, ENV['DATABASE_URL'] || "mysql://root@localhost/shortener")
class Url
  include DataMapper::Resource
  property :id,         Serial
  property :target,     String, :format => :url, :length => 0..1024, :index => true
  property :short,      String, :default => ""
end
get('/_privatesubmit') do
  target = URI::parse(params[:url]) rescue status(404) && return
  target = [target.to_s].unshift(("http://" unless target.scheme)).join
  "http://#{request.host}/" + (Url.first(:target => target) || Url.create!(:target => target, :short=>(Url.count+1).to_s(36))).short
end
get('/:url') { (url = Url.first(:short=>params[:url])) ? redirect(url.target) : status(404) }