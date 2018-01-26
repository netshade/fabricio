require 'fabricio/networking/app_request_model_factory'
require 'fabricio/networking/network_client'
require 'fabricio/models/app'
require 'fabricio/models/point'
require 'fabricio/models/issue'
require 'fabricio/models/issue_session'

module Fabricio
  module Service
    # Service responsible for fetching different App information
    class AppService

      # Initializes a new AppService object.
      #
      # @param session [Fabricio::Authorization::Session]
      # @param network_client [Fabricio::Networking::NetworkClient]
      # @return [Fabricio::Service::AppService]
      def initialize(session, network_client)
        @session = session

        @request_model_factory = Fabricio::Networking::AppRequestModelFactory.new
        @network_client = network_client
      end

      # Obtains the list of all apps
      #
      # @return [Array<Fabricio::Model::App>]
      def all
        request_model = @request_model_factory.all_apps_request_model
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body).map do |app_hash|
          Fabricio::Model::App.new(app_hash)
        end
      end

      # Obtains a specific app
      #
      # @param id [String] Application identifier
      # @return [Fabricio::Model::App]
      def get(id)
        request_model = @request_model_factory.get_app_request_model(id)
        response = @network_client.perform_request(request_model)
        Fabricio::Model::App.new(JSON.parse(response.body))
      end

      # Obtains the count of active users at the current moment
      #
      # @param id [String] Application identifier
      # @return [Integer]
      def active_now(id)
        request_model = @request_model_factory.active_now_request_model(@session, id)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['cardinality']
      end

      # Obtains the count of daily new users
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @return [Array<Fabricio::Model::Point>]
      def daily_new(id, start_time, end_time)
        request_model = @request_model_factory.daily_new_request_model(@session, id, start_time, end_time)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['series'].map do |array|
          Fabricio::Model::Point.new(array)
        end
      end

      # Obtains the count of daily active users
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @param build [String] The version of the build. E.g. '4.0.1 (38)'
      # @return [Array<Fabricio::Model::Point>]
      def daily_active(id, start_time, end_time, build)
        request_model = @request_model_factory.daily_active_request_model(@session, id, start_time, end_time, build)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['series'].map do |array|
          Fabricio::Model::Point.new(array)
        end
      end

      # Obtains the OS distribution timeseries
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @return [Array<Fabricio::Model::Point>]
      def os_distribution(id, start_time, end_time)
        request_model = @request_model_factory.os_distribution_timeseries_model(@session, id, start_time, end_time)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['series'].map do |array|
          Fabricio::Model::Point.new(array)
        end
      end

      # Obtains the device distribution timeseries
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @return [Array<Fabricio::Model::Point>]
      def device_distribution(id, start_time, end_time)
        request_model = @request_model_factory.device_distribution_timeseries_model(@session, id, start_time, end_time)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['series'].map do |array|
          Fabricio::Model::Point.new(array)
        end
      end

      # Obtains the count of weekly active users
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @param build [String] The version of the build. E.g. '4.0.1 (38)'
      # @return [Array<Fabricio::Model::Point>]
      def weekly_active(id, start_time, end_time, build)
        request_model = @request_model_factory.weekly_active_request_model(@session, id, start_time, end_time, build)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['series'].map do |array|
          Fabricio::Model::Point.new(array)
        end
      end

      # Obtains the count of monhtly active users
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @param build [String] The version of the build. E.g. '4.0.1 (38)'
      # @return [Array<Fabricio::Model::Point>]
      def monthly_active(id, start_time, end_time, build)
        request_model = @request_model_factory.monthly_active_request_model(@session, id, start_time, end_time, build)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['series'].map do |array|
          Fabricio::Model::Point.new(array)
        end
      end

      # Obtains the count of sessions
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @param build [String] The version of the build. E.g. '4.0.1 (38)'
      # @return [Integer]
      def total_sessions(id, start_time, end_time, build)
        request_model = @request_model_factory.total_sessions_request_model(@session, id, start_time, end_time, build)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['sessions']
      end

      # Obtains the number of crashes
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @param builds [Array<String>] The versions of the app. E.g. ['4.0.1 (38)', '4.0.2 (45)']
      # @return [Integer]
      def crashes(id, start_time, end_time, builds)
        request_model = @request_model_factory.crash_count_request_model(id, start_time, end_time, builds)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['data']['project']['crashlytics']['scalars']['crashes']
      end

      # Obtains application crashfree. It's calculated using a simple formula:
      # crashfree = 1 - total_crashes / total_sessions.
      # AFAIK Fabric.io website uses the same calculations. However, mobile app behaves differently and shows another value.
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @param build [String] The version of the build. E.g. '4.0.1 (38)'
      # @return [Float]
      def crashfree(id, start_time, end_time, build)
        sessions = total_sessions(id, start_time, end_time, build)
        crashes = crashes(id, start_time, end_time, [build])
        1 - crashes.to_f / sessions
      end

      # Obtains top issues
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @param build [String] The version of the build. E.g. '4.0.1 (38)'
      # @param count [Int] Number of issue
      # @return [Array<Fabricio::Model::Issue>]
      def top_issues(id, start_time, end_time, builds, count)
        request_model = @request_model_factory.top_issues_request_model(id, start_time, end_time, builds, count)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)['data']['project']['crashlytics']['_issues4Eg1Tv']['edges'].map do |edge|
          Fabricio::Model::Issue.new(edge['node'])
        end
      end

      # Obtains single issue
      #
      # @param id [String] Application identifier
      # @param issue_external_id [String] Issue external identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @return [Fabricio::Model::Issue]
      def single_issue(id, issue_external_id, start_time, end_time)
        request_model = @request_model_factory.single_issue_request_model(id, issue_external_id, start_time, end_time)
        response = @network_client.perform_request(request_model)
        Fabricio::Model::Issue.new(JSON.parse(response.body)['data']['project']['crashlytics']['_issueeUsmi'])
      end

      # Obtains single issue
      #
      # @param id [String] Application identifier
      # @param issue_external_id [String] Issue external identifier
      # @param session_id [String] Session identifier
      # @return [Fabricio::Model::Issue]
      def issue_session(id, issue_external_id, session_id)
        request_model = @request_model_factory.issue_session_request_model(id, issue_external_id, session_id)
        response = @network_client.perform_request(request_model)
        json = JSON.parse(response.body)
        link = response.headers['Link']
        unless link.nil?
          json['header_link'] = link
          link_parts = link.split(", ")
          link_parts.each do |part|
          	if part.include? 'rel="prev"'
          		json['prev_session_id'] = part.sub('>; rel="prev"', "").sub('<', "").split("sessions/")[1]
          	elsif part.include? 'rel="next"'
          		json['next_session_id'] = part.sub('>; rel="next"', "").sub('<', "").split("sessions/")[1]
          	end
          end
        end
        Fabricio::Model::IssueSession.new(json)
      end

      # Add comment to issue
      #
      # @param id [String] Application identifier
      # @param issue_external_id [String] Issue external identifier
      # @param message [String] Comment message
      # @return [JSON]
      def add_comment(id, issue_external_id, message)
        request_model = @request_model_factory.add_comment_request_model(id, issue_external_id, message)
        response = @network_client.perform_request(request_model)
        JSON.parse(response.body)
      end

      # Obtains application OOM-free (Out of Memory).
      #
      # @param id [String] Application identifier
      # @param start_time [String] Timestamp of the start date
      # @param end_time [String] Timestamp of the end date
      # @param builds [Array<String>] The versions of the app. E.g. ['4.0.1 (38)', '4.0.2 (45)']
      # @return [Float]
      def oomfree(id, start_time, end_time, builds)
        start_date = Time.at(start_time.to_i).to_datetime
        end_date = Time.at(end_time.to_i).to_datetime
        days = (end_date - start_date).to_i + 1

        request_model = @request_model_factory.oom_count_request_model(id, days, builds)
        response = @network_client.perform_request(request_model)

        result = JSON.parse(response.body)
        sessions = result['data']['project']['crashlytics']['oomSessionCounts']['timeSeries'][0]['allTimeCount']
        ooms = result['data']['project']['crashlytics']['oomCounts']['timeSeries'][0]['allTimeCount']
        1 - ooms.to_f / sessions
      end
    end
  end
end
