require 'sinatra'
require 'rack/cors'

require "erb"
require 'roo'
require 'json'

require_relative "lib/chart.rb"

class ChartsApp < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/uploads' do
    #文件临时存储在服务器上
    file_name = params[:file][:filename]
    file = params[:file][:tempfile]
    File.open("./public/download_tmp/#{file_name}", 'wb') do |f|
      f.write(file.read)
    end

    #处理数据
    @data = data_parse(xls_parse(file_name))
    
    #生成一个html文件
    render_chart(@data, file_name)

    send_file "./public/download_tmp/#{file_name.split('.').first}.html", :filename => "#{file_name.split('.').first}.html", :type => 'Application/octet-stream'
  end

  private
  def data_parse(data)
    return {} unless data.is_a?(Hash)
    result = {}
    data.each_pair do |key, value|
      x_data = value.first
      x_data.shift
      x_data = x_data.map{|date| Date.parse(date.to_s).strftime("%-m/%d")}
      case 
      when key.include?('支付商品件数')
        value[1, value.length - 1].each do |e|
          item = e.first.split("-").first #获取商品类目
          pro_id = e.first.split("-").last #获取商品ID
          result[item] = {"x_data" => x_data, "top10" => nil, "trends" => nil, "pay_data" => {}} unless result.has_key?(item)
          e.shift
          result[item]["pay_data"][pro_id] = e
        end
      else
        value[1, value.length - 1].each do |e|
          item = e.first #获取商品类目
          result[item] = {"x_data" => x_data, "top10" => nil, "trends" => nil, "pay_data" => {}} unless result.has_key?(item)
          e.shift
          key.include?('top') ? result[item]["top10"] = e :  result[item]["trends"] = e
        end
      end
    end
    return result.to_json
  end

  def xls_parse(file_name)
    xls_file = "./public/download_tmp/#{file_name}" # "数据_0720.xlsx"
    file = Roo::Excelx.new(xls_file)
    sheets = file.sheets

    sheets.each do |sheet_name|
      sheet = file.sheet(sheet_name)
      tmp_data = []

      case sheet_name
      when '支付商品件数'
        (sheet.first_row..sheet.last_row).each do |n|
          tmp_data << sheet.row(n)
        end
      else
        (sheet.first_row..sheet.last_row).each do |n|
          tmp_data << sheet.row(n)
        end
      end
      instance_variable_set("@#{sheet_name}_datas", tmp_data.transpose)
    end
    data_hash = {}
    sheets.each do |sheet_name|
      data_hash[sheet_name] = instance_variable_get("@#{sheet_name}_datas")
    end
    return data_hash
  rescue IOError => e
    warn "没有找到对应的文件"
  end

  def render_chart(data, file_name)
    chart = Chart.new data

    template = chart.build
    rhtml = ERB.new(template)

    # # Produce result.
    content = rhtml.result(chart.get_binding)

    File.open("./public/download_tmp/#{file_name.split('.').first}.html", 'w') do |f|
      f.write(content)
    end

  end

end
