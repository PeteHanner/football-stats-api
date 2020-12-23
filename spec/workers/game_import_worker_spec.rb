require "rails_helper"
RSpec.describe GamesImportWorker, type: :worker do
  describe "#perform" do
    it "calls GameCreateWorker on each game returned from the API query" do
      games = File.read("spec/factories/games_api_response.json")
      response = OpenStruct.new({code: 200, body: games})
      allow(HTTParty).to receive(:get).and_return(response)
      number_of_games = JSON.parse(games).length

      expect(GameCreateWorker).to receive(:perform_async).exactly(number_of_games).times

      GamesImportWorker.new.perform(0, 0)
    end

    it "also checks next week + first week of next season if no arguments provided" do
      create(:game, season: 1, week: 1)

      expect(GamesImportWorker).to receive(:perform_async).with(1, 2)
      expect(GamesImportWorker).to receive(:perform_async).with(2, 1)

      GamesImportWorker.new.perform
    end

    it "raises error if API query fails" do
      response = OpenStruct.new({code: 500, body: ""})
      allow(HTTParty).to receive(:get).and_return(response)

      error_msg = "ERROR: #{described_class.name} received response code 500 for 2000 season week 1"
      expect { GamesImportWorker.new.perform(2000, 1) }.to raise_error(error_msg)
    end
  end
end
