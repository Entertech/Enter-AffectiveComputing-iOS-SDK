//
//  AffectiveChartsSleepStageView.swift
//  EnterAffectiveCloudUI
//
//  Created by Enter M1 on 2023/12/13.
//  Copyright © 2023 Hangzhou Enter Electronic Technology Co., Ltd. All rights reserved.
//

import UIKit
import DGCharts
import SnapKit

public class AffectiveChartsSleepStageView: UIView {
    
    internal let chartView = AffectiveChartsSleepDetailCommonView()
    internal var interval = 1
    internal var dataSorce: [Double] = []
    
    private var awakeImage: UIImage?
    private var remImage: UIImage?
    private var lightImage: UIImage?
    private var deepImage: UIImage?
    private let awakeLabel = UILabel()
    private let remLabel = UILabel()
    private let lightLabel = UILabel()
    private let deepLabel = UILabel()
    /// 设置数据
    /// - Parameter array: 数据
    /// - Returns: self
    public func setData(_ array: [Int], param: AffectiveChartsSleepParameter) -> Self {
        guard array.count > 0 else {return self}
        dataSorce.removeAll()
        array.forEach { value in
            if value == 0 || value == 1 {
                dataSorce.append(7) //清醒
            } else if value == 4 {
                dataSorce.append(5) //rem
            } else if value == 2 {
                dataSorce.append(3) //浅睡
            } else if value == 3 {
                dataSorce.append(1) //深睡
            }
        }
        chartView.chartParam = param
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = 8
        chartView.leftAxis.labelCount = 4
        chartView.leftAxis.drawTopYLabelEntryEnabled = true
        chartView.leftAxis.drawBottomYLabelEntryEnabled = false
        chartView.leftAxis.valueFormatter = AffectiveChartsSleepStageYFormatter(lan: param.text)
        chartView.leftYAxisRenderer = AffectiveChartsSleepStageYRender(viewPortHandler: chartView.viewPortHandler, axis: chartView.leftAxis, transformer: chartView.getTransformer(forAxis: .left))
        chartView.xAxis.spaceMin = 1
        chartView.xAxis.spaceMax = 1
        awakeLabel.text = param.text[0]
        awakeLabel.textColor = param.yAxisLabelColor
        awakeLabel.font = UIFont.systemFont(ofSize: 10)
        remLabel.text = param.text[1]
        remLabel.textColor = param.yAxisLabelColor
        remLabel.font = UIFont.systemFont(ofSize: 10)
        lightLabel.text = param.text[2]
        lightLabel.textColor = param.yAxisLabelColor
        lightLabel.font = UIFont.systemFont(ofSize: 10)
        deepLabel.text = param.text[3]
        deepLabel.textColor = param.yAxisLabelColor
        deepLabel.font = UIFont.systemFont(ofSize: 10)
        return self
    }
    
    
    
    /// layout
    /// - Returns: self
    public func stepTwoSetLayout() -> Self {
        self.addSubview(chartView)
        chartView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        chartView.addSubview(awakeLabel)
        chartView.addSubview(remLabel)
        chartView.addSubview(lightLabel)
        chartView.addSubview(deepLabel)
        
        awakeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
        }
        remLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalTo(awakeLabel.snp.bottom).offset(14)
        }
        lightLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalTo(remLabel.snp.bottom).offset(14)
        }
        deepLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalTo(lightLabel.snp.bottom).offset(14)
        }
        return self
    }
    

    
    public func build() {
        guard let colors = chartView.chartParam?.lineColors, colors.count > 4 else {return}
        let screenWidth = UIScreen.main.bounds.width > 500 ? 500 : UIScreen.main.bounds.width
        var iconWidth = screenWidth / CGFloat(dataSorce.count)+2
        iconWidth = max(iconWidth, 8)
        awakeImage = createRoundRectangleImage(size: CGSize(width: iconWidth, height: 16), cornerRadius: 2, backgroundColor: colors[1])
        remImage = createRoundRectangleImage(size: CGSize(width: iconWidth, height: 16), cornerRadius: 2, backgroundColor: colors[2])
        lightImage = createRoundRectangleImage(size: CGSize(width: iconWidth, height: 16), cornerRadius: 2, backgroundColor: colors[3])
        deepImage = createRoundRectangleImage(size: CGSize(width: iconWidth, height: 16), cornerRadius: 2, backgroundColor: colors[4])
        
        var yVals: [ChartDataEntry] = []
        
        for i in stride(from: 0, to: dataSorce.count, by: 1) {
            let value = dataSorce[i]
            if value == 7 {
                yVals.append(ChartDataEntry(x: Double(i*interval), y: Double(dataSorce[i]), icon: awakeImage))
            } else if value == 5 {
                yVals.append(ChartDataEntry(x: Double(i*interval), y: Double(dataSorce[i]), icon: remImage))
            } else if value == 3 {
                yVals.append(ChartDataEntry(x: Double(i*interval), y: Double(dataSorce[i]), icon: lightImage))
            } else if value == 1 {
                yVals.append(ChartDataEntry(x: Double(i*interval), y: Double(dataSorce[i]), icon: deepImage))
            }
        }
        let set = LineChartDataSet(entries: yVals, label: "")
        
        set.mode = .horizontalBezier
        set.drawCirclesEnabled = false
        set.drawCircleHoleEnabled = false
        set.drawFilledEnabled = false
        set.lineWidth = 2
        set.setColor(colors[0])
        set.drawIconsEnabled = true
        set.highlightEnabled = false
        set.drawValuesEnabled = false
        let data = LineChartData(dataSet: set)
        
        chartView.data = data
    }
    
    func createRoundRectangleImage(size: CGSize, cornerRadius: CGFloat, backgroundColor: UIColor = .white) -> UIImage? {
        // Begin a new image context
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        // Set the fill color
        backgroundColor.setFill()
        // Create a path with rounded corners
        let rect = CGRect(origin: .zero, size: size)
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        // Fill the path with the color
        context.addPath(bezierPath.cgPath)
        context.fillPath()
        // Get the image from the current context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // End the image context
        UIGraphicsEndImageContext()
        return image
    }
    
}


