//
//  SingleGraphTableViewCell.swift
//  SunnyMood
//
//  Created by bytedance on 2020/7/25.
//  Copyright © 2020 edu.pku. All rights reserved.
//

import UIKit
import Charts

class SingleGraphTableViewCell: UITableViewCell {

    @IBOutlet weak var chartView: LineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadData(navigationController: UINavigationController?) {
        //创建折线图组件对象
        chartView.legend.enabled = false
        chartView.leftAxis.enabled = false
        chartView.leftAxis.spaceTop = 0.4
        chartView.leftAxis.spaceBottom = 0.4
        chartView.rightAxis.enabled = false
        chartView.xAxis.enabled = false
        //折线图背景色
        chartView.backgroundColor = UIColor(red: 89/255, green: 199/255, blue: 250/255,
                                            alpha: 1)
        //生成8条随机数据
        var dataEntries = [ChartDataEntry]()
        for i in 0..<8 {
            let y = arc4random()%100
            let entry = ChartDataEntry.init(x: Double(i), y: Double(y))
            dataEntries.append(entry)
        }
        //这50条数据作为1根折线里的所有数据
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "李子明")
        chartDataSet.lineWidth = 1.75
        chartDataSet.circleRadius = 5.0
        chartDataSet.circleHoleRadius = 2.5
        chartDataSet.setColor(.white)
        chartDataSet.setCircleColor(.white)
        chartDataSet.highlightColor = .white
        chartDataSet.drawValuesEnabled = false
        //目前折线图只包括1根折线
        let chartData = LineChartData(dataSets: [chartDataSet])
         
        //设置折现图数据
        chartView.data = chartData
    }
    
}
