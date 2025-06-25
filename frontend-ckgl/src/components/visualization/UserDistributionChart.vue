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
  name: 'UserDistributionChart',
  components: { VChart },
  props: {
    total: {
      type: Number,
      default: 0
    },
    male: {
      type: Number,
      default: 0
    },
    female: {
      type: Number,
      default: 0
    }
  },
  computed: {
    chartOption() {
      return {
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        legend: {
          data: ['总数', '男性', '女性']
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'value',
          boundaryGap: [0, 0.01]
        },
        yAxis: {
          type: 'category',
          data: ['用户分布']
        },
        series: [
          {
            name: '总数',
            type: 'bar',
            data: [this.total],
            itemStyle: {
              color: '#5470C6'
            }
          },
          {
            name: '男性',
            type: 'bar',
            data: [this.male],
            itemStyle: {
              color: '#91CC75'
            }
          },
          {
            name: '女性',
            type: 'bar',
            data: [this.female],
            itemStyle: {
              color: '#EE6666'
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
