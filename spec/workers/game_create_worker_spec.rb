require "rails_helper"

RSpec.describe GameCreateWorker, type: :worker do
  describe "#perform" do
    it "returns if the game score is not yet present" do
      incomplete_data = {"foo": "bar"}

      GameCreateWorker.new.perform(incomplete_data)
      expect(Game.all.count).to eq(0)
    end

    # it "will not create a duplicate game"

    # it "returns without failing if the CFB API cannot be accessed" do
    #   response = {code: 500}
    #   allow(HTTParty).to receive(:get).and_return(response)
    # end

    it "creates a game object from a successfully returned API call" do
      response = JSON.parse(File.read("spec/factories/game_api_response.json"))
    end
  end
end
