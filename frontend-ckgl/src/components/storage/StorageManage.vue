<template>
  <div class="container">
    <!-- 预警信息区域 -->
    <!-- 预警信息区域 -->
    <div v-if="warningStorages.length > 0" class="warning-section">
      <el-tabs v-model="warningTab" type="card">
        <el-tab-pane label="空仓预警" name="empty">
          <el-alert
              title="以下仓库存在空仓预警，请及时补货！"
              type="warning"
              :closable="false"
              show-icon>
          </el-alert>
        </el-tab-pane>
        <el-tab-pane label="超仓预警" name="full">
          <el-alert
              title="以下仓库存在超仓预警，请注意库存管理！"
              type="error"
              :closable="false"
              show-icon>
          </el-alert>
        </el-tab-pane>
      </el-tabs>

      <div class="warning-table-container">
        <el-table
            :data="paginatedWarningData"
            :header-cell-style="warningHeaderStyle"
            border
            height="250px">
          <el-table-column prop="name" label="仓库名称" width="180"></el-table-column>
          <el-table-column prop="count" label="物品数量" width="150" align="center">
            <template slot-scope="scope">
              <el-tag :type="getCountTagType(scope.row.count)" size="medium">
                {{ scope.row.count || 0 }}
                <i v-if="scope.row.count === 0" class="el-icon-warning" style="margin-left: 5px;"></i>
                <i v-if="scope.row.count > 10000" class="el-icon-warning" style="margin-left: 5px;"></i>
                <i v-if="scope.row.count > 1000 && scope.row.count <= 10000" class="el-icon-info" style="margin-left: 5px;"></i>
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="remark" label="备注"></el-table-column>
        </el-table>
      </div>

      <div class="warning-pagination">
        <el-pagination
            @size-change="handleWarningSizeChange"
            @current-change="handleWarningCurrentChange"
            :current-page="warningPageNum"
            :page-sizes="[5]"
            :page-size="warningPageSize"
            layout="prev, pager, next"
            :total="filteredWarningStorages.length">
        </el-pagination>
      </div>
    </div>

    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input
          v-model="name"
          placeholder="请输入仓库名"
          suffix-icon="el-icon-search"
          style="width: 200px;"
          @keyup.enter.native="loadPost">
      </el-input>
      <el-button type="primary" style="margin-left: 5px;" @click="loadPost">查询</el-button>
      <el-button type="success" @click="resetParam">重置</el-button>
      <el-button type="primary" style="margin-left: 5px;" @click="add">新增</el-button>
    </div>

    <!-- 主表格区域 -->
    <div class="table-container">
      <el-table
          :data="tableData"
          :header-cell-style="{ background: '#f2f5fc', color: '#555555' }"
          border
          height="100%">
        <el-table-column prop="id" label="ID" width="60"></el-table-column>
        <el-table-column prop="name" label="仓库名" width="180"></el-table-column>
        <el-table-column prop="count" label="物品数量" width="150" align="center">
          <template slot-scope="scope">
            <el-tag :type="getCountTagType(scope.row.count)" size="medium">
              {{ scope.row.count || 0 }}
              <i v-if="scope.row.count === 0" class="el-icon-warning" style="margin-left: 5px;"></i>
              <i v-if="scope.row.count > 10000" class="el-icon-warning" style="margin-left: 5px;"></i>
              <i v-if="scope.row.count > 8000 && scope.row.count <= 10000" class="el-icon-info" style="margin-left: 5px;"></i>
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注"></el-table-column>
        <el-table-column prop="operate" label="操作" width="180">
          <template slot-scope="scope">
            <el-button size="small" type="success" @click="mod(scope.row)">编辑</el-button>
            <el-popconfirm
                title="确定删除吗？"
                @confirm="del(scope.row.id)"
                style="margin-left: 5px;">
              <el-button slot="reference" size="small" type="danger">删除</el-button>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 分页 -->
    <div class="pagination-bar">
      <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="pageNum"
          :page-sizes="[5, 10, 20,30]"
          :page-size="pageSize"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total">
      </el-pagination>
    </div>

    <!-- 编辑对话框 -->
    <el-dialog
        title="提示"
        :visible.sync="centerDialogVisible"
        width="30%"
        center>
      <el-form ref="form" :rules="rules" :model="form" label-width="80px">
        <el-form-item label="仓库名" prop="name">
          <el-col :span="20">
            <el-input v-model="form.name"></el-input>
          </el-col>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-col :span="20">
            <el-input type="textarea" v-model="form.remark"></el-input>
          </el-col>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="centerDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="save">确 定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: "StorageManage",
  data() {
    return {
      warningPageSize: 5,
      warningPageNum: 1,
      // 预警相关数据
      warningStorages: [],
      warningTab: 'empty',
      // 原有数据保持不变
      tableData: [],
      pageSize:10,
      pageNum:1,
      total:0,
      name:'',
      centerDialogVisible:false,
      form:{
        id:'',
        name:'',
        remark:''
      },
      rules: {
        name: [
          {required: true, message: '请输入仓库名', trigger: 'blur'}
        ]
      }
    }
  },
  computed: {
    // 计算当前显示的预警仓库
    currentWarningStorages() {
      if (this.warningTab === 'empty') {
        return this.warningStorages.filter(item => item.count === 0);
      } else {
        return this.warningStorages.filter(item => item.count > 10000);
      }
    },
    // 计算当前显示的预警仓库
    filteredWarningStorages() {
      if (this.warningTab === 'empty') {
        return this.warningStorages.filter(item => item.count === 0);
      } else {
        return this.warningStorages.filter(item => item.count > 10000);
      }
    },
    // 分页后的预警数据
    paginatedWarningData() {
      const start = (this.warningPageNum - 1) * this.warningPageSize;
      const end = start + this.warningPageSize;
      return this.filteredWarningStorages.slice(start, end);
    }
  },
  methods:{

    // 预警分页方法
    handleWarningSizeChange(val) {
      this.warningPageSize = val;
      this.warningPageNum = 1;
    },
    handleWarningCurrentChange(val) {
      this.warningPageNum = val;
    },
    // 新增预警相关方法
    async loadWarningData() {
      try {
        // 并发获取仓库列表和数量统计
        const [listRes, statsRes] = await Promise.all([
          this.$axios.get(`${this.$httpUrl}/storage/list`),
          this.$axios.get(`${this.$httpUrl}/storage/number`)
        ]);

        if (listRes.data.code === 200 && statsRes.data.code === 200) {
          const storageMap = {};
          // 创建数量映射，初始所有仓库数量为0
          listRes.data.data.forEach(storage => {
            storageMap[storage.name] = 0;
          });

          // 更新有返回值的仓库数量
          statsRes.data.data.forEach(item => {
            storageMap[item.name] = item.value;
          });

          // 合并数量信息
          this.warningStorages = listRes.data.data.map(storage => {
            return {
              id: storage.id,
              name: storage.name,
              count: storageMap[storage.name] || 0,
              remark: storage.remark || ''
            };
          });
        }
      } catch (error) {
        console.error('获取预警数据失败:', error);
      }
    },

    getCountTagType(count) {
      if (count === 0) return 'danger';       // 空仓
      if (count > 10000) return 'danger';     // 超仓
      if (count > 8000) return 'warning';     // 超过1000
      if(count <100) return 'warning';
      return 'success';                       // 正常
    },

    warningHeaderStyle() {
      return {
        background: '#f2f5fc',
        color: '#555555',
        fontWeight: 'bold'
      };
    },
    resetForm() {
      this.$refs.form.resetFields();
    },
    async del(id) {
      try {
        const res = await this.$axios.get(`${this.$httpUrl}/storage/del?id=${id}`);

        if(res.data.code === 200) {
          this.$message.success('删除成功！');
          this.loadPost();
        } else {
          // 根据后端返回的错误信息显示不同的提示
          if(res.data.code === 500 && res.data.msg.includes('关联')) {
            this.$message.error('删除失败：该仓库存在关联数据，请先处理关联项');
          } else {
            this.$message.error(res.data.msg || '删除失败');
          }
        }
      } catch (error) {
        console.error('删除出错:', error);
        if(error.response && error.response.status === 500) {
          this.$message.error('删除失败：该仓库可能被其他数据引用');
        } else {
          this.$message.error('删除请求失败，请检查网络');
        }
      }
    },
    mod(row){
      this.centerDialogVisible = true
      this.$nextTick(()=>{
        //赋值到表单
        this.form.id = row.id
        this.form.name = row.name
        this.form.remark = row.remark
      })
    },
    add(){

      this.centerDialogVisible = true
      this.$nextTick(()=>{
        this.resetForm()
      })
      this.form.id = ''; // 确保新增时ID为空

    },
    doSave(){
      this.$axios.post(this.$httpUrl+'/storage/save',this.form).then(res=>res.data).then(res=>{
        console.log(res)
        if(res.code==200){

          this.$message({
            message: '操作成功！',
            type: 'success'
          });
          this.centerDialogVisible = false
          this.loadPost()
          this. resetForm()
        }else{
          this.$message({
            message: '操作失败！',
            type: 'error'
          });
        }

      })
    },
    doMod(){
      this.$axios.post(this.$httpUrl+'/storage/update',this.form).then(res=>res.data).then(res=>{
        console.log(res)
        if(res.code==200){

          this.$message({
            message: '操作成功！',
            type: 'success'
          });
          this.centerDialogVisible = false
          this.loadPost()
          this. resetForm()
        }else{
          this.$message({
            message: '操作失败！',
            type: 'error'
          });
        }

      })
    },
    save(){
      this.$refs.form.validate((valid) => {
        if (valid) {
          if(this.form.id){
            this.doMod();
          }else{
            this.doSave();
          }
        } else {
          console.log('error submit!!');
          return false;
        }
      });

    },
    handleSizeChange(val) {
      console.log(`每页 ${val} 条`);
      this.pageNum=1
      this.pageSize=val
      this.loadPost()
    },
    handleCurrentChange(val) {
      console.log(`当前页: ${val}`);
      this.pageNum=val
      this.loadPost()
    },
    resetParam(){
      this.name=''
      this.loadPost()
    },
    // 修改原有方法，添加预警数据加载
    // 修改loadPost方法，合并数量信息
    loadPost() {
      this.$axios.post(this.$httpUrl+'/storage/listPage',{
        pageSize: this.pageSize,
        pageNum: this.pageNum,
        param: {
          name: this.name
        }
      }).then(res => res.data).then(res => {
        if(res.code == 200){
          // 先保存原始表格数据
          const tableData = res.data;

          // 获取数量统计
          this.$axios.get(`${this.$httpUrl}/storage/number`).then(statsRes => {
            if(statsRes.data.code === 200) {
              const countMap = {};
              // 创建数量映射，初始所有仓库数量为0
              tableData.forEach(item => {
                countMap[item.name] = 0;
              });

              // 更新有返回值的仓库数量
              statsRes.data.data.forEach(item => {
                countMap[item.name] = item.value;
              });

              // 合并数量信息到表格数据
              this.tableData = tableData.map(item => {
                return {
                  ...item,
                  count: countMap[item.name] || 0
                };
              });

              this.total = res.total;
              // 加载预警数据
              this.loadWarningData();
            }
          });
        } else {
          alert('获取数据失败');
        }
      });
    }
  },
  beforeMount() {
    this.loadPost()
  }
}
</script>

