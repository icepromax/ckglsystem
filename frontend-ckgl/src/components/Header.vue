<template>
  <div class="header-container">
    <div class="menu-toggle">
      <i :class="icon" class="toggle-icon" @click="collapse"></i>
    </div>
    <div class="header-title">
        <span class="title-text">仓库管理系统</span>
    </div>
    <div class="user-menu">
      <el-dropdown trigger="hover">
        <div class="avatar">
          <el-avatar :size="36" :src=avatarUrl() class="header-avatar"></el-avatar>
        <span class="user-name">
          {{user.name}}
          <i class="el-icon-arrow-down"></i>
        </span>
        </div>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item @click.native="toUser">
            <i class="el-icon-user"></i> 个人中心
          </el-dropdown-item>
          <el-dropdown-item divided @click.native="logout">
            <i class="el-icon-switch-button"></i> 退出登录
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
export default {
  name: "Header",
  data() {
    return {
      user: JSON.parse(sessionStorage.getItem('CurUser')) || { name: '用户' },
      avatarMap: {
        0: require('@/assets/avatars/avatar0.png'),  // 超级管理员
        1: require('@/assets/avatars/avatar1.png'),   // 管理员
        2: require('@/assets/avatars/avatar2.png')     // 普通用户
      }
    }
  },
  props: {
    icon: {
      type: String,
      required: true
    }
  },
  methods: {
    avatarUrl() {
      // 根据用户角色返回对应的头像
      return this.avatarMap[this.user.roleId]
    },
    toUser() {
      this.$router.push("/Home");
    },
    logout() {
      this.$confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
        center: true,
      })
          .then(() => {
            this.$message({
              type: 'success',
              message: '退出登录成功！'
            });
            sessionStorage.clear();
            this.$router.push("/");
          })
          .catch(() => {
            this.$message({
              type: 'info',
              message: '已取消退出登录'
            });
          });
    },
    collapse() {
      this.$emit('doCollapse');
    }
  }
}
</script>

<style scoped>
.header-container {
  display: flex;
  align-items: center;
  height: 60px;
  padding: 0 20px;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

.menu-toggle {
  display: flex;
  align-items: center;
  margin-right: 16px;
}

.toggle-icon {
  font-size: 20px;
  cursor: pointer;
  transition: all 0.3s;
}

.toggle-icon:hover {
  color: #1890ff;
}

.header-title {
  flex: 1;
  font-size: 22px;
  font-weight: 600;
  text-align: center;
  color: #333;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.header-avatar {
  border: 2px solid #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.12);
}

.title-text {
  vertical-align: middle;
}

.user-menu {
  display: flex;
  align-items: center;
}

.user-name {
  display: inline-flex;
  align-items: center;
  cursor: pointer;
  padding: 0 10px;
  transition: all 0.3s;
}

.user-name:hover {
  color: #1890ff;
}

.el-dropdown-menu__item {
  padding: 0 20px;
  line-height: 36px;
}

.el-dropdown-menu__item i {
  margin-right: 8px;
}
</style>
