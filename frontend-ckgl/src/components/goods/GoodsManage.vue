<template>
  <div class="goods-manage-container">
    <!-- 搜索栏 -->
    <div class="search-bar">
      <el-input
          v-model="name"
          placeholder="请输入物品名"
          suffix-icon="el-icon-search"
          style="width: 200px;"
          @keyup.enter.native="loadPost">
      </el-input>
      <el-select v-model="storage" placeholder="请选择仓库" style="margin-left: 5px;width: 180px;">
        <el-option
            v-for="item in storageData"
            :key="item.id"
            :label="item.name"
            :value="item.id">
        </el-option>
      </el-select>
      <el-select v-model="goodstype" placeholder="请选择分类" style="margin-left: 5px;width: 180px;">
        <el-option
            v-for="item in goodstypeData"
            :key="item.id"
            :label="item.name"
            :value="item.id">
        </el-option>
      </el-select>

      <el-button type="primary" style="margin-left: 5px;" @click="loadPost">查询</el-button>
      <el-button type="success" @click="resetParam">重置</el-button>

      <el-button type="primary" style="margin-left: 5px;" @click="add" v-if="user.roleId!=2">新增</el-button>
      <el-button type="primary" style="margin-left: 5px;" @click="inGoods" v-if="user.roleId!=2">入库</el-button>
      <el-button type="primary" style="margin-left: 5px;" @click="outGoods" v-if="user.roleId!=2">出库</el-button>
    </div>

    <!-- 主表格区域 -->
    <div class="table-container">
      <el-table
          :data="tableData"
          :header-cell-style="{ background: '#f2f5fc', color: '#555555' }"
          border
          highlight-current-row
          @current-change="selectCurrentChange"
          style="width: 100%"
          height="calc(100vh - 280px)">
        <el-table-column prop="id" label="ID" width="60"></el-table-column>
        <el-table-column prop="name" label="物品名" width="160"></el-table-column>
        <el-table-column prop="storage" label="仓库" width="160" :formatter="formatStorage"></el-table-column>
        <el-table-column prop="goodstype" label="分类" width="160" :formatter="formatGoodstype"></el-table-column>
        <el-table-column prop="count" label="数量" width="160"></el-table-column>
        <el-table-column prop="wholesalePrice" label="批发价" width="120" align="right">
          <template slot-scope="scope">
            {{ scope.row.wholesalePrice | formatPrice }}
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" width="160"></el-table-column>
        <el-table-column prop="operate" label="操作" width="220" v-if="user.roleId!=2">
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

    <!-- 物品维护对话框 -->
    <el-dialog
        title="物品维护"
        :visible.sync="centerDialogVisible"
        width="30%"
        center>
      <el-form ref="form" :rules="rules3" :model="form" label-width="80px">
        <el-form-item label="物品名" prop="name">
          <el-col :span="20">
            <el-input v-model="form.name"></el-input>
          </el-col>
        </el-form-item>
        <el-form-item label="仓库" prop="storage">
          <el-col :span="20">
            <el-select v-model="form.storage" placeholder="请选择仓库" style="width: 100%">
              <el-option
                  v-for="item in storageData"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id">
              </el-option>
            </el-select>
          </el-col>
        </el-form-item>
        <el-form-item label="分类" prop="goodstype">
          <el-col :span="20">
            <el-select v-model="form.goodstype" placeholder="请选择分类" style="width: 100%">
              <el-option
                  v-for="item in goodstypeData"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id">
              </el-option>
            </el-select>
          </el-col>
        </el-form-item>
        <el-form-item label="数量" prop="count">
          <el-col :span="20">
            <el-input v-model="form.count" :value="0" disabled placeholder="0"></el-input>
          </el-col>
        </el-form-item>
        <el-form-item label="批发价" prop="wholesalePrice">
          <el-col :span="20">
            <el-input v-model="form.wholesalePrice" placeholder="请输入批发价"></el-input>
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

    <!-- 入库对话框 -->
    <el-dialog
        title="入库"
        :visible.sync="inDialogVisible"
        width="30%"
        center>
      <el-dialog
          width="75%"
          title="用户选择"
          :visible.sync="innerVisible"
          append-to-body>
        <SelectUser @doSelectUser="doSelectUser"></SelectUser>
        <span slot="footer" class="dialog-footer">
          <el-button @click="innerVisible = false">取 消</el-button>
          <el-button type="primary" @click="confirmUser">确 定</el-button>
        </span>
      </el-dialog>

      <el-form ref="form1" :rules="rules" :model="form1" label-width="80px">
        <el-form-item label="物品名">
          <el-col :span="20">
            <el-input v-model="form1.goodsname" readonly></el-input>
          </el-col>
        </el-form-item>
        <el-form-item label="申请人">
          <el-col :span="20">
            <el-input v-model="form1.username" readonly @click.native="selectUser"></el-input>
          </el-col>
        </el-form-item>
        <el-form-item label="数量" prop="count">
          <el-col :span="20">
            <el-input v-model="form1.count"></el-input>
          </el-col>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-col :span="20">
            <el-input type="textarea" v-model="form1.remark"></el-input>
          </el-col>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="inDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="doInGoods">确 定</el-button>
      </span>
    </el-dialog>

    <!-- 出库对话框 -->
    <el-dialog
        title="出库"
        :visible.sync="outDialogVisible"
        width="30%"
        center>
      <el-dialog
          width="75%"
          title="用户选择"
          :visible.sync="innerVisible"
          append-to-body>
        <SelectUser @doSelectUser="doSelectUser"></SelectUser>
        <span slot="footer" class="dialog-footer">
          <el-button @click="innerVisible = false">取 消</el-button>
          <el-button type="primary" @click="confirmUser">确 定</el-button>
        </span>
      </el-dialog>

      <el-form ref="form1" :rules="rules1" :model="form1" label-width="80px">
        <el-form-item label="物品名">
          <el-col :span="20">
            <el-input v-model="form1.goodsname" readonly></el-input>
          </el-col>
        </el-form-item>
        <el-form-item label="申请人">
          <el-col :span="20">
            <el-input v-model="form1.username" readonly @click.native="selectUser"></el-input>
          </el-col>
        </el-form-item>
        <el-form-item label="数量" prop="count">
          <el-col :span="20">
            <el-input v-model="form1.count"></el-input>
          </el-col>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-col :span="20">
            <el-input type="textarea" v-model="form1.remark"></el-input>
          </el-col>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="outDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="doOutGoods">确 定</el-button>
      </span>
    </el-dialog>
  </div>
