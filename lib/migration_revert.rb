require "migration_revert/version"

unless ActiveRecord::Migration::CommandRecorder.method_defined? :revert
  require "migration_revert/ext/migration"
  require "migration_revert/ext/command_recorder"
end
