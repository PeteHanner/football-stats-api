desc "Run the game import worker to grab all possible new games"
task import_new_games: :environment do
  puts "calling GamesImportWorker"
  GamesImportWorker.new.perform
  puts "done calling GamesImportWorker"
end

desc "Run a backfill on missing stats for the current season"
task run_stats_backfill: :environment do
  puts "calling StatsBackfillWorker"
  StatsBackfillWorker.new.perform
  puts "done calling StatsBackfillWorker"
end
