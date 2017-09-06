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

  ### FILES ####################################################################

  describe "Files" do
    [
      # [file,                                            mode, user,       group,      [expectations]]
      ["/usr/share/logstash/config/logstash.yml",         640, "logstash",  "logstash", [:be_file]],
      ["/usr/share/logstash/config/log4j2.properties",    640, "logstash",  "logstash", [:be_file]],
      ["/usr/share/logstash/pipeline/logstash.conf",      640, "logstash",  "logstash", [:be_file]],
    ].each do |file, mode, user, group, expectations|
      expectations ||= []
      context file(file) do
        it { is_expected.to exist }
        it { is_expected.to be_file }       if expectations.include?(:be_file)
        it { is_expected.to be_directory }  if expectations.include?(:be_directory)
        it { is_expected.to be_mode(mode) } unless mode.nil?
        it { is_expected.to be_owned_by(user) } unless user.nil?
        it { is_expected.to be_grouped_into(group) } unless group.nil?
        its(:sha256sum) do
          is_expected.to eq(
              Digest::SHA256.file("config/#{subject.name}").to_s
          )
        end if expectations.include?(:eq_sha256sum)
      end
    end
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

  # describe "URLs" do
  #   # Execute Serverspec command locally
  #   before(:each)  { set :backend, :exec }
  #   [
  #     # [url, stdout, stderr]
  #     [ "http://#{ENV["SERVICE_NAME"]}.local",
  #       "^#{IO.binread("spec/fixtures/www/index.html")}$",
  #       "\\r\\n< HTTP/1.1 301 Moved Permanently\\r\\n< Location: https://#{ENV["SERVICE_NAME"]}.local/\\r\\n",
  #     ],
  #     [ "http://#{ENV["SERVICE_NAME"]}.local/index.html",
  #       "^#{IO.binread("spec/fixtures/www/index.html")}$",
  #       "\\r\\n< HTTP/1.1 301 Moved Permanently\\r\\n< Location: https://#{ENV["SERVICE_NAME"]}.local/index.html\\r\\n",
  #     ],
  #     [ "https://#{ENV["SERVICE_NAME"]}.local",
  #       "^#{IO.binread("spec/fixtures/www/index.html")}$",
  #     ],
  #     [ "https://#{ENV["SERVICE_NAME"]}.local/index.html",
  #       "^#{IO.binread("spec/fixtures/www/index.html")}$",
  #     ],
  #   ].each do |url, stdout, stderr|
  #     context url do
  #       subject { command("curl --location --silent --show-error --verbose #{url}") }
  #       it "should exist" do
  #         expect(subject.exit_status).to eq(0)
  #       end
  #       it "should match \"#{stdout.gsub(/\n/, "\\n")}\"" do
  #         expect(subject.stdout).to match(stdout)
  #       end unless stdout.nil?
  #       it "should match \"#{stderr}\"" do
  #         expect(subject.stderr).to match(stderr)
  #       end unless stderr.nil?
  #     end
  #   end
  # end

  ##############################################################################

end
