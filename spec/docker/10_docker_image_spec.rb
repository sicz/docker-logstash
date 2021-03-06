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

  ### OS #######################################################################

  describe "Operating system" do
    context "family" do
      # We can not simple test the os[:family] because CentOS is reported as "redhat"
      subject { file("/etc/centos-release") }
      it "sould eq \"centos\"" do
        expect(subject).to be_file
      end
    end
    context "locale" do
      context "CHARSET" do
        subject { command("echo ${CHARSET}") }
        it { expect(subject.stdout.strip).to eq("UTF-8") }
      end
      context "LANG" do
        subject { command("echo ${LANG}") }
        it { expect(subject.stdout.strip).to eq("en_US.UTF-8") }
      end
      context "LC_ALL" do
        subject { command("echo ${LC_ALL}") }
        it { expect(subject.stdout.strip).to eq("en_US.UTF-8") }
      end
    end
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
      "java-1.#{ENV["OPENJDK_PRODUCT_VERSION"]}.0-openjdk-headless",
    ].each do |package, version, installer|
      describe package(package) do
        it { is_expected.to be_installed }                        if installer.nil? && version.nil?
        it { is_expected.to be_installed.with_version(version) }  if installer.nil? && ! version.nil?
        it { is_expected.to be_installed.by(installer) }          if ! installer.nil? && version.nil?
        it { is_expected.to be_installed.by(installer).with_version(version) } if ! installer.nil? && ! version.nil?
      end
    end
  end

  ### PACKAGES #################################################################

  describe "Development Packages", :test => :docker_image, :dev => true do
    [
      # [package,                   version,                    installer]
      "gcc",
      "git",
      "java-1.#{ENV["OPENJDK_PRODUCT_VERSION"]}.0-openjdk-devel",
      "make",
      "vim-enhanced",
      ["bundler",                   nil,                        "gem"],
      ["rake",                      nil,                        "gem"],
      ["rspec",                     nil,                        "gem"],
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
      # [
      #   file,
      #   mode, user, group, [expectations],
      #   rootfs, srcfile,
      #   [match],
      # ]
      [
        "/docker-entrypoint.sh",
        755, "root", "root", [:be_file],
      ],
      [
        "/docker-entrypoint.d/31-logstash-environment.sh",
        644, "root", "root", [:be_file, :eq_sha256sum],
      ],
      [
        "/docker-entrypoint.d/50-logstash-certs.sh",
        644, "root", "root", [:be_file, :eq_sha256sum],
      ],
      [
        "/docker-entrypoint.d/60-logstash-fragments.sh",
        644, "root", "root", [:be_file, :eq_sha256sum],
      ],
      [
        "/docker-entrypoint.d/70-logstash-settings.sh",
        644, "root", "root", [:be_file, :eq_sha256sum],
      ],
      [
        "/docker-entrypoint.d/80-logstash-options.sh",
        644, "root", "root", [:be_file, :eq_sha256sum],
      ],
      [
        "/usr/share/logstash",
        755, "root", "root", [:be_directory],
      ],
      [
        "/usr/share/logstash/bin",
        755, "root", "root", [:be_directory],
      ],
      [
        "/usr/share/logstash/config",
        750, "logstash", "logstash", [:be_directory],
      ],
      [
        "/usr/share/logstash/config/logstash.docker.yml",
        640, "logstash", "logstash", [:be_file],
      ],
      [
        "/usr/share/logstash/config/logstash.yml",
        640, "logstash", "logstash", [:be_file],
        nil, nil,
        "^# logstash.docker.yml$",
      ],
      [
        "/usr/share/logstash/config/log4j2.docker.properties",
        640, "logstash", "logstash", [:be_file, :eq_sha256sum],
      ],
      [
        "/usr/share/logstash/config/log4j2.properties",
        640, "logstash", "logstash", [:be_file],
        nil, nil,
        "^# log4j2.docker.properties$",
      ],
      [
        "/usr/share/logstash/data",
        750, "logstash", "logstash", [:be_directory],
      ],
      [
        "/usr/share/logstash/logs",
        750, "logstash", "logstash", [:be_directory],
      ],
      [
        "/usr/share/logstash/pipeline",
        750, "logstash", "logstash", [:be_directory]
      ],
    ].each do |file, mode, user, group, expectations, rootfs, srcfile, match|
      expectations ||= []
      rootfs = "rootfs" if rootfs.nil?
      srcfile = file if srcfile.nil?
      context file(file) do
        it { is_expected.to exist }
        it { is_expected.to be_file }       if expectations.include?(:be_file)
        it { is_expected.to be_directory }  if expectations.include?(:be_directory)
        it { is_expected.to be_mode(mode) } unless mode.nil?
        it { is_expected.to be_owned_by(user) } unless user.nil?
        it { is_expected.to be_grouped_into(group) } unless group.nil?
        case match
        when String
          its(:content) { is_expected.to match(match) }
        when Array
          match.each do |m|
            its(:content) { is_expected.to match(m) }
          end
        end
        its(:sha256sum) do
          is_expected.to eq(
            Digest::SHA256.file("#{rootfs}/#{srcfile}").to_s
          )
        end if expectations.include?(:eq_sha256sum)
      end
    end
  end

  ### XPACK_FILES ##############################################################

  describe "X-Pack Files", :test => :docker_image, :x_pack => true do
    [
      # [
      #   file,
      #   mode, user, group, [expectations],
      #   rootfs, srcfile,
      #   [match],
      # ]
      [
        "/docker-entrypoint.d/32-x-pack-environment.sh",
        644, "root", "root", [:be_file, :eq_sha256sum],
        "x-pack/rootfs",
      ],
      [
        "/docker-entrypoint.d/62-x-pack-fragments.sh",
        644, "root", "root", [:be_file, :eq_sha256sum],
        "x-pack/rootfs",
      ],
      [
        "/usr/share/logstash/config/logstash.yml",
        640, "logstash", "logstash", [:be_file],
        nil, nil,
        [
          "^# logstash.docker.yml$",
          "^# logstash.x-pack.yml$",
        ]
      ],
    ].each do |file, mode, user, group, expectations, rootfs, srcfile, match|
      expectations ||= []
      rootfs = "rootfs" if rootfs.nil?
      srcfile = file if srcfile.nil?
      context file(file) do
        it { is_expected.to exist }
        it { is_expected.to be_file }       if expectations.include?(:be_file)
        it { is_expected.to be_directory }  if expectations.include?(:be_directory)
        it { is_expected.to be_mode(mode) } unless mode.nil?
        it { is_expected.to be_owned_by(user) } unless user.nil?
        it { is_expected.to be_grouped_into(group) } unless group.nil?
        case match
        when String
          its(:content) { is_expected.to match(match) }
        when Array
          match.each do |m|
            its(:content) { is_expected.to match(m) }
          end
        end
        its(:sha256sum) do
          is_expected.to eq(
            Digest::SHA256.file("#{rootfs}/#{srcfile}").to_s
          )
        end if expectations.include?(:eq_sha256sum)
      end
    end
  end

  ##############################################################################

end

################################################################################
