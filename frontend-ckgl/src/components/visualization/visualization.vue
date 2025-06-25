<template>
  <div class="dashboard-container">


    <div class="chart-container">
      <!-- 左上：用户分布柱状图 -->
      <div class="chart-item">
        <h3>用户性别分布</h3>
        <user-distribution-chart
            :total="userData.total"
            :male="userData.male"
            :female="userData.female"
        />
      </div>

      <!-- 右上：物品类别对比柱状图 -->
      <div class="chart-item">
        <h3>物品类别所含物品种类数量对比</h3>
        <category-comparison-chart :data="categoryData" />
      </div>

      <!-- 左下：物品名词云 -->
      <div class="chart-item">
        <h3>物品名词云</h3>
        <goods-wordcloud :data="wordcloudData" />
      </div>

      <!-- 右下：仓库类别占比饼图 -->
      <div class="chart-item">
        <h3>仓库物品占比(只展示存储了物品类别的仓库)</h3>
        <storage-pie-chart :data="storageData" />
      </div>
    </div>
  </div>
</template>

<script>
import UserDistributionChart from './UserDistributionChart.vue'
import CategoryComparisonChart from './CategoryComparisonChart.vue'
import GoodsWordcloud from './GoodsWordcloud.vue'
import StoragePieChart from './StoragePieChart.vue'

export default {
  name: 'Dashboard',
  components: {
    UserDistributionChart,
    CategoryComparisonChart,
    GoodsWordcloud,
    StoragePieChart
  },
  data() {
    return {
      userData: {
        total: 0,
        male: 0,
        female: 0
      },
      categoryData: [],
      wordcloudData: [],
      storageData: []
    }
  },
  created() {
    this.fetchData()
  },
  methods: {
    async fetchData() {
      try {
        // 模拟API请求获取数据
        // 实际项目中替换为真实的API调用
        const responses = await Promise.all([
          this.$axios.get(this.$httpUrl+'/user/stats'),
          this.$axios.get(this.$httpUrl+'/goodstype/number'),
          this.$axios.get(this.$httpUrl+'/goods/number'),
          this.$axios.get(this.$httpUrl+'/storage/number')
        ])

        const statsResponse = responses[0].data;
        const goodstypeResponse = responses[1].data;
        const goodsResponse =responses[2].data;
        const storageResponse = responses[3].data;
        this.userData = {
          total: statsResponse.data.total || 0,
          male: statsResponse.data.male || 0,
          female: statsResponse.data.female || 0
        };

        this.categoryData = goodstypeResponse.data.map(item => ({
          name: item.name,
          value: item.count || 0  // 确保count为null/undefined时默认为0
        }));

        this.wordcloudData = goodsResponse.data.map(item=>({
          name: item.name,
          value: item.value || 0
        }))

        this.storageData= storageResponse.data.map(item=>({
              name: item.name,
              value: item.value || 0
        }))

      } catch (error) {
        console.error('获取数据失败-------:', error)
        // 使用模拟数据
        this.loadMockData()
      }
    },
    loadMockData() {
      this.userData = {
        total: 156,
        male: 92,
        female: 64
      }

      this.categoryData = [
        { name: '电子产品', value: 342 },
        { name: '办公用品', value: 256 },
        { name: '生活用品', value: 189 },
        { name: '食品饮料', value: 147 },
        { name: '其他', value: 85 }
      ]

      this.wordcloudData = [
        { name: '笔记本电脑', value: 80 },
        { name: '打印机', value: 65 },
        { name: '办公桌', value: 50 },
        { name: '椅子', value: 45 },
        { name: '显示器', value: 40 },
        { name: '键盘', value: 35 },
        { name: '鼠标', value: 30 },
        { name: '文件夹', value: 28 },
        { name: '笔记本', value: 25 },
        { name: '订书机', value: 20 },
        { name: '笔', value: 18 },
        { name: '矿泉水', value: 15 },
        { name: '零食', value: 12 }
      ]

      this.storageData = [
        { value: 335, name: '电子产品' },
        { value: 310, name: '办公用品' },
        { value: 234, name: '生活用品' },
        { value: 135, name: '食品饮料' },
        { value: 154, name: '其他' }
      ]
    }
  }
}
</script>

<style scoped>
.dashboard-container {

  background-color: #f5f7fa;
}

.header {
  margin-bottom: 30px;
  text-align: center;
}

.chart-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-template-rows: 1fr 1fr;
  gap: 20px;
  height: calc(100vh - 100px);
}

.chart-item {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  padding: 15px;
  display: flex;
  flex-direction: column;
}

.chart-item h3 {
  margin-top: 0;
  margin-bottom: 15px;
  text-align: center;
  color: #333;
}

.chart-item > div {
  flex: 1;
  width: 100%;
  height: calc(100% - 40px);
}
</style>
