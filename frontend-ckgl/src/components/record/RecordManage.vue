<template>
  <div class="record-manage-container">
    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input
          v-model="name"
          placeholder="请输入物品名"
          suffix-icon="el-icon-search"
          style="width: 200px;"
          @keyup.enter.native="loadPost">
      </el-input>
      <el-select
          v-model="storage"
          placeholder="请选择仓库"
          style="margin-left: 5px; width: 180px;">
        <el-option
            v-for="item in storageData"
            :key="item.id"
            :label="item.name"
            :value="item.id">
        </el-option>
      </el-select>
      <el-select
          v-model="goodstype"
          placeholder="请选择分类"
          style="margin-left: 5px; width: 180px;">
        <el-option
            v-for="item in goodstypeData"
            :key="item.id"
            :label="item.name"
            :value="item.id">
        </el-option>
      </el-select>

      <el-button type="primary" style="margin-left: 5px;" @click="loadPost">查询</el-button>
      <el-button type="success" @click="resetParam">重置</el-button>
    </div>

    <!-- 表格区域 -->
    <div class="table-container">
      <el-table
          :data="tableData"
          :header-cell-style="{ background: '#f2f5fc', color: '#555555' }"
          border
          style="width: 100%"
          height="calc(100vh - 220px)">
        <el-table-column prop="id" label="ID" width="80" align="center"></el-table-column>
        <el-table-column prop="goodsname" label="物品名" width="150" show-overflow-tooltip></el-table-column>
        <el-table-column prop="storagename" label="仓库" width="150" show-overflow-tooltip></el-table-column>
        <el-table-column prop="goodstypename" label="分类" width="150" show-overflow-tooltip></el-table-column>
        <el-table-column prop="adminname" label="操作人" width="150" show-overflow-tooltip></el-table-column>
        <el-table-column prop="username" label="申请人" width="150" show-overflow-tooltip></el-table-column>
        <el-table-column prop="count" label="数量" width="120" align="center">
          <template slot-scope="scope">
            <el-tag :type="scope.row.count > 0 ? 'success' : 'danger'">
              {{ scope.row.count > 0 ? '+' + scope.row.count : scope.row.count }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createtime" label="操作时间" width="180" align="center"></el-table-column>
        <el-table-column prop="remark" label="备注" width="180" show-overflow-tooltip></el-table-column>
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
  </div>
</template>

<script>
    export default {
        name: "RecordManage",
        data() {

            return {
                user : JSON.parse(sessionStorage.getItem('CurUser')),
                storageData:[],
                goodstypeData:[],
                tableData: [],
                pageSize:10,
                pageNum:1,
                total:0,
                name:'',
                storage:'',
                goodstype:'',
                centerDialogVisible:false,
                form:{
                    id:'',
                    name:'',
                    storage:'',
                    goodstype:'',
                    count:'',
                    remark:''
                },
            }
        },
        methods:{
            formatStorage(row){
                let temp =  this.storageData.find(item=>{
                    return item.id == row.storage
                })

                return temp && temp.name
            },
            formatGoodstype(row){
                let temp =  this.goodstypeData.find(item=>{
                    return item.id == row.goodstype
                })

                return temp && temp.name
            },
            resetForm() {
                this.$refs.form.resetFields();
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
                this.storage=''
                this.goodstype=''
                //this.loadStorage()
                //this.loadGoodstype()
                this.loadPost()
            },
            loadStorage(){
                this.$axios.get(this.$httpUrl+'/storage/list').then(res=>res.data).then(res=>{
                    console.log(res)
                    if(res.code==200){
                        this.storageData=res.data
                    }else{
                        alert('获取数据失败')
                    }

                })
            },
            loadGoodstype(){
                this.$axios.get(this.$httpUrl+'/goodstype/list').then(res=>res.data).then(res=>{
                    console.log(res)
                    if(res.code==200){
                        this.goodstypeData=res.data
                    }else{
                        alert('获取数据失败')
                    }

                })
            },
            loadPost(){
                this.$axios.post(this.$httpUrl+'/record/listPage',{
                    pageSize:this.pageSize,
                    pageNum:this.pageNum,
                    param:{
                        name:this.name,
                        goodstype:this.goodstype+'',
                        storage:this.storage+'',
                        roleId:this.user.roleId+'',
                        userId:this.user.id+''
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
            },
        },
        beforeMount() {
            this.loadStorage()
            this.loadGoodstype()
            this.loadPost()

        }
    }
</script>

<style scoped>
/* 基础容器样式 */
.record-manage-container {
  padding: 20px;
  height: 90vh;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  background-color: #f5f7fa;
}

/* 搜索栏样式 */
.search-bar {
  margin-bottom: 15px;
  flex-shrink: 0;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 5px;
  padding: 10px;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

/* 表格容器样式 */
.table-container {
  flex: 1;
  overflow: hidden;
  margin-bottom: 15px;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
  padding: 10px;
}

/* 分页栏样式 */
.pagination-bar {
  flex-shrink: 0;
  text-align: center;
  padding: 10px;
  background-color: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.05);
}

/* 表格样式优化 */
.el-table {
  border-radius: 4px;
}

.el-table::before {
  height: 0;
}

/* 数量标签样式 */
.el-tag {
  font-weight: bold;
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

/* 响应式调整 */
@media (max-width: 992px) {
  .search-bar {
    flex-direction: column;
    align-items: flex-start;
  }

  .search-bar > * {
    margin-left: 0 !important;
    margin-bottom: 5px;
    width: 100%;
  }

  .el-table {
    height: calc(100vh - 260px) !important;
  }
}

@media (max-width: 768px) {
  .record-manage-container {
    padding: 10px;
  }

  .el-table-column {
    width: auto !important;
  }
}
</style>
