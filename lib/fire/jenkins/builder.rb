require 'jenkins_api_client'
require 'nokogiri'
require 'fileutils'
require 'pathname'
require "fire/jenkins/builder/version"

module Fire
  module Jenkins
    module Builder
    	class Base
				attr_reader :config
				attr_reader :client

				REQUIRED_KEYS = %w[server_url server_port username password template_job_name job_view branch].freeze

				def initialize(config)
					@client = JenkinsApi::Client.new(
						server_url: config['server_url'], 
						server_port: config['server_port'],
						username: config['username'], 
						password: config['password'],
						log_level: config['log_level'] || 'info'
						)
					@config = config || {}
					validate!
				end

				def create
					client.job.create_or_update(job_name, target_xml)
					client.view.add_job(config['job_view'], job_name)
					build
				end

				def build
					jobs = client.job.list(job_name)
					if jobs.empty?
						create
					else
						job_name = client.job.chain(jobs, 'success', ['all'])[0]
						client.job.build(job_name, config['parameters'])
					end
				end

				def job_name
					@job_name = begin
						(config['job_name'] || (config['job_name_prefix'] + config['branch'])).sub('/', '_')
					end
				end

				private

				def target_xml
					job_config = client.job.get_config(config['template_job_name'])		
					parameters = config['parameters'] || []

					doc = Nokogiri::XML(job_config)
					properties = doc.search('//parameterDefinitions')
					properties.children.each do |child|
						next if child.children.empty?

						children = child.children.reject { |c| c.name.nil? }
						matched = false
						defaultValue = nil
						children.each do |c|
							if c.name == 'name' && parameters.keys.include?(c.content)
								matched = true 
								defaultValue = parameters[c.content]
							end

							c.content = defaultValue if matched && c.name == 'defaultValue'
						end
					end

					branch_spec_node = doc.search("//hudson.plugins.git.BranchSpec")
					branch_node = branch_spec_node.children.find { |c| c.name == 'name' }
					branch_node.content = config['branch']
					doc.to_xml
				end

				def validate! 
					raise "job_name 和 job_name_prefix 必须有一个不为空" if config['job_name'].nil? && config['job_name_prefix'].nil?

					empty_value_keys = REQUIRED_KEYS.select { |key| config[key].nil? }
					raise "#{empty_value_keys.join(', ')} 不能为空" if empty_value_keys.any?
				end
			end
		end
  end
end
