<template>
  <el-menu
      background-color="#545c64"
      text-color="#fff"
      active-text-color="#ffd04b"
      style="height: 100%;"
      default-active="/Home"
      :collapse="isCollapse"
      :collapse-transition="false"
      router
      class="custom-aside-menu"
  >
    <el-menu-item index="/Home" class="home-item">
      <i class="el-icon-s-home"></i>
      <span slot="title">首页</span>
    </el-menu-item>

    <!--动态获取菜单-->
    <el-menu-item
        :index="'/'+item.menuclick"
        v-for="(item,i) in menu"
        :key="i"
        class="dynamic-menu-item"
    >
      <i :class="item.menuicon"></i>
      <span slot="title">{{item.menuname}}</span>
    </el-menu-item>
  </el-menu>
</template>

<script>
export default {
  name: "Aside",
  data(){
    return {}
  },
  computed:{
    "menu":{
      get(){
        return this.$store.state.menu
      }
    }
  },
  props:{
    isCollapse:Boolean
  }
}
</script>

<style scoped>
/* 整体菜单样式 */
.custom-aside-menu {
  border-right: none !important;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
}

/* 菜单项通用样式 */
.el-menu-item {
  transition: all 0.3s ease;
  margin: 4px 8px;
  border-radius: 4px;
}

/* 首页菜单项特殊样式 */
.home-item {
  background-color: rgba(84, 92, 100, 0.8) !important;
  font-weight: bold;
}

/* 动态菜单项样式 */
.dynamic-menu-item {
  background-color: rgba(84, 92, 100, 0.6) !important;
}

/* 鼠标悬停效果 */
.el-menu-item:hover {
  background-color: rgba(255, 208, 75, 0.1) !important;
}

/* 激活菜单项样式 */
.el-menu-item.is-active {
  background-color: rgba(255, 208, 75, 0.2) !important;
  box-shadow: inset 3px 0 0 #ffd04b;
}

/* 图标样式调整 */
.el-menu-item i {
  margin-right: 8px;
  font-size: 18px;
  vertical-align: middle;
}

/* 文字样式 */
.el-menu-item span {
  font-size: 14px;
  letter-spacing: 0.5px;
  vertical-align: middle;
}

/* 折叠状态下图标居中 */
.el-menu--collapse .el-menu-item i {
  margin-right: 0;
  font-size: 20px;
}
</style>
