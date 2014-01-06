require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Files" do
  get "/files/:file_path" do
    let(:file_path) { "#{SecureRandom.hex}.txt" }

    let(:published_bucket) { AppContainer.s3_published_bucket }

    let!(:published_object) do
      published_object = published_bucket.objects[file_path]
      published_object.write("data", :metadata => {
        "encrypted_aes_key" => "key",
        "encrypted_aes_iv" => "iv"
      })
      published_object
    end

    example "Reading a file once" do
      do_request

      expect(response_body).to eq("data")
      expect(status).to eq(200)
      expect(response_headers["Encrypted-Aes-Key"]).to eq("key")
      expect(response_headers["Encrypted-Aes-Iv"]).to eq("iv")

      do_request

      expect(status).to eq(404)

      expect(published_object.exists?).to be_false
    end

    context "no file extension" do
      let(:file_path) { SecureRandom.hex }

      example "Reading a file once - has no extension", :document => false do
        do_request

        expect(response_body).to eq("data")
        expect(status).to eq(200)
      end
    end
  end
end