<style scoped>

/* 预警区域样式 */
.warning-section {
  margin-bottom: 20px;
  padding: 15px;
  background-color: #fffaf6;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.08);
}

.warning-table-container {
  height: 200px;
  overflow: hidden;
}

.warning-table {
  width: 100%;
}

.warning-pagination {
  margin-top: 10px;
  text-align: center;
}

/* 表格样式优化 */
.el-table {
  width: 100% !important;
}

.el-table::before {
  height: 0;
}
/* 新增样式 */
.count-warning {
  color: #E6A23C;
  font-weight: bold;
}

.count-danger {
  color: #F56C6C;
  font-weight: bold;
}
/* 新增样式 */
.warning-count {
  color: #F56C6C;
  font-weight: bold;
}
/* 预警区域样式 */
.warning-section {
  margin-bottom: 20px;
  padding: 15px;
  background-color: #fffaf6;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.08);
}

.warning-table {
  margin-top: 10px;
}

</style>
<style scoped>
/* 基础容器样式 */
.container {
  padding: 20px;
  height: 90vh;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  overflow: hidden;
}

/* 预警区域样式 */
.warning-section {
  flex-shrink: 0;
  margin-bottom: 15px;
  background-color: #fffaf6;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.warning-table-container {
  max-height: 300px;
  overflow-y: auto;
}