</template>


<script>
import SelectUser from "../user/SelectUser";
export default {
  name: "GoodsManage",
  components: {SelectUser},
  data() {
    let checkCount = (rule, value, callback) => {
      if(value>9999){
        callback(new Error('数量输入过大'));
      }else{
        callback();
      }
    };

    let checkOutCount = (rule, value, callback) => {
      if(!this.currentRow) {
        callback(new Error('请先选择物品'));
        return;
      }
      if(value > this.currentRow.count) {
        callback(new Error('出库数量不能超过库存数量'));
      } else if(value <= 0) {
        callback(new Error('出库数量必须大于0'));
      } else {
        callback();
      }
    };

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
      inDialogVisible:false,
      outDialogVisible:false,
      innerVisible:false,
      currentRow:{},
      tempUser:{},
      currentCount: 0,
      form:{
        id:'',
        name:'',
        storage:'',
        goodstype:'',
        count:'',
        wholesalePrice: '',
        remark:''
      },
      form1:{
        goods:'',
        goodsname:'',
        count:'',
        username:'',
        userid:'',
        adminId:'',
        remark:'',
        action:'1'
      },
      rules1: {
        name: [
          {required: true, message: '请输入物品名', trigger: 'blur'}
        ],
        storage:[
          {required: true, message: '请选择仓库', trigger: 'blur'}
        ],
        goodstype:[
          {required: true, message: '请选择分类', trigger: 'blur'}
        ],
        count: [
          {required: true, message: '请输入数量', trigger: 'blur'},
          {validator: checkOutCount, trigger: 'blur'}
        ]
      },
      rules: {
        name: [
          {required: true, message: '请输入物品名', trigger: 'blur'}
        ],
        storage:[
          {required: true, message: '请选择仓库', trigger: 'blur'}
        ],
        goodstype:[
          {required: true, message: '请选择分类', trigger: 'blur'}
        ],
        count: [
          {required: true, message: '请输入数量', trigger: 'blur'},
          {pattern: /^([1-9][0-9]*){1,4}$/,message: '数量必须为正整数字',trigger: "blur"},
          {validator:checkCount,trigger: 'blur'}
        ],
      },
      rules3:{
        name: [
          {required: true, message: '请输入物品名', trigger: 'blur'}
        ],
        storage:[
          {required: true, message: '请选择仓库', trigger: 'blur'}
        ],
        goodstype:[
          {required: true, message: '请选择分类', trigger: 'blur'}
        ],
        wholesalePrice: [
          { pattern: /^\d+(\.\d{1,2})?$/, message: '请输入正确的价格格式', trigger: 'blur' }
        ]
      }
    }
  },
  filters: {
    formatPrice(value) {
      if (value === null || value === undefined || value === '') return '未定价';
      return `¥${parseFloat(value).toFixed(2)}`;
    }
  },
  methods:{
    doSelectUser(val){
      console.log(val)
      this.tempUser = val
    },
    confirmUser(){
      this.form1.username = this.tempUser.name
      this.form1.userid = this.tempUser.id
      this.innerVisible = false
    },
    selectCurrentChange(val) {
      this.currentRow = val;
    },
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
    resetInForm(){
      this.$refs.form1.resetFields();
    },
    del(id){
      console.log(id)
      this.$axios.get(this.$httpUrl+'/goods/del?id='+id).then(res=>res.data).then(res=>{
        console.log(res)
        if(res.code==200){
          this.$message({
            message: '操作成功！',
            type: 'success'
          });
          this.loadPost()
        }else{
          this.$message({
            message: '操作失败！',
            type: 'error'
          });
        }
      })
    },
    mod(row){
      this.centerDialogVisible = true
      this.$nextTick(()=>{
        this.form = {
          id: row.id,
          name: row.name,
          storage: row.storage,
          goodstype: row.goodstype,
          count: row.count,
          wholesalePrice: row.wholesale_price,
          remark: row.remark
        }
      })
    },
    add(){
      this.centerDialogVisible = true
      this.$nextTick(()=>{
        this.resetForm()
        this.form.id = ''
        this.form.count = 0
        this.form.wholesalePrice = ''
      })
    },
    inGoods(){
      if(!this.currentRow||!this.currentRow.id){
        alert('请选择记录');
        return;
      }
      this.inDialogVisible = true
      this.$nextTick(()=>{
        this.resetInForm()
      })
      this.form1.goodsname = this.currentRow.name
      this.form1.goods = this.currentRow.id
      this.form1.adminId=this.user.id
      this.form1.action='1'
    },
    outGoods(){
      if(!this.currentRow||!this.currentRow.id){
        alert('请选择记录');
        return;
      }
      this.outDialogVisible = true
      this.$nextTick(()=>{
        this.resetInForm()
      })
      this.form1.goodsname = this.currentRow.name
      this.form1.goods = this.currentRow.id
      this.form1.adminId=this.user.id
      this.form1.action='2'
      this.currentCount = this.currentRow.count;
    },
    selectUser(){
      this.innerVisible=true
    },
    doSave(){
      this.$axios.post(this.$httpUrl+'/goods/save',this.form).then(res=>res.data).then(res=>{
        console.log(this.form)
        if(res.code==200){
          this.$message({
            message: '操作成功！',
            type: 'success'
          });
          this.centerDialogVisible = false
          this.loadPost()
          this.resetForm()
        }else{
          this.$message({
            message: '操作失败！',
            type: 'error'
          });
        }
      })
    },
    doMod(){
      this.$axios.post(this.$httpUrl+'/goods/update',this.form).then(res=>res.data).then(res=>{
        console.log(res)
        if(res.code==200){
          this.$message({
            message: '操作成功！',
            type: 'success'
          });
          this.centerDialogVisible = false
          this.loadPost()
          this.resetForm()
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
    doInGoods(){
      this.$refs.form1.validate((valid) => {
        if (valid) {
          this.$axios.post(this.$httpUrl+'/record/save',this.form1).then(res=>res.data).then(res=>{
            console.log(res)
            if(res.code==200){
              this.$message({
                message: '操作成功！',
                type: 'success'
              });
              this.inDialogVisible = false
              this.loadPost()
              this.resetInForm()
            }else{
              this.$message({
                message: '操作失败！',
                type: 'error'
              });
            }
          })
        } else {
          console.log('验证失败');
          return false;
        }
      });
    },
    doOutGoods(){
      this.$refs.form1.validate((valid) => {
        if (valid) {
          if(this.form1.action === '2' && this.form1.count > this.currentRow.count) {
            this.$message.error('出库数量不能超过库存数量');
            return;
          }
          this.$axios.post(this.$httpUrl+'/record/save',this.form1).then(res=>res.data).then(res=>{
            console.log(res)
            if(res.code==200){
              this.$message({
                message: '操作成功！',
                type: 'success'
              });
              this.outDialogVisible = false
              this.loadPost()
              this.resetInForm()
            }else{
              this.$message({
                message: '操作失败！',
                type: 'error'
              });
            }
          })
        } else {
          console.log('验证失败');
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
      this.storage=''
      this.goodstype=''
      this.loadStorage()
      this.loadGoodstype()
      this.loadPost()
    },
    loadPost(){
      this.$axios.post(this.$httpUrl+'/goods/listPage',{
        pageSize:this.pageSize,
        pageNum:this.pageNum,
        param:{
          name:this.name,
          goodstype:this.goodstype+'',
          storage:this.storage+''
        }
      }).then(res=>res.data).then(res=>{
        console.log(res)
        if(res.code==200){
          this.tableData = res.data.map(item => ({
            ...item,
            wholesalePrice: item.wholesalePrice ?? null
          }));
          this.total = res.total
        }else{
          alert('获取数据失败')
        }
      })
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
    }
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
.goods-manage-container {
  padding: 20px;
  height: 80vh;
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

/* 操作按钮样式 */
.el-button--small {
  padding: 7px 12px;
}

/* 对话框样式优化 */
.el-dialog__body {
  padding: 20px 20px;
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
    height: calc(100vh - 320px) !important;
  }
}

@media (max-width: 768px) {
  .goods-manage-container {
    padding: 10px;
  }

  .el-dialog {
    width: 90% !important;
  }

  .inner-dialog {
    width: 95% !important;
  }
}
</style>
