<template>
  <div class="notice-container">
    <!-- 头部标题和操作按钮 -->
    <div class="notice-header">
      <h2>系统通告</h2>
      <el-button
          v-if="user.roleId === 0"
          type="primary"
          @click="showAddDialog"
          icon="el-icon-plus">
        发布新通告
      </el-button>
    </div>

    <!-- 通告列表 -->
    <div class="notice-list">
      <el-card
          v-for="item in noticeList"
          :key="item.id"
          class="notice-item"
          :class="{ 'is-top': item.isTop }"
          shadow="hover">
        <div slot="header" class="notice-title">
          <el-tag v-if="item.isTop" type="danger" size="mini">置顶</el-tag>
          <span>{{ item.title }}</span>
          <span class="notice-meta">
            {{ item.publisher }} · {{ formatTime(item.publishTime) }}
          </span>
        </div>
        <div class="notice-content-preview">
          {{ previewContent(item.content) }}
        </div>
        <div class="notice-actions">
          <el-button type="text" @click="showDetail(item)">查看详情</el-button>

          <el-button
              v-if="user.roleId === 0"
              type="text"
              @click="toggleTop(item.id, !item.isTop)">
            {{ item.isTop ? '取消置顶' : '置顶' }}
          </el-button>


          <el-button
              v-if="user.roleId === 0"
              type="text"
              @click="showEditDialog(item)">
            编辑
          </el-button>
          &nbsp;
          <el-popconfirm
              v-if="user.roleId === 0"
              title="确定删除该通告吗？"
              @confirm="deleteNotice(item.id)">
            <el-button slot="reference" type="text" style="color: #F56C6C">删除</el-button>
          </el-popconfirm>

        </div>
      </el-card>
    </div>

    <!-- 分页组件 -->
    <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="pageNum"
        :page-sizes="[5, 10, 20]"
        :page-size="pageSize"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total">
    </el-pagination>

    <!-- 通告详情对话框 -->
    <el-dialog
        :title="currentNotice.title"
        :visible.sync="detailVisible"
        width="60%">
      <div class="notice-detail-meta">
        <span>发布人: {{ currentNotice.publisher }}</span>
        <span style="margin-left: 20px;">发布时间: {{ formatFullTime(currentNotice.publishTime) }}</span>
      </div>
      <div class="notice-detail-content">
        {{ currentNotice.content }}
      </div>
    </el-dialog>

    <!-- 新增/编辑通告对话框 -->
    <el-dialog
        :title="isEdit ? '编辑通告' : '发布新通告'"
        :visible.sync="dialogVisible"
        width="60%">
      <el-form :model="noticeForm" :rules="rules" ref="noticeForm">
        <el-form-item label="标题" prop="title">
          <el-input v-model="noticeForm.title" placeholder="请输入通告标题"></el-input>
        </el-form-item>
        <el-form-item label="内容" prop="content">
          <el-input
              type="textarea"
              v-model="noticeForm.content"
              :rows="8"
              placeholder="请输入通告内容"></el-input>
        </el-form-item>
        <el-form-item label="置顶">
          <el-switch v-model="noticeForm.isTop"></el-switch>
        </el-form-item>
      </el-form>
      <span slot="footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitNotice">{{ isEdit ? '更新' : '发布' }}</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
