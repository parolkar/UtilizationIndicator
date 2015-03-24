
namespace :utilization_kpi do
  desc "get cpu utilization kpi"
  task "cpu" do
    require 'aws-sdk'  

    ec2  = Aws::EC2::Client.new(region:'ap-southeast-1') 
    # Get the instances
    instances = ec2.describe_instances.data["reservations"].collect { |c| c.instances.map(&:instance_id) }.flatten.uniq
    instance_utilizations = []


    cloudwatch = Aws::CloudWatch::Client.new(region: 'ap-southeast-1')
    
    instances.each do |instance_id|   
      stats = cloudwatch.get_metric_statistics({
       :namespace   => 'AWS/EC2',
       :metric_name => 'CPUUtilization',
       :statistics  => ['Average'],
       :dimensions  => [
         { :name => "InstanceId", :value => instance_id },
       ],
       :start_time  => (Time.now - 7.days).iso8601,
       :end_time    => Time.now.iso8601,
       :period      => 60*24 # a day
      })
    
       avgs_arr = stats.datapoints.map(&:average)
       if avgs_arr.size == 0
          p "#{instance_id} : No Data points"
       else 
          avg = avgs_arr.sum / avgs_arr.size.to_f
         instance_utilizations << avg
       end
     end

     p instance_utilizations.inspect
     p "Max : #{instance_utilizations.max}"
     p "Min : #{instance_utilizations.min}"
     p "Avg : #{instance_utilizations.sum / instance_utilizations.size.to_f}"


   end

end
