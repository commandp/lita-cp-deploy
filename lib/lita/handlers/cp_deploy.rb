module Lita
  module Handlers
    class CpDeploy < Handler
      route(
        %r{deploy\s((\w|\s)+)},
        :deploy,
        :command => true,
        :help    => {
          'deploy (short_name)' => 'Start deploy'
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
        response.reply(deploy_config)
        if deploy_item = find_by_deploy_item(response.matches.flatten[0])
          response.reply(":running_dog: 開始執行 #{deploy_item['name']} 的佈署...")
          
          if deploy_item['type'] == 'aws'
            opsworks = Aws::OpsWorks::Client.new(
              region: ENV['AWS_REGION'],
              access_key_id: ENV['AWS_ACCESS_KEY'],
              secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
            )

            resp = opsworks.create_deployment({
              stack_id: deploy_item['stack_id'],
              app_id: deploy_item['app_id'],
              command: {
                name: 'deploy',
                args: { 'migrate' => ['true'] }
              },
              comment: "#{response.user.name} through #{robot.name} deploy"
            })
          elsif deploy_item['type'] == 'http_get'
            http_response = http.get "#{deploy_item['TriggerURL']}"
            if http_response.status == 200
              response.reply('200 OK')
            else
              response.reply(http_response.status)
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
