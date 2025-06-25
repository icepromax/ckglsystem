<template>
  <div class="container">
    <div class="search-bar">
      <el-input
          v-model="name"
          placeholder="请输入分类名"
          suffix-icon="el-icon-search"
          style="width: 200px;"
          @keyup.enter.native="loadPost">
      </el-input>
      <el-button type="primary" style="margin-left: 5px;" @click="loadPost">查询</el-button>
      <el-button type="success" @click="resetParam">重置</el-button>
      <el-button type="primary" style="margin-left: 5px;" @click="add">新增</el-button>
    </div>

    <div class="table-container">
      <el-table
          :data="tableData"
          :header-cell-style="{ background: '#f2f5fc', color: '#555555' }"
          border
          style="width: 100%"
          height="calc(100vh - 220px)">
        <el-table-column prop="id" label="ID" width="60"></el-table-column>
        <el-table-column prop="name" label="分类名" width="180"></el-table-column>
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

    <el-dialog
        title="提示"
        :visible.sync="centerDialogVisible"
        width="30%"
        center>
      <el-form ref="form" :rules="rules" :model="form" label-width="80px">
        <el-form-item label="分类名" prop="name">
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
        name: "GoodstypeManage",
        data() {
            return {
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
                        {required: true, message: '请输入分类名', trigger: 'blur'}
                    ]
                }
            }
        },
        methods:{
            resetForm() {
                this.$refs.form.resetFields();
            },
          async del(id) {
            try {
              // 先确认删除
              await this.$confirm('确定要删除此分类吗？', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
              });

              const res = await this.$axios.get(`${this.$httpUrl}/goodstype/del?id=${id}`);

              if(res.data.code === 200) {
                this.$message.success('删除成功！');
                this.loadPost();
              } else {
                // 根据后端返回的错误信息显示不同的提示
                if(res.data.code === 500 && res.data.msg.includes('关联')) {
                  this.$message.error('删除失败：该分类下存在关联物品，请先处理关联物品');
                } else {
                  this.$message.error(res.data.msg || '删除失败');
                }
              }
            } catch (error) {
              if(error !== 'cancel') { // 用户取消删除不报错
                console.error('删除出错:', error);
                if(error.response && error.response.status === 500) {
                  this.$message.error('删除失败：该分类可能被物品引用');
                } else {
                  this.$message.error('删除请求失败，请检查网络');
                }
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

            },
            doSave(){
                this.$axios.post(this.$httpUrl+'/goodstype/save',this.form).then(res=>res.data).then(res=>{
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
                this.$axios.post(this.$httpUrl+'/goodstype/update',this.form).then(res=>res.data).then(res=>{
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
            loadPost(){
                this.$axios.post(this.$httpUrl+'/goodstype/listPage',{
                    pageSize:this.pageSize,
                    pageNum:this.pageNum,
                    param:{
                        name:this.name
                    }
                }).then(res=>res.data).then(res=>{
                    console.log(res)
                    if(res.code==200){
                        this.tableData=res.data
                        this.total=res.total
                    }else{
                        alert('获取数据失败')
                    }

                })
            }
        },
        beforeMount() {
            this.loadPost()
        }
    }
</script>

<style scoped>
/* 基础容器样式 */
.container {
  padding: 20px;
  height: 80vh;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
}

/* 搜索栏样式 */
.search-bar {
  margin-bottom: 15px;
  flex-shrink: 0;
}

/* 表格容器样式 */
.table-container {
  flex: 1;
  overflow: hidden;
  margin-bottom: 15px;
}

/* 分页栏样式 */
.pagination-bar {
  flex-shrink: 0;
  text-align: center;
}

/* 表格滚动条美化 */
.el-table::before {
  height: 0; /* 去除表格底部边框 */
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
    margin-bottom: 5px;
  }

  .el-table {
    height: calc(100vh - 250px) !important;
  }
}

/* 滚动条美化 */
.el-table__body-wrapper::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.el-table__body-wrapper::-webkit-scrollbar-thumb {
  background-color: rgba(0,0,0,0.2);
  border-radius: 3px;
}

.el-table__body-wrapper::-webkit-scrollbar-track {
  background: rgba(0,0,0,0.05);
}
</style>
