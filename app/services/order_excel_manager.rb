class OrderExcelManager
  def self.generate_home_delivery_order_xls(orders)
    workbook = Spreadsheet::Workbook.new
    sheet = workbook.create_worksheet name: "宅配訂單清單"

    orders.each_with_index do |order, index|
      row = sheet.row(index)
      row.push order.ship_name, order.ship_phone, "", order.ship_address, "4277907101", "", order.id, "", "1", "文具飾品", order.total, "1", order.note, "", ""
    end

    spreadsheet = StringIO.new
    workbook.write spreadsheet
    spreadsheet.string
  end

  def self.picking_list_index(order_ids)
    picking_list_index = {}
    order_ids.each_with_index { |id, index| picking_list_index[id] = (index + 1) }
    picking_list_index
  end
end