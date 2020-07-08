require "json"

##
# This class iterate through a json file and sum values in order to find the most viewed topic id
#
# the format of entry data is a json file with an array of theses objects :
# { "id": string, "views_count": integer, "likes_count": integer, "dislikes_count": integer, "topic_ids": array[string] }
#
# it returns a hash with the values of the most viewed topic
#
# {
#   id:             string,         id of topic
#   views_count:    int,            number of view for this topic
#   likes_count:    int,            number of view for this topic
#   dislikes_count: int,            number of view for this topic
#   video_ids:      array[string],  ids of videos where this topic appears
#   topic_ids:      array[string],  ids of topics linked to the sames videos as the current topic
# }
#
# @parameter file_path, the path of json file to parse, default value is 'videos.json'
#
# calling the service: HotTopicFinder.new.perform
class HotTopicFinder
  DEFAULT_ACC_TEMPLATE = { views_count: 0, likes_count: 0, dislikes_count: 0, video_ids: [] }.freeze

  attr_reader :videos, :acc

  def initialize(file_path: 'videos.json')
    @videos = read_json(file_path)
    @acc = {}
  end

  def perform
    @best_topic = DEFAULT_ACC_TEMPLATE.dup

    each_topic do |video, topic_id|
      # creates a default value when topic_id is not existing in accumulator hash
      build_accumulator_template(topic_id)

      # convert video 'id' key in video_id in order to prepare merge
      sanitized_video = sanitized_video_hash(video)

      # merge accumulator values and current video value
      increment_accumulator(sanitized_video, topic_id)

      # always keep the most viewed topic in memory to avoid another iteration
      # through accumulator at the end
      compare_views(@acc[topic_id])
    end

    @best_topic
  end

  private

  ##
  # create a default hash for accumulator when the topic is not listed in it.
  # add the id of the topic
  def build_accumulator_template(topic_id)
    return unless @acc[topic_id].nil?
    @acc[topic_id] = { id: topic_id }.merge(DEFAULT_ACC_TEMPLATE.dup)
  end

  ##
  # video hash has an id key, we need to remove it and transform it in an array
  # for the merge
  def sanitized_video_hash(video)
    sanitized = video.dup
    sanitized[:video_ids] = [sanitized[:id]]
    sanitized.delete(:id)
    sanitized
  end

  ##
  # sum values of accumulator and new video hash
  def increment_accumulator(video, topic_id)
    @acc[topic_id].merge!(video) do |_k, a_value, b_value|
      if a_value.is_a?(Array)
        (a_value + b_value).uniq
      else
        a_value + b_value
      end
    end
  end

  ##
  # we always keep the most viewed topic in memory to avoid iterate through
  # the accumulator at the end in order to improve performances
  def compare_views(current_topic)
    return if @best_topic[:views_count] > current_topic[:views_count]

    @best_topic = current_topic
  end

  ##
  # iterate through every topic in every video hash
  def each_topic
    @videos.each do |video|
      video[:topic_ids].each do |topic_id|
        yield(video, topic_id)
      end
    end
  end

  def read_json(file_path)
    json_from_file = File.read(file_path)
    JSON.parse(json_from_file, symbolize_names: true)
  end
end

result = HotTopicFinder.new.perform
puts "\e[36m#-[ Summary          ]----------------------------------------------------------------\e[0m"
puts "Most viewed topic id is : \e[35m'#{result[:id]}'\e[0m with \e[35m#{result[:views_count]}\e[0m views"
puts "\e[36m--------------------------------------------------------------------------------------\e[0m"

puts "\e[36m#-[ Detailled result ]----------------------------------------------------------------\e[0m"
p result