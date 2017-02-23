EnisysGw::Application.configure do
#Rails.application.configure do
  config.eager_load = false
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers

  # Raise exception on mass assignment protection for Active Record models
  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)

  # Do not compress assets
  config.assets.js_compressor = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Sendmail
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings   = {
    :address        => 'localhost',
    :port           => 25,
    :domain         => 'localhost',
    :user_name      => nil,
    :password       => nil,
    :authentication => nil
  }
  config.cache_store = :dalli_store, 'localhost:11211', {
    :namespace => "enisys-gw-development",
    :expires_in => 3600
  }
  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
