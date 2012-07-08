# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Talon::Application.initialize!

# uncomment the following line to run in development mode
if Rails.env.development?
 config = YAML.load(File.read('../../../desktop/config.yml'))   
 user_name = config['user_name']
 password = config['password']
else
 user_name = ENV['SENDGRID_USERNAME']
 password = ENV['SENDGRID_PASSWORD']
end

ActionMailer::Base.smtp_settings = {
  :user_name =>  user_name,
  :password => password,
  :domain => "ospreypointpartners.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}
