<template>
  <div class="loginBody">
    <!-- 背景图片 -->
    <div class="background-image"></div>

    <div class="loginDiv">
      <div class="login-content">
        <h1 class="system-title">仓库管理系统</h1>
        <h1 class="login-title">欢迎登录</h1>
        <el-form :model="loginForm" label-width="80px"
                 :rules="rules" ref="loginForm" class="login-form">
          <el-form-item label="账号" prop="no">
            <el-input type="text" v-model="loginForm.no"
                      autocomplete="off" size="medium" prefix-icon="el-icon-user">
            </el-input>
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input type="password" v-model="loginForm.password"
                      show-password autocomplete="off" size="medium"
                      prefix-icon="el-icon-lock" @keyup.enter.native="confirm">
            </el-input>
          </el-form-item>
          <el-form-item label="验证码" prop="captcha">
            <div class="captcha-container">
              <el-input
                  v-model="loginForm.captcha"
                  placeholder="请输入验证码"
                  @keyup.enter.native="confirm"
                  style="width: 150px; margin-right: 10px;">
              </el-input>
              <canvas
                  ref="captchaCanvas"
                  @click="refreshCaptcha"
                  class="captcha-image"
                  width="120"
                  height="40">
              </canvas>
            </div>
          </el-form-item>
          <el-form-item class="login-btn">
            <el-button type="primary" @click="confirm" :disabled="confirm_disabled" round>
              登 录
            </el-button>
          </el-form-item>
        </el-form>
      </div>

      <!-- 新增帮助链接 -->
      <div class="login-help">
        <span @click="showHelpDialog">没有账号？忘记密码？</span>
      </div>
    </div>

    <!-- 帮助对话框 -->
    <el-dialog
        title="账号帮助"
        :visible.sync="helpDialogVisible"
        width="30%"
        center>
      <div class="help-content">
        <p>如需申请账号或重置密码，请联系以下系统管理员：</p>
        <ul>
          <li><i class="el-icon-user-solid"></i> 超级管理员：(电话：18855079620)</li>
          <li><i class="el-icon-user"></i> 普通管理员： (电话：18855079621)</li>
        </ul>
        <p class="help-tip">请在工作时间（9:00-18:00）联系</p>
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button type="primary" @click="helpDialogVisible = false">确 定</el-button>
      </span>
    </el-dialog>

  </div>
</template>

