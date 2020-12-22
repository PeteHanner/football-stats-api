desc "Run the game import worker to grab all possible new games"
task import_new_games: :environment do
  puts "calling GameImportWorker"
  GameImportWorker.new.perform
  puts "done calling GameImportWorker"
end
