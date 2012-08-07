# MigrationRevert

Reversible migrations are very cool.

Some commands are not reversible, for example the removal of a table or a column.

Also, one downside is that it is now more difficult to write the reverse of a migration if `change` is used. When `up` and `down` were used, one could simply swap the code around.

This gem introduces `Migration#revert` that makes it trivial to revert a past migration, in part or in whole, or do the doing a reversible removal of a table/column.

Note that `revert` can even be called from legacy migrations using `up` & `down` and that it can revert legacy-style migrations too. For anyone changing their mind every second day, `revert` is fully nestable.

Sounds useful? Give a +1 to https://github.com/rails/rails/pull/7280

## Usage

Reverses the migration commands for the given block and
the given migrations.

The following migration will remove the table 'horses'
and create the table 'apples' on the way up, and the reverse
on the way down.

    class FixTLMigration < ActiveRecord::Migration
      def change
        revert do
          create_table(:horses) do |t|
            t.text :content
            t.datetime :remind_at
          end
        end
        create_table(:apples) do |t|
          t.string :variety
        end
      end
    end

Or equivalently, if `TenderloveMigration` is defined as in the
documentation for Migration:

    class FixupTLMigration < ActiveRecord::Migration
      def change
        revert TenderloveMigration

        create_table(:apples) do |t|
          t.string :variety
        end
      end
    end

This command can be nested.

## Installation

Add this line to your application's Gemfile:

    gem 'migration_revert'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install migration_revert
