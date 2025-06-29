import Vue from 'vue'
import App from './App.vue'
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css';
import './assets/global.css';
import axios from "axios";
import VueRouter from 'vue-router';
import router from './router';
import store from './store';
import ECharts from 'vue-echarts'
import * as echarts from 'echarts/core'
import { TitleComponent, TooltipComponent } from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'

// 正确导入词云模块
import 'echarts-wordcloud' // 必须单独导入

echarts.use([
  TitleComponent,
  TooltipComponent,
  CanvasRenderer
  // 注意：WordCloudChart 不需要手动注册
])

Vue.component('v-chart', ECharts)



Vue.prototype.$axios=axios;
Vue.prototype.$httpUrl='http://localhost:8002'  //将地址设置为全局
Vue.config.productionTip = false
//Vue.use(ElementUI);
Vue.use(VueRouter);
Vue.use(ElementUI,{size:'small'});
new Vue({
  router,
  store,
  render: h => h(App),
}).$mount('#app')


/**
前端学习笔记02：
main.js定义：main.js是项目的入口文件，项目中所有的页面都会加载main.js。
主要有三个作用：
  1.实例化Vue。
  2.放置项目中经常会用到的插件和CSS样式。
  3.存储全局变量。
**/
