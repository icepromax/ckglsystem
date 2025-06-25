<template>
  <div class="home-container">
    <div class="welcome-section">
      <h1 class="welcome-title">{{'欢迎你！'+user.name}}</h1>
      <el-button
          type="primary"
          @click="showEditDialog"
          class="edit-button">
        编辑个人信息
      </el-button>
      <div class="welcome-animation">
        <div class="circle circle-1"></div>
        <div class="circle circle-2"></div>
        <div class="circle circle-3"></div>
      </div>
    </div>

    <transition name="fade" mode="out-in">
      <el-descriptions class="user-info-card" title="个人信息" :column="2" size="20" border>
        <el-descriptions-item>
          <template slot="label">
            <i class="el-icon-s-custom"></i>
            账号
          </template>
          <span class="info-value">{{user.no}}</span>
        </el-descriptions-item>
        <el-descriptions-item>
          <template slot="label">
            <i class="el-icon-mobile-phone"></i>
            电话
          </template>
          <span class="info-value">{{user.phone}}</span>
        </el-descriptions-item>
        <el-descriptions-item>
          <template slot="label">
            <i class="el-icon-location-outline"></i>
            性别
          </template>
          <el-tag
              :type="user.sex === '1' ? 'primary' : 'danger'"
              class="animated-tag"
              disable-transitions>
            <i :class="user.sex==1?'el-icon-male':'el-icon-female'"></i>
            {{user.sex==1?"男":"女"}}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item>
          <template slot="label">
            <i class="el-icon-tickets"></i>
            角色
          </template>
          <el-tag
              type="success"
              class="animated-tag"
              disable-transitions>
            {{user.roleId==0?"超级管理员":(user.roleId==1?"管理员":"用户")}}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </transition>

    <!-- 个人信息编辑弹窗 -->
    <el-dialog
        title="编辑个人信息"
        :visible.sync="editDialogVisible"
        width="40%"
        center
        class="edit-dialog">

      <el-tabs v-model="activeTab">
        <!-- 基本信息编辑 -->
        <el-tab-pane label="基本信息" name="info">
          <el-form
              ref="infoForm"
              :model="editForm"
              :rules="infoRules"
              label-width="100px">
            <el-form-item label="姓名" prop="name">
              <el-input v-model="editForm.name"></el-input>
            </el-form-item>
            <el-form-item label="电话" prop="phone">
              <el-input v-model="editForm.phone"></el-input>
            </el-form-item>
            <el-form-item label="年龄" prop="age">
              <el-input v-model="editForm.age"></el-input>
            </el-form-item>
            <el-form-item label="性别" prop="sex">
              <el-radio-group v-model="editForm.sex">
                <el-radio label="1">男</el-radio>
                <el-radio label="0">女</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <!-- 修改密码 -->
        <el-tab-pane label="修改密码" name="password">
          <el-form
              ref="pwdForm"
              :model="pwdForm"
              :rules="pwdRules"
              label-width="120px">
            <el-form-item label="原密码" prop="oldPassword">
              <el-input
                  v-model="pwdForm.oldPassword"
                  type="password"
                  show-password></el-input>
            </el-form-item>
            <el-form-item label="新密码" prop="newPassword">
              <el-input
                  v-model="pwdForm.newPassword"
                  type="password"
                  show-password></el-input>
            </el-form-item>
            <el-form-item label="确认新密码" prop="confirmPassword">
              <el-input
                  v-model="pwdForm.confirmPassword"
                  type="password"
                  show-password></el-input>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>

      <span slot="footer" class="dialog-footer">
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button
            type="primary"
            @click="submitForm"
            :loading="submitting">
          保存修改
        </el-button>
      </span>
    </el-dialog>

    <div class="date-utils-container">
      <DateUtils></DateUtils>
    </div>
  </div>
</template>

