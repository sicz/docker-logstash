require "docker_helper"

### DOCKER_CONTAINER ###########################################################

describe "Docker container", :test => :docker_container do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ### DOCKER_CONTAINER #########################################################

  describe docker_container(ENV["CONTAINER_NAME"]) do
    # Execute Serverspec command locally
    before(:each) { set :backend, :exec }
    it { is_expected.to be_running }
  end

  ### PROCESSES ################################################################

  describe "Processes" do
    [
      # [process,                   user,             group,            pid]
      ["tini",                      "root",           "root",           1],
      ["java",                      "logstash",       "logstash"],
    ].each do |process, user, group, pid|
      context process(process) do
        it { is_expected.to be_running }
        its(:pid) { is_expected.to eq(pid) } unless pid.nil?
        its(:user) { is_expected.to eq(user) } unless user.nil?
        its(:group) { is_expected.to eq(group) } unless group.nil?
      end
    end
  end

  ### PORTS ####################################################################

  # TODO: Specinfra due the bug is not able to test listening ports
  describe "Ports" do
    [
      # [port, proto]
      [5000, "tcp"],
    ].each do |port, proto|
      context port(port) do
        it { is_expected.to be_listening.with(proto) }
      end
    end
  end

  ### LOGSTASH #################################################################

  # TODO: Logstash monitoring API:
  # https://www.elastic.co/guide/en/logstash/current/monitoring-logstash.html#monitoring

  describe "Logstash endpoint" do
    # Execute Serverspec commands locally
    before(:each)  { set :backend, :exec }
    [
      # [
      #   url,
      #   stdout,
      #   stderr,
      #   curl_opts
      # ]
      [ "https://#{ENV["SERVER_CRT_HOST"]}:5000",
        nil,
        "^< HTTP/1.1 200 OK\\r$",
        "-XPUT -H 'content-type: text/plain' -d 'message 1'"
      ],
    ].each do |url, stdout, stderr, curl_opts|
      context url do
        subject { command("curl #{curl_opts} --location --silent --show-error --verbose #{url}") }
        its(:exit_status) { is_expected.to eq(0) }
        its(:stdout) { is_expected.to match(/#{stdout}/) } unless stdout.nil?
        its(:stderr) { is_expected.to match(/#{stderr}/) } unless stderr.nil?
      end
    end
  end

  ##############################################################################

end