<script>
export default {
  name: "Login",
  data() {
    return {
      helpDialogVisible: false,
      confirm_disabled: false,
      captchaText: '', // 存储验证码文本
      loginForm: {
        no: '',
        password: '',
        captcha: ''
      },
      rules: {
        no: [
          { required: true, message: '请输入账号', trigger: 'blur' }
        ],
        password: [
          { required: true, message: '请输密码', trigger: 'blur' }
        ],
        captcha: [
          { required: true, message: '请输入验证码', trigger: 'blur' },
          { validator: this.validateCaptcha, trigger: 'blur' }
        ]
      }
    }
  },
  mounted() {

    this.refreshCaptcha();
  },
  methods: {
    showHelpDialog() {
      this.helpDialogVisible = true;
    },
    // 生成随机验证码文本
    generateRandomCode(length = 4) {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 去除容易混淆的字符
      let code = '';
      for (let i = 0; i < length; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      return code;
    },

    // 绘制验证码
    refreshCaptcha() {
      const canvas = this.$refs.captchaCanvas;
      const ctx = canvas.getContext('2d');

      // 生成新验证码
      this.captchaText = this.generateRandomCode();

      // 清空画布
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // 绘制背景
      ctx.fillStyle = '#f5f5f5';
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      // 绘制干扰线
      for (let i = 0; i < 5; i++) {
        ctx.strokeStyle = `rgb(${Math.floor(Math.random() * 100)},${Math.floor(Math.random() * 100)},${Math.floor(Math.random() * 100)})`;
        ctx.beginPath();
        ctx.moveTo(Math.random() * canvas.width, Math.random() * canvas.height);
        ctx.lineTo(Math.random() * canvas.width, Math.random() * canvas.height);
        ctx.stroke();
      }

      // 绘制验证码文本
      ctx.font = '24px Arial';
      ctx.fillStyle = '#333';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';

      // 添加文字扭曲效果
      for (let i = 0; i < this.captchaText.length; i++) {
        ctx.save();
        ctx.translate(30 + i * 20, 20);
        ctx.rotate((Math.random() - 0.5) * 0.4);
        ctx.fillText(this.captchaText[i], 0, 0);
        ctx.restore();
      }
    },

    // 验证码校验
    validateCaptcha(rule, value, callback) {
      if (!value) {
        callback(new Error('请输入验证码'));
      } else if (value.toUpperCase() !== this.captchaText) {
        callback(new Error('验证码不正确'));
      } else {
        callback();
      }
    },

    confirm() {
      this.$refs.loginForm.validate((valid) => {
        if (valid) {
          this.confirm_disabled = true;

          // 先验证验证码
          if (this.loginForm.captcha.toUpperCase() !== this.captchaText) {
            this.$message.error('验证码错误！');
            this.refreshCaptcha();
            this.confirm_disabled = false;
            return;
          }

          this.$axios.post(this.$httpUrl+'/user/login', this.loginForm)
              .then(res => res.data)
              .then(res => {
                if(res.code == 200) {
                  sessionStorage.setItem("CurUser", JSON.stringify(res.data.user))
                  this.$store.commit("setMenu", res.data.menu)
                  this.$router.replace('/home');
                } else {
                  this.$message.error(res.msg || '校验失败，用户名或密码错误！');
                  this.refreshCaptcha();
                }
              })
              .catch(() => {
                this.$message.error('登录失败，请检查网络连接！');
                this.refreshCaptcha();
              })
              .finally(() => {
                this.confirm_disabled = false;
              });
        }
      });
    }
  }
}
</script>


<style scoped>
/* 新增帮助链接样式 */
.login-help {
  margin-top: 15px;
  text-align: center;
  font-size: 14px;
  color: #666;
}

.login-help span {
  color: #3a7bd5;
  cursor: pointer;
  transition: color 0.3s;
}

.login-help span:hover {
  color: #00d2ff;
  text-decoration: underline;
}

/* 帮助对话框内容样式 */
.help-content {
  line-height: 1.8;
}

.help-content ul {
  padding-left: 20px;
  margin: 10px 0;
}

.help-content li {
  margin-bottom: 8px;
  list-style-type: none;
  padding-left: 25px;
  position: relative;
}

.help-content li i {
  position: absolute;
  left: 0;
  top: 3px;
  color: #3a7bd5;
}

.help-tip {
  font-size: 12px;
  color: #999;
  margin-top: 15px;
  text-align: center;
}
/* 新增系统标题样式 */
.system-title {
  margin: 0 0 10px 0;
  text-align: center;
  color: #3a7bd5;
  font-size: 32px;
  font-weight: bold;
  text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.2);
  background: linear-gradient(to right, #3a7bd5, #00d2ff);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  animation: fadeInDown 0.8s ease-out;
}


.loginBody {
  position: absolute;
  width: 100%;
  height: 100%;
  overflow: hidden;
  display: flex;
  justify-content: center;
  align-items: center;
}

.background-image {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  background-image: url('~@/assets/login.png');
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.6;
  z-index: 1;
}

.loginDiv {
  position: relative;
  width: 420px;
  padding: 40px;
  background: rgba(255, 255, 255, 0.85);
  border-radius: 10px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
  z-index: 2;
  animation: fadeInUp 0.8s ease-out;
}

/* 新增验证码样式 */
.captcha-container {
  display: flex;
  align-items: center;
}

.captcha-image {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  cursor: pointer;
  background: #f5f5f5;
}

/* 其他原有样式保持不变... */
</style>
<style scoped>
.loginBody {
  position: absolute;
  width: 100%;
  height: 100%;
  overflow: hidden;
  display: flex;
  justify-content: center;
  align-items: center;
}

.background-image {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  background-image: url('~@/assets/login.png'); /* 替换为你的背景图片路径 */
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.6; /* 调整透明度 */
  z-index: 1;
}

.loginDiv {
  position: relative;
  width: 420px;
  padding: 40px;
  background: rgba(255, 255, 255, 0.85); /* 提高表单区域透明度 */
  border-radius: 10px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
  z-index: 2;
  animation: fadeInUp 0.8s ease-out;
}

.login-content {
  width: 100%;
}

.login-title {
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', sans-serif;
  margin: 0 0 20px 0;
  text-align: center;
  color: #333;
  font-size: 24px;
  font-weight: 800;
}

.login-form {
  margin-top: 20px;
}

.login-form /deep/ .el-form-item__label {
  color: #666;
  font-weight: 500;
}

.login-form /deep/ .el-input__inner {
  border-radius: 20px;
  padding-left: 35px;
}

.login-form /deep/ .el-input__prefix {
  left: 10px;
}

.login-btn {
  margin-top: 30px;
  text-align: center;
}

.login-btn /deep/ .el-button {
  width: 100%;
  padding: 12px 20px;
  font-size: 16px;
  border-radius: 20px;
  background: linear-gradient(to right, #3a7bd5, #00d2ff);
  border: none;
  transition: all 0.3s ease;
}

.login-btn /deep/ .el-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(58, 123, 213, 0.4);
}

.login-footer {
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  color: #666;
}

.login-footer a {
  color: #3a7bd5;
  text-decoration: none;
  transition: color 0.3s;
}

.login-footer a:hover {
  color: #00d2ff;
  text-decoration: underline;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