<script>
import DateUtils from "./DateUtils";
export default {
  name: "Home",
  components: {DateUtils},
  data() {
    // 验证手机号
    const validatePhone = (rule, value, callback) => {
      if (!/^1[3-9]\d{9}$/.test(value)) {
        callback(new Error('请输入正确的手机号码'));
      } else {
        callback();
      }
    };

    // 验证确认密码
    const validateConfirmPwd = (rule, value, callback) => {
      if (value !== this.pwdForm.newPassword) {
        callback(new Error('两次输入密码不一致!'));
      } else {
        callback();
      }
    };

    return {
      user: {},
      editDialogVisible: false,
      activeTab: 'info',
      submitting: false,
      editForm: {
        id: '',
        name: '',
        phone: '',
        sex: '',
        no:'',
        password:'',
        age:'',
        roleId:''
      },
      pwdForm: {
        oldPassword: '',
        newPassword: '',
        confirmPassword: ''
      },
      infoRules: {
        name: [
          { required: true, message: '请输入姓名', trigger: 'blur' },
          { min: 2, max: 10, message: '长度在2到10个字符', trigger: 'blur' }
        ],
        phone: [
          { required: true, message: '请输入手机号码', trigger: 'blur' },
          { validator: validatePhone, trigger: 'blur' }
        ]
      },
      pwdRules: {
        oldPassword: [
          { required: true, message: '请输入原密码', trigger: 'blur' }
        ],
        newPassword: [
          { required: true, message: '请输入新密码', trigger: 'blur' },
          { min: 6, max: 16, message: '长度在6到16个字符', trigger: 'blur' }
        ],
        confirmPassword: [
          { required: true, message: '请再次输入新密码', trigger: 'blur' },
          { validator: validateConfirmPwd, trigger: 'blur' }
        ]
      }
    }
  },
  methods: {
    init() {
      const userData = JSON.parse(sessionStorage.getItem('CurUser'));
      this.user = {...userData};
    },

    showEditDialog() {
      this.editDialogVisible = true;
      this.activeTab = 'info';
      // 初始化表单数据
      this.editForm = {
        id: this.user.id,
        name: this.user.name,
        phone: this.user.phone,
        sex: this.user.sex + '',
        no: this.user.no,
        password: this.user.password,
        age: this.user.age,
        roleId: this.user.roleId
      };
      this.pwdForm = {
        oldPassword: '',
        newPassword: '',
        confirmPassword: ''
      };
    },

    submitForm() {
      this.submitting = true;

      if (this.activeTab === 'info') {
        this.updateInfo();
      } else {
        this.updatePassword();
      }
    },

    updateInfo() {
      this.$refs.infoForm.validate(valid => {
        if (valid) {
          this.$axios.post(this.$httpUrl+'/user/update', this.editForm).then(res => {
            if (res.data.code === 200) {
              this.$message.success('个人信息更新成功');
              // 更新本地存储和显示数据
              const updatedUser = {...this.user, ...this.editForm};
              sessionStorage.setItem('CurUser', JSON.stringify(updatedUser));
              this.user = updatedUser;
              this.editDialogVisible = false;
            } else {
              this.$message.error(res.data.msg || '更新失败');
            }
            this.submitting = false;
          }).catch(() => {
            this.submitting = false;
          });
        } else {
          this.submitting = false;
          return false;
        }
      });
    },

    updatePassword() {
      this.$refs.pwdForm.validate(valid => {
        if (valid) {
          this.editForm.password=this.pwdForm.newPassword

          this.$axios.post(this.$httpUrl+'/user/update', this.editForm).then(res => {
            if (res.data.code === 200) {
              this.$message.success('密码修改成功');
              this.editDialogVisible = false;
            } else {
              this.$message.error(res.data.msg || '密码修改失败');
            }
            this.submitting = false;
          }).catch(() => {
            this.submitting = false;
          });
        } else {
          this.submitting = false;
          return false;
        }
      });
    }
  },
  created() {
    this.init();
  }
}
</script>

<style scoped>
/* 原有样式保持不变 */
.home-container {
  text-align: center;
  background: linear-gradient(135deg, #f1f1f3 0%, #f0f0fa 100%);
  margin: 0;
  overflow: hidden;
  position: relative;
  height: 70vh;
}

.welcome-section {
  margin: 30px 0 50px;
  position: relative;
}

.welcome-title {
  font-size: 50px;
  color: #333;
  text-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
  animation: fadeInDown 1s ease;
}

.welcome-animation {
  position: absolute;
  width: 100%;
  height: 100px;
  top: 50%;
  left: 0;
  transform: translateY(-50%);
  z-index: -1;
}

.circle {
  position: absolute;
  border-radius: 50%;
  background: rgba(64,158,255,0.1);
  animation: float 6s infinite ease-in-out;
}

.circle-1 {
  width: 100px;
  height: 100px;
  left: 10%;
  top: 0;
  animation-delay: 0s;
}

.circle-2 {
  width: 150px;
  height: 150px;
  right: 15%;
  top: 20px;
  animation-delay: 1s;
}

.circle-3 {
  width: 70px;
  height: 70px;
  left: 30%;
  top: 50px;
  animation-delay: 2s;
}

.user-info-card {
  width: 90%;
  margin: 0 auto 30px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
  border-radius: 10px;
  overflow: hidden;
  transform: translateY(0);
  transition: all 0.3s ease;
}

.user-info-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 35px rgba(0,0,0,0.15);
}

.info-value {
  font-weight: bold;
  color: #409EFF;
}

.animated-tag {
  animation: pulse 2s infinite;
}

.date-utils-container {
  margin-top: 30px;
  animation: fadeIn 1.5s ease;
}

/* 新增编辑按钮样式 */
.edit-button {
  margin-bottom: 20px;
  padding: 12px 24px;
  font-size: 16px;
  border-radius: 25px;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
  transition: all 0.3s;
}

.edit-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(64, 158, 255, 0.4);
}

/* 编辑弹窗样式 */
.edit-dialog {
  border-radius: 12px;
}

.edit-dialog .el-dialog__header {
  background: linear-gradient(135deg, #409EFF 0%, #66b1ff 100%);
  border-radius: 12px 12px 0 0;
}

.edit-dialog .el-dialog__title {
  color: white;
  font-size: 18px;
}

.edit-dialog .el-tabs__item {
  font-size: 16px;
  padding: 0 20px;
}

.edit-dialog .el-form-item {
  margin-bottom: 22px;
}

/* 动画定义 */
@keyframes fadeInDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-20px);
  }
}

@keyframes pulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
  }
}

.fade-enter-active, .fade-leave-active {
  transition: opacity .5s;
}
.fade-enter, .fade-leave-to {
  opacity: 0;
}

@media (max-width: 768px) {
  .welcome-title {
    font-size: 36px;
  }

  .user-info-card {
    width: 95%;
  }

  .edit-dialog {
    width: 90% !important;
  }
}
</style>
