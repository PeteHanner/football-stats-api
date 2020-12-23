desc "Run the game import worker to grab all possible new games"
task import_new_games: :environment do
  puts "calling GamesImportWorker"
  GamesImportWorker.new.perform
  puts "done calling GamesImportWorker"
end
