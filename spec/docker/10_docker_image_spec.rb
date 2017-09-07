require "docker_helper"

### DOCKER_IMAGE ###############################################################

describe "Docker image", :test => :docker_image do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ### DOCKER_IMAGE #############################################################

  describe docker_image(ENV["DOCKER_IMAGE"]) do
    # Execute Serverspec command locally
    before(:each) { set :backend, :exec }
    it { is_expected.to exist }
  end

  ### USERS ####################################################################

  describe "Users" do
    [
      # [user,                      uid,  primary_group]
      ["logstash",                  1000, "logstash"],
    ].each do |user, uid, primary_group|
      context user(user) do
        it { is_expected.to exist }
        it { is_expected.to have_uid(uid) } unless uid.nil?
        it { is_expected.to belong_to_primary_group(primary_group) } unless primary_group.nil?
      end
    end
  end

  ### GROUPS ###################################################################

  describe "Groups" do
    [
      # [group,                     gid]
      ["logstash",                  1000],
    ].each do |group, gid|
      context group(group) do
        it { is_expected.to exist }
        it { is_expected.to have_gid(gid) } unless gid.nil?
      end
    end
  end

  ### PACKAGES #################################################################

  describe "Packages" do
    [
      # [package,                   version,                    installer]
      "bash",
    ].each do |package, version, installer|
      describe package(package) do
        it { is_expected.to be_installed }                        if installer.nil? && version.nil?
        it { is_expected.to be_installed.with_version(version) }  if installer.nil? && ! version.nil?
        it { is_expected.to be_installed.by(installer) }          if ! installer.nil? && version.nil?
        it { is_expected.to be_installed.by(installer).with_version(version) } if ! installer.nil? && ! version.nil?
      end
    end
  end

  ### COMMANDS #################################################################

  describe "Commands" do

    # [command, version, args]
    commands = [
      ["/usr/lib/jvm/jre/bin/java",         ENV["DOCKER_VERSION"], "-version"],
      ["/usr/share/logstash/bin/logstash",  ENV["DOCKER_VERSION"]],
    ]

    commands.each do |command, version, args|
      describe "Command \"#{command}\"" do
        subject { file(command) }
        let(:version_regex) { /\W#{version}\W/ }
        let(:version_cmd) { "#{command} #{args.nil? ? "--version" : "#{args}"}" }
        it "should be installed#{version.nil? ? nil : " with version \"#{version}\""}" do
          expect(subject).to exist
          expect(subject).to be_executable
          expect(command(version_cmd).stdout).to match(version_regex) unless version.nil?
        end
      end
    end
  end

  ### FILES ####################################################################

  describe "Files" do
    [
      # [file,                                            mode, user,       group,      [expectations]]
      ["/docker-entrypoint.sh",                           755, "root",      "root",     [:be_file]],
      ["/docker-entrypoint.d/30-environment-logstash.sh", 644, "root",      "root",     [:be_file, :eq_sha256sum]],
      ["/docker-entrypoint.d/60-logstash-settings.sh",    644, "root",      "root",     [:be_file, :eq_sha256sum]],
      ["/usr/share/logstash",                             755, "root",      "root",     [:be_directory]],
      ["/usr/share/logstash/bin",                         755, "root",      "root",     [:be_directory]],
      ["/usr/share/logstash/config",                      750, "logstash",  "logstash", [:be_directory]],
      ["/usr/share/logstash/data",                        750, "logstash",  "logstash", [:be_directory]],
      ["/usr/share/logstash/logs",                        750, "logstash",  "logstash", [:be_directory]],
      ["/usr/share/logstash/pipeline",                    750, "logstash",  "logstash", [:be_directory]],
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

  ##############################################################################

end

################################################################################
