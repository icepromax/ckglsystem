<template>
  <v-chart :option="chartOption" autoresize />
</template>

<script>
export default {
  props: ['data'],
  computed: {
    chartOption() {
      return {
        series: [{
          type: 'wordCloud', // 注意这里是全小写
          shape: 'circle',
          data: this.data || [{ name: '无数据', value: 10 }]
        }]
      }
    }
  }
}
</script>
