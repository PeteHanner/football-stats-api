require "rails_helper"

RSpec.describe GameCreateWorker, type: :worker do
  describe "#perform" do
    it "creates a game object from a successfully returned API call" do
      games = load_json_file("spec/factories/games_api_response.json")
      drives = File.read("spec/factories/drive_api_response.json")
      response = OpenStruct.new({code: 200, body: drives})
      allow(HTTParty).to receive(:get).and_return(response)

      GameCreateWorker.new.perform(games[0])

      expect(Game.all.count).to eq(1)
    end

    it "calls FirstOrderGameStatsWorker on the game once created" do
      games = load_json_file("spec/factories/games_api_response.json")
      drives = File.read("spec/factories/drive_api_response.json")
      response = OpenStruct.new({code: 200, body: drives})
      allow(HTTParty).to receive(:get).and_return(response)

      expect(FirstOrderGameStatsWorker).to receive(:perform_async)

      GameCreateWorker.new.perform(games[0])
    end

    it "returns if the game score is not yet present" do
      incomplete_data = {"foo": "bar"}

      GameCreateWorker.new.perform(incomplete_data)
      expect(Game.all.count).to eq(0)
    end

    it "will not create a duplicate game" do
      create(:game, api_ref: 1)
      games = load_json_file("spec/factories/games_api_response.json")
      games[0]["id"] = 1
      GameCreateWorker.new.perform(games[0])

      expect(Game.all.count).to eq(1)

      games[0]["id"] = 2
      GameCreateWorker.new.perform(games[0])

      expect(Game.all.count).to eq(2)
    end

    it "raises error if API query fails" do
      games = load_json_file("spec/factories/games_api_response.json")
      response = OpenStruct.new({code: 500, body: ""})
      error_msg = "ERROR: #{described_class.name} received response code 500 for API game ID #{games[0]["id"]}"
      allow(HTTParty).to receive(:get).and_return(response)

      expect { GameCreateWorker.new.perform(games[0]) }.to raise_error(error_msg)
    end

    it "raises error if unable to save game" do
      games = load_json_file("spec/factories/games_api_response.json")
      drives = File.read("spec/factories/drive_api_response.json")
      response = OpenStruct.new({code: 200, body: drives})
      allow(HTTParty).to receive(:get).and_return(response)
      allow_any_instance_of(Game).to receive(:save!).and_raise(StandardError, "ERROR MESSAGE")
      error_msg = "ERROR: #{described_class.name} encountered error: ERROR MESSAGE\n\nWhile building game from API data:\n\n#{games[0]}"

      expect { GameCreateWorker.new.perform(games[0]) }.to raise_error(error_msg)
    end
  end
end
