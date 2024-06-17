class SchemaRegistry < Formula
  desc "Serving layer for Kafka metadata."
  homepage "https://github.com/confluentinc/schema-registry"
  url "https://packages.confluent.io/archive/7.6/confluent-community-7.6.1.tar.gz"
  sha256 "ae9a81f3cc914a21b977abeff1fa4778bf79a2c2dc8f5fc822e2da15d960bb92"
  license "Confluent Community License"

  #depends_on "openjdk"
  #depends_on "zookeeper"
  #depends_on "kafka"

  def install
    # Remove other services available in the archive
    Dir["bin/*"].select {|f| not /schema-registry.*/ =~ f}.each {|f| rm_rf f}
    Dir["etc/*"].select {|f| not /schema-registry/ =~ f}.each {|f| rm_rf f}
    Dir["share/doc/*"].select {|f| not /schema-registry.*/ =~ f}.each {|f| rm_rf f}

    # Configure the logs directory
    data = var/"lib"
    File.write(
      "etc/schema-registry/schema-registry.properties",
      "log.dirs=#{data}/schema-registry-logs",
      mode: "a+"
    )

    prefix.install "share"
    prefix.install "lib"
    prefix.install "bin"

    etc.install "etc/schema-registry"

    mkdir prefix/"etc"
    ln_s etc/"schema-registry", prefix/"etc/schema-registry"

    # create directory for stdout+stderr output logs when run by launchd
    (var+"log/schema-registry").mkpath
  end

  service do
    run [opt_bin/"schema-registry-start", etc/"schema-registry/schema-registry.properties"]
    keep_alive true
    working_dir HOMEBREW_PREFIX
    log_path var/"log/schema-registry/schema_registry_output.log"
    error_log_path var/"log/schema-registry/schema_registry_output.log"
  end

  #test do
    #ENV["LOG_DIR"] = "#{testpath}/kafkalog"

    ## Workaround for https://issues.apache.org/jira/browse/KAFKA-15413
    ## See https://github.com/Homebrew/homebrew-core/pull/133887#issuecomment-1679907729
    #ENV.delete "COLUMNS"

    #(testpath/"kafka").mkpath
    #cp "#{etc}/kafka/zookeeper.properties", testpath/"kafka"
    #cp "#{etc}/kafka/server.properties", testpath/"kafka"
    #inreplace "#{testpath}/kafka/zookeeper.properties", "#{var}/lib", testpath
    #inreplace "#{testpath}/kafka/server.properties", "#{var}/lib", testpath

    #zk_port = free_port
    #kafka_port = free_port
    #inreplace "#{testpath}/kafka/zookeeper.properties", "clientPort=2181", "clientPort=#{zk_port}"
    #inreplace "#{testpath}/kafka/server.properties" do |s|
      #s.gsub! "zookeeper.connect=localhost:2181", "zookeeper.connect=localhost:#{zk_port}"
      #s.gsub! "#listeners=PLAINTEXT://:9092", "listeners=PLAINTEXT://:#{kafka_port}"
    #end

    #begin
      #fork do
        #exec "#{bin}/zookeeper-server-start #{testpath}/kafka/zookeeper.properties " \
             #"> #{testpath}/test.zookeeper-server-start.log 2>&1"
      #end

      #sleep 15

      #fork do
        #exec "#{bin}/kafka-server-start #{testpath}/kafka/server.properties " \
             #"> #{testpath}/test.kafka-server-start.log 2>&1"
      #end

      #sleep 30

      #system "#{bin}/kafka-topics --bootstrap-server localhost:#{kafka_port} --create --if-not-exists " \
             #"--replication-factor 1 --partitions 1 --topic test > #{testpath}/kafka/demo.out " \
             #"2>/dev/null"
      #pipe_output "#{bin}/kafka-console-producer --bootstrap-server localhost:#{kafka_port} --topic test 2>/dev/null",
                  #"test message"
      #system "#{bin}/kafka-console-consumer --bootstrap-server localhost:#{kafka_port} --topic test " \
             #"--from-beginning --max-messages 1 >> #{testpath}/kafka/demo.out 2>/dev/null"
      #system "#{bin}/kafka-topics --bootstrap-server localhost:#{kafka_port} --delete --topic test " \
             #">> #{testpath}/kafka/demo.out 2>/dev/null"
    #ensure
      #system "#{bin}/kafka-server-stop"
      #system "#{bin}/zookeeper-server-stop"
      #sleep 10
    #end

    #assert_match(/test message/, File.read("#{testpath}/kafka/demo.out"))
  #end
end
