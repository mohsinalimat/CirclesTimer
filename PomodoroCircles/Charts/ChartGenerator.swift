import UIKit
import SwiftCharts

class ChartGenerator : ChartsDataProviderDelegate {
    fileprivate(set) var isInitialized = false
    fileprivate var chart: Chart? = nil
    fileprivate let viewHolder: UIView
    fileprivate let chartPageScroller: ChartPageScroller
    fileprivate let chartSettings: ChartSettings
    fileprivate var yModel: ChartAxisModel!
    fileprivate var visibilityStates: [AverageUnit: Bool]
    
    fileprivate var xAxis: ChartAxisLayer!
    fileprivate var yAxis: ChartAxisLayer!
    fileprivate var innerFrame: CGRect!
    fileprivate var backgroundLayers: [ChartLayer]!
    fileprivate var circleLayer: ChartLayer? = nil
    fileprivate var lineModel: ChartLineModel<ChartPoint>? = nil
    fileprivate let circleViewGenerator: (_ chartPointModel: ChartPointLayerModel<ChartPoint>, _ layer: ChartPointsLayer<ChartPoint>, _ chart: Chart) -> UIView?
    
    init(chartHolder: UIView, timeUnit: TimeUnit, visibility: [AverageUnit: Bool]) {
        viewHolder = chartHolder
        chartPageScroller = ChartPageScroller(timeUnit: timeUnit)
        yModel = chartPageScroller.createYAxisModel()
        visibilityStates = visibility
        
        chartSettings = ChartSettings()
        chartSettings.leading = 0
        chartSettings.top = 10
        chartSettings.trailing = 20
        chartSettings.bottom = -20
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 0
        chartSettings.axisStrokeWidth = 1
        chartSettings.spacingBetweenAxesX = 5
        chartSettings.spacingBetweenAxesY = 5
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.setLocalizedDateFormatFromTemplate(ChartConstants.formatterTemplate)
        let label = formatter.string(from: Date())
        let labelSpacing = label.size(attributes: [NSFontAttributeName: ChartConstants.monospaceFont]).width / 2
        chartSettings.labelsToAxisSpacingX = labelSpacing
        
        circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: 4)
            circleView.fillColor = ChartConstants.mainColor
            return circleView
        }
        
        PomodoroDataProvider.sharedInstance.chartsDelegate = self
    }
    
    func createChart() {
        refreshChart(true)
    }
    
    func changeTimeUnit(to unit: TimeUnit) {
        chartPageScroller.currentTimeUnit = unit
        refreshChart(true)
    }
    
    func setVisibilityState(_ state: Bool, for unit: AverageUnit) {
        visibilityStates[unit] = state
        refreshChart(false)
    }
    
    func scrollPage(_ direction: ScrollingDirection) {
        chartPageScroller.scrollPage(direction)
        refreshChart(true)
    }
    
    func chartDataFullUpdate() {
        yModel = chartPageScroller.createYAxisModel()
        scrollPage(.start)
    }
    
    func chartDataDayUpdate(_ yModelUpdate: Bool) {
        if yModelUpdate {
            yModel = chartPageScroller.createYAxisModel()
        }
        if chartPageScroller.positionFromNow >= -1 {
            scrollPage(.none)
        }
    }
    
    fileprivate func refreshChart(_ fullRefresh: Bool) {
        if let oldChart = chart {
            oldChart.clearView()
            chart = nil
        }
        
        let chartPage = chartPageScroller.chartPage
        if fullRefresh {
            let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: viewHolder.bounds, xModel: chartPage.xModel, yModel: yModel)
            xAxis = coordsSpace.xAxis
            yAxis = coordsSpace.yAxis
            innerFrame = coordsSpace.chartInnerFrame
            
            let areaLayer = ChartPointsAreaLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPage.productivityLinePoints, areaColor: ChartConstants.areaColor, animDuration: 0, animDelay: 0, addContainerPoints: true)
            let settings = ChartGuideLinesDottedLayerSettings(linesColor: ChartConstants.areaColor, linesWidth: 0.5, dotWidth: 0.5, dotSpacing: 0.5)
            let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: settings)
            backgroundLayers = [xAxis, yAxis, areaLayer, guidelinesLayer]
            
            lineModel = nil
            circleLayer = nil
            if chartPage.productivityLinePoints.count > 0 {
                let productivityLineModel = ChartLineModel(chartPoints: chartPage.productivityLinePoints, lineColor: ChartConstants.mainColor, lineWidth: 1, animDuration: 0, animDelay: 0)
                lineModel = productivityLineModel
                
                var circleLinePoints = chartPage.productivityLinePoints
                let count = circleLinePoints.count
                if count > 1 && circleLinePoints[count - 1].x.scalar == circleLinePoints[count - 2].x.scalar {
                    circleLinePoints.removeLast()
                }
                let chartPointsCircleLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: circleLinePoints, viewGenerator: circleViewGenerator)
                circleLayer = chartPointsCircleLayer
            }
        }
        
        var lineModels = [ChartLineModel]()
        if visibilityStates[.averagePreviousInterval]! {
            let averagePreviousIntervalLineModel = ChartLineModel(chartPoints: chartPage.averagePreviousIntervalLinePoints, lineColor: ChartConstants.averagePreviousIntervalColor, lineWidth: 1, animDuration: 0, animDelay: 0)
            lineModels.append(averagePreviousIntervalLineModel)
        }
        if visibilityStates[.averagePreviousUnit]! {
            let averagePreviousUnitLineModel = ChartLineModel(chartPoints: chartPage.averagePreviousUnitLinePoints, lineColor: ChartConstants.averagePreviousUnitColor, lineWidth: 1, animDuration: 0, animDelay: 0)
            lineModels.append(averagePreviousUnitLineModel)
        }
        if visibilityStates[.previousUnit]! {
            let previousUnitLineModel = ChartLineModel(chartPoints: chartPage.previousUnitLinePoints, lineColor: ChartConstants.previousUnitColor, lineWidth: 1, animDuration: 0, animDelay: 0)
            lineModels.append(previousUnitLineModel)
        }
        if let model = lineModel {
            lineModels.append(model)
        }
        
        let linesLayer = ChartPointsLineLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, lineModels: lineModels)
        var layers = backgroundLayers
        layers?.append(linesLayer)
        if let foregroundLayer = circleLayer {
            layers?.append(foregroundLayer)
        }
        
        chart = Chart(
            frame: viewHolder.bounds,
            layers: layers!
        )
        if !isInitialized {
            isInitialized = true
        }
        viewHolder.addSubview(chart!.view)
    }
}
