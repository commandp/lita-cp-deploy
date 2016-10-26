module Lita
  module Handlers
    class CpDeploy < Handler
      route(
        %r{deploy\s((?:\s*\w+)+)(?:\s+(?:revision|r)\=([\w\/\_\-\.]+))?$},
        :deploy,
        :command => true,
        :help    => {
          'deploy (short_name)' => 'Start deploy',
          'deploy <short_name> revision=<revision>' => 'Start deploy a specific revision',
          'deploy <short_name> r=<revision>' => 'Start deploy a specific revision (short)'
        }
      )

      route(
        %r{deploy\shelp},
        :deploy_help,
        :command => true,
        :help    => {
          'deploy help' => '顯示有什麼可以 deploy 的 '
        }
      )

      def deploy(response)
        brunch = response.matches.flatten[1]

        if deploy_item = find_by_deploy_item(response.matches.flatten[0])

          if deploy_item['type'] == 'aws'
            opsworks = Aws::OpsWorks::Client.new(
              region: deploy_item['region'] || ENV['AWS_REGION'],
              access_key_id: ENV['AWS_ACCESS_KEY'],
              secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
            )

            custom_json = nil
            if brunch
              app_name = opsworks.describe_apps(app_ids: [deploy_item['app_id']])[0][0].shortname
              custom_json = "{\"revision\":\"#{brunch}\",\"deploy\":{\"#{app_name}\":{\"scm\":{\"revision\":\"#{brunch}\"}}}}"
              custom_json = JSON.parse(custom_json)
            end

            deployment_configuration = {
              stack_id: deploy_item['stack_id'],
              app_id: deploy_item['app_id'],
              command: {
                name: 'deploy',
                args: { 'migrate' => ['true'] }
              },
              comment: "#{response.user.name} through #{robot.name} deploy",
              custom_json: custom_json ? custom_json.to_json : nil
            }

            deployment_configuration['LayerIds'] = deploy_item['layer_ids'] if deploy_item['layer_ids']
            resp = opsworks.create_deployment(deployment_configuration)

            responsereply(":running_dog: 開始執行 #{deploy_item['name']} 的佈署...")
          elsif deploy_item['type'] == 'jenkins'
            trigger_url = deploy_item['TriggerURL']
            trigger_url += "&REVISION=#{brunch}" if brunch

            uri = URI(trigger_url)

            req = Net::HTTP::Get.new(uri)
            req.basic_auth deploy_item['user'], deploy_item['password']

            res = Net::HTTP.start(uri.hostname, uri.port) {|http|
              http.request(req)
            }
            if res.code == "201"
              response.reply(":running_dog: 開始執行 #{deploy_item['name']} 的佈署...#{brunch}")
            else
              response.reply("Error: #{res.code}")
            end
          else
            response.reply('Error: item type only ["aws", "http_get"]')
          end
        end
      end

      def deploy_help(response)
        str = []
        deploy_config['deploy_itams'].each do |item|
          str << "deploy #{item['short_name']} => #{item['name']}\n"
        end
        response.reply(str.join)
      end

      private

      def find_by_deploy_item(short_name)
        deploy_config['deploy_itams'].select {|key| key['short_name'] == short_name }.first
      end

      def deploy_config
        JSON.parse(ENV['DEPLOY_CONFIG'])
      end

      Lita.register_handler(self)
    end
  end
end