public class AffectiveChartsSleepStageYFormatter: NSObject, AxisValueFormatter {
    var language = ["Awake", "REM", "Light", "Deep"]
    init(lan: [String]) {
        super.init()
        self.language = lan
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        var retValue = ""
//        if value == 8 {
//            retValue = language[0]
//        } else if value == 6 {
//            retValue = language[1]
//        } else if value == 4 {
//            retValue = language[2]
//        } else if value == 2 {
//            retValue = language[3]
//        }
        return retValue
    }
}



class AffectiveChartsSleepStageYRender: YAxisRenderer {

    override init(viewPortHandler: ViewPortHandler, axis: YAxis, transformer: Transformer?) {
        super.init(viewPortHandler: viewPortHandler, axis: axis, transformer: transformer)
    }

    /// draws the y-axis labels to the screen
    override func renderAxisLabels(context: CGContext)
    {
        guard
            axis.isEnabled,
            axis.isDrawLabelsEnabled
            else { return }

        let xoffset = axis.xOffset
        let yoffset = axis.labelFont.lineHeight / 3.5 + axis.yOffset
        
        let dependency = axis.axisDependency
        let labelPosition = axis.labelPosition
        
        let xPos: CGFloat
        let textAlign: TextAlignment
        var yInnerOffset: CGFloat = 0 // pressure 在内部时需要设置偏移
        
        if dependency == .left
        {
            if labelPosition == .outsideChart
            {
                textAlign = .right
                xPos = viewPortHandler.offsetLeft - xoffset
            }
            else
            {
                textAlign = .left
                xPos = viewPortHandler.offsetLeft + xoffset
                yInnerOffset =  axis.labelFont.lineHeight
            }
        }
        else
        {
            if labelPosition == .outsideChart
            {
                textAlign = .left
                xPos = viewPortHandler.contentRight + xoffset
            }
            else
            {
                textAlign = .right
                xPos = viewPortHandler.contentRight - xoffset
            }
        }
        
        drawYLabels(context: context,
                    fixedPosition: xPos,
                    positions: transformedPositions(),
                    offset: yoffset - axis.labelFont.lineHeight + yInnerOffset,
                    textAlign: textAlign)
    }

    
    override func renderGridLines(context: CGContext) {
        guard axis.isEnabled else { return }

        if axis.drawGridLinesEnabled
        {
            let positions = transformedPositions()
            
            context.saveGState()
            defer { context.restoreGState() }
            context.clip(to: self.gridClippingRect)
            
            context.setShouldAntialias(axis.gridAntialiasEnabled)
            context.setStrokeColor(axis.gridColor.cgColor)
            context.setLineWidth(axis.gridLineWidth)
            context.setLineCap(axis.gridLineCap)
            
            if axis.gridLineDashLengths != nil
            {
                context.setLineDash(phase: axis.gridLineDashPhase, lengths: axis.gridLineDashLengths)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            // draw the grid
            positions.forEach {
                if $0 != positions.first {
                    drawGridLine(context: context, position: $0)
                }
                
            }
        }

        if axis.drawZeroLineEnabled
        {
            // draw zero line
            drawZeroLine(context: context)
        }
    }
    


}