.warning-table {
  width: 100%;
  min-width: 600px;
}

/* 搜索栏样式 */
.search-bar {
  flex-shrink: 0;
  margin-bottom: 15px;
  padding: 10px 0;
  display: flex;
  align-items: center;
}

/* 主表格容器 */
.table-container {
  flex: 1;
  overflow: hidden;
  margin-bottom: 15px;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

/* 分页栏样式 */
.pagination-bar {
  flex-shrink: 0;
  padding: 10px 0;
  text-align: center;
}

/* 表格样式优化 */
.el-table {
  width: 100% !important;
}

.el-table::before {
  height: 0;
}

/* 滚动条美化 */
.warning-table-container::-webkit-scrollbar,
.el-table__body-wrapper::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.warning-table-container::-webkit-scrollbar-thumb,
.el-table__body-wrapper::-webkit-scrollbar-thumb {
  background-color: rgba(0,0,0,0.2);
  border-radius: 4px;
}

.warning-table-container::-webkit-scrollbar-track,
.el-table__body-wrapper::-webkit-scrollbar-track {
  background: rgba(0,0,0,0.05);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .container {
    padding: 10px;
  }

  .search-bar {
    flex-wrap: wrap;
  }

  .search-bar > * {
    margin-bottom: 8px;
    width: 100%;
  }

  .warning-table {
    min-width: 100%;
  }

  .warning-table-container {
    max-height: 200px;
  }

  .el-dialog {
    width: 90% !important;
  }
}

/* 预警标签样式 */
.warning-count {
  color: #F56C6C;
  font-weight: bold;
}
</style>
