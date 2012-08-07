module ActiveRecord
  class Migration
    # Reverses the migration commands for the given block and
    # the given migrations.
    #
    # The following migration will remove the table 'horses'
    # and create the table 'apples' on the way up, and the reverse
    # on the way down.
    #
    #   class FixTLMigration < ActiveRecord::Migration
    #     def change
    #       revert do
    #         create_table(:horses) do |t|
    #           t.text :content
    #           t.datetime :remind_at
    #         end
    #       end
    #       create_table(:apples) do |t|
    #         t.string :variety
    #       end
    #     end
    #   end
    #
    # Or equivalently, if +TenderloveMigration+ is defined as in the
    # documentation for Migration:
    #
    #   class FixupTLMigration < ActiveRecord::Migration
    #     def change
    #       revert TenderloveMigration
    #
    #       create_table(:apples) do |t|
    #         t.string :variety
    #       end
    #     end
    #   end
    #
    # This command can be nested.
    #
    def revert(*migration_classes)
      run(*migration_classes.reverse, :revert => true) unless migration_classes.empty?
      if block_given?
        if @connection.respond_to? :revert
          @connection.revert { yield }
        else
          recorder = CommandRecorder.new(@connection)
          @connection = recorder
          suppress_messages do
            @connection.revert { yield }
          end
          @connection = recorder.delegate
          recorder.commands.each do |cmd, args, block|
            send(cmd, *args, &block)
          end
        end
      end
    end

    def reverting?
      @connection.respond_to?(:reverting) && @connection.reverting
    end

    # Runs the given migration classes.
    # Last argument can specify options:
    # - :direction (default is :up)
    # - :revert (default is false)
    #
    def run(*migration_classes)
      opts = migration_classes.extract_options!
      dir = opts[:direction] || :up
      dir = (dir == :down ? :up : :down) if opts[:revert]
      if reverting?
        # If in revert and going :up, say, we want to execute :down without reverting, so
        revert { run(*migration_classes, direction: dir, revert: true) }
      else
        migration_classes.each do |migration_class|
          migration_class.new.exec_migration(@connection, dir)
        end
      end
    end

    # Execute this migration in the named direction
    def migrate(direction)
      return unless respond_to?(direction)

      case direction
      when :up   then announce "migrating"
      when :down then announce "reverting"
      end

      time   = nil
      ActiveRecord::Base.connection_pool.with_connection do |conn|
        time = Benchmark.measure do
          exec_migration(conn, direction)
        end
      end

      case direction
      when :up   then announce "migrated (%.4fs)" % time.real; write
      when :down then announce "reverted (%.4fs)" % time.real; write
      end
    end

    def exec_migration(conn, direction)
      @connection = conn
      if respond_to?(:change)
        if direction == :down
          revert { change }
        else
          change
        end
      else
        send(direction)
      end
    ensure
      @connection = nil
    end
  end
end
