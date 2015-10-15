gem 'dalli'

gsub_file "config/environments/production.rb", "# config.cache_store = :mem_cache_store", "config.cache_store = :mem_cache_store"
