describe NibeUplink::System do
  let(:client) { double }
  let(:system) { double }
  let(:subject) { described_class.new(client, system) }

  describe "#to_h_with_suffix" do
    it "returns a hash with unique keys" do
      array = [
        ["foo", "2 V"],
        ["bar", "1 degC"],
        ["current", "1.5 A"],
        ["current", "0.5 A"],
        ["current", "2.5 A"],
        ["a", "a a"]
      ]
      expected_result = {
        "foo" => "2 V",
        "bar" => "1 degC",
        "current" => "1.5 A",
        "current_2" => "0.5 A",
        "current_3" => "2.5 A",
        "a" => "a a"
      }

      expect(subject.send(:to_h_with_suffix, array)).to eq(expected_result)
    end
  end
end
