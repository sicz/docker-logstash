require "docker_helper"

### JAVA_CERTIFICATE #########################################################

describe "Java certificate", :test => :java_cert do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ### CONFIG ###################################################################

  ca_crt            = "/usr/share/logstash/config/ca.crt"
  server_crt        = "/usr/share/logstash/config/server.crt"

  truststore        = "/usr/share/logstash/config/truststore.jks"
  truststore_pwd    = "/usr/share/logstash/config/truststore.pwd"
  truststore_user   = "logstash"
  truststore_group  = "logstash"
  truststore_mode   = 640

  keystore          = "/usr/share/logstash/config/keystore.jks"
  keystore_pwd      = "/usr/share/logstash/config/keystore.pwd"
  keystore_user     = "logstash"
  keystore_group    = "logstash"
  keystore_mode     = 640

  ### TRUSTSTORE_PASSPHRASE ####################################################

  describe "Java truststore passphrase \"#{truststore_pwd}\"" do
    context "file" do
      subject { file(truststore_pwd) }
      it { is_expected.to be_file }
      it { is_expected.to be_mode(truststore_mode) }
      it { is_expected.to be_owned_by(truststore_user) }
      it { is_expected.to be_grouped_into(truststore_group) }
    end
  end

  ### TRUSTSTORE ###############################################################

  describe "Java truststore \"#{truststore}\"" do
    context "file" do
      subject { file(truststore) }
      it { is_expected.to be_file }
      it { is_expected.to be_mode(truststore_mode) }
      it { is_expected.to be_owned_by(truststore_user) }
      it { is_expected.to be_grouped_into(truststore_group) }
    end
    context "truststore" do
      # Get server certificate fingerprint
      let(:ca_crt_fingerprint) do
        Serverspec::Type::Command
        .new("openssl x509 -noout -fingerprint -sha1 -in #{ca_crt}")
        .stdout
        .sub(/^SHA1 Fingerprint=/, "")
        .strip
      end
      subject do
        command("keytool -list -keystore #{truststore} -storepass $(cat #{truststore_pwd})")
      end
      it "should be valid" do
        expect(subject.exit_status).to eq(0)
      end
      it "should be JKS type" do
        expect(subject.stdout).to match(/^Keystore type: JKS$/)
      end
      it "should contains CA certificate" do
        expect(subject.stdout).to match(/^ca.crt,/)
        expect(subject.stdout).to match(/^ca.crt,.*\btrustedCertEntry\b/)
        expect(subject.stdout).to match(/\nca.crt,[^\n]*\nCertificate fingerprint \(SHA1\): #{ca_crt_fingerprint}\n/m)
      end
      # TODO: Test certificate
    end
  end

  ### KEYSTORE_PASSPHRASE ######################################################

  describe "Java keystore passphrase \"#{keystore_pwd}\"" do
    context "file" do
      subject { file(keystore_pwd) }
      it { is_expected.to be_file }
      it { is_expected.to be_mode(keystore_mode) }
      it { is_expected.to be_owned_by(keystore_user) }
      it { is_expected.to be_grouped_into(keystore_group) }
    end
  end

  ### KEYSTORE #################################################################

  describe "Java keystore \"#{keystore}\"" do
    context "file" do
      subject { file(keystore) }
      it { is_expected.to be_file }
      it { is_expected.to be_mode(keystore_mode) }
      it { is_expected.to be_owned_by(keystore_user) }
      it { is_expected.to be_grouped_into(keystore_group) }
    end
    context "keystore" do
      # Get server certificate fingerprint
      let(:server_crt_fingerprint) do
        Serverspec::Type::Command
        .new("openssl x509 -noout -fingerprint -sha1 -in #{server_crt}")
        .stdout
        .sub(/^SHA1 Fingerprint=/, "")
        .strip
      end
      subject do
        command("keytool -list -keystore #{keystore} -storepass $(cat #{keystore_pwd})")
      end
      it "should be valid" do
        expect(subject.exit_status).to eq(0)
      end
      it "should be JKS type" do
        expect(subject.stdout).to match("Keystore type: JKS")
      end
      it "should contains server certificate and private key" do
        expect(subject.stdout).to match(/^server.crt,/)
        expect(subject.stdout).to match(/^server.crt,.*\bPrivateKeyEntry\b/)
        expect(subject.stdout).to match(/\nserver.crt,[^\n]*\nCertificate fingerprint \(SHA1\): #{server_crt_fingerprint}\n/m)
      end
      # TODO: test certificate
      # TODO: test key
    end
  end

  ##############################################################################

end

################################################################################
