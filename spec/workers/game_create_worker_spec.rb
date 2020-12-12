require "rails_helper"

RSpec.describe GameCreateWorker, type: :worker do
  describe "#perform" do
    it "returns if the game score is not yet present" do
      incomplete_data = {"foo": "bar"}

      GameCreateWorker.new.perform(incomplete_data)
      expect(Game.all.count).to eq(0)
    end

    it "will not create a duplicate game" do
      game = create(:game, api_ref: 1)
      games = load_json_file("spec/factories/games_api_response.json")
      games[0]["id"] = 1
      GameCreateWorker.new.perform(games[0])

      expect(Game.all.count).to eq(1)

      games[0]["id"] = 2
      GameCreateWorker.new.perform(games[0])

      expect(Game.all.count).to eq(2)
    end

    it "returns without failing if the CFB API cannot be accessed" do
      games = load_json_file("spec/factories/games_api_response.json")
      response = OpenStruct.new({code: 500, body: ""})
      allow(HTTParty).to receive(:get).and_return(response)

      expect(Rails.logger).to receive(:error).with("Drive data query for API game ID #{games[0]["id"]} returned response code 500")

      GameCreateWorker.new.perform(games[0])
    end

    it "creates a game object from a successfully returned API call" do
      games = load_json_file("spec/factories/games_api_response.json")
      drives = File.read("spec/factories/drive_api_response.json")
      response = OpenStruct.new({code: 200, body: drives})
      allow(HTTParty).to receive(:get).and_return(response)

      GameCreateWorker.new.perform(games[0])

      expect(Game.all.count).to eq(1)
    end
  end
end
