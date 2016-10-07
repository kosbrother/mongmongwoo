class OrderDeliveryExcelGenerator
  def self.generate_home_delivery_order_xls(orders)
    workbook = Spreadsheet::Workbook.new
    sheet = workbook.create_worksheet name: "宅配訂單清單"

    orders.each_with_index do |order, index|
      row = sheet.row(index)
      row.push order.ship_name, order.ship_phone, "", order.ship_address, "4277907101", "", order.id, "", "1", "文具飾品", order.is_paid == true ? 0 : order.total, order.is_paid == true ? "" : "1", order.note, "", ""
    end

    spreadsheet = StringIO.new
    workbook.write spreadsheet
    spreadsheet.string
  end
end