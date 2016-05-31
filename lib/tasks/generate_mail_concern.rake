namespace :mail_concern do
  task :order_concern => :environment do    
    Order.all.each do |order|
      if order.status == "完成取貨"
        order.mail_concern = MailConcern.create!
        puts "#{order.mail_concern.id} created!"
      end
    end
  end
end