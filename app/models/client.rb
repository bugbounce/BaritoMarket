require 'securerandom'

class Client < ActiveRecord::Base
  acts_as_paranoid
  validates_presence_of :name

  belongs_to :user, required: true
  belongs_to :stream, required: true
  belongs_to :store, required: true
  belongs_to :forwarder, required: true
  has_many :client_groups
  has_many :user_groups, through: :client_groups

  after_create :generate_application_secret, :copy_kafka_topics_from_forwarder, :generate_produce_url, :setup_forwarder, :copy_kibana_host_from_store, :copy_kafka_topic_partition_from_stream

  private
  def copy_kafka_topics_from_forwarder
    update_column(:kafka_topics, self.forwarder.kafka_topics)
  end

  def generate_produce_url
    produce_url = "http://#{self.stream.receiver_host}:#{self.stream.receiver_port}/str/#{self.stream_id}/st/#{self.store_id}/fw/#{self.forwarder_id}/sv/#{self.id}/produce/#{self.kafka_topics}"
    update_column(:produce_url, produce_url)
  end

  def setup_forwarder
    self.forwarder.set_stream_and_store(self.stream, self.store)
  end

  def copy_kibana_host_from_store
    update_column(:kibana_host, self.store.kibana_host)
  end

  def copy_kafka_topic_partition_from_stream
    update_column(:kafka_topic_partition, self.stream.kafka_topic_partition)
  end

  def generate_application_secret
    app_secret = SecureRandom.base64
    update_column(:application_secret, app_secret)
  end
end