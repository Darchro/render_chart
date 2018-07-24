# Build template data class.
class Chart
  def initialize(data)
    @data = data
  end

  # Support templating of member data.
  def get_binding
    binding
  end

  def build
    # Create template.
    template = %{
      <!DOCTYPE HTML>
      <html>
          <head>
              <meta charset="utf-8"><link rel="icon" href="https://static.jianshukeji.com/highcharts/images/favicon.ico">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <style>
                  html, body{ margin:0; height:100%; }
                  a {
                    text-decoration:none;
                    font-size: 16px;
                  }
                  .box {
                    background-color: #CFCFCF;
                  }
                  .title {
                    margin-left: 12px;
                    font-size: 20px;
                  }
                  .box ul {
                   list-style-type: none;
                   margin:0px;
                   padding:0px;
                  }
                  .box li {
                   margin:7px;
                   padding:5px;
                   float:left;
                   width:120px;
                  }
              </style>
              <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/css/select2.min.css" rel="stylesheet" />
              <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
              <script src="https://img.hcharts.cn/highcharts/highcharts.js"></script>
              <script src="https://img.hcharts.cn/highcharts/modules/exporting.js"></script>
              <script src="http://code.highcharts.com/modules/offline-exporting.js"></script>
              <script src="https://img.hcharts.cn/highcharts-plugins/highcharts-zh_CN.js"></script>
              <script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/js/select2.min.js"></script>
          </head>
          <body>
              <div>
                <select id='item' style='width: 200px;'></select>
                <select id='list' style='width: 500px;'></select>
              </div>
              <div id="container" style="min-width:600px;height:600px"></div>

              <div class='box'>
                <div class='title'>天猫地址：</div>
                <div class='tm_list'>
                  <ul id='tb_links'>
                  </ul>
                </div>
              </div>
              <script>
              var data = <%= @data %>;

              for(var item in data){
                var option = document.createElement("option");
                    option.text = item;
                    option.value = item;
                document.getElementById("item").appendChild(option)
              }

              var default_item_name = Object.keys(data)[0];

              function init_chart(item_name, pro_id){
                $("#list").empty();
                $("#list").append($('<option>', {
                                      value: 'all',
                                      text: '全部'
                                  }));
                for(var item in data[item_name]["pay_data"]){
                  var option = document.createElement("option");
                    option.text = item;
                    option.value = item;
                    document.getElementById("list").appendChild(option)
                }

                $("#list").val(pro_id);
                

                var X_datas = data[item_name]["x_data"];
                var top10_data = data[item_name]["top10"];
                var trend_data = data[item_name]["trends"]
                var series_data = [];
                
                $("#tb_links").empty();
                series_data.push({name: 'TOP10', type: 'column', yAxis: 0, data: top10_data})
                series_data.push({name: '行业大盘交易指数', type: 'spline', yAxis: 1, data: trend_data, dashStyle: 'shortdot'})
                if(pro_id == 'all'){
                  for(var item in data[item_name]["pay_data"]){
                    series_data.push({name: item, type: 'spline', yAxis: 0, data: data[item_name]["pay_data"][item], visible: false})
                    var li_ele = $('<li>');
                    var link_ele = $('<a>', {href: "https://detail.tmall.com/item.htm?id="+item, text: item, target: '_blank'});
                    $("#tb_links").append(li_ele.append(link_ele));
                  }
                }else{
                  series_data.push({name: pro_id, type: 'spline', yAxis: 0,data: data[item_name]["pay_data"][pro_id]})
                  var li_ele = $('<li>');
                  var link_ele = $('<a>', {href: "https://detail.tmall.com/item.htm?id="+pro_id, text: pro_id, target: '_blank'});
                  $("#tb_links").append(li_ele.append(link_ele));
                }

                var chart = Highcharts.chart('container', {
                    chart: {
                        zoomType: 'x'
                    },
                    title: {
                      text: '多妙屋--'+item_name+'数据趋势图'
                    },
                    credits: {
                      enabled: false
                    },
                    xAxis: [{
                        categories: X_datas,
                        crosshair: true
                    }],
                    yAxis: [{ // Primary yAxis
                        gridLineWidth: 0,
                        labels: {
                            format: '{value} 件',
                            style: {
                                color: Highcharts.getOptions().colors[3]
                            }
                        },
                        title: {
                            // text: '支付商品件数',
                            text: '',
                            style: {
                                color: Highcharts.getOptions().colors[3]
                            }
                        },
                        opposite: false
                    }, { // Tertiary  yAxis
                        gridLineWidth: 0,
                        title: {
                            text: '行业大盘交易指数',
                            style: {
                                color: Highcharts.getOptions().colors[1]
                            }
                        },
                        labels: {
                            format: '{value}',
                            style: {
                                color: Highcharts.getOptions().colors[1]
                            }
                        },
                        opposite: true
                    }],
                    tooltip: {
                        shared: true
                    },
                    legend: {
                        layout: 'horizontal',
                        backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
                    },
                    series: series_data
                });
              }
              init_chart(default_item_name, 'all');

              $("#item").select2();
              $("#list").select2();

              $("#item").on('change', function(){
                init_chart($(this).val(), 'all');
              });
              $("#list").on('change', function(){
                init_chart($("#item").val(), $(this).val());
              });
              </script>
          </body>
      </html>
    }.gsub(/^  /, '')

    template
  end

end