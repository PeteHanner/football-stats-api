require "rails_helper"
RSpec.describe GameImportWorker, type: :worker do
  describe "#perform" do
    it "calls GameCreateWorker on each game returned from the API query" do
      games = File.read("spec/factories/games_api_response.json")
      response = OpenStruct.new({code: 200, body: games})
      allow(HTTParty).to receive(:get).and_return(response)
      number_of_games = JSON.parse(games).length

      expect(GameCreateWorker).to receive(:perform_async).exactly(number_of_games).times

      GameImportWorker.new.perform(0, 0)
    end

    it "also checks next week + first week of next season if no arguments provided"

    it "logs error and safely exits if API query fails"
  end
end
