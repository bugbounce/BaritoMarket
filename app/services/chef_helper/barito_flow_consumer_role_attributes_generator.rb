module ChefHelper
  class BaritoFlowConsumerRoleAttributesGenerator
    def initialize(app_secret_key, 
                   kafka_hosts, 
                   elasticsearch_host, 
                   consul_hosts, 
                   opts = {})
      @app_secret_key = app_secret_key
      @kafka_hosts = kafka_hosts
      @kafka_port = opts[:kafka_port] || 9092
      @elasticsearch_host = elasticsearch_host
      @elasticsearch_port = opts[:elasticsearch_port] || 9200
      @consul_hosts = consul_hosts
      @role_name = opts[:role_name] || 'barito-flow-consumer'
    end

    def generate
      kafka_hosts_and_port = @kafka_hosts.
        map{ |kafka_host| "#{kafka_host}:#{@kafka_port}" }
      kafka_hosts_and_port = kafka_hosts_and_port.join(',')
      elasticsearch_url = "http://#{@elasticsearch_host}:#{@elasticsearch_port}"

      {
        'barito-flow' => {
          'consumer' => {
            'env_vars' => {
              'BARITO_KAFKA_BROKERS' => kafka_hosts_and_port,
              'BARITO_KAFKA_GROUP_ID' => 'barito-group',
              'BARITO_KAFKA_CONSUMER_TOPICS' => 'barito-log',
              'BARITO_ELASTICSEARCH_URL' => elasticsearch_url,
              'BARITO_PUSH_METRIC_URL' => "http://#{Figaro.env.market_end_point}/api/increase_log_count",
              'BARITO_PUSH_METRIC_TOKEN' => @app_secret_key,
              'BARITO_PUSH_METRIC_INTERVAL' => '30s',
            }
          }
        },
        'consul' => {
          'run_as_server' => false,
          'hosts' => @consul_hosts
        },
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
