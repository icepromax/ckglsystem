<template>
  <v-chart class="chart" :option="chartOption" autoresize />
</template>

<script>
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart } from 'echarts/charts'
import {
  GridComponent,
  TitleComponent,
  TooltipComponent,
  LegendComponent
} from 'echarts/components'
import VChart from 'vue-echarts'

use([
  CanvasRenderer,
  BarChart,
  GridComponent,
  TitleComponent,
  TooltipComponent,
  LegendComponent
])

export default {
  name: 'CategoryComparisonChart',
  components: { VChart },
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    chartOption() {
      return {
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          },
          formatter: '{b}<br/>{a}: {c}'
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: this.data.map(item => item.name),
          axisLabel: {
            interval: 0,
            rotate: 30
          }
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: '数量',
            type: 'bar',
            data: this.data.map(item => item.value),
            itemStyle: {
              color: function(params) {
                const colorList = ['#5470C6', '#91CC75', '#EE6666', '#FAC858', '#73C0DE']
                return colorList[params.dataIndex % colorList.length]
              }
            },
            label: {
              show: true,
              position: 'top'
            }
          }
        ]
      }
    }
  }
}
</script>

<style scoped>
.chart {
  width: 100%;
  height: 100%;
}
</style>
