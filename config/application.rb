require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module RedPins
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # ERROR CODES
    SUCCESS = 1
    ERR_NO_USER_EXISTS = -1
    ERR_USER_EXISTS = -2
    ERR_BAD_EMAIL = -3
    ERR_BAD_FACEBOOK_ID = -4
    ERR_USER_LIKE_EVENT = -5
    ERR_USER_POST_COMMENT = -6
    ERR_USER_CREATION = -7
    ERR_USER_BOOKMARK = -8
    ERR_USER_DELETE_EVENT = -9
    ERR_USER_CANCEL_EVENT = -10
    ERR_USER_RESTORE_EVENT = -11
    ERR_USER_VERIFICATION = -12
    ERR_USER_REMOVE_BOOKMARK = -13
    ERR_USER_UPLOAD_PHOTO = -14
    ERR_USER_GET_BOOKMARKS = -15
    ERR_USER_REMOVE_COMMENT = -16
    ERR_USER_GET_RECENT_EVENTS = -17
    ERR_USER_GET_PROFILE = -18
    ERR_USER_GET_MY_EVENTS = -19

    ERR_BAD_TITLE = -20
    ERR_BAD_START_TIME = -21
    ERR_BAD_END_TIME = -22
    ERR_BAD_LOCATION = -23
    ERR_NO_EVENT_EXISTS = -24
    ERR_EVENT_CREATION = -25
    ERR_USER_GET_SIMPLE_RECOMMENDATIONS = -26
    ERR_USER_GET_LIKES = -27


    #FACEBOOK APP ID/SECRET
    APP_ID = '335179273261206'
    APP_SECRET = 'b1c4654b972f651998acc3d762e79d4d'

  end
end