const user =JSON.parse(sessionStorage.getItem('CurUser'))
console.log(user)
export default {
  data() {
    return {
      noticeList: [],
      pageNum: 1,
      pageSize: 10,
      total: 0,
      currentNotice: {},
      detailVisible: false,
      dialogVisible: false,
      isEdit: false,
      noticeForm: {
        id: null,
        title: '',
        content: '',
        isTop: false,
        publisher: ''
      },
      rules: {
        title: [
          { required: true, message: '请输入标题', trigger: 'blur' },
          { max: 100, message: '标题长度不能超过100个字符', trigger: 'blur' }
        ],
        content: [
          { required: true, message: '请输入内容', trigger: 'blur' }
        ]
      },
      user : JSON.parse(sessionStorage.getItem('CurUser'))
    }
  },
  created() {
    this.fetchNotices()
    // 设置发布人默认为当前用户
    this.noticeForm.publisher = this.user.name || '管理员'
  },
  methods: {
    // 获取通告列表
    async fetchNotices() {
      try {
        const res = await this.$axios.get(this.$httpUrl+'/notice/page', {
          params: {
            pageNum: this.pageNum,
            pageSize: this.pageSize
          }
        })
        if (res.data.code === 200) {
          this.noticeList = res.data.data
          this.total = res.data.total
        }
      } catch (error) {
        this.$message.error('获取通告列表失败')
      }
    },

    // 分页大小改变
    handleSizeChange(val) {
      this.pageSize = val
      this.fetchNotices()
    },

    // 当前页改变
    handleCurrentChange(val) {
      this.pageNum = val
      this.fetchNotices()
    },

    // 显示详情
    showDetail(notice) {
      this.currentNotice = notice
      this.detailVisible = true
    },

    // 显示新增对话框
    showAddDialog() {
      this.isEdit = false
      this.noticeForm = {
        id: null,
        title: '',
        content: '',
        isTop: false,
        publisher: this.user.name || '管理员'
      }
      this.dialogVisible = true
    },

    // 显示编辑对话框
    showEditDialog(notice) {
      this.isEdit = true
      this.noticeForm = {
        id: notice.id,
        title: notice.title,
        content: notice.content,
        isTop: notice.isTop,
        publisher: notice.publisher
      }
      this.dialogVisible = true
    },

    // 提交新增/编辑
    submitNotice() {
      this.$refs.noticeForm.validate(async valid => {
        if (valid) {
          try {
            const url = this.isEdit ? '/notice/update' : '/notice/add'
            const res = await this.$axios.post(this.$httpUrl+url, this.noticeForm)

            if (res.data.code === 200) {
              this.$message.success(this.isEdit ? '更新成功' : '发布成功')
              this.dialogVisible = false
              this.fetchNotices()
            }
          } catch (error) {
            this.$message.error(this.isEdit ? '更新失败' : '发布失败')
          }
        }
      })
    },

    // 删除通告
    async deleteNotice(id) {
      try {
        const res = await this.$axios.delete(this.$httpUrl+`/notice/delete/${id}`)
        if (res.data.code === 200) {
          this.$message.success('删除成功')
          this.fetchNotices()
        }
      } catch (error) {
        this.$message.error('删除失败')
      }
    },

    // 置顶/取消置顶

    async toggleTop(id, isTop) {
      try {
        const res = await this.$axios.patch(this.$httpUrl+`/notice/${id}/top`, { isTop });

        if (res.data.code === 200) {
          this.$message.success(isTop ? '已置顶' : '已取消置顶');
          this.fetchNotices();
        }
      } catch (error) {
        this.$message.error('操作失败: ' + error.message);
        console.error('Error details:', error.response);
      }
    },

    // 内容预览
    previewContent(content) {
      return content.length > 100 ? content.substring(0, 100) + '...' : content
    },

    // 格式化时间
    formatTime(time) {
      if (!time) return ''
      const date = new Date(time)
      return `${date.getFullYear()}-${(date.getMonth()+1).toString().padStart(2,'0')}-${date.getDate().toString().padStart(2,'0')}`
    },

    // 完整时间格式化
    formatFullTime(time) {
      if (!time) return ''
      const date = new Date(time)
      return `${date.getFullYear()}-${(date.getMonth()+1).toString().padStart(2,'0')}-${date.getDate().toString().padStart(2,'0')} ${date.getHours().toString().padStart(2,'0')}:${date.getMinutes().toString().padStart(2,'0')}:${date.getSeconds().toString().padStart(2,'0')}`
    }
  }
}
</script>
<style scoped>
.notice-container {
  padding: 20px;
  height: calc(100vh - 120px); /* 根据实际情况调整 */
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.notice-list {
  flex: 1;
  overflow-y: auto;
  margin-bottom: 20px;
}

.notice-item {
  margin-bottom: 15px;
  transition: all 0.3s;
  /* 添加以下样式防止内容过长 */
  max-height: 200px; /* 可根据需要调整 */
  overflow: hidden;
  position: relative;
}

.notice-content-preview {
  color: #606266;
  line-height: 1.6;
  margin-bottom: 10px;
  /* 添加文本溢出处理 */
  display: -webkit-box;
  -webkit-line-clamp: 3; /* 显示3行 */
  -webkit-box-orient: vertical;
  overflow: hidden;
  text-overflow: ellipsis;
}

.notice-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.notice-list {
  margin-bottom: 20px;
}

.notice-item {
  margin-bottom: 15px;
  transition: all 0.3s;
}

.notice-item.is-top {
  border-left: 3px solid #f56c6c;
}

.notice-item:hover {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.notice-title {
  display: flex;
  align-items: center;
}

.notice-title .el-tag {
  margin-right: 10px;
}

.notice-meta {
  margin-left: auto;
  color: #909399;
  font-size: 12px;
}

.notice-content-preview {
  color: #606266;
  line-height: 1.6;
  margin-bottom: 10px;
}

.notice-actions {
  text-align: right;
}

.notice-detail-meta {
  color: #909399;
  font-size: 14px;
  margin-bottom: 20px;
}

.notice-detail-content {
  line-height: 1.8;
  white-space: pre-line;
}
</style>
