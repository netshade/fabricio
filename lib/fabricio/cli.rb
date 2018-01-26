require 'thor'
require 'fabricio'
require 'fileutils'
require 'yaml'

module Fabricio
  class CLI < Thor

    # Constants
    CREDENTIAL_DIRECTORY_PATH = "#{Dir.home}/.fabricio"
    CREDENTIAL_FILE_PATH = "#{CREDENTIAL_DIRECTORY_PATH}/.credential"
    FABRIC_GRAPHQL_API_URL = 'https://api-dash.fabric.io/graphql'

    desc "credential", "Setup credential"
    def credential
      say("Setup credential")
      credential = ask_credential

      tmp_client = Fabricio::Client.new do |config|
        config.username = credential.email
        config.password = credential.password
      end

      organization = tmp_client.organization.get
      unless organization.nil?
        say("Successful login to #{organization.name}")
        create_credential_file(credential)
      else
        say("Login failed")
      end

      say("Complete!")
    end

    desc "organization", "Obtain organization"
    option :app_id => :required, :type => :string
    def organization
      say("#{client.organization.get.to_s}")
    end

    desc "apps", "Obtain all app"
    def apps
      say client.app.all.to_json
    end

    desc "app", "Obtain single app"
    option :app_id => :required, :type => :string
    def app(app_id)
      say("#{client.app.get(app_id).to_s}")
    end

    desc "builds", "Obtain all builds"
    option :app_id => :required, :type => :string
    def builds(app_id)
      say client.build.all(app_id).to_json
    end

    desc "topbuilds", "Obtain top builds"
    option :app_id => :required, :type => :string
    option :start => :optional, :type => :string
    option :finish => :optional, :type => :string
    def topbuilds(app_id, start = nil, finish = nil)
      start  ||= Time.now - ((24 * 60 * 60) * 7)
      finish ||= Time.now
      say client.build.top_versions(app_id, start, finish).to_json
    end

    desc "os", "Obtain os distribution over time"
    option :app_id => :required, :type => :string
    option :start => :optional, :type => :string
    option :finish => :optional, :type => :string
    def os(app_id, start = nil, finish = nil)
      start  ||= Time.now - ((24 * 60 * 60) * 7)
      finish ||= Time.now
      say client.app.os_distribution(app_id, start, finish).to_json
    end

    desc "device", "Obtain device distribution over time"
    option :app_id => :required, :type => :string
    option :start => :optional, :type => :string
    option :finish => :optional, :type => :string
    def device(app_id, start = nil, finish = nil)
      start  ||= Time.now - ((24 * 60 * 60) * 7)
      finish ||= Time.now
      say client.app.device_distribution(app_id, start, finish).to_json
    end

    desc "build", "Obtain single build"
    option :app_id => :required, :type => :string
    option :version => :required, :type => :string
    option :build_number => :required, :type => :string
    def build(app_id, version, build_number)
      say client.build.get(app_id, version, build_number).to_json
    end

    private
    def client
      email = ""
      password = ""
      if File.file?(CREDENTIAL_FILE_PATH)
        credential = YAML.load_file(CREDENTIAL_FILE_PATH)
        email = credential['email']
        password = credential['password']
      else
        ask_credential
      end

      client = Fabricio::Client.new do |config|
        config.username = email
        config.password = password
      end
    end

    def create_credential_file(credential)
      FileUtils.mkdir_p(CREDENTIAL_DIRECTORY_PATH)
      credential_hash = {
        "email" => credential.email,
        "password" => credential.password
      }
      File.open(CREDENTIAL_FILE_PATH,'w') do |f|
          f.write credential_hash.to_yaml
      end
      say("Your credential in #{CREDENTIAL_FILE_PATH}")
    end

    def ask_credential
      say("We have to know you're email from fabric account")
      email = ask("email: ")
      say("Now we want your password. Do not be afraid, it is stored locally")
      password = ask("password: ", :echo => false)
      say("")
      Fabricio::Model::Credential.new(email, password)
    end

  end
end
